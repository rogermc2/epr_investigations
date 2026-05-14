
with Ada.Streams;               --  For binary file writing
with Ada.Streams.Stream_IO;
with Ada.Text_IO;

package body Utilities is

   function File_Length (File_Name : String) return Natural is
      use Ada.Streams.Stream_IO;
      File_ID  : Ada.Streams.Stream_IO.File_Type;
      Length   : Natural := 0;
   begin
      Open (File_ID, In_File, File_Name);
      Length := Natural (Ada.Streams.Stream_IO.Size (File_ID));
      Close (File_ID);

      return Length;

   end File_Length;

   function Load_Particles (File_Name : String) return Particle_Vector is
      use Ada.Streams.Stream_IO;
      use Particle_Vector_Package;
      File_ID   : Ada.Streams.Stream_IO.File_Type;
      In_Stream : Stream_Access;
      Particles : Particle_Vector;
      Item      : Particle_Data;
   begin
      Create (File_ID, In_File, File_Name);
      In_Stream := Stream (File_ID);
      while not End_Of_File (File_ID) loop
         Particle_Data'Read (In_Stream, Item);
         Particles.Append (Item);
      end loop;

      return Particles;

   end Load_Particles;

   procedure Save (Filename : String; Particles : Particle_Vector) is
      use Ada.Streams.Stream_IO;
      use Particle_Vector_Package;
      File_ID    : Ada.Streams.Stream_IO.File_Type;
      Out_Stream : Stream_Access;
      Curs       : Cursor := Particles.First;
   begin
      Create (File_ID, Out_File, Filename);
      Out_Stream := Stream (File_ID);
      while Has_Element (Curs) loop
         Particle_Data'Write (Out_Stream, Element (Curs));
         Next  (Curs);
      end loop;
      Close (File_ID);

   end Save;

   procedure Save_As_Text (File_Name : String; Particles : Particle_Vector) is
      use Ada.Text_IO;
      use Particle_Vector_Package;
      File_ID : File_Type;
      Curs    : Cursor := Particles.First;
      Item    : Particle_Data;
   begin
      Create (File_ID, Out_File, File_Name);
      while Has_Element (Curs) loop
         Item := Element (Curs);
         Put_Line (File_ID, Float'Image (Item.E) & "," &
                     Float'Image (Item.P) & "," & Float'Image (Item.Spin_N));
         Next  (Curs);
      end loop;
      Close (File_ID);

   end Save_As_Text;

end Utilities;
