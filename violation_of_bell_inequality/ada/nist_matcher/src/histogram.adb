
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

with Printing; use Printing;

package body Histogram is

procedure Draw_Histogram (A_Data, B_Data : Setting_Time_Vector) is
   use Setting_Time_Package;
   use Long_Integer_Package;
   Routine_Name : constant String := "Histogram.Draw_Histogram ";
   --  Define histogram structure constants
   Bin_Size   : constant Long_Integer := 10000000;
   Num_Bins   : constant Long_Integer := 100;
   type Bin_Array is array (1 .. Num_Bins) of Integer;

   Curs_A     : Setting_Time_Package.Cursor := A_Data.First;
   Curs_B     : Setting_Time_Package.Cursor := B_Data.First;
   Delta_Data : Long_Integer_Vector;
   Curs_Delta : Long_Integer_Package.Cursor := Delta_Data.First;
    --  Store time differences safely
   Bins : Bin_Array := (others => 0);
   Current_Value : Long_Integer;
   Bin_Index     : Long_Integer;
   Total_Records : Long_Integer := 0; -- Track size safely
begin
   --  Put_Line (Routine_Name);
   --  Put_Line ( "First A and B: " & Double_Natural'Image (Element (Curs_A).Time) &
   --           ",  " & Double_Natural'Image (Element (Curs_B).Time));
   Curs_A := A_Data.First;
   Curs_B := B_Data.First;
   while Has_Element (Curs_A) and then Has_Element (Curs_B) loop
      Delta_Data.Append
         (Long_Integer (Element (Curs_A).Time - Element (Curs_B).Time));
      Next (Curs_A);
      Next (Curs_B);
   end loop;

   Print_Long_Integer_Vector (Routine_Name & "Delta: ", Delta_Data, 1, 10);

   while Has_Element (Curs_Delta) loop
      begin
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
      end;
   end loop;

   Put_Line ("Processed total records: " &
          Long_Integer'Image (Total_Records));
   Put_Line ("--- Data Distribution Histogram ---");
   Put_Line ("Bin Range  | Frequency  | Bar Chart");
   Put_Line ("------------------------------------");

   for I in Bins'Range loop
      declare
         Lower_Bound : constant Long_Integer := (I - 1) * Bin_Size;
         Upper_Bound : constant Long_Integer := (I * Bin_Size) - 1;
      begin
         --  Print Bin range labels cleanly
         if I = Num_Bins then
            Put ("  " & Long_Integer'Image (Lower_Bound) & " and up | ");
         else
            Put ("  " & Long_Integer'Image (Lower_Bound) & " - " &
            Long_Integer'Image (Upper_Bound) & " | ");
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

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));
         return;

end Draw_Histogram;

end Histogram;
