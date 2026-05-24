
with Ada.Command_Line; use Ada.Command_Line;
with Ada.Numerics;
with Ada.Streams;               --  For binary file writing
with Ada.Streams.Stream_IO;
with Ada.Text_IO;

with Maths;
with Vector_Functions;

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
      use Particle_Data_Package;
      File_ID   : Ada.Streams.Stream_IO.File_Type;
      In_Stream : Stream_Access;
      Particles : Particle_Vector;
      Item      : Particle_Data;
   begin
      Open (File_ID, In_File, File_Name);
      In_Stream := Stream (File_ID);
      while not End_Of_File (File_ID) loop
         Particle_Data'Read (In_Stream, Item);
         Particles.Append (Item);
      end loop;
      Close (File_ID);

      return Particles;

   end Load_Particles;

   function Load_Station_Results (File_Name : String) return Result_Vector is
      use Ada.Streams.Stream_IO;
      use Result_Vector_Package;
      File_ID   : Ada.Streams.Stream_IO.File_Type;
      In_Stream : Stream_Access;
      Result    : Result_Data;
      Results   : Result_Vector;
   begin
      Open (File_ID, In_File, File_Name);
      In_Stream := Stream (File_ID);
      while not End_Of_File (File_ID) loop
         Float'Read (In_Stream, Result.Setting);
         Float'Read (In_Stream, Result.Outcome);
         Results.Append (Result);
      end loop;
      Close (File_ID);
      return Results;

   end Load_Station_Results;

   procedure Process_Command_Line (Duration_Val : out Duration;
                                   Num_Settings : out Positive;
                                   Settings     : out Settings_Vector;
                                   Spin         : out Float) is
      use Ada.Numerics;
      use Ada.Text_IO;
      use Maths;
      use Vector_Functions;
      use Float_Vector_Package;
      use Settings_Vector_Package;
      Arg_Count       : constant Integer := Argument_Count;
      L_Space         : Float_Vector;
      Parsed_Settings : Settings_Vector;
   begin
      Num_Settings := 4;
      if Arg_Count < 1 then
         Put_Line ("Usage: ");
         Put_Line (" station <ArmSrcFile> setting1,setting2,setting3,...");
      else
         New_Line;
         if Arg_Count = 1 then
            Duration_Val := Duration (Float'Value (Argument (1)));
            L_Space := Linear_Space (0.0, 2.0 * Pi, Num_Settings);
            declare
               Curs : Float_Vector_Package.Cursor := L_Space.First;
            begin
               while Has_Element (Curs) loop
                  Settings.Append (Element (Curs));
                  Next (Curs);
               end loop;
            end;
         end if;

         if Arg_Count > 1 then
            L_Space := Parse_Floats (Argument (2));
            declare
               Curs : Float_Vector_Package.Cursor := L_Space.First;
            begin
               while Has_Element (Curs) loop
                  Parsed_Settings.Append (Element (Curs));
                  Next (Curs);
               end loop;
            end;

            for I in Parsed_Settings.First_Index ..
              Parsed_Settings.Last_Index loop
               Settings.Append
                 (To_Radians (Parsed_Settings.Element (I)));
            end loop;
            Num_Settings := Positive (Length (Settings));
         end if;

         if Arg_Count > 2 then
            Spin := Float'Value (Argument (3));
         else
            Spin := 1.0;
         end if;
      end if;

   end Process_Command_Line;

   procedure Save (File_Name : String; Station : Station_Type) is
      use Ada.Streams.Stream_IO;
      use Result_Vector_Package;
      File_ID    : Ada.Streams.Stream_IO.File_Type;
      Out_Stream : Stream_Access;
      Curs       : Cursor := Station.Results.First;
   begin
      Create (File_ID, Out_File, File_Name);
      Out_Stream := Stream (File_ID);
      while Has_Element (Curs) loop
         Float'Write (Out_Stream, Element (Curs).Setting);
         Float'Write (Out_Stream, Element (Curs).Outcome);
         Next (Curs);
      end loop;
      Close (File_ID);

   end Save;

   procedure Save_As_Text (File_Name : String; Particles : Particle_Vector) is
      use Ada.Text_IO;
      use Particle_Data_Package;
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

   procedure Save_Particles (Filename : String; Particles : Particle_Vector) is
      use Ada.Streams.Stream_IO;
      use Particle_Data_Package;
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

   end Save_Particles;

end Utilities;
