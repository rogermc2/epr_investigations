
with Ada.Text_IO; use Ada.Text_IO;

with Delft_Utils; use Delft_Utils;
with Maths;
with Printing; use Printing;

package body Delft_Printing is

   procedure Print_Delft_Data_List (Name : String; Data : Delft_Data_List;
                               Start : Positive := 1; Finish : Natural := 0) is
      Item  : Raw_Result_Record;
      Last  : Natural;
      Line  : Natural := 0;
   begin
      if Finish > 0 and then Finish <= Natural (Data.Last_index) then
         Last := Finish;
      else
         Last := Natural (Data.Last_index);
      end if;

      Put_Line (Name & ": ");
      Put_Line ("Line A Set B Set  A Result B Result");
      if Start >= Data.First_Index and then Last <= Data.Last_index then
         for Index in Start .. Last loop
            Item := Data (Index);
            Line := Line + 1;
            Put_Line (Natural'Image (Line) &
               ":   " & Long_Float'Image (Item.A_Setting) &
               "    " & Long_Float'Image (Item.B_Setting) &
               "       " & Integer'Image (Item.A_Outcome) &
               "      " & Integer'Image (Item.B_Outcome));
         end loop;
      else
         Put_Line
           ("Print_Delft_Data_List called with invalid start or finish index.");
         Put_Line ("Start: " & Integer'Image (Start) & ",  Finish: " &
                   Integer'Image (Finish));
         Put_Line ("Data.First_Index: " & Integer'Image (Data.First_Index) &
                   ",  Data.Last_index: " & Integer'Image (Data.Last_index));
      end if;
      New_Line;

   end Print_Delft_Data_List;

   procedure Print_Delft_Sample_List (Name : String; Data : Delft_Sample_Data_List;
                               Start : Positive := 1; Finish : Natural := 0) is
      Item  : Delft_Sample_Data_Record;
      Last  : Natural;
   begin
      if Finish > 0 and then Finish <= Natural (Data.Last_index) then
         Last := Finish;
      else
         Last := Natural (Data.Last_index);
      end if;

      Put_Line (Name & ": ");
      Put_Line (" A   B  AB");
      if Start >= Data.First_Index and then Last <= Data.Last_index then
         for Index in Start .. Last loop
            Item := Data (Index);
            Put_Line (UV'Image (Item.A_Detection) & "  " &
               UV'Image (Item.B_Detection) & "  " & UV'Image (Item.AB));
         end loop;
      else
         Put_Line
           ("Print_Delft_Sample_List called with invalid start or finish index.");
         Put_Line ("Start: " & Integer'Image (Start) & ",  Finish: " &
                   Integer'Image (Finish));
         Put_Line ("Data.First_Index: " & Integer'Image (Data.First_Index) &
                   ",  Data.Last_index: " & Integer'Image (Data.Last_index));
      end if;
      New_Line;

   end Print_Delft_Sample_List;

   procedure Print_Delft_Statistics
     (Message : String; Mean_A, Mean_B, Mean_AB : Float;
      Detections : Delft_Sample_Data_List; Det_A, Det_B : Detect_Type) is
      use Maths;
   begin
      Put_Line (Message & ": ");
      Print_Float_2 (" Sample_Mean A", Mean_A, " Sample SD A",
       Sample_Std_Deviation (Get_Delft_Integer_List (Detections, Det_A), Mean_A));
      Print_Float_2 (" Sample_Mean B", Mean_B, " Sample SD B",
       Sample_Std_Deviation (Get_Delft_Integer_List (Detections, Det_B), Mean_B));
      Print_Float_2 (" Sample_Mean AB", Mean_AB, " Sample SD AB",
       Sample_Std_Deviation (Get_Delft_Integer_List (Detections, Det_A), Mean_AB));

   end Print_Delft_Statistics;

end Delft_Printing;