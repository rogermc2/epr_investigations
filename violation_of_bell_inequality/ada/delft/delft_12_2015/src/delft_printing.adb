
with Ada.Text_IO; use Ada.Text_IO;

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
      Put_Line ("Line A Set   B Set  A Result   B Result");
      if Start >= Data.First_Index and then Last <= Data.Last_index then
         for Index in Start .. Last loop
            Item := Data (Index);
            Line := Line + 1;
            Put_Line (Natural'Image (Line) &
               ":   " & Integer'Image (Item.A_Setting) &
               "      " & Integer'Image (Item.B_Setting) &
               "   " & Integer'Image (Item.A_Result) &
               "   " & Integer'Image (Item.B_Result));
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

end Delft_Printing;