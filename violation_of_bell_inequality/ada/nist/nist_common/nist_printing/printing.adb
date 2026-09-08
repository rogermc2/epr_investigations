
with Ada.Text_IO; use Ada.Text_IO;

package  body Printing is

   procedure Print_Raw_Data (Raw_Data : Raw_Data_Record) is
   begin
      Put_Line ("Raw Data:");
      Put_Line ("Channel: " & Unsigned_Byte'Image (Raw_Data.Channel));
      Put_Line ("Time_Tag: " & Unsigned_8_Byte'Image (Raw_Data.Time_Tag));
      Put_Line ("Transfer_ID: " & Unsigned_2_Byte'Image (Raw_Data.Transfer_ID));
      New_Line;
   end Print_Raw_Data;

   procedure Print_Processed_Data (Data : Data_Record) is
   begin
      Put_Line ("Processed Data:");
      Put_Line ("Channel: " & Channel_Type'Image (Data.Channel));
      Put_Line ("Time_Tag: " & Unsigned_8_Byte'Image (Data.Time_Tag));
      Put_Line ("Transfer_ID: " & Integer'Image (Data.Transfer_ID));
      New_Line;
   end Print_Processed_Data;
   
end Printing;