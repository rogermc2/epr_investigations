
with Interfaces;

with Types;

package Utils is

   procedure Convert_To_Text (Hex_Source_File, Text_Target_File : String);
   function Load_Data (File_Name : String) return Types.Bounded_String_List;
   procedure OEM_Data (Source_File, OEM_Directory : String);
   procedure Save_Data (File_Name : String; Data : Types.Bounded_String_List);
   procedure Swap_Endian (Data : in out Interfaces.Unsigned_16);

end Utils;
