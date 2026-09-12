
--  with Ada.Text_IO; use Ada.Text_IO;

--  with NIST_Printing; use NIST_Printing;
--  with Printing; use Printing;

package body  NIST_Utilities is

   procedure Align_Data
    (A_Sync_Data, B_Sync_Data: in out Double_Natural_Vector;
     A_Det_Data, B_Det_Data : in out Setting_Time_Vector) is
      use Setting_Time_Package;
      --  Routine_Name : constant String := "NIST_Utilities.Align_Sync_Data ";
      AgtB         : constant Boolean := A_Sync_Data.First_Element >
                        B_Sync_Data.First_Element;
      Delta_Time   : Double_Natural;
      Offset       : Double_Natural;

      procedure Apply_Delta_Time
       (Sync_Data : in out Double_Natural_Vector;
        Det_Data : in out Setting_Time_Vector; Delta_Time : Double_Natural) is
      use Double_Natural_Package;
         Sync_Curs : Double_Natural_Package.Cursor := Sync_Data.First;
         Det_Curs  : Setting_Time_Package.Cursor := Det_Data.First;
         Sync_Item : Double_Natural;
         Det_Item  : Setting_Time_Record;
      begin
         while Has_Element (Sync_Curs) loop
            Sync_Item := Element (Sync_Curs);
            Sync_Item := Sync_Item - Delta_Time;
            Sync_Data.Replace_Element (Sync_Curs, Sync_Item);
            Next (Sync_Curs);
         end loop;

         while Has_Element (Det_Curs) loop
            Det_Item := Element (Det_Curs);
            Det_Item.Time := Det_Item.Time - Delta_Time;
            Det_Data.Replace_Element (Det_Curs, Det_Item);
            Next (Det_Curs);
         end loop;
      end Apply_Delta_Time;

      procedure Apply_Sync_Offset (Sync_Data : in out Double_Natural_Vector;
       Offset : Double_Natural) is
         use Double_Natural_Package;
         Curs : Double_Natural_Package.Cursor := Sync_Data.First;
         Item : Double_Natural;
      begin
         while Has_Element (Curs) loop
            Item := Element (Curs) - Offset;
            Sync_Data.Replace_Element (Curs, Item);
            Next (Curs);
         end loop;

      end Apply_Sync_Offset;

      procedure Apply_Det_Offset (Data : in out Setting_Time_Vector;
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

      end Apply_Det_Offset;

      function Min_Time (A_Sync, B_Sync : Double_Natural;
       A_Det, B_Det : Setting_Time_Record)
       return Double_Natural is
         Min : Double_Natural := A_Sync;
       begin
         if B_Sync < Min then
            Min := B_Sync;
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
      --  Put_Line (Routine_Name & "Delta_Time: " &
      --              Double_Natural'Image (Delta_Time));
      --  Adjust A and B times to start at the same time
      if AgtB then
         Apply_Delta_Time (A_Sync_Data, A_Det_Data, Delta_Time);
      else
         Apply_Delta_Time (B_Sync_Data, B_Det_Data, Delta_Time);
      end if;

      --  Print_Double_Natural_Vector ("Align_Data A_Sync_Data", A_Sync_Data, 1, 1);
      --  Print_Double_Natural_Vector ("Align_Data B_Sync_Data", B_Sync_Data, 1, 1);
      --  Print_Setting_Time_Vector ("Align_Data A_Det_Data", A_Det_Data, 1, 1);
      --  Print_Setting_Time_Vector ("Align_Data B_Det_Data", B_Det_Data, 1, 1);

      Offset := Min_Time (A_Sync_Data.First_Element, B_Sync_Data.First_Element,
       A_Det_Data.First_Element, B_Det_Data.First_Element) - 1;
      --  Put_Line (Routine_Name & "Offset: " & Double_Natural'Image (Offset));
      --  Adjust A and B times to both start at 0.
      Apply_Sync_Offset (A_Sync_Data, Offset);
      Apply_Sync_Offset (B_Sync_Data, Offset);
      Apply_Det_Offset (A_Det_Data, Offset);
      Apply_Det_Offset (B_Det_Data, Offset);

      --  Print_Double_Natural_Vector ("Align_Sync_Data A_Data", A_Sync_Data, 1, 1);
      --  Print_Double_Natural_Vector ("Align_Sync_Data B_Data", B_Sync_Data, 1, 1);
      --  Print_Setting_Time_Vector ("Align_Det_Data A_Data", A_Det_Data, 1, 1);
      --  Print_Setting_Time_Vector ("Align_Det_Data B_Data", B_Det_Data, 1, 1);

   end Align_Data;

end NIST_Utilities;