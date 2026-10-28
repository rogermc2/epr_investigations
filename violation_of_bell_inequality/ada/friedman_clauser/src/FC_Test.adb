
with Freedman_1972_Results; use Freedman_1972_Results;
with Freedman_Clauser_Test; use Freedman_Clauser_Test;

with Printing; use Printing;
procedure FC_Test is
   Chi_Square_Score : Long_Float;
begin
   Compute_Crosstab_Chi (Freedman_Results, Chi_Square_Score);
   Print_Long_Float_Line ("Freedman 1972 Thesis Chi Square Score",
      Chi_Square_Score);

   FC_H0_Test;

end FC_Test;