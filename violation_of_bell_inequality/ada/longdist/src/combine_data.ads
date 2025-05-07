
with Types; use Types;

package Combine_Data is

   procedure Load_Photon_Data (Data_File : String;
                               Data      : out String13_Array);
   procedure Load_OEM_Data (Data_File : String;
                            Data      : out String4_Array);
   procedure Save_Data (Data_File : String; Data : String46_Array);
   function Time_Diff (A, B : String_13) return String_12;

end Combine_Data;
