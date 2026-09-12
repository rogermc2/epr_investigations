
with NIST_Types; use NIST_Types;
with Types; use Types;

package Process_Detection_Data is

   procedure Load_Detection_Data (CSV_Det_Data : String;
    Data_Out : out Setting_Time_Vector; Num_Rows : Double_Natural);
   procedure Match_Detection_Times (A_Data, B_Data : in out Setting_Time_Vector;
    Matched_CSV_AB : String; Width : Natural; Delta_Time : Double_Natural;
    Num_Found : out Natural;
     Selected_Pair_Indices : out Match_List);
   function Number_Of_Matches (File_Name : String) return Natural;

end Process_Detection_Data;
