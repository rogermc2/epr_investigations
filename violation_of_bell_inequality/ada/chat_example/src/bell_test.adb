
with Bell_Test_Types; use Bell_Test_Types;
with Bell_Test_Utilities; use Bell_Test_Utilities;

procedure Bell_Test is
   use Rand_Int;
   --  This is a simple test of the Bell Test Utilities package.
   --  It generates some random data for Alice and Bob,
   --  applies a correction to Alice's data and then
   --  finds coincidences between the two datasets.

   Slope      : constant Long_Float := 1.0;
   Intercept  : constant Long_Float := 0.0;
   Window_Bin : constant Timetag_Bin := 10;
   Gen        : Generator;
   --  Random_Int : Rand_Range;

   --  Generate some random data for Alice and Bob
   Alice_Raw_Data : Timetag_Array (1 .. 100);
   Bob_Data       : Timetag_Array (1 .. 100);
begin
   Reset (Gen);

   --  Initialize the data arrays with random values
   for I in Alice_Raw_Data'Range loop
      --  Random_Int := Random;
      Alice_Raw_Data (I) := Timetag_Bin (Random (Gen) * 1000);
      Bob_Data (I) := Timetag_Bin (Random (Gen) * 1000);
   end loop;

   --  Apply the correction to Alice's data
   for I in Alice_Raw_Data'Range loop
      Alice_Raw_Data (I) :=
       Correct_Alice_Time (Alice_Raw_Data (I), Slope, Intercept);
   end loop;

   --  Find coincidences between the corrected Alice data and Bob's data
   Find_Coincidences (Alice_Raw_Data, Bob_Data, Window_Bin);

end Bell_Test;