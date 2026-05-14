
with Types; use Types;

package Utilities is

   function File_Length (File_Name : String) return Natural;
   function Load_Particles (File_Name : String) return Particle_Vector;
   procedure Save (Filename : String; Particles : Particle_Vector);
   procedure Save_As_Text (File_Name : String; Particles : Particle_Vector);

end Utilities;
