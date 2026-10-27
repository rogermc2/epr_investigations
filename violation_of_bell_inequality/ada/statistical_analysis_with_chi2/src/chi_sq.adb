
package body Chi_Sq is

   function Compute_Chi_Square (Num_Obs : Count_Array;
               Expectations : Expectations_Record) return Chi_Value is
      Total_Events : Long_Float := 0.0;
      Chi_Square   : Chi_Value := 0.0;
      Expected     : Count_Array;
      Theoretical_Prob : constant Count_Array :=
         (Long_Float (Expectations.E_AA),   --  Expected proportion for 00
         Long_Float (Expectations.E_AB),    --  Expected proportion for 01
         Long_Float (Expectations.E_BA),    --  Expected proportion for 10
         Long_Float (Expectations.E_BB));   --  Expected proportion for 11
   begin
      --  Tally the Grand Total of events
      for I in Quadrant_Index loop
         Total_Events := Total_Events + Num_Obs (I);
      end loop;

      --  Compute Chi-Square terms: (O - E)^2 / E
      for I in Quadrant_Index loop
         Expected (I) := Theoretical_Prob(I) * Total_Events;
         Chi_Square := Chi_Square +
         Chi_Value (((Num_Obs (I) - Expected (I)) ** 2) / Expected (I));
      end loop;

      return Chi_Square;

   end Compute_Chi_Square;

   function Lookup_P_Value (Calculated_Chi : Chi_Value) return P_Value is
      X0     : Chi_Value;
      X1     : Chi_Value;
      Y0     : P_Value;
      Y1     : P_Value;
      Result : P_Value := 0.0;
      Done   : Boolean := False;
      Index  : Table_Index := 1;
   begin
      --  Boundary Check: Near perfect alignment with expectations
      if Calculated_Chi <= DF3_Lookup_Table(1).Chi_Square_Score then
         return 1.0;
      end if;

      --  Boundary Check: Massive mathematical rejection floor
      if Calculated_Chi >= DF3_Lookup_Table(16).Chi_Square_Score then
         return 0.0;
      end if;

      --  Scan the table rows to locate the bracket
      while Index <= 15 and then not Done loop
         Done := Calculated_Chi >=
            DF3_Lookup_Table (Index).Chi_Square_Score and then
            Calculated_Chi <= DF3_Lookup_Table (Index + 1).Chi_Square_Score;
         if Done then
            X0 := DF3_Lookup_Table (Index).Chi_Square_Score;
            X1 := DF3_Lookup_Table (Index + 1).Chi_Square_Score;
            Y0 := DF3_Lookup_Table (Index).Probability;
            Y1 := DF3_Lookup_Table (Index + 1).Probability;

            --  Standard Linear Interpolation formula
            Result :=
               Y0 + (Y1 - Y0) * P_Value ((Calculated_Chi - X0) / (X1 - X0));
         end if;

         Index := Index + 1;
      end loop;

      return Result;

   end Lookup_P_Value;

end Chi_Sq;