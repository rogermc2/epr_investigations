
with Types; use Types;

package Utilities is

   function Angles_Vector_To_Array
     (Angles_Vector : Float_Vector) return Float_Array;
   function File_Length (File_Name : String) return Natural;
   function Load_Particles (File_Name : String) return Particle_Vector;
   function Load_Station_Results (File_Name : String) return Result_Vector;
   function Parse_Floats (Str : String) return Float_Vector;
   procedure  Process_Command_Line (Duration_Val : out Duration;
                                    Settings     : out Float_Vector;
                                    Spin         : out Float);
   procedure Save (Station : Station_Type; File_Name : String);
   procedure Save_Particles (Filename : String; Particles : Particle_Vector);
   procedure Save_As_Text (File_Name : String; Particles : Particle_Vector);

end Utilities;
