
with Types; use Types;
package Utils is

   procedure Load_Photon_Data (Data_File : String;
                               Data      : out String13_Array);
   procedure Load_OEM_Data (Data_File : String;
                            Data      : out String3_Array);
   procedure Save_Data (Data_File : String; Data : String30_Array);

end Utils;
