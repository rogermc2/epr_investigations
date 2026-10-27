
with Ada.Numerics;

package body Statistics is

   function Compute_Chi_Square
      (Theoretical_Prob, Obs : Count_Array) return Long_Float is
      Total_Events : Long_Float := 0.0;
      Chi_Square   : Long_Float := 0.0;
      Expected     : Count_Array;

      --  Theoretical expectations for these specific phase angles
      --  (Converts your -0.750 expectations back into proportional probabilities)
      --  Theoretical_Prob : constant Count_Array :=
      --     (1 => 0.125,  -- Expected proportion for 00
      --     2 => 0.375,  -- Expected proportion for 01
      --     3 => 0.375,  -- Expected proportion for 10
      --     4 => 0.125   -- Expected proportion for 11);
   begin
      for I in Quadrant_Index loop
         Total_Events := Total_Events + Obs(I);
      end loop;

      --  Compute Chi-Square terms: (O - E)^2 / E
      for I in Quadrant_Index loop
         Expected(I) := Theoretical_Prob (I) * Total_Events;
         Chi_Square  := Chi_Square + ((Obs(I) - Expected(I)) ** 2) / Expected(I);
      end loop;

      return Chi_Square;
   end Compute_Chi_Square;

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
