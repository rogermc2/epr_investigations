
with Types;

package Utils is

   function Load_Data (File_Name : String) return Types.Bounded_String_List;
   procedure Save_Data (File_Name : String; Data : Types.Bounded_String_List);

end Utils;
