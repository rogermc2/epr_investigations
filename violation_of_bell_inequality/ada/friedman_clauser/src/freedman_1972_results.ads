
with Freedman_Clauser_Types; use Freedman_Clauser_Types;

package Freedman_1972_Results is

   --  Freedman-Clauser 1972 Experimental Constants
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

end Freedman_1972_Results;