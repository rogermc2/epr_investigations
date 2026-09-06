
with Types; use Types;
package Convert_Compressed_File is

   procedure NIST_Data (Source_File, Det_File, Sync_File :
                         String; Num_Rows : Double_Natural := 30);

end Convert_Compressed_File;
