
with SA_Types; use SA_Types;

package Chi_Sq is
   type Chi_Value is new Long_Float;
   type P_Value   is new Long_Float;
   type Table_Index is new Positive range 1 .. 16;
   type Quadrant_Index is range 1 .. 4;
   type Count_Array is array (Quadrant_Index) of Long_Float;

   type Table_Row is record
      Chi_Square_Score : Chi_Value;
      Probability      : P_Value;
   end record;
   type Reference_Table is array (Table_Index) of Table_Row;

   --  Definitive Chi-Square distribution anchor values for 3 degrees of freedom
   DF3_Lookup_Table : constant Reference_Table :=
     (1  => (Chi_Square_Score => 0.115,  Probability => 0.990),
      2  => (Chi_Square_Score => 0.216,  Probability => 0.975),
      3  => (Chi_Square_Score => 0.352,  Probability => 0.950),
      4  => (Chi_Square_Score => 0.584,  Probability => 0.900),
      5  => (Chi_Square_Score => 1.213,  Probability => 0.750),
      6  => (Chi_Square_Score => 2.366,  Probability => 0.500),
      7  => (Chi_Square_Score => 4.108,  Probability => 0.250),
      8  => (Chi_Square_Score => 6.251,  Probability => 0.100),
      9  => (Chi_Square_Score => 7.815,  Probability => 0.050), -- Standard Critical Value
      10 => (Chi_Square_Score => 9.348,  Probability => 0.025),
      11 => (Chi_Square_Score => 11.345, Probability => 0.010),
      12 => (Chi_Square_Score => 12.838, Probability => 0.005),
      13 => (Chi_Square_Score => 14.320, Probability => 0.002),
      14 => (Chi_Square_Score => 16.266, Probability => 0.001),
      15 => (Chi_Square_Score => 21.108, Probability => 0.0001),
      16 => (Chi_Square_Score => 26.125, Probability => 0.00001));

   function Compute_Chi_Square (Num_Obs : Count_Array;
               Expectations : Expectations_Record) return Chi_Value;
   function Lookup_P_Value (Calculated_Chi : Chi_Value) return P_Value;

end Chi_Sq;