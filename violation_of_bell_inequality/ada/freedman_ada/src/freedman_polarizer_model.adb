
with Ada.Numerics; use Ada.Numerics;
with Ada.Numerics.Complex_Types; use Ada.Numerics.Complex_Types;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;

with Random_Unit_Vectors;

package body Freedman_Polarizer_Model is

   --  Freedman & Clauser (1972) Measured Constants
   P1_Eps_Maj : constant Float := 0.97;   --  5513 A channel
   P1_Eps_min : constant Float := 0.038;
   P2_Eps_Maj : constant Float := 0.96;   --  4227 A channel
   P2_Eps_min : constant Float := 0.037;

   G          : Generator;

   --  Helper Functions
   function To_Radians (Deg : Float) return Float is
   begin
      return Deg * (Pi / 180.0);

   end To_Radians;

   function Norm_Squared (Psi : Jones_Vector) return Float is
   begin
      return (Psi.Ex.Re ** 2 + Psi.Ex.Im ** 2) +
             (Psi.Ey.Re ** 2 + Psi.Ey.Im ** 2);

   end Norm_Squared;

   function Normalize (Psi : Jones_Vector) return Jones_Vector is
      Mag : constant Float := Sqrt (Norm_Squared (Psi));
   begin
      return (Ex => Psi.Ex / Mag, Ey => Psi.Ey / Mag);

   end Normalize;

   --  2. Construct Freedman Pile-of-Plates Polarizer
   function Create_Polarizer
     (Angle_Deg, Eps_Major, Eps_Minor : Float;
      Inserted   : Boolean := True) return Pile_Of_Plates_Polarizer is
      Rad        : constant Float := To_Radians (Angle_Deg);
      Cos_Angle  : constant Float := Cos (Rad);
      Sin_Angle  : constant Float := Sin (Rad);
      Cos_Sq     : constant Float := Cos_Angle ** 2;
      Sin_Sq     : constant Float := Sin_Angle ** 2;
      CS         : constant Float := Cos_Angle * Sin_Angle;
      Amp_Maj    : constant Float := Sqrt (Eps_Major);
      Amp_min    : constant Float := Sqrt (Eps_Minor);
      Diff       : constant Float := Amp_Maj - Amp_min;
      Phi_Matrix : Jones_Matrix;
   begin
      Phi_Matrix (1, 1) :=
         (Re => Amp_Maj * Cos_Sq + Amp_min * Sin_Sq, Im => 0.0);
      Phi_Matrix (1, 2) := (Re => Diff * CS, Im => 0.0);
      Phi_Matrix (2, 1) := (Re => Diff * CS, Im => 0.0);
      Phi_Matrix (2, 2) := (Re => Amp_Maj * Sin_Sq +
         Amp_min * Cos_Sq, Im => 0.0);

      return (Angle_Deg, Eps_Major, Eps_Minor, Inserted, Phi_Matrix);

   end Create_Polarizer;

   --  3. Single-Photon Interaction with Pile-of-Plates Polarizer
   procedure Interact
     (P   : Pile_Of_Plates_Polarizer; Photon : in out Jones_Vector;
      Gen : Ada.Numerics.Float_Random.Generator; Transmitted : out Boolean) is
      Out_State : Jones_Vector;
      Prob      : Float;
   begin
      --  In Freedman's apparatus, plates could be folded completely out
      if not P.Inserted then
         Transmitted := True;
      else
         Out_State.Ex := P.Matrix (1, 1) * Photon.Ex +
             P.Matrix (1, 2) * Photon.Ey;
         Out_State.Ey := P.Matrix (2, 1) * Photon.Ex +
             P.Matrix (2, 2) * Photon.Ey;
         Prob := Norm_Squared (Out_State);

         Transmitted := Ada.Numerics.Float_Random.Random (Gen) < Prob;
         if Transmitted then
            Photon := Normalize (Out_State);
         end if;
      end if;

   end Interact;

   --  4. Simulate Entangled Calcium Cascade Pair:
   --     |Psi> = 1/sqrt(2) (|HH> + |VV>)
   --     Measures normalized coincidence rate R(phi) / R_0
   function Simulate_Coincidence
     (Num_Pairs : Positive; Angle_1, Angle_2 : Float;
      Seed      : Integer := 1972) return Float is
      use Random_Unit_Vectors;
      a            : constant Real_Vector_3D := (0.0, 0.5, 0.0);
      b            : constant Real_Vector_3D := (0.5, 0.5, 0.0);
      lambda       : constant Complex_Vector_3D :=
                      Random_Complex_Unit_Vector (G);
      P1           : constant Pile_Of_Plates_Polarizer :=
        Create_Polarizer (Angle_1, P1_Eps_Maj, P1_Eps_min);
      P2           : constant Pile_Of_Plates_Polarizer :=
        Create_Polarizer (Angle_2, P2_Eps_Maj, P2_Eps_min);
      Gen          : Ada.Numerics.Float_Random.Generator;
      Photon_1     : Jones_Vector :=
            To_Jones_Vector (lambda, (0.0, 0.0, 0.0));
      Photon_2     : Jones_Vector :=
            To_Jones_Vector (Opposite (lambda), (0.0, 0.0, 0.0));
      Pass_1       : Boolean;
      Pass_2       : Boolean;
      Coinc_Both   : Natural := 0;
   begin
      Ada.Numerics.Float_Random.Reset (Gen, Seed);

      for I in 1 .. Num_Pairs loop
         --  Generate entangled pair in |HH> + |VV> basis
         --  (Equivalent to |RR> + |LL> in circular basis)
         if Ada.Numerics.Float_Random.Random (Gen) < 0.5 then
            --  Both Horizontal (0 deg)
            Photon_1 := (Ex => (1.0, 0.0), Ey => (0.0, 0.0));
            Photon_2 := (Ex => (1.0, 0.0), Ey => (0.0, 0.0));
         else
            --  Both Vertical (90 deg)
            Photon_1 := (Ex => (0.0, 0.0), Ey => (1.0, 0.0));
            Photon_2 := (Ex => (0.0, 0.0), Ey => (1.0, 0.0));
         end if;

         --  Note: For full rotational invariance of |HH> + |VV> at arbitrary
         --  angles, we project Photon 2 onto Photon 1's collapsed state if
         --  Photon 1 passes, or orthogonal state if blocked, followed by P2.
         --  Equivalently, we generate an isotropic hidden-angle basis:
         declare
            Basis_Angle : constant Float :=
              Ada.Numerics.Float_Random.Random (Gen) * 2.0 * Pi;
         begin
            Photon_1 := (Ex => (Cos (Basis_Angle), 0.0),
                         Ey => (Sin (Basis_Angle), 0.0));
            Photon_2 := Photon_1;
         end;

         --  Measure Photon 1 at Polarizer 1
         Interact (P1, Photon_1, Gen, Pass_1);

         if Pass_1 then
            --  Quantum collapse: Photon 2 collapses to match Photon 1's state
            Photon_2 := Photon_1;
            Interact (P2, Photon_2, Gen, Pass_2);
            if Pass_2 then
               Coinc_Both := Coinc_Both + 1;
            end if;
         end if;
      end loop;

      --  R_0 is the coincidence rate with
      --  both polarizers removed (= Num_Pairs)
      return Float (Coinc_Both) / Float (Num_Pairs);

   end Simulate_Coincidence;

   --  Theoretical Quantum Prediction from Freedman's Thesis Eq. (5):
   --  R(phi)/R_0 = 1/4 (eM1 + em1)(eM2 + em2) +
   --  1/4 (eM1 - em1)(eM2 - em2) cos(2*phi)
   function Freedman_Theory_Ratio (Phi_Deg : Float) return Float is
      Sum_1  : constant Float := P1_Eps_Maj + P1_Eps_min;
      Sum_2  : constant Float := P2_Eps_Maj + P2_Eps_min;
      Diff_1 : constant Float := P1_Eps_Maj - P1_Eps_min;
      Diff_2 : constant Float := P2_Eps_Maj - P2_Eps_min;
   begin
      return 0.25 * (Sum_1 * Sum_2 +
                      Diff_1 * Diff_2 * Cos (2.0 * To_Radians (Phi_Deg)));

   end Freedman_Theory_Ratio;

end Freedman_Polarizer_Model;
