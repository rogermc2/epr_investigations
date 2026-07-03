
with Ada.Text_IO; use Ada.Text_IO;

with Printing; use Printing;

package body  NIST_Utils is

 procedure Align_Timing_Data (A_Data, B_Data : in out Setting_Time_Vector) is
      use Setting_Time_Package;
      Routine_Name : constant String := "Process_Sync_Data.Align_Timing_Data ";
      A_Curs       : Cursor := A_Data.First;
      B_Curs       : Cursor := B_Data.First;
      A_Item       : Setting_Time_Record := Element (A_Data.First);
      B_Item       : Setting_Time_Record := Element (B_Data.First);
      Delta_Time   : constant Double_Natural :=
                         abs (A_Item.Time - B_Item.Time);
      A_Gt_B       : constant Boolean := A_Item.Time >= B_Item.Time;
      Offset       : Double_Natural;
      begin
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
               A_Data.Replace_Element (A_Curs, A_Item);
            else
               B_Item.Time := B_Item.Time - Delta_Time;
               B_Data.Replace_Element (B_Curs, B_Item);
            end if;
            Next (A_Curs);
            Next (B_Curs);
         end loop;

         A_Curs := A_Data.First;
         B_Curs := B_Data.First;
         while Has_Element (A_Curs) loop
            A_Item := Element (A_Curs);
            A_Item.Time := A_Item.Time - Offset;
            A_Data.Replace_Element (A_Curs, A_Item);
            Next (A_Curs);
         end loop;

         while Has_Element (B_Curs) loop
            B_Item := Element (B_Curs);
            B_Item.Time := B_Item.Time - Offset;
            B_Data.Replace_Element (B_Curs, B_Item);
            Next (B_Curs);
         end loop;

         Print_Setting_Time_Vector ("Align_Timing_Data A_Data", A_Data, 1, 5);
         Print_Setting_Time_Vector ("Align_Timing_Data B_Data", B_Data, 1, 5);

   end Align_Timing_Data;

end NIST_Utils;