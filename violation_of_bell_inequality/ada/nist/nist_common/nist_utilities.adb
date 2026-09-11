
with Ada.Text_IO; use Ada.Text_IO;

with NIST_Printing; use NIST_Printing;
with Types; use Types;

package body  NIST_Utilities is

   procedure Align_Data
    (A_Sync_Data, B_Sync_Data, A_Det_Data, B_Det_Data : in out Setting_Time_Vector) is
      use Setting_Time_Package;
      Routine_Name : constant String := "NIST_Utilities.Align_Sync_Data ";
      A_Sync_Curs  : Cursor := A_Sync_Data.First;
      B_Sync_Curs  : Cursor := B_Sync_Data.First;
      A_Det_Curs   : Cursor := A_Det_Data.First;
      B_Det_Curs   : Cursor := B_Det_Data.First;
      A_Item       : Setting_Time_Record := Element (A_Sync_Data.First);
      B_Item       : Setting_Time_Record := Element (B_Sync_Data.First);
      A_Det        : Setting_Time_Record := Element (A_Det_Data.First);
      B_Det        : Setting_Time_Record := Element (B_Det_Data.First);
      A_Gt_B       : Boolean;
      Delta_Time   : Double_Natural;
      Offset       : Double_Natural;
   begin
      A_Gt_B := A_Item.Time >= B_Item.Time;
      Delta_Time := abs (A_Item.Time - B_Item.Time);
      if A_Gt_B then
         Offset := B_Item.Time - 1;
      else
         Offset := A_Item.Time - 1;
      end if;
      Put_Line (Routine_Name & "Delta_Time: " &
                  Double_Natural'Image (Delta_Time) &
                  ", Offset: " & Double_Natural'Image (Offset));
      --  Adjust A and B times to start at the same time
      while Has_Element (A_Sync_Curs) and then Has_Element (B_Sync_Curs) loop
         A_Item := Element (A_Sync_Curs);
         B_Item := Element (B_Sync_Curs);
         if A_Gt_B then
            A_Item.Time := A_Item.Time - Delta_Time;
            A_Det.Time := A_Det.Time - Delta_Time;
            A_Sync_Data.Replace_Element (A_Sync_Curs, A_Item);
            A_Det_Data.Replace_Element (A_Det_Curs, A_Det);
         else
            B_Item.Time := B_Item.Time - Delta_Time;
            B_Det.Time := B_Det.Time - Delta_Time;
            B_Sync_Data.Replace_Element (B_Sync_Curs, B_Item);
            B_Det_Data.Replace_Element (B_Det_Curs, A_Det);
         end if;
         Next (A_Sync_Curs);
         Next (B_Sync_Curs);
      end loop;

      --  Adjust A and B times to both start at 0.
      A_Sync_Curs := A_Sync_Data.First;
      B_Sync_Curs := B_Sync_Data.First;
      A_Det_Curs := A_Det_Data.First;
      B_Det_Curs := B_Det_Data.First;

      while Has_Element (A_Sync_Curs) loop
         A_Item := Element (A_Sync_Curs);
         A_Item.Time := A_Item.Time - Offset;
         A_Sync_Data.Replace_Element (A_Sync_Curs, A_Item);
         Next (A_Sync_Curs);
      end loop;

      while Has_Element (B_Sync_Curs) loop
         B_Item := Element (B_Sync_Curs);
         B_Item.Time := B_Item.Time - Offset;
         B_Sync_Data.Replace_Element (B_Sync_Curs, B_Item);
         Next (B_Sync_Curs);
      end loop;

      while Has_Element (A_Det_Curs) loop
         A_Item := Element (A_Det_Curs);
         A_Item.Time := A_Item.Time - Offset;
         A_Sync_Data.Replace_Element (A_Det_Curs, A_Item);
         Next (A_Det_Curs);
      end loop;

      while Has_Element (B_Det_Curs) loop
         B_Item := Element (B_Det_Curs);
         B_Item.Time := B_Item.Time - Offset;
         B_Sync_Data.Replace_Element (B_Det_Curs, B_Item);
         Next (B_Det_Curs);
      end loop;

      Print_Setting_Time_Vector ("Align_Sync_Data A_Data", A_Sync_Data, 1, 5);
      --  Print_Setting_Time_Vector ("Align_Sync_Data B_Data", B_Sync_Data, 1, 5);
      --  Print_Setting_Time_Vector ("Align_Det_Data A_Data", A_Sync_Data, 1, 5);
      --  Print_Setting_Time_Vector ("Align_Det_Data B_Data", B_Sync_Data, 1, 5);

   end Align_Data;

end NIST_Utilities;