
with Ada.Numerics;

package body Statistics is

   function Compute_Chi_Square
      (Theoretical_Prob : Expectations_Record; Obs_Freq : Count_Array)
         return Chi_Value is
      Total_Events : Long_Float := 0.0;
      Chi_Square   : Chi_Value := 0.0;
      Expect_Freq  : Count_Array;
      --  Theoretical expectations for these specific phase angles
      --  (Converts your -0.750 expectations back into proportional probabilities)
      --  Theoretical_Prob : constant Count_Array :=
      --     (1 => 0.125,  -- Expected proportion for 00
      --     2 => 0.375,  -- Expected proportion for 01
      --     3 => 0.375,  -- Expected proportion for 10
      --     4 => 0.125   -- Expected proportion for 11);
   begin
      for I in Quadrant_Index loop
         Total_Events := Total_Events + Obs_Freq(I);
      end loop;

      Expect_Freq (1) := Long_Float (Theoretical_Prob.E_AA) * Total_Events;
      Expect_Freq (2) := Long_Float (Theoretical_Prob.E_AB) * Total_Events;
      Expect_Freq (3) := Long_Float (Theoretical_Prob.E_BA) * Total_Events;
      Expect_Freq (4) := Long_Float (Theoretical_Prob.E_BB) * Total_Events;

      --  Compute Chi-Square terms: (O - E)^2 / E
      for I in Quadrant_Index loop
         Chi_Square := Chi_Square +
         Chi_Value (((Obs_Freq (I) - Expect_Freq (I)) ** 2) / Expect_Freq (I));
      end loop;

      return Chi_Square;

   end Compute_Chi_Square;

   procedure Compute_Free_Crosstab_Chi ( N00, N01, N10, N11 : Long_Float;
         Chi_Square_Score : out Long_Float) is
      --  Calculate Row and Column Marginal Totals
      Row_0_Total : constant Long_Float := N00 + N01; -- A Setting = 0
      Row_1_Total : constant Long_Float := N10 + N11; -- A Setting = 1
      Col_0_Total : constant Long_Float := N00 + N10; -- B Setting = 0
      Col_1_Total : constant Long_Float := N01 + N11; -- B Setting = 1

      --  2,738 matches:
      Grand_Total  : constant Long_Float := N00 + N01 + N10 + N11;
      Observed     : array (1..2, 1..2) of Long_Float;
      Expected     : array (1..2, 1..2) of Long_Float;
      Temp_Term    : Long_Float;
   begin
      --  1. Populate Observed Grid
      Observed (1,1) := N00;
      Observed (1,2) := N01;
      Observed (2,1) := N10;
      Observed (2,2) := N11;

      --  2. Dynamically calculate Expected values
      --   based entirely on  grid margins
      Expected (1,1) := (Row_0_Total * Col_0_Total) / Grand_Total;
      Expected (1,2) := (Row_0_Total * Col_1_Total) / Grand_Total;
      Expected (2,1) := (Row_1_Total * Col_0_Total) / Grand_Total;
      Expected (2,2) := (Row_1_Total * Col_1_Total) / Grand_Total;

      --  3. Accumulate Chi-Square Score: sum of (O - E)^2 / E
      Chi_Square_Score := 0.0;
      for R in 1 .. 2 loop
         for C in 1 .. 2 loop
            Temp_Term :=
               ((Observed(R,C) - Expected(R,C)) ** 2) / Expected(R,C);
            Chi_Square_Score := Chi_Square_Score + Temp_Term;
         end loop;
      end loop;

   end Compute_Free_Crosstab_Chi;

   function Lookup_P_Value (Calculated_Chi : Chi_Value) return P_Value is
      X0, X1 : Chi_Value;
      Y0, Y1 : P_Value;
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
      for I in Table_Index range 1 .. 15 loop
         if Calculated_Chi >= DF3_Lookup_Table (I).Chi_Square_Score and then
            Calculated_Chi <= DF3_Lookup_Table (I + 1).Chi_Square_Score then
            X0 := DF3_Lookup_Table (I).Chi_Square_Score;
            X1 := DF3_Lookup_Table (I + 1).Chi_Square_Score;
            Y0 := DF3_Lookup_Table (I).Probability;
            Y1 := DF3_Lookup_Table (I + 1).Probability;

            --  Standard Linear Interpolation formula
            return Y0 +
               (Y1 - Y0) * P_Value ((Calculated_Chi - X0) / (X1 - X0));
         end if;
      end loop;

      return 0.0;
   end Lookup_P_Value;

   function Statistical_EAB (theta : Float) return Float is
      use Ada.Numerics;
   begin
      return 2.0 * theta / Pi - 1.0;
   end Statistical_EAB;

   function Statistical_EAB (A, B : Long_Float) return Float is
   begin
      return Statistical_EAB (abs (Float (A - B)));

   end Statistical_EAB;

end Statistics;
