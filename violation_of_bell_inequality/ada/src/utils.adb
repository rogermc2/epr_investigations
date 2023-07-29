
with Interfaces;

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
      OEM_0_File   : constant String := OEM_Directory & "OEM_0.csv";
      OEM_1_File   : constant String := OEM_Directory & "OEM_1.csv";
      Source_ID    : File_Type;
      OEM_0_ID     : File_Type;
      OEM_1_ID     : File_Type;
      Val          : String (1 .. 4);
      First_0      : Boolean := True;
      First_1      : Boolean := True;
   begin
      Open (Source_ID, In_File, Source_File);
      Create (OEM_0_ID, Out_File, OEM_0_File);
      Create (OEM_1_ID, Out_File, OEM_1_File);

      while not End_Of_File (Source_ID) loop
         Get (Source_ID, Val);
         if Val = "0000" then
            if First_0 then
               First_0 := False;
            else
               Put (OEM_0_ID, ",");
            end if;
            Put (OEM_0_ID, "0");

         elsif Val = "0001" then
            if First_0 then
               First_0 := False;
            else
               Put (OEM_0_ID, ",");
            end if;
            Put (OEM_0_ID, "1");

         elsif Val = "0002" then
            if First_1 then
               First_1 := False;
            else
               Put (OEM_1_ID, ",");
            end if;
            Put (OEM_1_ID, "0");

         elsif Val = "0003" then
            if First_1 then
               First_1 := False;
            else
               Put (OEM_1_ID, ",");
            end if;
            Put (OEM_1_ID, "1");
         end if;
      end loop;

      Close (OEM_0_ID);
      Close (OEM_1_ID);
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
