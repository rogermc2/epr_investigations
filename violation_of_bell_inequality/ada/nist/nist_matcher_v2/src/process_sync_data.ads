
with Types; use Types;

package Process_Sync_Data is

   procedure Match_Syncs
     (A_Sync_CSV, B_Sync_CSV, Matched_Sync_CSV : String; Width : Natural;
      Num_Found : out Natural; Selected_Pairs : out Match_List;
      Offset : out Double_Natural);

end Process_Sync_Data;
