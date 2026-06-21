
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

with Printing; use Printing;

package body Histogram is

procedure Draw_Histogram (A_Data, B_Data : Setting_Time_Vector; Width : Natural) is
   use Setting_Time_Package;
   use Double_Integer_Package;
   Routine_Name : constant String := "Histogram.Draw_Histogram ";
   H_Width      : constant Double_Natural := Double_Natural (Width / 2);
   --  Define histogram structure constants
   Bin_Size     : constant Double_Integer := 10000000;
   Num_Bins     : constant Double_Integer := 100;
   type Bin_Array is array (1 .. Num_Bins) of Integer;

   Curs_A        : Setting_Time_Package.Cursor := A_Data.First;
   Curs_B        : Setting_Time_Package.Cursor := B_Data.First;
   Delta_Data    : Double_Integer_Vector;
   Curs_Delta    : Double_Integer_Package.Cursor := Delta_Data.First;
    --  Store time differences safely
   Bins          : Bin_Array := (others => 0);
   Current_Value : Double_Integer;
   Bin_Index     : Double_Integer;
   --  Index_A       : Double_Natural;
   Total_Records : Double_Natural := 0; -- Track size safely
begin
   --  Histogram Delta_t = B (j) - A_(i)  for B (j) near A_(i)
   --  for i - width / 2 <= j <= i + width / 2
   --  Put_Line ( "First A and B: " & Double_Natural'Image (Element (Curs_A).Time) &
   --           ",  " & Double_Natural'Image (Element (Curs_B).Time));
   --  Index_A := Double_Natural (A_Data.First_Index) + H_Width;
   --  Curs_B := B_Data.First;
   --  while Has_Element (Curs_A) loop
   for I in Double_Natural (A_Data.First_Index) + H_Width ..
                Double_Natural (A_Data.Last_Index) - H_Width loop
      null;
      --  Delta_Data.Append
      --     (Long_Integer (Element (Curs_A).Time - Element (Curs_B).Time));
      --  Next (Curs_A);
      --  Next (Curs_B);
   end loop;

   --  while Has_Element (Curs_A) and then Has_Element (Curs_B) loop
   --     Delta_Data.Append
   --        (Long_Integer (Element (Curs_A).Time - Element (Curs_B).Time));
   --     Next (Curs_A);
   --     Next (Curs_B);
   --  end loop;

   Print_Double_Integer_Vector (Routine_Name & "Delta: ", Delta_Data, 1, 10);

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
          Double_Natural'Image (Total_Records));
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

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));
         return;

end Draw_Histogram;

end Histogram;
