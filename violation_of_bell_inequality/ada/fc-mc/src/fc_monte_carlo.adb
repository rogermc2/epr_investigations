
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Ada.Numerics; use Ada.Numerics;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;

with Maths; use Maths;
with Printing; use Printing;
with Support; use Support;
with Types;

procedure FC_Monte_Carlo is

   type Degree_Array is array (1 .. 5) of Float;
   type Rate_Array   is array (1 .. 5) of Float;

   Gen                  : Generator;
   Num_Pairs            : constant Long_Integer := 5_000_000;
   Angles_Deg           : constant Degree_Array :=
      (0.0, 22.5, 45.0, 67.5, 90.0);
   Angles_Rad           : Degree_Array;
   QM_Rates             : Rate_Array;
   Local_R_Rates        : Rate_Array;
   QM_R_R0              : Rate_Array;
   Local_R_R_R0         : Rate_Array;
   Phi                  : Float;
   Pol_1                : Float;
   Lamda                : Float;
   Passed_1_QM          : Boolean;
   Passed_2_QM          : Boolean;
   Passed_1_Local_R     : Boolean;
   Passed_2_Local_R     : Boolean;
   Coincidences_QM      : Long_Integer;
   Coincidences_Local_R : Long_Integer;
   QM_Stat              : Float;
   Local_R_Stat         : Float;

begin
   Reset(Gen);
   for I in Angles_Deg'Range loop
      Angles_Rad (I) := To_Radians (Angles_Deg (I));
   end loop;

   Put_Line("Running Monte Carlo simulation with" &
        Long_Integer'Image (Num_Pairs) & " photon pairs per angle:");
   New_Line;

   for I in Angles_Rad'Range loop
      Phi := Angles_Rad (I);
      Coincidences_QM := 0;
      Coincidences_Local_R := 0;

      for Pair in 1 .. Num_Pairs loop
         --  1. QM Model (Wave-function collapse)
         --  Generate random uniform initial polarization [0, 2*Pi)
         Pol_1 :=  2.0 * Random (Gen) + Pi;
         --  Photon 1 interacts with Analyzer 1 (set to 0 rad)
         --  using Malus's Law
         Passed_1_QM := Random (Gen) < QM_Expectation (Pol_1);
         --  Non-local Collapse:
         --  If photon 1 passes photon 2 is projected to 0 rad.
         --  It encounters Analyzer 2 to angle 'Phi'.
         Passed_2_QM := Random (Gen) < QM_Expectation (Phi);

         if Passed_1_QM and Passed_2_QM then
            Coincidences_QM := Coincidences_QM + 1;
         end if;

         --  2. LOCAL REALISTIC MODEL (Hidden Variables)
         --  The photon pair shares a hidden variable Lambda assigned at the source
         Lamda := QM_Expectation (Random (Gen));

         --  Local measurements are strictly independent, relying entirely on Lambda
         --  QM_Expectation = Cos (Angle)^2
         Passed_1_Local_R := Random (Gen) < QM_Expectation (Lamda);
         Passed_2_Local_R := Random (Gen) < QM_Expectation (Lamda - Phi);
         if Passed_1_Local_R and Passed_2_Local_R then
            Coincidences_Local_R := Coincidences_Local_R + 1;
         end if;
      end loop;
      Put_Line ("Coincidences_QM" & Long_Integer'Image (Coincidences_QM));

      --  Calculate raw coincidence rates
      QM_Rates (I) := Float (Coincidences_QM) / Float (Num_Pairs);
      Local_R_Rates (I) := Float (Coincidences_Local_R) / Float (Num_Pairs);
   end loop;
   Print_Float_Array ("QM_Rates", Types.Float_Array (QM_Rates));

   --  Compute R(phi)/R0 normalization ratio.
   --  Freedman-Clauser normalized metrics using the
    --  maximum correlation baseline (at 0 degrees).
   for I in QM_Rates'Range loop
      QM_R_R0 (I) := QM_Rates (I) / QM_Rates (1);
      Local_R_R_R0 (I) := Local_R_Rates (I) / Local_R_Rates (1);
   end loop;
   --  Print_Float_Array ("QM_R_R0", Types.Float_Array (QM_R_R0));

   Put_Line("Angle (deg)  |  QM R(phi)/R0  |  Local Realism R(phi)/R0");
   Put_Line("---------------------------------------------------------");
   for I in Angles_Deg'Range loop
         Put (Angles_Deg (I), Fore => 4, Aft => 1, Exp => 0);
         Put("         |  ");
      Put (QM_R_R0 (I), Fore => 2, Aft => 4, Exp => 0);
         Put("         |  ");
      Put (Local_R_R_R0 (I), Fore => 2, Aft => 4, Exp => 0);
      New_Line;
   end loop;

   --  Evaluate Freedman-Clauser Bell Metric
   --  Historical bound inequality: |R(22.5) - R(67.5)| / R0 <= 0.25
   QM_Stat := Abs (QM_R_R0 (2) - QM_R_R0 (4));
   Local_R_Stat := Abs (Local_R_R_R0 (2) - Local_R_R_R0 (4));

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
   Put (Local_R_Stat, Fore => 1, Aft => 4, Exp => 0);
   New_Line;

end FC_Monte_Carlo;
