
with Types; use Types;

package Process_Data is

   procedure Load_NIST_Data (Source_File, Target_File : String;
    Num_Rows : Double_Natural := 30);

end Process_Data;
