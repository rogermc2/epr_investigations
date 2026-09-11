
with Ada.Text_IO; use Ada.Text_IO;

with NIST_Printing; use NIST_Printing;
with Types; use Types;

package body  NIST_Utilities is

   procedure Align_Data
    (A_Sync_Data, B_Sync_Data, A_Det_Data, B_Det_Data : in out Setting_Time_Vector) is
      use Setting_Time_Package;
      Routine_Name : constant String := "NIST_Utilities.Align_Sync_Data ";
      Delta_Time   : Double_Natural;
      Offset       : Double_Natural;

      procedure Apply_Delta_Time (Data : in out Setting_Time_Vector;
       Delta_Time : Double_Natural) is
         Curs : Cursor := Data.First;
         Item : Setting_Time_Record;
      begin
         while Has_Element (Curs) loop
            Item := Element (Curs);
            Item.Time := Item.Time - Delta_Time;
            Data.Replace_Element (Curs, Item);
            Next (Curs);
         end loop;

      end Apply_Delta_Time;

      procedure Apply_Offset (Data : in out Setting_Time_Vector;
       Offset : Double_Natural) is
         Curs : Cursor := Data.First;
         Item : Setting_Time_Record;
      begin
         while Has_Element (Curs) loop
            Item := Element (Curs);
            Item.Time := Item.Time - Offset;
            Data.Replace_Element (Curs, Item);
            Next (Curs);
         end loop;

      end Apply_Offset;

      function Min_Time (A_Sync, B_Sync, A_Det, B_Det : Setting_Time_Record)
       return Double_Natural is
         Min : Double_Natural := A_Sync.Time;
       begin
         if B_Sync.Time < Min then
            Min := B_Sync.Time;
         end if;
         if A_Det.Time < Min then
            Min := A_Det.Time;
         end if;
         if B_Det.Time < Min then
            Min := B_Det.Time;
         end if;
         return Min;

      end Min_Time;

   begin
      Delta_Time := Min_Time (A_Sync_Data.First_Element, B_Sync_Data.First_Element,
       A_Det_Data.First_Element, B_Det_Data.First_Element);
      Put_Line (Routine_Name & "Delta_Time: " &
                  Double_Natural'Image (Delta_Time));
      --  Adjust A and B times to start at the same time
      Apply_Delta_Time (A_Sync_Data, Delta_Time);
      Apply_Delta_Time (B_Sync_Data, Delta_Time);
      Apply_Delta_Time (A_Det_Data, Delta_Time);
      Apply_Delta_Time (B_Det_Data, Delta_Time);
      Print_Setting_Time_Vector ("Align_Data A_Sync_Data", A_Sync_Data, 1, 3);
      Print_Setting_Time_Vector ("Align_Data B_Sync_Data", B_Sync_Data, 1, 3);
      Print_Setting_Time_Vector ("Align_Data A_Det_Data", A_Det_Data, 1, 3);
      Print_Setting_Time_Vector ("Align_Data B_Det_Data", B_Det_Data, 1, 3);

      Offset := Min_Time (A_Sync_Data.First_Element, B_Sync_Data.First_Element,
       A_Det_Data.First_Element, B_Det_Data.First_Element) - 1;
      Put_Line (Routine_Name & "Offset: " & Double_Natural'Image (Offset));
      --  Adjust A and B times to both start at 0.
      Apply_Offset (A_Sync_Data, Offset);
      Apply_Offset (B_Sync_Data, Offset);
      Apply_Offset (A_Det_Data, Offset);
      Apply_Offset (B_Det_Data, Offset);

      Print_Setting_Time_Vector ("Align_Sync_Data A_Data", A_Sync_Data, 1, 5);
      --  Print_Setting_Time_Vector ("Align_Sync_Data B_Data", B_Sync_Data, 1, 5);
      --  Print_Setting_Time_Vector ("Align_Det_Data A_Data", A_Sync_Data, 1, 5);
      --  Print_Setting_Time_Vector ("Align_Det_Data B_Data", B_Sync_Data, 1, 5);

   end Align_Data;

end NIST_Utilities;