
with Types; use Types;

package Utilities is

   function Angles_Vector_To_Array
     (Angles_Vector : Float_Vector) return Float_Array;
   function File_Length (File_Name : String) return Natural;
   function Load_Particles (File_Name : String) return Particle_Vector;
   function Parse_Floats (Str : String) return Float_Vector;
   function Process_Command_Line return Float_Vector;
   procedure Save (Station : Station_Type; File_Name : String);
   procedure Save (Filename : String; Particles : Particle_Vector);
   procedure Save_As_Text (File_Name : String; Particles : Particle_Vector);

end Utilities;
