
with Types; use Types;

package Utils is

   --  procedure Convert_Hex_To_Text (Hex_Source_File, Text_Target_File : String);
   --  function Hex (aByte : Byte) return String;
   --  function Load_Data (File_Name : String) return Bounded_String_List;
   --  procedure Save_Data (File_Name : String; Data : Bounded_String_List);
   function To_IEEE_Double_Big_Endian (Data  : Byte_Array) return Float;

end Utils;
