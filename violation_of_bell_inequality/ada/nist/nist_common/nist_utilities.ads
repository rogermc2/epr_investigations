
with NIST_Types; use NIST_Types;
with Types; use Types;

package  NIST_Utilities is

 procedure Align_Sync_Data
 (A_Sync_Data, B_Sync_Data : in out Setting_Time_Vector;
     Delta_Time, Offset : out Double_Natural; A_Gt_B : out Boolean);

end NIST_Utilities;