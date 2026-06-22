
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

with Printing; use Printing;

package body Histogram is

procedure Draw_Histogram (A_Data, B_Data : Setting_Time_Vector) is
   use Setting_Time_Package;
   use Double_Integer_Package;
   Routine_Name : constant String := "Histogram.Draw_Histogram ";
   --  Define histogram structure constants
   Bin_Size     : constant Double_Integer := 10000000;
   Num_Bins     : constant Double_Integer := 100;
   type Bin_Array is array (1 .. Num_Bins) of Integer;

   Delta_Data    : Double_Integer_Vector;
   Curs_Delta    : Double_Integer_Package.Cursor := Delta_Data.First;
   Bins          : Bin_Array := (others => 0);
   Current_Value : Double_Integer;
   Bin_Index     : Double_Integer;
   Index_B       : Double_Natural := B_Data.First_Index;
   Total_Records : Double_Natural := 0; -- Track size safely

   function Find_Nearest (Index_A : Double_Natural;
                        Index_B : in out Double_Natural) return Double_Integer is
      A      : constant Double_Natural := A_Data (Index_A).Time;
      Del    : Double_Integer;
      Result : Double_Integer;
   begin
      if Index_B < B_Data.Last_Index then
         while Index_B < B_Data.Last_Index and then
         B_Data (Index_B).Time < A loop
            del := Double_Integer (A) -
               Double_Integer (B_Data (Index_B).Time);
            if Index_B > 1 then
               if abs (del) <
                  abs (Double_Integer (A - B_Data (Index_B - 1).Time)) then
                  Result := del;
               else
                  Index_B := Index_B - 1;
                  Result := Double_Integer (A - B_Data (Index_B).Time);
               end if;
            else
               Result := del;
            end if;

            Index_B := Index_B + 1;
         end loop;
      else
         Index_B := B_Data.Last_Index;
         Result := Double_Integer (B_Data.Last_Element.Time - A);
      end if;

      return Result;

   end Find_Nearest;

begin
   Put_Line (Routine_Name);
   --  Histogram Delta_t = B (j) - A_(i)  for B (j) near A_(i)
   --  for i - width / 2 <= j <= i + width / 2
   for index in A_Data.First_Index .. A_Data.Last_Index loop
      Delta_Data.Append (Find_Nearest (index, Index_B));
   end loop;

   Print_Double_Integer_Vector (Routine_Name & "Delta: ", Delta_Data, 1, 10);

   Curs_Delta := Delta_Data.First;
   while Has_Element (Curs_Delta) loop
         --  Read one integer from the current line
         Current_Value := Element  (Curs_Delta);
         Total_Records := Total_Records + 1;

         --  Calculate bin assignment
         Bin_Index := (Current_Value / Bin_Size) + 1;

         --  Bound checking for safely updating bins
         if Bin_Index < 1 then
            Bin_Index := 1;
         elsif Bin_Index > Num_Bins then
            Bin_Index := Num_Bins;
         end if;

         Bins (Bin_Index) := Bins (Bin_Index) + 1;
         Next  (Curs_Delta) ;
   end loop;

   Put_Line ("--- Data Distribution Histogram ---");
   Put_Line ("Bin Range  | Frequency  | Bar Chart");
   Put_Line ("------------------------------------");

   for I in Bins'Range loop
      declare
         Lower_Bound : constant Double_Integer := (I - 1) * Bin_Size;
         Upper_Bound : constant Double_Integer := (I * Bin_Size) - 1;
      begin
         --  Print Bin range labels cleanly
         if I = Num_Bins then
            Put ("  " & Double_Integer'Image (Lower_Bound) & " and up | ");
         else
            Put ("  " & Double_Integer'Image (Lower_Bound) & " - " &
            Double_Integer'Image (Upper_Bound) & " | ");
         end if;

         --  Print total counts per interval
         Put (Integer'Image (Bins (I)) & "    | ");

         --  Render text bar safely (cap rendering at 50 max to prevent terminal clutter)
         declare
            Bar_Length : Integer := Bins (I);
         begin
            if Bar_Length > 50 then
               Bar_Length := 50;
            end if;

            for J in 1 .. Bar_Length loop
               Put ("*");
            end loop;

            if Bins (I) > 50 then
               Put ("+"); -- Indicate that the bar extends further
            end if;
         end;
         New_Line;
      end;
   end loop;

   Put_Line (Routine_Name & "processed " &
    Double_Natural'Image (Total_Records) & " records");

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));
         return;

end Draw_Histogram;

end Histogram;
