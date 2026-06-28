
with Types; use Types;

package Process_Detection_Data is

   --  procedure Find_Raw_Window_Width
   --    (CSV_Times_A, CSV_Times_B : String; Delta_A : Natural;
   --     Min_Width, Max_Width     : out Natural);
   procedure Match_Photon_Times
     (CSV_AB, Match : String; Delta_Val : Double_Natural; Width : Natural;
      Num_Found     : out Natural; Selected_Pairs : out Match_List;
      Num_Rows      : Natural := 0);
   function Number_Of_Matches (File_Name : String) return Natural;

end Process_Detection_Data;
