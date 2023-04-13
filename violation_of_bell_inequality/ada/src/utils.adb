
with Interfaces;

with Ada.Sequential_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO;

with Basic_Printing; use Basic_Printing;

package body Utils is

   package IO is new Ada.Sequential_IO (Interfaces.Unsigned_8);

   --  ------------------------------------------------------------------------

   function Hex (Byte : Interfaces.Unsigned_8) return String is
      use Interfaces;
      Hex_Chars : constant array (Unsigned_8 range 0 .. 15)
        of Character := ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
                        'A', 'B', 'C', 'D', 'E', 'F');
      Half_Byte_1 : constant Unsigned_8 := Byte mod 16;
      Half_Byte_2 : constant Unsigned_8 := Byte / 16;
   begin
      return Hex_Chars (Half_Byte_2) & Hex_Chars (Half_Byte_1);
   end Hex;

   --  ------------------------------------------------------------------------

   function Load_Data (File_Name : String)
                       return Types.Unbounded_List is
      use IO;
      Routine_Name : constant String := "Utils.Load_Data ";
      Data_File    : File_Type;
      Data         : Interfaces.Unsigned_8;
      Hex_Data     : Types.Unbounded_List;
   begin

      Open (Data_File, In_File, File_Name);
      Read (Data_File, Data);

      while not End_Of_File (Data_File) loop
         Read (Data_File, Data);
         Hex_Data.Append (To_Unbounded_String (Hex (Data)));
      end loop;

      Close (Data_File);

      Print_Unbound_List (Routine_Name & "Hex_Data", Hex_Data, 1, 40);

      return Hex_Data;

   exception
      when others =>
         Ada.Text_IO.Put_Line (Routine_Name & "failed.");
         return Hex_Data;

   end Load_Data;

   --  -------------------------------------------------------------------------

end Utils;
