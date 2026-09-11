
with Ada.Text_IO; use Ada.Text_IO;

with Types; use Types;

package body NIST_Printing is

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

   procedure Print_Setting_Time_Vector
     (Name  : String; Data : Setting_Time_Vector;
      Start : Positive := 1; Finish : Natural := 0) is
      use Setting_Time_Package;
      Start_Idx : constant Double_Positive := Double_Positive (Start);
      Last      : Double_Positive;
      Item      : Setting_Time_Record;
   begin
      if Finish > 0 then
         Last := Double_Positive (Finish);
      else
         Last := Double_Positive (Data.Length);
      end if;

      Put_Line (Name & ": ");
      if Start_Idx >= Data.First_Index and then
       Last <= Data.Last_Index then
         for Index in Start_Idx .. Last loop
            Item := Data (Index);
            Put_Line ("Time: " & Double_Natural'Image (Item.Time));
            Put_Line ("Channel: " & Channel_Type'Image (Item.Setting));
         end loop;
      else
         Put_Line ("Print_Setting_Time_Vector called with invalid" &
          " start or finish index.");
      end if;
      New_Line;
   end Print_Setting_Time_Vector;

end NIST_Printing;