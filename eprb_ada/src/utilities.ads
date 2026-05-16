
with Types; use Types;

package Utilities is
   function File_Length (File_Name : String) return Natural;
   function Filter_Rows (Arr : Raw_Data_Array; Mask : Boolean_Array)
                         return Result_Vector;
   function Load_Particles (File_Name : String) return Particle_Vector;
   function Load_Station_Results (File_Name : String) return Result_Vector;
   procedure Process_Command_Line (Duration_Val : out Duration;
                                    Settings     : out Float_Vector;
                                    Spin         : out Float);
function Product_Column2 (Arr1, Arr2 : Raw_Data_Array) return Float_Array;
   procedure Save (Station : Station_Type; File_Name : String);
   procedure Save_Particles (Filename : String; Particles : Particle_Vector);
   procedure Save_As_Text (File_Name : String; Particles : Particle_Vector);

end Utilities;
