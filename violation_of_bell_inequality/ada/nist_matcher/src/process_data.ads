
with Types; use Types;

package Process_Data is

   procedure Find_Raw_Window_Width
     (CSV_Times_A, CSV_Times_B : String; Delta_A : Float;
      Min_Width, Max_Width     : out Float);
   procedure Match_Photon_Times
     (Pairs_CSV : String; Delta_A, Width : Float;
      Num_Found : out Natural; Selected_Pairs : out Match_List;
      Num_Rows  : Natural := 0);
   function Number_Of_Matches (File_Name : String) return Natural;

end Process_Data;
