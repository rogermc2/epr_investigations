
--  with Ada.Assertions; use Ada.Assertions;
--  with Ada.Text_IO; use Ada.Text_IO;

--  with NIST_Printing; use NIST_Printing;
--  with Printing; use Printing;
--  with Ada.Text_IO;
with Types; use Types;

package body  NIST_Utilities is

   procedure Align_Data
    (A_Data, B_Data: in out Nist_Data_List) is
      use Nist_Data_Package;
      --  Routine_Name : constant String := "NIST_Utilities.Align_Data ";
      AgtB         : constant Boolean := A_Data.First_Element.Time_Tag >
                        B_Data.First_Element.Time_Tag;
      Delta_Time   : Double_Positive;
      A_Offset     : Double_Natural;
      B_Offset     : Double_Natural;

      procedure Apply_Delta_Time
       (Data : in out Nist_Data_List; Delta_Time : Double_Positive) is
         Curs :  Nist_Data_Package.Cursor := Data.First;
         Item : Data_Record;
      begin
         while Has_Element (Curs) loop
            Item := Element (Curs);
            --  Ada.Text_IO.Put_Line ("Apply_Delta_Time Item.Time_Tag, Delta_Time" &
            --  Double_Positive'Image (Item.Time_Tag) & ", " & Double_Positive'Image (Delta_Time));
            if Delta_Time > Item.Time_Tag then
               Item.Time_Tag := Item.Time_Tag - Delta_Time;
               Data.Replace_Element (Curs, Item);
            end if;
            Next (Curs);
         end loop;

      end Apply_Delta_Time;

      procedure Apply_Offset (Data : in out Nist_Data_List;
       Offset : Double_Natural) is
         --  use Nist_Data_Package;
         Curs : Cursor := Data.First;
         Item : Data_Record;
      begin
         while Has_Element (Curs) loop
            Item := Element (Curs);
            if Item.Time_Tag > Double_Positive (Offset) then
               Item.Time_Tag := Item.Time_Tag - Double_Positive (Offset);
               Data.Replace_Element (Curs, Item);
            end if;
            Next (Curs);
         end loop;

      end Apply_Offset;

      function Min_Time (A_Time, B_Time : Double_Positive)
       return Double_Positive is
         Min : Double_Positive := A_Time;
       begin
         if B_Time < Min then
            Min := A_Time;
         end if;

         return Min;

      end Min_Time;

   begin
      --  Assert (A_Data.First_Element.Time_Tag > 0,
      --  "A_Data.First_Element.Time_Tag invalid: " &
      --  Double_Positive'Image (A_Data.First_Element.Time_Tag));
      Delta_Time := Min_Time (A_Data.First_Element.Time_Tag,
       B_Data.First_Element.Time_Tag);
      if Delta_Time > 1 then
         Delta_Time := Delta_Time - 1;
      end if;
      --  Put_Line (Routine_Name & "Delta_Time: " &
      --              Double_Natural'Image (Delta_Time));
      --  Adjust A and B times to start at the same time
      if AgtB then
         Apply_Delta_Time (A_Data, Delta_Time);
      else
         Apply_Delta_Time (B_Data, Delta_Time);
      end if;

      --  Print_Double_Natural_Vector ("Align_Data A_Sync_Data after delta", A_Sync_Data, 1, 1);
      --  Print_Double_Natural_Vector ("Align_Data B_Sync_Data", B_Sync_Data, 1, 1);
      --  Print_Setting_Time_Vector ("Align_Data A_Det_Data", A_Det_Data, 1, 1);
      --  Print_Setting_Time_Vector ("Align_Data B_Det_Data", B_Det_Data, 1, 1);

      A_Offset := Double_Natural (A_Data.First_Element.Time_Tag) - 1;
      B_Offset := Double_Natural (B_Data.First_Element.Time_Tag) - 1;

      --  Adjust A and B times to both start at 0.
      Apply_Offset (A_Data, A_Offset);
      Apply_Offset (B_Data, B_Offset);

      --  Put_Line ("A_Offset:" & Double_Natural'Image (A_Offset));
      --  Print_Double_Natural_Vector ("Align_Sync_Data A_Data", A_Sync_Data, 1, 1);
      --  Print_Double_Natural_Vector ("Align_Sync_Data B_Data", B_Sync_Data, 1, 1);
      --  New_Line;
      --  Print_Setting_Time_Vector ("Align_Det_Data A_Data", A_Det_Data, 1, 1);
      --  Print_Setting_Time_Vector ("Align_Det_Data B_Data", B_Det_Data, 1, 1);

   end Align_Data;

end NIST_Utilities;