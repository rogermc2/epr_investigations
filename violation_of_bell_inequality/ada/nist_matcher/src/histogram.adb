
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

with Printing; use Printing;

package body Histogram is

   type Bin_Array is array (Positive range <>) of Integer;

procedure Print_Histogram (Bins : Bin_Array; Bin_Size : Double_Integer;
   Index_A_Start : Double_Natural);

procedure Draw_Histogram (A_Data, B_Data : Setting_Time_Vector) is
   use Setting_Time_Package;
   use Double_Integer_Package;
   Routine_Name : constant String := "Histogram.Draw_Histogram ";
   --  Define histogram structure constants
   Bin_Size      : constant Double_Integer := 1000;
   Num_Bins      : constant Positive := 110;
   Index_A_Start : constant Double_Natural := A_Data.First_Index;
   Index_A_End   : Double_Natural := A_Data.Last_Index - 10000;

   Delta_Data    : Double_Integer_Vector;
   Curs_Delta    : Double_Integer_Package.Cursor := Delta_Data.First;
   Bins          : Bin_Array (1 .. Num_Bins) := (others => 0);
   Current_Value : Double_Integer;
   Bin_Index     : Positive;
   Index_B       : Double_Natural := B_Data.First_Index;
   Total_Records : Double_Natural := 0;

   function Find_Nearest (Index_A : Double_Natural;
                          Index_B : in out Double_Natural) return Double_Integer is
      A          : constant Double_Natural := A_Data (Index_A).Time;
      Delta_Time : Double_Integer;
      Result     : Double_Integer;
   begin
      if Index_B < B_Data.Last_Index then
         while Index_B < B_Data.Last_Index and then
            B_Data (Index_B).Time < A loop
            Delta_Time := Double_Integer (A) -
               Double_Integer (B_Data (Index_B).Time);
            if Index_B > 1 then
               if abs (Delta_Time) <
                  abs (Double_Integer (A - B_Data (Index_B - 1).Time)) then
                  Result := Delta_Time;
               else
                  Index_B := Index_B - 1;
                  Result := Double_Integer (A - B_Data (Index_B).Time);
               end if;
            else
               Result := Delta_Time;
            end if;

            Index_B := Index_B + 1;
         end loop;
      else
         Index_B := B_Data.Last_Index;
         Result := Double_Integer (B_Data.Last_Element.Time - A);
      end if;

      return Result;

   exception
      when Error : others =>
         Put_Line (Routine_Name & "Find_Nearest" &
          Exception_Information (Error));
      return Result;

   end Find_Nearest;

begin
   --  Histogram Delta_t = B (j) - A_(i)  for B (j) near A_(i)
   --  for index in A_Data.First_Index .. A_Data.Last_Index loop

   if Index_A_End > A_Data.Last_Index then
         Index_A_End := A_Data.Last_Index;
         Put_Line (Routine_Name &
           "WARNING: Index_A_End > A_Data.Last_Index," &
            " Index_A_End set to A_Data.Last_Index");
      end if;

   --  For each A, store shortest time difference between A time and B time
   for index in Index_A_Start .. Index_A_End loop
      --  Store shortest time difference between A time and B time
      Delta_Data.Append (Find_Nearest (index, Index_B));
   end loop;

   Print_Double_Integer_Vector (Routine_Name & "Delta: ", Delta_Data, 1, 10);

   Curs_Delta := Delta_Data.First;
   while Has_Element (Curs_Delta) loop
      Current_Value := Element  (Curs_Delta);
      Total_Records := Total_Records + 1;

      --  Calculate bin assignment for Current_Value
      Bin_Index := Positive ((Current_Value / Bin_Size) + 1);
      --  Bound checking for updating bins
      if Bin_Index < 1 then
         Bin_Index := 1;
      elsif Bin_Index > Num_Bins then
         Bin_Index := Num_Bins;
      end if;

      --  Incement value of assigned bin
      Bins (Bin_Index) := Bins (Bin_Index) + 1;
      Next  (Curs_Delta) ;
   end loop;

   Print_Histogram (Bins, Bin_Size, Index_A_Start);
   Put_Line (Routine_Name & "processed " &
      Double_Natural'Image (Total_Records) & " records");

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;

end Draw_Histogram;

procedure Print_Histogram (Bins : Bin_Array; Bin_Size : Double_Integer;
   Index_A_Start  : Double_Natural) is
   Routine_Name   : constant String := "Histogram.Print_Histogram ";
   Max_Bar_Length : constant Positive := 60;
   Start          : constant Double_Integer := Double_Integer (Index_A_Start);
   Bar_Length     : Natural;
   Lower_Bound    : Double_Integer;
   Upper_Bound    : Double_Integer;
begin
   Put_Line ("--- Data Distribution Histogram ---");
   Put_Line ("Bin size: " & Double_Integer'Image (Bin_Size));
   Put_Line ("       Bin Range   | Frequency | Bar Chart");
   Put_Line ("------------------------------------");

   for I in Bins'Range loop
      Lower_Bound := Start + Double_Integer (I - 1) * Bin_Size;
      Upper_Bound := Start + Double_Integer (I) * Bin_Size - 1;
      --  Print Bin range labels
      if I = Bins'Last then
         Put ("  " &
          Double_Integer'Image (Lower_Bound) & " and up | ");
      else
         Put ("  " &
          Double_Integer'Image (Lower_Bound) & " - " &
         Double_Integer'Image (Upper_Bound) & " | ");
      end if;

      --  Print total counts per interval
      Put (Integer'Image (Bins (I)) & "    | ");

      --  Render text bar (cap rendering at 50 max to prevent terminal clutter)
      Bar_Length := Bins (I);
      if Bar_Length > Max_Bar_Length then
         Bar_Length := Max_Bar_Length;
      end if;

         --  for J in 1 .. Bar_Length loop
         --     Put ("*");
         --  end loop;

         if Bins (I) > Max_Bar_Length then
            --  Indicate that the bar extends further
            Put ("+");
         end if;
         New_Line;
   end loop;

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;
   end Print_Histogram;

end Histogram;
