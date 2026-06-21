with Ada.Text_IO; use Ada.Text_IO;
--  with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

--  with Ada.IO_Exceptions;

package body Histogram is

procedure Draw_Histogram (A_Data, B_Data : Setting_Time_Vector) is
   use Setting_Time_Package;
   use Long_Integer_Package;
   --  Define histogram structure constants
   Bin_Size   : constant Long_Integer := 10000000;
   Num_Bins   : constant Long_Integer := 100;
   type Bin_Array is array (1 .. Num_Bins) of Integer;

   Curs_A     : Setting_Time_Package.Cursor := A_Data.First;
   Curs_B     : Setting_Time_Package.Cursor := B_Data.First;
   Delta_Data : long_integer_vector;
   Curs_Delta : Long_Integer_Package.Cursor := Delta_Data.First;
    --  Store time differences safely
   Bins : Bin_Array := (others => 0);
   --  File_Name : constant String := "large_data.txt";
   --  Input_File : File_Type;
   Current_Value : Long_Integer;
   Bin_Index     : Long_Integer;
   Total_Records : Long_Integer := 0; -- Track size safely
begin
   --  1. Open the file for sequential reading
   --  Open (File => Input_File, Mode => In_File, Name => File_Name);
   while Has_Element (Curs_A) and Has_Element (Curs_B) loop
      Delta_Data.Append (Long_Integer (Element (Curs_A).Time - Element (Curs_B).Time));
      Next (Curs_A);
      Next (Curs_B);
   end loop;

   --  2. Stream data line-by-line to save memory
   --  while not End_Of_File (Input_File) loop
   while Has_Element (Curs_Delta) loop
      begin
         --  Read one integer from the current line
         --  Get (Input_File, Current_Value);
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

         --  Increment the bin counter directly
         Bins (Bin_Index) := Bins (Bin_Index) + 1;
         Next  (Curs_Delta) ;

      --  exception
         --  Skip lines with malformed data or blank spaces safely
         --  when Data_Error | End_Error =>
         --     Skip_Line (Input_File);
      end;
   end loop;

   --  Close (Input_File);

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
               Put ("+"); -- Indicator that the bar extends further
            end if;
         end;
         New_Line;
      end;
   end loop;

   exception
      when others =>
         Put_Line ("Draw_Histogram error");
         return;

end Draw_Histogram;

end Histogram;
