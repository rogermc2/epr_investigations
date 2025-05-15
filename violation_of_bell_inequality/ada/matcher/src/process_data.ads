
with Types; use Types;

package Process_Data is

   procedure Match_Photon_Times
     (CSV_A, CSV_B : String; Delta_A, Width : Double;
      Selected_Pairs : out Match_List);

end Process_Data;
