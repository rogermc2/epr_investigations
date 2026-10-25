
package body Chi_Sq is

   function Compute_Chi_Square (Obs : Count_Array) return Long_Float is
      Total_Events : Long_Float := 0.0;
      Chi_Square   : Long_Float := 0.0;
      Expected     : Count_Array;

      --  Theoretical expectations for these specific phase angles
      --  (Converts your -0.750 expectations back into proportional probabilities)
      Theoretical_Prob : constant Count_Array := (
         1 => 0.125,    --  Expected proportion for 00
         2 => 0.375,    --  Expected proportion for 01
         3 => 0.375,    --  Expected proportion for 10
         4 => 0.125);   --  Expected proportion for 11
   begin
      --  Tally the Grand Total of events
      for I in Quadrant_Index loop
         Total_Events := Total_Events + Obs(I);
      end loop;

      --  Compute Chi-Square terms: (O - E)^2 / E
      for I in Quadrant_Index loop
         Expected(I) := Theoretical_Prob(I) * Total_Events;
         Chi_Square  := Chi_Square + ((Obs(I) - Expected(I)) ** 2) / Expected(I);
      end loop;

      return Chi_Square;

   end Compute_Chi_Square;

end Chi_Sq;