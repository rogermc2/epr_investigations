
with Types; use Types;

package Combine_CSVs is

  procedure Combine_Nist (A_CSV, B_CSV, Combined_CSV : String;
   Num_Rows : Double_Natural := 30);

end Combine_CSVs;
