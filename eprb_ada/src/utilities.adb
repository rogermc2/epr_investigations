
with Ada.Streams;               --  For binary file writing
with Ada.Streams.Stream_IO;

package body Utilities is

   --  Save procedure: saves particle array to a binary file
   --  (simple binary dump)
   procedure Save (Filename : String; Particles : Particle_Vector) is
      use Ada.Streams.Stream_IO;
      File_ID    : Ada.Streams.Stream_IO.File_Type;
      Out_Stream : Stream_Access;
   begin
      Create (File_ID, Out_File, Filename);
      Out_Stream := Stream (File_ID);
      for I in Particles'Range loop
         Particle'Write (Out_Stream, Particles (I));
      end loop;
      Close (File_ID);

   end Save;

end Utilities;
