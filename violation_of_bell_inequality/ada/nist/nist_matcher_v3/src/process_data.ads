
with Types; use Types;

with NIST_Types; use NIST_Types;

package Process_Data is

   procedure Load_NIST_Data (Source_File : String;
    NIST_Data : out Nist_Data_List);
   procedure Match_Syncs
     (A_Sync_Data, B_Sync_Data: in out Double_Natural_Vector;
      Matched_Sync_CSV : String; Width : Natural;
      Num_Found : out Natural; Selected_Pairs : out Match_List;
      Offset : out Double_Natural);

end Process_Data;
