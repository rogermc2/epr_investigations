
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Strings;
with Ada.Strings.Fixed;
with Ada.Text_IO; use Ada.Text_IO;
with Printing;

package body Histogram is

type Bin_Array is array (Positive range <>) of Integer;

--  The second channel number is the 8-byte integer raw timetag.
--  Each timetag bin corresponds to 78.125 ps.
--  The absolute timestamps at alice and bob are different because
--  they were started at different times but they are counting at
--  the same rate and are synchronized by the 10MHz external reference.
procedure Print_Histogram (Bins : Bin_Array; Bin_Size : Double_Positive);
procedure Save_Data (Data_File : String; Data : Double_Natural_Vector);

function Draw_Histogram (A_Data, B_Data : Double_Natural_Vector)
      return Double_Natural is
   use Double_Natural_Package;
   Routine_Name : constant String := "Histogram.Draw_Histogram ";
   --  Define histogram structure constants
   Bin_Size       : constant Double_Positive := 10;
   Num_Bins       : constant Positive := 100;
   Index_B        : Double_Positive := B_Data.First_Index;
   Delta_Data     : Double_Natural_Vector;
   Curs_Delta     : Double_Natural_Package.Cursor := Delta_Data.First;
   Bins           : Bin_Array (1 .. Num_Bins) := (others => 0);
   Bin_Index      : Positive;
   Current_Value  : Double_Natural;
   Total_Records  : Double_Natural := 0;
   Max_Frequency  : Double_Natural := 0;
   Max_Freq_Index : Positive;
   Nearest        : Double_Natural;
   Best_Delta     : Double_Natural := 0;

   function Find_Nearest
       (Index_A : Double_Positive; Index_B : in out Double_Positive)
        return Double_Natural is
      A_Time      : constant Double_Natural := A_Data (Index_A);
      Pos_Index_B : Double_Positive := Index_B;
      B_Time      : Double_Natural;
      Delta_Time  : Double_Integer := 0;
   begin
      if Pos_Index_B < B_Data.Last_Index then
         --  Skip Index_B until B_Data (Index_B).Time >= A_Time
         while Pos_Index_B < B_Data.Last_Index and then
            B_Data (Pos_Index_B) < A_Time loop
            Pos_Index_B := Pos_Index_B + 1;
         end loop;

         if Pos_Index_B > 1 then
            Pos_Index_B := Pos_Index_B - 1;
         end if;

         --  B_Data (Index_B).Time < A_Time
         B_Time := B_Data (Pos_Index_B);
         Delta_Time := Double_Integer (A_Time - B_Time);

         if Pos_Index_B > 1 and then abs (Delta_Time) >
            abs (Double_Integer (A_Time - B_Data (Pos_Index_B + 1))) then
            Pos_Index_B := Pos_Index_B + 1;
            B_Time := B_Data (Pos_Index_B);
            Delta_Time := Double_Integer (B_Time - A_Time);
            end if;

      else  --  Index_B = B_Data.Last_Index
        Delta_Time := Double_Integer (A_Time - B_Data (Pos_Index_B));
      end if;

      Index_B := Double_Positive (Pos_Index_B);

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
      Nearest :=
       Find_Nearest (Double_Positive (Index_A), Double_Positive (Index_B));
      Delta_Data.Append (Nearest);
   end loop;
   --  Printing.Print_Double_Natural_Vector ("Delta_Data", Delta_Data, 1, 10);

   Curs_Delta := Delta_Data.First;
   while Has_Element (Curs_Delta) loop
      Current_Value := Element  (Curs_Delta);
      Total_Records := Total_Records + 1;
      --  Put_Line (Routine_Name & "Current_Value " &
      --     Double_Natural'Image (Current_Value));

      Bin_Index := Positive (Double_Positive (Delta_Data.Length) / Bin_Size + 1);
      --  Bound checking for updating bins
      if Bin_Index < 1 then
         Bin_Index := 1;
      elsif Bin_Index > Num_Bins then
         Bin_Index := Num_Bins;
      end if;

      --  Increment value of assigned bin
      Bins (Bin_Index) := Bins (Bin_Index) + 1;
      if Double_Natural (Bins (Bin_Index)) > Max_Frequency then
         Max_Freq_Index := Bin_Index;
         Max_Frequency := Double_Natural (Bins (Bin_Index));
      end if;
      Next  (Curs_Delta);
   end loop;

   Print_Histogram (Bins, Bin_Size);

   Best_Delta :=
      Double_Natural (Bins (Max_Freq_Index)) * Double_Natural (Bin_Size);
   Put_Line (Routine_Name & "best delta = " & Double_Natural'Image (Best_Delta) &
      " ps, frequency = " & Double_Natural'Image (Max_Frequency));
   Put_Line (Routine_Name & "processed " &
      Double_Natural'Image (Total_Records) & " records");

   --  Save_Data ("histogram.txt", Delta_Data);

   return Best_Delta;

   exception
      when Error : others =>
         New_Line;
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;

end Draw_Histogram;

procedure Print_Histogram (Bins : Bin_Array; Bin_Size : Double_Positive) is
   Routine_Name   : constant String := "Histogram.Print_Histogram ";
   Max_Bar_Length : constant Positive := 30000;
   Bar_Length     : Natural;
   Lower_Bound    : Double_Positive := 1;
   Upper_Bound    : Double_Positive;
begin
   Put_Line ("--- Data Distribution Histogram ---");
   Put_Line ("Bin size: " & Double_Positive'Image (Bin_Size));
   Put_Line ("Bin Range (dt) | Frequency | Bar Chart");
   Put_Line ("------------------------------------");

   for I in Bins'Range loop
      if I > 1 then
         Lower_Bound := Double_Positive (I - 1) * Bin_Size;
      end if;
      Upper_Bound := Double_Positive (I) * Bin_Size - 1;
      --  Print Bin range labels
      if I = Bins'Last then
         Put ("  " &
          Double_Positive'Image (Lower_Bound) & " and up | ");
      else
         Put ("  " &
          Double_Positive'Image (Lower_Bound) & " - " &
         Double_Positive'Image (Upper_Bound) & "     | ");
      end if;

      --  Print total counts per interval (frequency)
      Put (Integer'Image (Bins (I)) & "    | ");
      Bar_Length := Bins (I);
      if Bar_Length > Max_Bar_Length then
         Bar_Length := Max_Bar_Length;
      end if;

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

   procedure Save_Data (Data_File : String; Data : Double_Natural_Vector) is
   use Ada.Strings;
   use Ada.Strings.Fixed;
      use Double_Natural_Package;
      Routine_Name : constant String := "Histogram.Save_Data ";
      Curs         : Cursor := Data.First;
      Out_ID       : File_Type;
   begin
      Create (Out_ID, Out_File, Data_File);

      while Has_Element (Curs) loop
         Put_Line (Out_ID, Trim (Double_Natural'Image (Element (Curs)), Both));
         Next (Curs);
      end loop;

      Close (Out_ID);
      Put_Line (Routine_Name & "Data file written to " & Data_File);

   end Save_Data;

end Histogram;
