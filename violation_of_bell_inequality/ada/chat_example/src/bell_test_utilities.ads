
with Bell_Test_Types; use Bell_Test_Types;

package Bell_Test_Utilities is

   function Correct_Alice_Time (Alice_Raw : Timetag_Bin;
      Slope, Intercept : Long_Float) return Timetag_Bin;
   procedure Find_Coincidences (Alice_Data, Bob_Data : Timetag_Array;
                                 Window_Bin : Timetag_Bin);

end Bell_Test_Utilities;