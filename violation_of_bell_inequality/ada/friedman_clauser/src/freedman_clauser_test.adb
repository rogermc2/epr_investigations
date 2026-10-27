
with Ada.Text_IO; use Ada.Text_IO;

package body Freedman_Clauser_Test is

  procedure FC_H0_Test is
   --  Example of driving your H0 engine with the array loop
   --  Tolerance   : constant Ratio_Value := 0.05;
   Current_Row : Freedman_Record;
   --  Expected_E  : Ratio_Value;
   --  Error_Pct   : Ratio_Value;
begin
   Put_Line ("1972 Freedman PhD Thesis H0 Verification");

   for I in Data_Index loop
      Current_Row := Freedman_Results (I);

      --  Your alternative theory calculation block goes here.
      --  For example, calculate Expected_E as a function of Current_Row.Angle_Degrees...
      --  Expected_E := Calculate_My_Alternative_Inequality(Current_Row.Angle_Degrees);

      --  For placeholder tracking, assume a sample target calculation
      --  Error_Pct := (Abs(Current_Row.Normalized_Rate - Expected_E) / Expected_E) * 100.0;

      --  Output the comparison cleanly to your console window...
   end loop;

   end FC_H0_Test;

   procedure Freedman_Kolmogorov_Chi_Square is
      use Ada.Numerics;
      use Freedman_Clauser_Math;
    --  Record structure matching the 1972 thesis
    type Data_Row is record
        Angle_Deg : Float;
        Observed  : Float; --  R(phi)/R0 ratio
        Sigma     : Float; --  Empirical Standard Deviation
    end record;

    type Table_Index is range 1 .. 9;
    type Dataset_Table is array (Table_Index) of Data_Row;

    --  1. 1972 dataset from Freedman's thesis
    Freedman_Data : constant Dataset_Table :=
        (1 => (Angle_Deg => 0.0, Observed => 0.418, Sigma => 0.005),
        2 => (Angle_Deg => 22.5, Observed => 0.364, Sigma => 0.005),
        3 => (Angle_Deg => 45.0, Observed => 0.224, Sigma => 0.005),
        4 => (Angle_Deg => 67.5, Observed => 0.093, Sigma => 0.004),
        5 => (Angle_Deg => 90.0, Observed => 0.044, Sigma => 0.003),
        6 => (Angle_Deg => 112.5, Observed => 0.091, Sigma => 0.004),
        7 => (Angle_Deg => 135.0, Observed => 0.231, Sigma => 0.005),
        8 => (Angle_Deg => 157.5, Observed => 0.369, Sigma => 0.005),
        9 => (Angle_Deg => 180.0, Observed => 0.421, Sigma => 0.006));

   --  Table I. Measured polarizer efficiencies (page 53)
   --  (using a polarized light source shaped like the interaction region).
   --        Polarizer No. 1 Polarizer No. 2
   --  eM: 0.97 ± 0.01   0.038 ± 0.004
   --  em:  0.96 ± 0.01   0.037 ± 0.004

   --  Hardware Efficiency constraint (Page 53)
   Epsilon_M_1      : constant Float := 0.970; -- Max filter transmittance
   Epsilon_M_2      : constant Float := 0.038; -- Min filter transmittance
   Chi_Square_Total : Float := 0.0;
   Expected         : Float;
   Delta_t          : Float;
   Term             : Float;
   Rad              : Float;
begin
   Put_Line ("Kolmogorov Equation (I.3) Chi-Square Evaluation");
   Put_Line ("Angle (Deg) | Observed | Expected | Contribution");

   for I in Table_Index loop
       Rad := (Freedman_Data (I).Angle_Deg * Pi) / 180.0;
      --  Equation (I.3) Expectation Formula (page 21)
      --  Compute the strict, symmetric classical local realistic baseline
      Expected := 0.25 * ((Epsilon_M_1 + Epsilon_M_2) ** 2 +
         (Epsilon_M_1 - Epsilon_M_2) ** 2 * Cos (2.0 * Rad));
      --  Compute individual Chi_Square term contribution:
      Delta_t := Freedman_Data (I).Observed - Expected;
      Term := (Delta_t ** 2) / (Freedman_Data (I).Sigma ** 2);
      Chi_Square_Total := Chi_Square_Total + Term;

      Put (Float'Image (Freedman_Data (I).Angle_Deg) & " | ");
      Put (Float'Image (Freedman_Data (I).Observed) & " | ");
      Put (Float'Image (Expected) & " | ");
      Put_Line (Float'Image(Term));
   end loop;

   New_Line;
   Put_Line ("Final Consolidated Chi-Square Metric (Value): " &
       Float'Image(Chi_Square_Total));
   Put_Line
   ("Degrees of Freedom: 8 (9 data points minus 1 baseline constraint)");

end Freedman_Kolmogorov_Chi_Square;

end Freedman_Clauser_Test;
