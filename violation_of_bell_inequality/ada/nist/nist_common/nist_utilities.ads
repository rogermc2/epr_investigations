
with NIST_Types; use NIST_Types;
with Types; use Types;

package  NIST_Utilities is

 procedure Align_Data
 (A_Sync_Data, B_Sync_Data : in out Double_Natural_Vector;
  A_Det_Data, B_Det_Data : in out Setting_Time_Vector);

end NIST_Utilities;