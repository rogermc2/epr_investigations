
with Ada.Text_IO; use Ada.Text_IO;

--  with Printing; use Printing;

package body  NIST_Utils is

 procedure Align_Sync_Data
    (A_Sync_Data, B_Sync_Data : in out Setting_Time_Vector;
     Delta_Time, Offset : out Double_Natural) is
      use Setting_Time_Package;
      Routine_Name : constant String := "Process_Sync_Data.Align_Sync_Data ";
      A_Curs       : Cursor := A_Sync_Data.First;
      B_Curs       : Cursor := B_Sync_Data.First;
      A_Item       : Setting_Time_Record := Element (A_Sync_Data.First);
      B_Item       : Setting_Time_Record := Element (B_Sync_Data.First);
      A_Gt_B       : constant Boolean := A_Item.Time >= B_Item.Time;
   begin
      Delta_Time := abs (A_Item.Time - B_Item.Time);
         if A_Gt_B then
            Offset := B_Item.Time - 1;
         else
            Offset := A_Item.Time - 1;
         end if;
         Put_Line (Routine_Name & "Delta_Time: " &
                   Double_Natural'Image (Delta_Time) &
                   ", Offset: " & Double_Natural'Image (Offset));

         while Has_Element (A_Curs) and then Has_Element (B_Curs) loop
            A_Item := Element (A_Curs);
            B_Item := Element (B_Curs);
            if A_Gt_B then
               A_Item.Time := A_Item.Time - Delta_Time;
               A_Sync_Data.Replace_Element (A_Curs, A_Item);
            else
               B_Item.Time := B_Item.Time - Delta_Time;
               B_Sync_Data.Replace_Element (B_Curs, B_Item);
            end if;
            Next (A_Curs);
            Next (B_Curs);
         end loop;

         A_Curs := A_Sync_Data.First;
         B_Curs := B_Sync_Data.First;
         while Has_Element (A_Curs) loop
            A_Item := Element (A_Curs);
            A_Item.Time := A_Item.Time - Offset;
            A_Sync_Data.Replace_Element (A_Curs, A_Item);
            Next (A_Curs);
         end loop;

         while Has_Element (B_Curs) loop
            B_Item := Element (B_Curs);
            B_Item.Time := B_Item.Time - Offset;
            B_Sync_Data.Replace_Element (B_Curs, B_Item);
            Next (B_Curs);
         end loop;

         --  Print_Setting_Time_Vector ("Align_Sync_Data A_Data", A_Sync_Data, 1, 5);
         --  Print_Setting_Time_Vector ("Align_Sync_Data B_Data", B_Sync_Data, 1, 5);

   end Align_Sync_Data;

end NIST_Utils;