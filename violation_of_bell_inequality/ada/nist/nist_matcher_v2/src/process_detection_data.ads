
with NIST_Types; use NIST_Types;
with Types; use Types;

package Process_Detection_Data is

   procedure Align_Detection_Data
    (A_Det_Data, B_Det_Data : in out Setting_Time_Vector;
     Delta_Time, Offset : Double_Natural; A_Gt_B : Boolean);
   procedure Match_Detection_Times (CSV_AB_In, Matched_CSV_AB : String;
    Width : Natural; Delta_Time : Double_Natural; Num_Found : out Natural;
     Selected_Pair_Indices : out Match_List);
   function Number_Of_Matches (File_Name : String) return Natural;

end Process_Detection_Data;
