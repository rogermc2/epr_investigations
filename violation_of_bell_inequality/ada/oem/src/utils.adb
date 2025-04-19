
with Ada.Directories; use Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Sequential_IO;
with Ada.Streams;
with Ada.Streams.Stream_IO;
with Ada.Text_IO;

with Basic_Printing; use Basic_Printing;

package body Utils is

   package Seq_IO_U8 is new Ada.Sequential_IO (Interfaces.Unsigned_8);

   --  ------------------------------------------------------------------------

   procedure Convert_To_Text (Hex_Source_File, Text_Target_File : String) is
      Hex_Data : Types.Bounded_String_List;
   begin
      Hex_Data := Load_Data (Hex_Source_File);
      Save_Data (Text_Target_File, Hex_Data);
   end Convert_To_Text;

   --  ------------------------------------------------------------------------

   function Hex (Byte : Interfaces.Unsigned_8) return String is
      use Interfaces;
      Hex_Chars   : constant array (Unsigned_8 range 0 .. 15) of Character :=
        ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D',
        'E', 'F');
      Half_Byte_1 : constant Unsigned_8 := Byte mod 16;
      Half_Byte_2 : constant Unsigned_8 := Byte / 16;
   begin
      return Hex_Chars (Half_Byte_2) & Hex_Chars (Half_Byte_1);
   end Hex;

   --  ------------------------------------------------------------------------

   function Load_Data (File_Name : String) return Types.Bounded_String_List is
      use Seq_IO_U8;
      Routine_Name : constant String := "Utils.Load_Data ";
      Data_File    : File_Type;
      Data         : Interfaces.Unsigned_8;
      Hex_Data     : Types.Bounded_String_List;
   begin

      Open (Data_File, In_File, File_Name);

      while not End_Of_File (Data_File) loop
         Read (Data_File, Data);
         Hex_Data.Append (Hex (Data));
      end loop;

      Close (Data_File);

      Print_String_List
        (Routine_Name & "Hex_Data items 1 - 40", Hex_Data, 1, 40);

      return Hex_Data;

   exception
      when others =>
         Ada.Text_IO.Put_Line (Routine_Name & "failed.");
         return Hex_Data;

   end Load_Data;

   --  -------------------------------------------------------------------------

   procedure OEM_Data (Source_File, OEM_Directory : String) is
      use Interfaces;
      use Ada.Streams;
      use Ada.Text_IO;
      use Types;
      Routine_Name : constant String  := "Utils.OEM_Data ";
      OEM_File     : constant String  := OEM_Directory & "OEM.csv";
      Source_Size  : constant Natural := Natural (Size (Source_File));
      Data_Stream  : Stream_IO.Stream_Access;
      Source_ID    : Stream_IO.File_Type;
      OEM_ID       : Ada.Text_IO.File_Type;
      Line_Num     : Natural := 1;
      Data         : Byte_Array (1 .. 2);
      Swap         : Byte;
      Num_Invalid  : Natural := 0;
   begin
      Ada.Text_IO.Put_Line (Routine_Name & "Source File: " & Source_File);
      Stream_IO.Open (Source_ID, Stream_IO.In_File, Source_File);
      Data_Stream := Stream_IO.Stream (Source_ID);
      Ada.Text_IO.Create (OEM_ID, Out_File, OEM_File);

      while Line_Num < Source_Size and then
        not Stream_IO.End_Of_File (Source_ID) loop
         Byte_Array'Read (Data_Stream, Data);

         if Data (2) = 0 then
            Ada.Text_IO.Put (OEM_ID, "0,0");

         elsif Data (2) = 1 then
            Ada.Text_IO.Put (OEM_ID, "0,1");

         elsif Data (2) = 2 then
            Ada.Text_IO.Put (OEM_ID, "1,0");

         elsif Data (2) = 3 then
            Ada.Text_IO.Put (OEM_ID, "1,1");
         else
            Num_Invalid := Num_Invalid + 1;
            if Num_Invalid < 5 then
               Ada.Text_IO.Put_Line
                 (Routine_Name & "line " & Integer'Image (Line_Num) &
                    " Invalid Val: " & Byte'Image (Data (2)));
            end if;
         end if;

         if not Stream_IO.End_Of_File (Source_ID) then
            Ada.Text_IO.Put (OEM_ID, ",");
         end if;

         Line_Num := Line_Num + 1;
         Ada.Text_IO.New_Line (OEM_ID);
      end loop;

      Ada.Text_IO.Close (OEM_ID);
      Stream_IO.Close (Source_ID);

      Ada.Text_IO.Put_Line
        (Routine_Name & "Number of invalid items: " &
           Integer'Image (Num_Invalid));
      Ada.Text_IO.Put_Line
        (Routine_Name & "OEM files written to " & OEM_Directory);
      Ada.Text_IO.Put_Line
        (Routine_Name & "OEM file length: " &
           Natural'Image (Natural (Size (OEM_Directory & "OEM.csv"))));
      Ada.Text_IO.New_Line;

   exception
      when Error : others =>
         Put_Line (Routine_Name & "Line_Num" & Integer'Image (Line_Num));
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;
   end OEM_Data;

   --  -------------------------------------------------------------------------

   procedure Save_Data (File_Name : String; Data : Types.Bounded_String_List)
   is
      use Ada.Text_IO;
      Routine_Name : constant String := "Utils.Save_Data ";
      File_ID      : File_Type;
   begin
      Create (File_ID, Out_File, File_Name);
      for index in Data.First_Index .. Data.Last_Index loop
         Put (File_ID, Data (index));
      end loop;
      Close (File_ID);

      Ada.Text_IO.Put_Line (Routine_Name & File_Name & " written.");

   end Save_Data;

   --  -------------------------------------------------------------------------

   procedure Swap_Endian (Data : in out Interfaces.Unsigned_16) is
      use Interfaces;
      Right_Byte   : constant Unsigned_16 := Data and 16#FF#;
   begin
      Data := Shift_Left (Right_Byte, 8) +
        Shift_Right (Data and 16#FF00#, 8);

   end Swap_Endian;

   --  -------------------------------------------------------------------------

end Utils;
