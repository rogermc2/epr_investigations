
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Ada.Numerics;use Ada.Numerics;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;

with Maths; use Maths;
with Printing; use Printing;
with Support; use Support;
with Types;

procedure FC_Monte_Carlo is

   type Degree_Array is array (1 .. 5) of Float;
   type Rate_Array   is array (1 .. 5) of Float;

   Gen             : Generator;
   --  5 Million pairs per angle
   Num_Pairs       : constant Long_Integer := 5_000_000;
   Angles_Deg      : constant Degree_Array := (0.0, 22.5, 45.0, 67.5, 90.0);
   Angles_Rad      : Degree_Array;
   QM_Rates        : Rate_Array;
   LR_Rates        : Rate_Array;
   QM_R_R0         : Rate_Array;
   LR_R_R0         : Rate_Array;
   Phi             : Float;
   Pol_1           : Float;
   Lam             : Float;
   Passed_1_QM     : Boolean;
   Passed_2_QM     : Boolean;
   Passed_1_LR     : Boolean;
   Passed_2_LR     : Boolean;
   Coincidences_QM : Long_Integer;
   Coincidences_LR : Long_Integer;
   QM_Stat         : Float;
   LR_Stat         : Float;

begin
   Reset(Gen);
   for I in Angles_Deg'Range loop
      Angles_Rad (I) := To_Radians (Angles_Deg (I));
   end loop;

   Put_Line("Running Monte Carlo simulation in Ada with" &
        Long_Integer'Image(Num_Pairs) & " photon pairs per angle...");
   New_Line;

   for I in Angles_Rad'Range loop
      Phi := Angles_Rad (I);
      Coincidences_QM := 0;
      Coincidences_LR := 0;

      for Pair in 1 .. Num_Pairs loop
         --  1. QUANTUM MECHANICAL MODEL (Wave-function collapse)
         --  Generate random uniform initial polarization from [0, 2*Pi)
         Pol_1 :=  2.0 * Random (Gen) + Pi;
         --  Photon 1 interacts with Analyzer 1 (set at 0 rad)
         --  using Malus's Law
         Passed_1_QM := Random (Gen) < QM_Expectation (Pol_1);
         --  Non-local Collapse: If photon 1 passes,
         --  photon 2 is projected to 0 rad.
         --  It encounters Analyzer 2 at angle 'Phi'.
         Passed_2_QM := Random (Gen) < QM_Expectation (Phi);

         if Passed_1_QM and Passed_2_QM then
            Coincidences_QM := Coincidences_QM + 1;
         end if;

         --  2. LOCAL REALISTIC MODEL (Hidden Variables)
         --  The photon pair shares a hidden variable Lambda assigned at the source
         Lam := QM_Expectation (Random (Gen));

         --  Local measurements are strictly independent, relying entirely on Lambda
         Passed_1_LR := Random(Gen) < QM_Expectation (Lam);
         Passed_2_LR := Random(Gen) < QM_Expectation(Lam - Phi);

         if Passed_1_LR and Passed_2_LR then
            Coincidences_LR := Coincidences_LR + 1;
         end if;
      end loop;
      Put_Line ("Coincidences_QM" & Long_Integer'Image (Coincidences_QM));

      --  Calculate raw coincidence rates
      QM_Rates (I) := Float (Coincidences_QM) / Float (Num_Pairs);
      LR_Rates (I) := Float (Coincidences_LR) / Float (Num_Pairs);
   end loop;
   Print_Float_Array ("QM_Rates", Types.Float_Array (QM_Rates));

   --  Compute R(phi)/R0 normalization ratio.
   --  Freedman-Clauser normalized metrics using the
    --  maximum correlation baseline (at 0 degrees).
   for I in QM_Rates'Range loop
      QM_R_R0 (I) := QM_Rates (I) / QM_Rates (1);
      LR_R_R0 (I) := LR_Rates (I) / LR_Rates (1);
   end loop;
   Print_Float_Array ("QM_R_R0", Types.Float_Array (QM_R_R0));

   Put_Line("Angle (deg)  |  QM R(phi)/R0  |  Local Realism R(phi)/R0");
   Put_Line("---------------------------------------------------------");
   for I in Angles_Deg'Range loop
         Put (Angles_Deg (I), Fore => 4, Aft => 1, Exp => 0);
         Put("         |  ");
      Put (QM_R_R0 (I), Fore => 2, Aft => 4, Exp => 0);
         Put("         |  ");
      Put (LR_R_R0 (I), Fore => 2, Aft => 4, Exp => 0);
      New_Line;
   end loop;

   --  Evaluate Freedman-Clauser Bell Metric
   --  Historical bound inequality: |R(22.5) - R(67.5)| / R0 <= 0.25
   QM_Stat := Abs (QM_R_R0 (2) - QM_R_R0 (4));
   LR_Stat := Abs (LR_R_R0 (2) - LR_R_R0 (4));

   New_Line;
   Put_Line("Bell's Inequality Violation Test |R(22.5°) - R(67.5°)| / R0");
   Put_Line("Classical Local Realistic Limit: <= 0.2500");

   Put("Quantum Mechanical Simulation:    ");
   Put (QM_Stat, Fore => 1, Aft => 4, Exp => 0);
   if QM_Stat > 0.25 then
      Put_Line("  (Violation!)");
   else
      New_Line;
   end if;

   Put ("Local Realism Simulation:        ");
   Put (LR_Stat, Fore => 1, Aft => 4, Exp => 0);
   New_Line;

end FC_Monte_Carlo;
