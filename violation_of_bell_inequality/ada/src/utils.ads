
with Types;

package Utils is

   function Load_Data (File_Name : String) return Types.Bounded_String_List;
   procedure OEM_Data (Source_File, OEM_Directory : String);
   procedure Save_Data (File_Name : String; Data : Types.Bounded_String_List);

end Utils;
