
with Ada.Numerics.Generic_Elementary_Functions;

package Freedman_Clauser_Test is

   --  Floating-point type for precise statistical tracking
   type Ratio_Value is new Long_Float;

   --  Structure to hold the empirical parameters for each measured angle
   type Freedman_Record is record
      Angle_Degrees   : Ratio_Value;
      Normalized_Rate : Ratio_Value; --  R(phi) / R0
      Statistical_SD  : Ratio_Value; --  Standard Deviation (sigma)
   end record;

   --  Array index range for the 9 distinct physical orientations
   type Data_Index is new Positive range 1 .. 9;
   type Freedman_Data_Table is array (Data_Index) of Freedman_Record;

   --  Definitive 1972 Freedman-Clauser Eexperimental Constants
   Freedman_Results : constant Freedman_Data_Table :=
      (1 => (Angle_Degrees =>  0.0, Normalized_Rate => 0.418,
             Statistical_SD => 0.005),
       2 => (Angle_Degrees =>  22.5, Normalized_Rate => 0.364,
            Statistical_SD => 0.005), -- CHSH Angle
       3 => (Angle_Degrees =>  45.0, Normalized_Rate => 0.224,
            Statistical_SD => 0.005),
       4 => (Angle_Degrees =>  67.5, Normalized_Rate => 0.093,
            Statistical_SD => 0.004), -- CHSH Angle
       5 => (Angle_Degrees =>  90.0, Normalized_Rate => 0.044,
            Statistical_SD => 0.003),
       6 => (Angle_Degrees => 112.5, Normalized_Rate => 0.091,
            Statistical_SD => 0.004),
       7 => (Angle_Degrees => 135.0, Normalized_Rate => 0.231,
            Statistical_SD => 0.005),
       8 => (Angle_Degrees => 157.5, Normalized_Rate => 0.369,
            Statistical_SD => 0.005),
       9 => (Angle_Degrees => 180.0, Normalized_Rate => 0.421,
            Statistical_SD => 0.006));

   package Freedman_Clauser_Math is new
      Ada.Numerics.Generic_Elementary_Functions (Float);

   procedure FC_H0_Test;

end Freedman_Clauser_Test;