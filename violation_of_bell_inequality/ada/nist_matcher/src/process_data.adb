
--  with Ada.Directories;
with Ada.Exceptions;  use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

with Histogram;

package body Process_Data is

   procedure Load_Data (CSV_Data : String;
                Data_A, Data_B : in out Setting_Time_Vector);
   procedure Save_Match_List (File_Name : String; Pairs : Match_List);

   procedure Align_Data (A_Data, B_Data : in out Setting_Time_Vector) is
      use Setting_Time_Package;
      A_Curs       : Cursor := A_Data.First;
      B_Curs       : Cursor := B_Data.First;
      A_Item       : Setting_Time_Record := Element (A_Data.First);
      B_Item       : Setting_Time_Record := Element (B_Data.First);
      Delta_Time   : constant Double_Natural :=
                         abs (A_Item.Time - B_Item.Time);
      A_Gt_B       : constant Boolean := A_Item.Time >= B_Item.Time;
      Offset       : Double_Natural;
      begin
         if A_Gt_B
         then
            Offset := B_Item.Time - 1;
         else
            Offset := A_Item.Time - 1;
         end if;

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

      end Align_Data;

procedure Find_Raw_Window_Width
     (CSV_Times_A, CSV_Times_B : String; Delta_A : Natural;
      Min_Width, Max_Width     : out Natural) is
      use Setting_Time_Package;
      --  Routine_Name : constant String := "Process_Data.Find_Raw_Window_Width ";
      A_Data       : Setting_Time_Vector;
      B_Data       : Setting_Time_Vector;
      B_Index      : Double_Positive := 1;

      procedure Find_Width (A_Curs : Setting_Time_Package.Cursor) is
         A_Value   : constant Double_Natural :=
           Element (A_Curs).Time + Double_Natural (Delta_A);
         Width     : Natural;
      begin
         while B_Index < Double_Positive (B_Data.Length) and then
           B_Data.Element (B_Index).Time < A_Value
         loop
            B_Index := B_Index + 1;
         end loop;

         Width := Natural (B_Data.Element (B_Index).Time - A_Value);
         if Width > Max_Width then
            Max_Width := Width;
         elsif Width < Min_Width and then Width > 0 then
            --   Width can be < 0 at end of files.
            Min_Width := Width;
         end if;

      end Find_Width;

   begin
      Load_Data (CSV_Times_A, A_Data, B_Data);
      Min_Width := 1;
      Max_Width := 0;

      A_Data.Iterate (Find_Width'Access);

   end  Find_Raw_Window_Width;

procedure Load_Data (CSV_Data : String;
                  Data_A, Data_B : in out Setting_Time_Vector) is
      use Types.Setting_Time_Package;
      File_ID : File_Type;
      Header  : String_33;
      A_String : String_19;
      B_String : String_19;
      aLine   : String_40;
      Item    : Setting_Time_Record;
   begin
      Open (File_ID, In_File, CSV_Data);
      Header := Get_Line (File_ID);        -- Skip header
      while not End_Of_File (File_ID) loop
         aLine := Get_Line (File_ID);
         A_String := aLine (aLine'First .. aLine'First + 18);
         B_String := aLine (aLine'First + 21 .. aLine'Last);
         Item.Setting := Natural'Value (A_String (1 .. 1));
         Item.Time := Double_Natural'Value (A_String (4 .. 19));
         Data_A.Append (Item);
         Item.Setting := Natural'Value (B_String (1 .. 1));
         Item.Time := Double_Natural'Value (B_String (4 .. 19));
         Data_B.Append (Item);
      end loop;

      Close (File_ID);

   end Load_Data;

   procedure Match_Sync_Times
     (Pairs_CSV, Match_CSV : String; Delta_A, Width : Natural;
      Num_Found : out Natural; Selected_Pairs : out Match_List;
      Num_Rows  : Natural := 0) is
      use Histogram;
      use Match_Package;
      use Setting_Time_Package;
      Routine_Name : constant String := "Process_Data.Match_Sync_Times ";
      Use_Num_Rows : constant Boolean := Num_Rows > 0;
      A_Data       : Setting_Time_Vector;
      B_Data       : Setting_Time_Vector;
      B_Curs       : Setting_Time_Package.Cursor := B_Data.First;

         procedure Find_All_Matches (A_Curs : Setting_Time_Package.Cursor) is
         D_Width   : constant Double_Natural := Double_Natural (Width);
         A_Item    : constant Setting_Time_Record := Element (A_Curs);
         A_Time    : constant Double_Natural :=
            A_Item.Time + Double_Natural (Delta_A) + D_Width;
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
               if B_Item.Setting = 3 then
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
                  --  if Num_Found < 6 then
                  --     Put_Line (Routine_Name & "Match, A, B index:" &
                  --                 Integer'Image (To_Index (A_Curs)) & ",  " &
                  --                 Integer'Image (To_Index (B_Curs)));
                  --  end if;
               end if;
            end if;
         end if;

      end Find_All_Matches;

   begin
      Num_Found := 0;
      Load_Data (Pairs_CSV, A_Data, B_Data);
      Align_Data (A_Data, B_Data);
      Draw_Histogram  (A_Data, B_Data);
      B_Curs := First (B_Data);
      Next (B_Curs);  --  Skip header

      Put_Line (Routine_Name & "Data loaded");
      A_Data.Iterate (Find_All_Matches'Access);
      Put_Line (Routine_Name & "All matches found");
      New_Line;

      Save_Match_List (Match_CSV, Selected_Pairs);
      Put_Line (Routine_Name & "Selected_Pairs length:" &
                  Integer'Image (Integer (Selected_Pairs.Length)));
      New_Line;

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;

   end Match_Sync_Times;

   function Number_Of_Matches (File_Name : String) return Natural is
      Routine_Name : constant String := "Process_Data.Number_Of_Matches ";
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
      Routine_Name : constant String := "Process_Data.Save_Match_List ";
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

end Process_Data;
