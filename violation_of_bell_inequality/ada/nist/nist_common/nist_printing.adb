
with Interfaces;

with Ada.Text_IO; use Ada.Text_IO;

with Types; use Types;

package body NIST_Printing is

   procedure Print_NIST_Data_List
    (Name  : String; Data : Nist_Data_List;
      Start : Positive := 1; Finish : Natural := 0) is
      use Nist_Data_Package;
      Start_Idx : constant Double_Positive := Double_Positive (Start);
      Last      : Double_Positive;
      Item      : Data_Record;
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
            Put ("Channel: " & Channel_Type'Image (Item.Channel));
            Put (",  Time_Tag: " & Double_Positive'Image (Item.Time_Tag));
            Put_Line (",  Transfer_ID: " & Integer'Image (Item.Transfer_ID));
         end loop;
      else
         Put_Line ("Print_NIST_Data_List called with invalid" &
          " start or finish index.");
      end if;
      New_Line;

   end Print_NIST_Data_List;

   procedure Print_NIST_Data_Record (Name : String; Item : Data_Record) is
   begin
      Put_Line (Name & ": ");
      Put ("Channel: " & Channel_Type'Image (Item.Channel));
      Put (",  Time_Tag: " & Double_Positive'Image (Item.Time_Tag));
      Put_Line (",  Transfer_ID: " & Integer'Image (Item.Transfer_ID));
      New_Line;

   end Print_NIST_Data_Record;

   procedure Print_NIST_Event_List (Name : String; Data : Nist_Event_List;
      Start : Positive := 1; Finish : Natural := 0) is
      use Interfaces;
      use Nist_Event_Package;
      Start_Idx : constant Double_Positive := Double_Positive (Start);
      Last      : Double_Positive;
      Item      : NIST_Event_Record;
   begin
      if Finish > 0 then
         if Finish <= Natural (Data.Length) then
            Last := Double_Positive (Finish);
         else
            Last := Double_Positive (Data.Length);
         end if;
      else
         Last := Double_Positive (Data.Length);
      end if;

      Put_Line (Name & ": ");
      if Start_Idx >= Data.First_Index and then
       Last <= Data.Last_Index then
         for Index in Start_Idx .. Last loop
            Item := Data (Index);
            Put ("A Click Mask: " & Unsigned_16'Image (Item.A_Click_Mask));
            --  Put (",  A_Setting: " & Channel_Type'Image (Item.A_Setting));
            Put (",  B Click Mask: " & Unsigned_16'Image (Item.B_Click_Mask));
            --  Put_Line (",  B_Setting: " & Channel_Type'Image (Item.B_Setting));
         New_Line;
         end loop;
      else
         Put_Line ("Print_NIST_Event_List called with invalid" &
          " start or finish index.");
      end if;
      New_Line;

   end Print_NIST_Event_List;

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
      Put_Line ("Time_Tag: " & Double_Positive'Image (Data.Time_Tag));
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