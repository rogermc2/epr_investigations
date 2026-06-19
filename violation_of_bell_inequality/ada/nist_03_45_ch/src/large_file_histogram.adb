with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.IO_Exceptions;

package body Large_File_Histogram is

procedure Make_Histogram is

   -- Define histogram structure constants
   Bin_Size : constant Integer := 10;
   Num_Bins : constant Integer := 5;
   
   type Bin_Array is array (1 .. Num_Bins) of Integer;
   Bins : Bin_Array := (others => 0);
   
   -- File variables
   File_Name : constant String := "large_data.txt";
   Input_File : File_Type;
   
   Current_Value : Integer;
   Bin_Index     : Integer;
   Total_Records : Long_Integer := 0; -- Track size safely

begin
   -- 1. Open the file for sequential reading
      Open (File => Input_File, Mode => In_File, Name => File_Name);
   
   -- 2. Stream data line-by-line to save memory
   while not End_Of_File (Input_File) loop
      begin
         -- Read one integer from the current line
         Get (Input_File, Current_Value);
         Total_Records := Total_Records + 1;
         
         -- Calculate bin assignment
         Bin_Index := (Current_Value / Bin_Size) + 1;
         
         -- Bound checking for safely updating bins
         if Bin_Index < 1 then
            Bin_Index := 1;
         elsif Bin_Index > Num_Bins then
            Bin_Index := Num_Bins;
         end if;
         
         -- Increment the bin counter directly
         Bins (Bin_Index) := Bins (Bin_Index) + 1;
         
      exception
         -- Skip lines with malformed data or blank spaces safely
         when Data_Error | End_Error =>
            Skip_Line (Input_File);
      end;
   end loop;

   Close (Input_File);

   Put_Line ("Processed total records: " & Long_Integer'Image (Total_Records));
   Put_Line ("--- Data Distribution Histogram ---");
   Put_Line ("Bin Range  | Frequency  | Bar Chart");
   Put_Line ("------------------------------------");
   
   for I in Bins'Range loop
      declare
         Lower_Bound : Integer := (I - 1) * Bin_Size;
         Upper_Bound : Integer := (I * Bin_Size) - 1;
      begin
         -- Print Bin range labels cleanly
         if I = Num_Bins then
            Put ("  " & Integer'Image (Lower_Bound) & " and up | ");
         else
            Put ("  " & Integer'Image (Lower_Bound) & " - " & Integer'Image (Upper_Bound) & " | ");
         end if;
         
         -- Print total counts per interval
         Put (Integer'Image (Bins (I)) & "    | ");
         
         -- Render text bar safely (cap rendering at 50 max to prevent terminal clutter)
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
      when Name_Error =>
         Put_Line ("Error: The file '" & File_Name & "' was not found.");
         return;

end Make_Histogram;

end Large_File_Histogram;
