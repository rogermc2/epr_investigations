with Interfaces;

with Ada.Directories; use Ada.Directories;
with Ada.Sequential_IO;
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
      Hex_Chars    : constant array (Unsigned_8 range 0 .. 15)
        of Character := ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
                        'A', 'B', 'C', 'D', 'E', 'F');
      Half_Byte_1  : constant Unsigned_8 := Byte mod 16;
      Half_Byte_2  : constant Unsigned_8 := Byte / 16;
   begin
      return Hex_Chars (Half_Byte_2) & Hex_Chars (Half_Byte_1);
   end Hex;

   --  ------------------------------------------------------------------------

   function Load_Data (File_Name : String)
                       return Types.Bounded_String_List is
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

      Print_String_List (Routine_Name &
                           "Hex_Data items 1 - 40", Hex_Data, 1, 40);

      return Hex_Data;

   exception
      when others =>
         Ada.Text_IO.Put_Line (Routine_Name & "failed.");
         return Hex_Data;

   end Load_Data;

   --  -------------------------------------------------------------------------

   procedure OEM_Data (Source_File, OEM_Directory : String) is
      use Ada.Text_IO;
      Routine_Name : constant String := "Utils.OEM_Data ";
      OEM_File     : constant String := OEM_Directory & "OEM.csv";
      Source_Size  : constant Natural := Natural (Size (Source_File));
      Source_ID    : File_Type;
      OEM_ID       : File_Type;
      Line_Num     : Natural := 0;
      Val          : String (1 .. 4);
   begin
      Ada.Text_IO.Put_Line (Routine_Name & "Source File: " &
                              Source_File);
      New_Line;
      Open (Source_ID, In_File, Source_File);
      Create (OEM_ID, Out_File, OEM_File);

      while Line_Num < Source_Size / 8 and then
        not End_Of_File (Source_ID) loop
         Line_Num := Line_Num + 1;
         for field_num in 1 .. 2 loop
            if not End_Of_File (Source_ID) then
               Get (Source_ID, Val);
               if Val = "0000" then
                  Put (OEM_ID, "0");

               elsif Val = "0001" then
                  Put (OEM_ID, "1");

               elsif Val = "0002" then
                  Put (OEM_ID, "2");

               elsif Val = "0003" then
                  Put (OEM_ID, "3");
               end if;

               if field_num = 1 then
                  Put (OEM_ID, ",");
               end if;
            end if;
         end loop;

         New_Line (OEM_ID);
      end loop;

      Close (OEM_ID);
      Close (Source_ID);

      Ada.Text_IO.Put_Line (Routine_Name & "OEM files written to " &
                              OEM_Directory);

   end OEM_Data;

   --  -------------------------------------------------------------------------

   procedure Save_Data (File_Name : String; Data : Types.Bounded_String_List) is
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

end Utils;
