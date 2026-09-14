
with Types; use Types;

package Process_Sync_Data is

  procedure Load_Sync_Data
      (CSV_Data : String; Sync_Data : in out Double_Natural_Vector;
         Num_Rows : Double_Natural);
   procedure Match_Syncs
     (A_Sync_Data, B_Sync_Data: in out Double_Natural_Vector;
      Matched_Sync_CSV : String; Width : Natural;
      Num_Found : out Natural; Selected_Pairs : out Match_List;
      Offset : out Double_Natural);

end Process_Sync_Data;
