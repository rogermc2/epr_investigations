
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

package body Histogram is

   type Bin_Array is array (Positive range <>) of Integer;

procedure Print_Histogram (Bins : Bin_Array; Bin_Size : Double_Integer);

procedure Draw_Histogram (A_Data, B_Data : Setting_Time_Vector) is
   use Setting_Time_Package;
   use Double_Natural_Package;
   Routine_Name : constant String := "Histogram.Draw_Histogram ";
   --  Define histogram structure constants
   Bin_Size      : constant Double_Integer := 1;
   Num_Bins      : constant Positive := 30;
   Index_B       : Double_Positive := B_Data.First_Index;
   Delta_Data    : Double_Natural_Vector;
   Curs_Delta    : Double_Natural_Package.Cursor := Delta_Data.First;
   Bins          : Bin_Array (1 .. Num_Bins) := (others => 0);
   Bin_Index     : Positive;
   Current_Value : Double_Natural;
   Total_Records : Double_Natural := 0;
   --  Count         : Natural := 0;

   function Find_Nearest
       (Index_A : Double_Positive; Index_B : in out Double_Positive)
        return Double_Natural is
      A_Time     : constant Double_Natural := A_Data (Index_A).Time;
      B_Time     : Double_Natural;
      Delta_Time : Double_Integer := 0;
   begin
      --  Count := Count + 1;

      if Index_B < B_Data.Last_Index then
         --  Skip Index_B until B_Data (Index_B).Time >= A_Time
         while Index_B < B_Data.Last_Index and then
            B_Data (Index_B).Time < A_Time loop
            Index_B := Index_B + 1;
         end loop;

         if Index_B > 1 then
            Index_B := Index_B - 1;
         end if;

         --  B_Data (Index_B).Time < A_Time
         B_Time := B_Data (Index_B).Time;
         Delta_Time := Double_Integer (A_Time - B_Time);

         if Index_B > 1 and then abs (Delta_Time) >
            abs (Double_Integer (A_Time - B_Data (Index_B + 1).Time)) then
            Index_B := Index_B + 1;
            B_Time := B_Data (Index_B).Time;
            Delta_Time := Double_Integer (B_Time - A_Time);
            end if;

      else  --  Index_B = B_Data.Last_Index
        Delta_Time := Double_Integer (A_Time - B_Data (Index_B).Time);
      end if;

      return Double_Natural (abs (Delta_Time));

   exception
      when Error : others =>
         Put_Line (Routine_Name & "Find_Nearest" &
          Exception_Information (Error));
      return Double_Natural (abs (Delta_Time));

   end Find_Nearest;

begin
   --  Histogram Delta_t = B (j) - A_(i)  for B (j) near A_(i)
   --  For each A, store shortest time difference between A time and B time
   for Index_A in A_Data.First_Index .. A_Data.Last_Index loop
      --  Store shortest time difference between A time and B time
      Delta_Data.Append (Find_Nearest (Index_A, Index_B));
   end loop;

   --  Print_Double_Natural_Vector (Routine_Name & "Delta: ", Delta_Data, 1, 10);

   Curs_Delta := Delta_Data.First;
   while Has_Element (Curs_Delta) loop
      Current_Value := Element  (Curs_Delta);
      Total_Records := Total_Records + 1;

      Bin_Index := Positive ((Current_Value / Double_Natural (Bin_Size)) + 1);
      --  Bound checking for updating bins
      if Bin_Index < 1 then
         Bin_Index := 1;
      elsif Bin_Index > Num_Bins then
         Bin_Index := Num_Bins;
      end if;

      --  Increment value of assigned bin
      Bins (Bin_Index) := Bins (Bin_Index) + 1;
      Next  (Curs_Delta) ;
   end loop;

   Print_Histogram (Bins, Bin_Size);
   Put_Line (Routine_Name & "processed " &
      Double_Natural'Image (Total_Records) & " records");

   exception
      when Error : others =>
         New_Line;
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;

end Draw_Histogram;

procedure Print_Histogram (Bins : Bin_Array; Bin_Size : Double_Integer) is
   Routine_Name   : constant String := "Histogram.Print_Histogram ";
   Max_Bar_Length : constant Positive := 30000;
   Bar_Length     : Natural;
   Lower_Bound    : Double_Integer;
   Upper_Bound    : Double_Integer;
begin
   Put_Line ("--- Data Distribution Histogram ---");
   Put_Line ("Bin size: " & Double_Integer'Image (Bin_Size));
   Put_Line ("  Bin Range (dt)   | Frequency | Bar Chart");
   Put_Line ("------------------------------------");

   for I in Bins'Range loop
      Lower_Bound := Double_Integer (I - 1) * Bin_Size;
      Upper_Bound := Double_Integer (I) * Bin_Size - 1;
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
