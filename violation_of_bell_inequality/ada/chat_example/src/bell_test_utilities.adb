
with Ada.Text_IO; use Ada.Text_IO;

package body Bell_Test_Utilities is

   procedure Log_Match (Alice_Time, Bob_Time, Time_Diff : Timetag_Bin);
   function Correct_Alice_Time (Alice_Raw : Timetag_Bin;
      Slope, Intercept : Long_Float) return Timetag_Bin is
      --  Convert to float for regression math
      Raw_Float  : constant Long_Float := Long_Float (Alice_Raw);
      Corr_Float : constant Long_Float := Raw_Float * Slope + Intercept;
   begin

      return Timetag_Bin (Corr_Float);

   end Correct_Alice_Time;

   --  Alice_Data is pre-corrected using Correct_Alice_Time
   procedure Find_Coincidences (Alice_Data, Bob_Data : Timetag_Array;
                                 Window_Bin : Timetag_Bin) is
      Bob_Idx : Positive := Bob_Data'First;
      Diff    : Timetag_Bin;
      Current_Bob : Positive;
   begin
      for Alice_Idx in Alice_Data'Range loop
         --  Catch up Bob’s pointer so that it is close to Alice’s time
         while Bob_Idx < Bob_Data'Last and then
            Bob_Data (Bob_Idx) < (Alice_Data(Alice_Idx) - Window_Bin)
         loop
            Bob_Idx := Bob_Idx + 1;
         end loop;

         --  Check all Bob events inside the valid time window
         Current_Bob := Bob_Idx;
         while Current_Bob <= Bob_Data'Last and then
            Bob_Data (Current_Bob) <= (Alice_Data (Alice_Idx) + Window_Bin)
         loop
            Diff := Bob_Data (Current_Bob) - Alice_Data(Alice_Idx);
            --  Success! A matching pair has been found.
            Log_Match (Alice_Data (Alice_Idx), Bob_Data (Current_Bob), Diff);
            Current_Bob := Current_Bob + 1;
         end loop;
      end loop;

   end Find_Coincidences;

   procedure Log_Match (Alice_Time, Bob_Time, Time_Diff : Timetag_Bin) is
   begin
      Put_Line ("Match found: Alice = " & Timetag_Bin'Image (Alice_Time) &
                ", Bob = " & Timetag_Bin'Image (Bob_Time) &
                ", Diff = " & Timetag_Bin'Image (Time_Diff));
   end Log_Match;

end Bell_Test_Utilities;