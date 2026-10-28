
with Freedman_Clauser_Types; use Freedman_Clauser_Types;

package Freedman_Clauser_Test is

   procedure Compute_Crosstab_Chi
      (Freedman_Results : Freedman_Data_Table;
       Chi_Square_Score : out Long_Float);
   procedure FC_H0_Test;

end Freedman_Clauser_Test;