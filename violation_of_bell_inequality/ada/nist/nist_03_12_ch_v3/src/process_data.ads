
with NIST_Types; use NIST_Types;
with Types; use Types;

package Process_Data is

   procedure Load_NIST_Data (Source_File, Target_File : String;
    Num_Rows : Double_Natural := 30);
   procedure Load_NIST_Data_2 (Source_File, Target_File : String;
    Num_Rows : Double_Natural := 30);
   procedure Print_Raw_Data_Packet (Data : Raw_Data_Packet);

end Process_Data;
