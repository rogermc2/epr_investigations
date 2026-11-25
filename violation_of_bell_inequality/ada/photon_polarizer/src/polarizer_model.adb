
with Ada.Text_IO;
with Ada.Float_Text_IO;
with Ada.Numerics; use Ada.Numerics;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
with Ada.Numerics.Float_Random;

package body Polarizer_Model is

   function To_Radians (Deg : Float) return Float is
   begin
      return Deg * (Pi / 180.0);
   end To_Radians;

   --  Helper: Squared norm <psi | psi> = |Ex|^2 + |Ey|^2
   function Norm_Squared (Psi : Jones_Vector) return Float is
   begin
      return (Psi.Ex.Re ** 2 + Psi.Ex.Im ** 2) +
             (Psi.Ey.Re ** 2 + Psi.Ey.Im ** 2);
   end Norm_Squared;

   --  Helper: Normalize a state vector
   function Normalize (Psi : Jones_Vector) return Jones_Vector is
      Mag : constant Float := Sqrt (Norm_Squared (Psi));
   begin
      if Mag = 0.0 then
         raise Constraint_Error with "Zero-norm quantum state";
      end if;
      return (Ex => Psi.Ex / Mag, Ey => Psi.Ey / Mag);
   end Normalize;

   --  2. Photon State Constructors
   function Make_Linear_Photon (Angle_Deg : Float) return Jones_Vector is
      Rad : constant Float := To_Radians (Angle_Deg);
   begin
      return (Ex => (Re => Cos (Rad), Im => 0.0),
              Ey => (Re => Sin (Rad), Im => 0.0));
   end Make_Linear_Photon;

   function Make_RHC_Photon return Jones_Vector is
      Inv_Sqrt2 : constant Float := 1.0 / Sqrt (2.0);
   begin
      return (Ex => (Re => Inv_Sqrt2, Im => 0.0),
              Ey => (Re => 0.0,       Im => -Inv_Sqrt2));
   end Make_RHC_Photon;

   function Make_Unpolarized_Photon
     (Gen : Ada.Numerics.Float_Random.Generator) return Jones_Vector
   is
      Random_Rad : constant Float :=
        Ada.Numerics.Float_Random.Random (Gen) * 2.0 * Pi;
   begin
      return (Ex => (Re => Cos (Random_Rad), Im => 0.0),
              Ey => (Re => Sin (Random_Rad), Im => 0.0));
   end Make_Unpolarized_Photon;

   --  3. Polarizer Constructor (Ideal or Finite Extinction Ratio)
   function Create_Polarizer (Angle_Deg : Float;
      Extinction_Ratio_dB : Float := -1.0) return Linear_Polarizer is
      Rad     : constant Float := To_Radians (Angle_Deg);
      C       : constant Float := Cos (Rad);
      S       : constant Float := Sin (Rad);
      Leakage : Float := 0.0;
      M       : Jones_Matrix;
   begin
      if Extinction_Ratio_dB > 0.0 then
         --  ER_linear = 10^(dB / 10); amplitude leakage = sqrt(1 / ER_linear)
         Leakage := Sqrt (1.0 / (10.0 ** (Extinction_Ratio_dB / 10.0)));
      end if;

      M (1, 1) := (Re => C * C + Leakage * S * S, Im => 0.0);
      M (1, 2) := (Re => C * S * (1.0 - Leakage), Im => 0.0);
      M (2, 1) := (Re => C * S * (1.0 - Leakage), Im => 0.0);
      M (2, 2) := (Re => S * S + Leakage * C * C, Im => 0.0);

      return (Matrix => M);
   end Create_Polarizer;

   --  4. Single-Photon Interaction & Quantum State Collapse
   procedure Interact (P : Linear_Polarizer; Photon : in out Jones_Vector;
      Gen : Ada.Numerics.Float_Random.Generator; Transmitted : out Boolean) is
      Out_State : Jones_Vector;
      Prob      : Float;
      Roll      : Float;
   begin
      --  Apply 2x2 Jones Matrix: |psi_out> = P * |psi_in>
      Out_State.Ex :=
          P.Matrix (1, 1) * Photon.Ex + P.Matrix (1, 2) * Photon.Ey;
      Out_State.Ey :=
          P.Matrix (2, 1) * Photon.Ex + P.Matrix (2, 2) * Photon.Ey;

      --  Transmission probability T = <psi_out | psi_out>
      Prob := Norm_Squared (Out_State);

      --  Monte Carlo quantum measurement
      Roll := Ada.Numerics.Float_Random.Random (Gen);
      if Roll < Prob then
         --  Photon passes and collapses into normalized transmitted state
         Photon      := Normalize (Out_State);
         Transmitted := True;
      else
         --  Photon is absorbed
         Transmitted := False;
      end if;
   end Interact;

   --  5. Run Photon-by-Photon Monte Carlo Simulation
   function Simulate_Beam
     (Num_Photons     : Positive;
      Train           : Polarizer_Train;
      Unpolarized     : Boolean := True;
      Init_Angle_Deg  : Float   := 0.0;
      Seed            : Integer := 42) return Float
   is
      Gen         : Ada.Numerics.Float_Random.Generator;
      Photon      : Jones_Vector;
      Survived    : Boolean;
      Trans_Count : Natural := 0;
   begin
      Ada.Numerics.Float_Random.Reset (Gen, Seed);

      for I in 1 .. Num_Photons loop
         if Unpolarized then
            Photon := Make_Unpolarized_Photon (Gen);
         else
            Photon := Make_Linear_Photon (Init_Angle_Deg);
         end if;

         Survived := True;
         for P_Idx in Train'Range loop
            Interact (Train (P_Idx), Photon, Gen, Survived);
            exit when not Survived;
         end loop;

         if Survived then
            Trans_Count := Trans_Count + 1;
         end if;
      end loop;

      return Float (Trans_Count) / Float (Num_Photons);
   end Simulate_Beam;

   procedure Print_Result (Label : String; Measured, Theory : Float) is
   begin
      Ada.Text_IO.Put (Label & " -> Measured: ");
      Ada.Float_Text_IO.Put (Measured, Fore => 1, Aft => 4, Exp => 0);
      Ada.Text_IO.Put (" | Theory: ");
      Ada.Float_Text_IO.Put (Theory, Fore => 1, Aft => 4, Exp => 0);
      Ada.Text_IO.New_Line;
   end Print_Result;

end Polarizer_Model;
