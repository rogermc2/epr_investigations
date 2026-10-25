
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics.Generic_Elementary_Functions;

procedure Freedman_Kolmogorov_Chi_Square is
    use Math;
    type Real is new Long_Float;
    package Math is new Ada.Numerics.Generic_Elementary_Functions (Real);

    --  Record structure matching the exact 1972 thesis value
    type Data_Row is record
        Angle_Deg : Real;
        Observed : Real; --  R(phi)/R0 ratio
        Sigma : Real; --  Empirical Standard Deviation
    end record;

    type Table_Index is range 1 .. 9;
    type Dataset_Table is array (Table_Index) of Data_Row;

    -- 1. HARDCODED DEFINITIVE 1972 DATASET FROM THESIS
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

    --  2. FREEDMAN'S HARDWARE EFFICIENCY CONSTANTS (Page 44)
    Epsilon_1        : constant Real := 0.970; -- Max filter transmittance
    Epsilon_2        : constant Real := 0.038; -- Min filter transmittance
    --  Variables for tracking the summation
    Chi_Square_Total : Real := 0.0;
    Expected         : Real;
    Delta            : Real;
    Term             : Real;
    Rad              : Real;
begin
    Put_Line ("Kolmogorov Equation (I.3) Chi-Square Evaluation");
    Put_Line ("Angle (Deg) | Observed | Expected | Contribution");
    Put_Line ("-------------------------------------------------");

    for I in Table_Index loop
        --  Convert degrees to radians for the trig functions
        Rad := (Freedman_Data(I).Angle_Deg * Ada.Numerics.Pi) / 180.0;
        --  Equation (I.3) Expectation FORMULA
        --  Computing the strict, symmetric classical local realistic baseline
        Expected := 0.25 * ((Epsilon_1 + Epsilon_2)**2 + (Epsilon_1 - Epsilon_2)**2 * Cos(2.0 * Rad));
        --  Compute individual term contribution: (Observed - Expected)^2 / Sigma^2
        Delta := Freedman_Data(I).Observed - Expected;
        Term := (Delta ** 2) / (Freedman_Data(I).Sigma ** 2);
        Chi_Square_Total := Chi_Square_Total + Term;
        Put (Real'Image(Freedman_Data(I).Angle_Deg) & " | ");
        Put (Real'Image(Freedman_Data(I).Observed) & " | ");
        Put (Real'Image(Expected) & " | ");
        Put_Line (Real'Image(Term));
    end loop;

    New_Line;
    Put_Line ("Final Consolidated Chi-Square Metric (Value): " & Real'Image(Chi_Square_Total));
    Put_Line ("Degrees of Freedom: 8 (9 data points minus 1 baseline constraint)");

end Freedman_Kolmogorov_Chi_Square;