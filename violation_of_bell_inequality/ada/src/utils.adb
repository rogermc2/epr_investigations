
with Interfaces;

with Ada.Sequential_IO;
with Ada.Text_IO;

with Basic_Printing; use Basic_Printing;

package body Utils is

   package Seq_IO_U8 is new Ada.Sequential_IO (Interfaces.Unsigned_8);

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
      OEM_00_File  : constant String := OEM_Directory & "OEM_00.txt";
      OEM_01_File  : constant String := OEM_Directory & "OEM_01.txt";
      OEM_10_File  : constant String := OEM_Directory & "OEM_10.txt";
      OEM_11_File  : constant String := OEM_Directory & "OEM_11.txt";
      Source_ID    : File_Type;
      OEM_00_ID    : File_Type;
      OEM_01_ID    : File_Type;
      OEM_10_ID    : File_Type;
      OEM_11_ID    : File_Type;
   begin
      Open (Source_ID, In_File, Source_File);
      Create (OEM_00_ID, Out_File, OEM_00_File);
      Create (OEM_10_ID, Out_File, OEM_10_File);
      Create (OEM_01_ID, Out_File, OEM_01_File);
      Create (OEM_11_ID, Out_File, OEM_11_File);
      for index in Data.First_Index .. Data.Last_Index loop
         Put (File_ID, Data (index));
      end loop;
      Close (OEM_00_ID);
      Close (OEM_10_ID);
      Close (OEM_01_ID);
      Close (OEM_11_ID);
      Close (Source_ID);

      Ada.Text_IO.Put_Line (Routine_Name & "OEM files written.");

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
