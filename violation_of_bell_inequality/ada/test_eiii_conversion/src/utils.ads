
with Types;

package Utils is

   procedure Convert_To_Text (Hex_Source_File, Text_Target_File : String);
   function Load_Data (File_Name : String) return Types.Bounded_String_List;
   procedure Photon_Data (Source_File, Photon_Times_Directory : String);
   procedure Save_Data (File_Name : String; Data : Types.Bounded_String_List);

end Utils;
