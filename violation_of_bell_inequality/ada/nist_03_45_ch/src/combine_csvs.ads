
with Types; use Types;

package Combine_CSVs is

   procedure Combine
     (Photon_Data_A_CSV, Photon_Data_B_CSV, OEM_Data_A_CSV,
      OEM_Data_B_CSV, Combined_CSV : String;  Num_Rows : Positive := 30);

    procedure Combine_Nist (A_CSV, B_CSV, Combined_CSV : String;
      Num_Rows : Double_Integer := 30);

end Combine_CSVs;
