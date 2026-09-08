
with Types; use Types;

package Process_Detection_Data is
   procedure Match_Detection_Times (CSV_AB_In, Matched_CSV_AB : String;
    Width : Natural; Delta_Time : Double_Natural; Num_Found : out Natural;
     Selected_Pair_Indices : out Match_List);
   function Number_Of_Matches (File_Name : String) return Natural;

end Process_Detection_Data;
