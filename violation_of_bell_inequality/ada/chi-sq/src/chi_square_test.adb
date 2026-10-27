
with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Float_Text_IO;    use Ada.Float_Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;

procedure Chi_Square_Test is

   type Frequency_Array is array (Positive range <>) of Float;

   function Calculate_Chi_Square (Observed, Expected : Frequency_Array) return Float is
      Chi_Square_Sum : Float := 0.0;
      Diff           : Float;
   begin
      for I in Observed'Range loop
         Diff := Observed (I) - Expected (I);
         Chi_Square_Sum := Chi_Square_Sum + ((Diff * Diff) / Expected(I));
      end loop;
      return Chi_Square_Sum;
      
   end Calculate_Chi_Square;

   --  Static data for demonstration
   --  Example: Rolling a 6-sided die 60 times
   Observed_Counts    : constant Frequency_Array := (12.0, 8.0, 11.0, 15.0, 6.0, 8.0);
   Expected_Counts    : constant Frequency_Array := (10.0, 10.0, 10.0, 10.0, 10.0, 10.0);
   Degrees_Of_Freedom : constant Integer := Observed_Counts'Length - 1;
   Chi_Square_Stat    : Float;

begin
   Put_Line("Chi-Square Goodness-of-Fit Test");
   New_Line;

   --  Print Categories and Counts
   Put_Line("Bin | Observed | Expected");
   Put_Line("-------------------------");
   for I in Observed_Counts'Range loop
      Put(I, Width => 3);
      Put(" | ");
      Put(Observed_Counts(I), Fore => 4, Aft => 1, Exp => 0);
      Put("   | ");
      Put(Expected_Counts(I), Fore => 4, Aft => 1, Exp => 0);
      New_Line;
   end loop;
   Put_Line("-------------------------");
   New_Line;

   --  Calculate Statistic
   Chi_Square_Stat := Calculate_Chi_Square(Observed_Counts, Expected_Counts);

   --  Output Results
   Put("Calculated Chi-Square Statistic: ");
   Put(Chi_Square_Stat, Fore => 1, Aft => 4, Exp => 0);
   New_Line;

   Put("Degrees of Freedom: ");
   Put(Degrees_Of_Freedom, Width => 0);
   New_Line;

   New_Line;
   Put_Line("Note: Compare this statistic against a critical value table");
   Put_Line("or use a math library to calculate the exact p-value.");

end Chi_Square_Test;
