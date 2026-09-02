
with Ada.Exceptions;  use Ada.Exceptions;
with Ada.Strings.Fixed;
with Ada.Text_IO; use Ada.Text_IO;

with NIST_Utils; use NIST_Utils;

package body Process_Detection_Data is
   procedure Save_Detection_Data (CSV_AB_Data : String;
      Data_A, Data_B : Setting_Time_Vector);

   procedure Load_Data
    (CSV_AB_Data : String; Data_A, Data_B : out Setting_Time_Vector) is
      File_ID : File_Type;
      aLine   : String_40;
      Str_A  : String_19;
      Str_B  : String_19;
      Item_A  : Setting_Time_Record;
      Item_B  : Setting_Time_Record;
   begin
      Open (File_ID, In_File, CSV_AB_Data);
      Skip_Line (File_ID);   --  Skip header
      while not End_Of_File (File_ID) loop
         aLine := Get_Line (File_ID);
         Str_A := aLine (1 .. 19);
         Str_B := aLine (22 .. 40);
         if Str_A (1 .. 1) = "0" then
            Item_A.Setting := Polarizer_0;
         elsif Str_A (1 .. 1) = "1" then
            Item_A.Setting := Polarizer_45;
         else
            Put_Line ("Load_Data: Invalid A setting: " & Str_A (1 .. 1));
         end if;

         Item_A.Time := Double_Natural'Value (Str_A (3 .. 19));

         if Str_B (1 .. 1) = "0" then
            Item_B.Setting := Polarizer_0;
         elsif Str_B (1 .. 1) = "1" then
            Item_B.Setting := Polarizer_45;
         else
            Put_Line ("Load_Data: Invalid B setting: " & Str_B (1 .. 1));
         end if;
         Item_B.Time := Double_Natural'Value (Str_B (3 .. 19));

         Data_A.Append (Item_A);
         Data_B.Append (Item_B);
      end loop;

      Close (File_ID);

   end Load_Data;

   procedure Match_Detection_Times (CSV_AB, Matched_CSV_AB : String;
       Width : Natural; Delta_Val : Double_Natural; Num_Found : out Natural;
        Selected_Pairs : out Match_List) is
      use Setting_Time_Package;
      Routine_Name : constant String :=
       "Process_Detection_Data.Match_Detection_Times ";
      D_Width      : constant Double_Natural := Double_Natural (Width);
      Item         : Setting_Time_Record;
      A_Data       : Setting_Time_Vector;
      B_Data       : Setting_Time_Vector;
      A_Curs       : Cursor;
      B_Curs       : Cursor;
      Match_Record : Index_Record;
      Count        : Natural := 0;
      Find_Count   : Natural := 0;

      --  Find_Match finds a B record with time in range of A record time.
      --  If found the A and B pair are add to the selected records list.
      procedure Find_Match (A_Curs : Setting_Time_Package.Cursor) is
         A_Value   : constant Double_Natural := Element (A_Curs).Time;
         B_Val_Min : Double_Natural;
         B_Value   : Double_Natural;
         Match     : Boolean := False;
      begin
         Count := Count + 1;
         Find_Count := Find_Count + 1;
         --  if Find_Count < 6 then
         --     Put_Line (Routine_Name & "Find_All_Matches Find_Count:" &
         --           Natural'Image (Find_Count));
         --  end if;
         if Double_Integer (A_Value) - Double_Integer (D_Width) < 0 then
            B_Val_Min := 0;
         else
            B_Val_Min := A_Value - D_Width;
         end if;

         if Has_Element (B_Curs) then
            --  Find a minimum acceptable B value.
            B_Value := Element (B_Curs).Time;
            --  Move B_Index forward until B_Value is >= (A_Value - Width)
            while Has_Element (B_Curs) and then B_Value < B_Val_Min loop
               B_Value := Element (B_Curs).Time;
               Next (B_Curs);
            end loop;

            --  Element (B_Curs) is = or > B_Val_Min
            if Has_Element (B_Curs) then
               B_Value := Element (B_Curs).Time;
               Match := Abs (B_Value - A_Value) <= D_Width;
               --  if Find_Count < 6 then
               --     Put_Line (Routine_Name & "Find_All_Matches B_Value:" &
               --           Double_Natural'Image (B_Value));
               --  end if;

               if Match then
                  Put_Line (Routine_Name &
                  "Find_All_Matches Match found, Find_Count" &
                     Natural'Image (Find_Count));
                  --  Matched times found within window
                  Match_Record.A_Index := Double_Positive (To_Index (A_Curs));
                  Match_Record.B_Index := Double_Positive (To_Index (B_Curs));
                  Selected_Pairs.Append (Match_Record);
                  Num_Found := Num_Found + 1;
                  if Num_Found < 6 then
                     Put_Line (Routine_Name & "Match, A, B index:" &
                         Double_Positive'Image (To_Index (A_Curs)) & ",  " &
                         Double_Positive'Image (To_Index (B_Curs)));
                  end if;
               end if;
            end if;
         end if;
         if Num_Found < 6 then
            Put_Line (Routine_Name & "Find_All_Matches Num_Found:" &
                  Natural'Image (Num_Found));
         end if;

      exception
         when Error : others =>
            Put_Line (Routine_Name & "Find_Match " &
            Exception_Information (Error));
            raise;

      end Find_Match;

   begin
      --  CSV_AB file contains four columns of A and B setting and photon
      --  time data
      Put_Line (Routine_Name & "Delta_Val:" &
       Double_Natural'Image (Delta_Val));
      Load_Data (CSV_AB, A_Data, B_Data);
      Align_Timing_Data (A_Data, B_Data);
      B_Curs := B_Data.First;
      while Has_Element (B_Curs) loop
         Count := Count + 1;
         Item := Element (B_Curs);
         --  if Count < 4 then
         --      Put_Line (Routine_Name & "B.Time after alignment:" &
         --       Double_Natural'Image (Item.Time));
         --  end if;
         Item.Time := Item.Time + Delta_Val;
         --  if Count < 4 then
         --      Put_Line (Routine_Name & "B.Time after update, offset:" &
         --       Double_Natural'Image (Item.Time) & "  " &
         --        Double_Natural'Image (Delta_Val));
         --  end if;
         B_Data.Replace_Element (Position => B_Curs, New_Item => Item);
         Next (B_Curs);
      end loop;
      New_Line;

      A_Curs := First (A_Data);
      Next (A_Curs);  --  Skip header
      B_Curs := First (B_Data);
      Next (B_Curs);  --  Skip header
      Put_Line (Routine_Name & "A_Data.Iterate");
      A_Data.Iterate (Find_Match'Access);

      Save_Detection_Data (Matched_CSV_AB, A_Data, B_Data);

      --  Put_Line (Routine_Name & "Selected_Pairs length:" &
      --             Double_Natural'Image (Double_Natural (CSV_AB'Length)));
      New_Line;

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;

   end Match_Detection_Times;

   function Number_Of_Matches (File_Name : String) return Natural is
      use Ada.Strings.Fixed;
      Routine_Name : constant String :=
       "Process_Detection_Data.Number_Of_Matches ";
      File_ID      : File_Type;
      Num_Matches  : Natural := 0;
   begin
      Open (File_ID, In_File, File_Name);
      Skip_Line (File_ID);   --  Skip header
      Put_Line (Routine_Name & "File_Name: " & File_Name);
      while not End_Of_File (File_ID) loop
         declare
            aLine : constant String := Get_Line (File_ID);
            Pos_1 : constant Natural := Index (aLine, ",");
            Pos_2 : Natural;
         begin
            if Pos_1 > 0 and then Pos_1 < aLine'Last then
               Pos_2 := Index (aLine, ",", Pos_1 + 1);
               if Pos_2 > 0 then
                  if aLine (1 .. 2) = aLine (Pos_2 + 2 .. Pos_2 + 3) then
                     Num_Matches := Num_Matches + 1;
                  end if;
                else
                  Put_Line (Routine_Name & aLine & "has only one comma.");
               end if;
            else
               Put_Line (Routine_Name & aLine & "has no commas.");
            end if;
         end;
      end loop;

      Close (File_ID);

      Put_Line (Routine_Name & "Number of matches: " & Integer'Image (Num_Matches));
      return Num_Matches;

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));
         return Num_Matches;

   end Number_Of_Matches;

   procedure Save_Detection_Data (CSV_AB_Data : String;
      Data_A, Data_B : Setting_Time_Vector) is
      use Setting_Time_Package;
      Routine_Name : constant String :=
       "Process_Detection_Data.Save_NIST_Data ";
      Out_ID       : File_Type;
      Curs_A       : Setting_Time_Package.Cursor := Data_A.First;
      Curs_B       : Setting_Time_Package.Cursor := Data_B.First;
      Item_A       : Setting_Time_Record;
      Item_B       : Setting_Time_Record;
      A_Setting    : Natural;
      B_Setting    : Natural;
   begin
      Create (Out_ID, Out_File, CSV_AB_Data);

      --  Table Header
      Put_Line (Out_ID, "A Setting,A Time,B Setting,B_Time");
      while Has_Element (Curs_A) and then Has_Element (Curs_B) loop
         Item_A := Element (Curs_A);
         Item_B := Element (Curs_B);
         A_Setting := Channel_Type'Pos (Item_A.Setting) - 1;
         B_Setting := Channel_Type'Pos (Item_B.Setting) - 1;
         Put_Line (Out_ID, Natural'Image (A_Setting) & ", " &
          Double_Natural'Image (Item_A.Time) & ", " &
           Natural'Image (B_Setting) & ", " &
            Double_Natural'Image (Item_B.Time));
         Next (Curs_A);
         Next (Curs_B);
      end loop;

      Close (Out_ID);
      Put_Line (Routine_Name & "Data written to " & CSV_AB_Data);

   exception
      when Error : others =>
         Put_Line (Routine_Name & "Exception information:  " &
                     Exception_Information (Error));

   end Save_Detection_Data;

end Process_Detection_Data;
