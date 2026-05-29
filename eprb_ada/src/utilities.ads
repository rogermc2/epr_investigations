
with Types; use Types;

package Utilities is
   function File_Length (File_Name : String) return Natural;
   function Load_Paired_Data (File_Names : Unbounded_String_Vector)
                              return Outcome_Pair_Vector;
   function Load_Particles (File_Name : String) return Particle_Vector;
   function Load_Station_Results (File_Name : String) return Result_Vector;
   procedure Process_Command_Line (Duration_Val : in out Duration;
                                   Num_Settings : out Positive;
                                   Settings     : out Settings_Vector;
                                   Spin         : in out Float);
   procedure Save (File_Name : String; Station : Station_Type);
   procedure Save_Particles (Filename : String; Particles : Particle_Vector);
   procedure Save_As_Text (File_Name : String; Particles : Particle_Vector);

end Utilities;
