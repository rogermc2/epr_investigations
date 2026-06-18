
with Types; use Types;

package Combine_Data is

   procedure Load_Photon_Data (Data_File : String;
                               Data      : out String21_Array);
   procedure Load_NIST_Data (Data_File : String;
                             Data    : out String19_Array);
   procedure Load_OEM_Data (Data_File : String;
                            Data      : out String4_Array);
   procedure Save_Data (Data_File : String; Data : String53_Array);

end Combine_Data;
