
with Ada.Streams;               --  For binary file writing
with Ada.Streams.Stream_IO;
with Ada.Text_IO;

package body Utilities is

   --  Convert Angles_Vector to array for easier indexing
   function Angles_Vector_To_Array
     (Angles_Vector : Float_Vector) return Float_Array is
      use Float_Vector_Package;
      Curs       : Cursor := Angles_Vector.First;
      Temp_Array : Float_Array  (1 .. Integer (Length (Angles_Vector)));
      Index      : Natural := 0;
   begin
      while Has_Element (Curs) loop
         Index := Index + 1;
         Temp_Array (Index) := Element (Curs);
         Next (Curs);
      end loop;
      return Temp_Array;

   end Angles_Vector_To_Array;

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
      Close (File_ID);

      return Particles;

   end Load_Particles;

   function Parse_Floats (Str : String) return Float_Vector is
      use Float_Vector_Package;
      Result    : Float_Vector;
      Start_Pos : Natural := 0;
      Comma_Pos : Natural := 0;
      --  Val       : Float;

      procedure Form_Value (Val_Str : String) is
         --  Val_Str : String := Sub_Str;
         --  Val_Pos : Positive := Val_Str'First;
         --  Val_End : Positive := Val_Str'Last;
         Val_IO : Float := 0.0;
         --  Last : Positive;
      begin
         --  declare
         --     package Float_IO is new Ada.Float_Text_IO (Float);
         --     use Float_IO;
         --  begin
         Val_IO := Float'Value (Val_Str);

         Result.Append (Val_IO);
      end Form_Value;

   begin
      loop
         Comma_Pos := 0;
         for I in Start_Pos .. Str'Length loop
            if Str (I) = ',' then
               Comma_Pos := I;
               exit;
            end if;
         end loop;

         if Comma_Pos = 0 then
            declare
               Sub_Str : constant String := Str (Start_Pos .. Str'Last);
            begin
               Form_Value (Sub_Str);
            end;
         else
            declare
               Sub_Str : constant String :=
                 Str (Start_Pos .. Comma_Pos - 1);
            begin
               Form_Value (Sub_Str);
            end;
         end if;

         if Comma_Pos = 0 then
            exit;
         else
            Start_Pos := Comma_Pos + 1;
         end if;
      end loop;

      return Result;

   end Parse_Floats;

   procedure Save (Station : Station_Type; File_Name : String) is
      use Ada.Streams.Stream_IO;
      use Result_Vector_Package;
      File_ID    : Ada.Streams.Stream_IO.File_Type;
      Out_Stream : Stream_Access;
      Curs       : Cursor := Station.Results.First;
   begin
      Create (File_ID, Out_File, File_Name);
      Out_Stream := Stream (File_ID);
      --  for I in Station.Results'Range loop
      while Has_Element (Curs) loop
         --  Write Setting and Outcome as Float values
         --  Float'Write (Out_Stream, Station.Results (I).Setting);
         --  Float'Write (Out_Stream, Station.Results (I).Outcome);
         Float'Write (Out_Stream, Element (Curs).Setting);
         Float'Write (Out_Stream, Element (Curs).Outcome);
         Next (Curs);
      end loop;
      Close (File_ID);

   end Save;

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
