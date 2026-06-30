
with Types; use Types;

package Process_Detection_Data is
   procedure Match_Detection_Times (CSV_AB, Matched_CSV_AB : String;
                                     Delta_Val : Double_Natural);
   function Number_Of_Matches (File_Name : String) return Natural;

end Process_Detection_Data;
