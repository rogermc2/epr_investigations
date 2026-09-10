
with NIST_Types; use NIST_Types;
with Types; use Types;

package Process_Sync_Data is

  procedure Load_Sync_Data
      (CSV_Data : String; Sync_Data : in out Setting_Time_Vector);
   procedure Match_Syncs
     (A_Sync_Data, B_Sync_Data: Setting_Time_Vector; Matched_Sync_CSV : String; Width : Natural;
      Num_Found : out Natural; Selected_Pairs : out Match_List;
      Align_Delta, Align_Offset, Offset : out Double_Natural;
      A_Gt_B : out Boolean);

end Process_Sync_Data;
