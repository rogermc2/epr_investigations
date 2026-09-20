
with Interfaces;

with Ada.Text_IO; use Ada.Text_IO;

with Types; use Types;

package body NIST_Printing is

   procedure Find_Clicks (Message : String; Data : Nist_Data_List;
   Number : Positive := 5) is
      use Nist_Data_Package;
      Item    : Data_Record;
      Curs    : Cursor := Data.First;
      Rec_Num : Natural := 0;
      Count   : Natural := 0;
   begin
      Put_Line (Message);
      while Has_Element (Curs) loop
         Item := Element  (Curs);
         Rec_Num := Rec_Num + 1;
         if Count <= Number and then Item.Channel = Click then
            Count := Count + 1;
            Print_NIST_Data_Record (Natural'Image (Rec_Num), Item);
         end if;
         Next (Curs);
      end loop;

      if Count = 0 then
         Put_Line ("No clicks found.");
      end if;

   end Find_Clicks;

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
      if Integer (Data.Length) > 0 then
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
         Last <= Double_Positive (Data.Last_Index) then
            for Index in Start_Idx .. Last loop
               Item := Data (Index);
               Put (Double_Positive'Image (Index) & " ");
               Put (" A Click Mask:" & Unsigned_16'Image (Item.A_Click_Mask));
               Put (",  A_Setting: " & Channel_Type'Image (Item.A_Setting));
               Put (";  B Click Mask:" & Unsigned_16'Image (Item.B_Click_Mask));
               Put_Line (",  B_Setting: " & Channel_Type'Image (Item.B_Setting));
            end loop;
         else
            Put_Line ("Print_NIST_Event_List called with invalid" &
            " start or finish index.");
         end if;
      else
         Put_Line (Name & " Event_List is empty");
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