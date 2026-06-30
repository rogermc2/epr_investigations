
--  with Ada.Directories;
with Ada.Exceptions;  use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

with Histogram;

package body Process_Sync_Data is

   procedure Load_Sync_Data (CSV_Data : String;
       Sync_Data_A, Sync_Data_B : in out Setting_Time_Vector);
   procedure Save_Match_List (File_Name : String; Pairs : Match_List);

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

   end Align_Timing_Data;

procedure Load_Sync_Data (CSV_Data : String;
                  Sync_Data_A, Sync_Data_B : in out Setting_Time_Vector) is
      use Types.Setting_Time_Package;
      Routine_Name : constant String := "Process_Sync_Data.Load_Sync_Data ";
      File_ID      : File_Type;
      Header       : String_23;
      A_String     : String_19;
      B_String     : String_19;
      aLine        : String_40;
      Item         : Setting_Time_Record;
   begin
      Open (File_ID, In_File, CSV_Data);
      Header := Get_Line (File_ID);        -- Skip header
      --  Put_Line (Routine_Name & "Header: " & Header);
      Item.Setting := Sync;
      while not End_Of_File (File_ID) loop
         aLine := Get_Line (File_ID);
         A_String := aLine (aLine'First .. aLine'First + 18);
         B_String := aLine (aLine'First + 21 .. aLine'Last);
         Item.Time := Double_Natural'Value (A_String (1 .. 19));
         Sync_Data_A.Append (Item);
         Item.Time := Double_Natural'Value (B_String (1 .. 19));
         Sync_Data_B.Append (Item);
      end loop;
      Put_Line (Routine_Name & "Sync_Data_B loaded");
      New_Line;

      Close (File_ID);

   exception
      when Error : others =>
         New_Line;
         Put_Line (Routine_Name & Exception_Information (Error));
         Put_Line ("aLine: " & aLine);
         raise;

   end Load_Sync_Data;

   procedure Match_Syncs
     (Sync_Pairs_CSV, Matched_Sync_CSV : String; Width : Natural;
      Num_Found : out Natural; Selected_Pairs : out Match_List;
      Offset : out Double_Natural; Num_Rows : Natural := 0) is
      use Histogram;
      use Match_Package;
      use Setting_Time_Package;
      Routine_Name : constant String := "Process_Sync_Data.Match_Syncs ";
      D_Width      : constant Double_Natural := Double_Natural (Width);
      Use_Num_Rows : constant Boolean := Num_Rows > 0;
      A_Data       : Setting_Time_Vector;
      B_Data       : Setting_Time_Vector;
      B_Curs       : Setting_Time_Package.Cursor := B_Data.First;

         procedure Find_All_Matches (A_Curs : Setting_Time_Package.Cursor) is
         A_Item    : constant Setting_Time_Record := Element (A_Curs);
         A_Time    : constant Double_Natural := A_Item.Time + D_Width;
         B_Val_Min : constant Double_Natural := A_Time - D_Width;
         Item      : Index_Record;
         B_Item    : Setting_Time_Record;
         B_Time    : Double_Natural;
         Count     : Natural := 0;
         Match     : Boolean := False;
      begin
         Count := Count + 1;
         if Use_Num_Rows and Count > Num_Rows then
            null;
         elsif Has_Element (B_Curs) then
            B_Item := Element (B_Curs);
            B_Time := B_Item.Time;
            --  Move B_Index forward until B_Value is >= (A_Value - Width)
            while Has_Element (B_Curs) and then B_Time < B_Val_Min loop
               B_Item := Element (B_Curs);
               if B_Item.Setting = Sync then
                  B_Time := B_Item.Time;
               end if;
               Next (B_Curs);
            end loop;

            --  Element (B_Curs) is = or > B_Val_Min
            if Has_Element (B_Curs) then
               B_Item := Element (B_Curs);
               B_Time := B_Item.Time;
               Match := Abs (B_Time - A_Time) <= D_Width;

               if Match then
                  --  Matched times found within window
                  Item := (To_Index (A_Curs), To_Index (B_Curs));
                  Selected_Pairs.Append (Item);
                  Num_Found := Num_Found + 1;
                  if Num_Found < 6 then
                     Put_Line (Routine_Name & "Match, A, B index:" &
                      Double_Positive'Image (To_Index (A_Curs)) & ",  " &
                                   Double_Positive'Image (To_Index (B_Curs)));
                  end if;
               end if;
            end if;
         end if;

      exception
         when Error : others =>
            Put_Line (Routine_Name & "Find_All_Matches " &
             Exception_Information (Error));
            raise;

      end Find_All_Matches;

   begin
      Num_Found := 0;
      Put_Line (Routine_Name &
                "Source file, Sync_Pairs_CSV: " & Sync_Pairs_CSV);
      Load_Sync_Data (Sync_Pairs_CSV, A_Data, B_Data);

      --  If Align_Timing_Data is not called for Sync data, Draw_Histagram will
      --  exhibit a Bin index out of range error.
      --  Align_Timing_Data is called to align two data sets
      --  to the same time frame.
      --  The histogram is drawn to verify the alignment.
      Align_Timing_Data (A_Data, B_Data);
      Offset := Draw_Histogram  (A_Data, B_Data);

      B_Curs := First (B_Data);
      Next (B_Curs);  --  Skip header
      A_Data.Iterate (Find_All_Matches'Access);
      New_Line;
      Put_Line (Routine_Name & "Selected_Pairs length:" &
                  Integer'Image (Integer (Selected_Pairs.Length)));

      Save_Match_List (Matched_Sync_CSV, Selected_Pairs);
      New_Line;

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;

   end Match_Syncs;

   function Number_Of_Matches (File_Name : String) return Natural is
      Routine_Name : constant String := "Process_Sync_Data.Number_Of_Matches ";
      File_ID      : File_Type;
      aLine        : String_8;
      Num_Matches  : Natural := 0;
   begin
      Open (File_ID, In_File, File_Name);
      Skip_Line (File_ID);   --  Skip header
      while not End_Of_File (File_ID) loop
         aLine := Get_Line (File_ID);
         if aLine (1 .. 2) = aLine (4 .. 5) then
            Num_Matches := Num_Matches + 1;
         end if;
      end loop;

      Close (File_ID);

      return Num_Matches;

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));
         return Num_Matches;

   end Number_Of_Matches;

   procedure Save_Match_List (File_Name : String; Pairs : Match_List) is
      use Match_Package;
      Routine_Name : constant String := "Process_Sync_Data.Save_Match_List ";
      Match_ID     : File_Type;
      M_Curs       : Cursor := First (Pairs);
      Rec          : Index_Record;
   begin
      Create (Match_ID, Out_File, File_Name);
      while Has_Element (M_Curs) loop
         Rec :=  Element (M_Curs);
         Put_Line (Match_ID, Double_Positive'Image (Rec.A_Index) & ", " &
          Double_Positive'Image (Rec.B_Index));
         Next (M_Curs);
      end loop;

      Close (Match_ID);
      Put_Line (Routine_Name & "Data written to " & File_Name);

   end Save_Match_List;

end Process_Sync_Data;
