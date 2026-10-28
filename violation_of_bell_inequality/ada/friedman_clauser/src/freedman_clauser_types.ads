
with Ada.Numerics.Generic_Elementary_Functions;

package Freedman_Clauser_Types is
   --  Floating-point type for precise statistical tracking
   type Ratio_Value is new Long_Float;
   --  Array index range for the 9 distinct physical orientations
   type Data_Index is new Positive range 1 .. 9;

   --  Structure to hold the empirical parameters for each measured angle
   type Freedman_Record is record
      Angle_Degrees   : Ratio_Value;
      Normalized_Rate : Ratio_Value; --  R(phi) / R0
      Statistical_SD  : Ratio_Value; --  Standard Deviation (sigma)
   end record;

   type Freedman_Data_Table is array (Data_Index) of Freedman_Record;

   package Freedman_Clauser_Math is new
      Ada.Numerics.Generic_Elementary_Functions (Float);

end Freedman_Clauser_Types;