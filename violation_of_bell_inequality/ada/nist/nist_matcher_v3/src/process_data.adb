
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

with Histogram;
--  with Printing; use Printing;

package body Process_Data is

   procedure Save_Match_List (File_Name : String; Index_Pairs : Match_List);

   procedure Load_Sync_Data
      (CSV_Data : String; Sync_Data : in out Double_Natural_Vector;
         Num_Rows : Double_Natural) is
      use Double_Natural_Package;
      Routine_Name : constant String := "Process_Data.Load_Sync_Data ";
      File_ID      : File_Type;
      Item         : Double_Natural;
      Count        : Double_Natural := 0;
   begin
      Open (File_ID, In_File, CSV_Data);
      Item := 0;
      while Count < Num_Rows and then not End_Of_File (File_ID) loop
         Count := Count + 1;
         declare
            Time_Tag : constant String := Get_Line (File_ID);
         begin
            Item := Double_Natural'Value (Time_Tag);
         end;
         Sync_Data.Append (Item);
      end loop;
      --  Put_Line (Routine_Name & "Count " & Double_Natural'Image (Count));
      Put_Line (Routine_Name & "Sync_Data loaded from " & CSV_Data);

      Close (File_ID);

   exception
      when Error : others =>
         New_Line;
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;

   end Load_Sync_Data;

   procedure Match_Syncs
     (A_Sync_Data, B_Sync_Data : in out Double_Natural_Vector; Matched_Sync_CSV : String; Width : Natural;
      Num_Found : out Natural; Selected_Pairs : out Match_List;
      Offset : out Double_Natural) is
      use Histogram;
      use Match_Package;
      use Double_Natural_Package;
      Routine_Name : constant String := "Process_Sync_Data.Match_Syncs ";
      D_Width      : constant Double_Natural := Double_Natural (Width / 2);
      B_Curs       : Double_Natural_Package.Cursor := B_Sync_Data.First;
      Count        : Natural := 0;

         procedure Find_Sync_Match (A_Curs : Double_Natural_Package.Cursor) is
            A_Time    : constant Double_Natural := Element (A_Curs);
            --  A_Time    : constant Double_Natural := A_Item + D_Width;
            B_Val_Min : Double_Natural := A_Time;
            Item      : Index_Record;
            B_Time    : Double_Natural;
            Match     : Boolean := False;
         begin
            Count := Count + 1;
            if A_Time >= D_Width then
               B_Val_Min := A_Time - D_Width;
            end if;

            if Has_Element (B_Curs) then
               B_Time := Element (B_Curs);
               --  Move B_Index forward until B_Value is >= (A_Value - Width)
               while Has_Element (B_Curs) and then B_Time < B_Val_Min loop
                  B_Time := Element (B_Curs);
                  Next (B_Curs);
               end loop;

               --  Element (B_Curs) is = or > B_Val_Min
               if Has_Element (B_Curs) then
                  B_Time := Element (B_Curs);
                  Match := Abs (B_Time - A_Time) <= D_Width;

                  if Match then
                     --  Matched times found within window
                     Item.A_Index := Double_Positive (To_Index (A_Curs));
                     Item.B_Index := Double_Positive (To_Index (B_Curs));
                     Selected_Pairs.Append (Item);
                     Num_Found := Num_Found + 1;
                  end if;
                  Next (B_Curs);
               end if;
            end if;

         exception
            when Error : others =>
               Put_Line (Routine_Name & Exception_Information (Error));
               raise;

         end Find_Sync_Match;

   begin
      --  Print_Double_Natural_Vector ("A_Sync_Data", A_Sync_Data, 1, 8);
      --  Print_Double_Natural_Vector ("B_Sync_Data", B_Sync_Data, 1, 8);
      Num_Found := 0;
      A_Sync_Data.Iterate (Find_Sync_Match'Access);
      New_Line;

      Save_Match_List (Matched_Sync_CSV, Selected_Pairs);

      --  If Align_Sync_Data is not called for Sync data, Draw_Histagram will
      --  exhibit a Bin index out of range error.
      --  Align_Timing_Data is called to align two data sets
      --  to the same time frame.
      --  The histogram is drawn to verify the alignment.
      Offset := Draw_Histogram  (A_Sync_Data, B_Sync_Data);

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;

   end Match_Syncs;
   
   procedure NIST_Data (Source_File, Det_File, Sync_File :
                         String; Num_Rows : Double_Natural := 30) is
      use Ada.Streams;
      use Ada.Strings;
      use Ada.Strings.Fixed;
      Routine_Name : constant String  := "Process_Data.NIST_Data ";
      Source_Size  : constant Double_Natural :=
       Double_Natural (Ada.Directories.Size (Source_File));
      Data_Stream  : Stream_IO.Stream_Access;
      Source_ID    : Stream_IO.File_Type;
      Det_ID       : Ada.Text_IO.File_Type;
      Synch_ID     : Ada.Text_IO.File_Type;
      Log_ID       : Ada.Text_IO.File_Type;
      Raw_Data     : Raw_Data_Record;
      Data         : Data_Record;
      Pol_Setting  : String (1 .. 2);
      Click        : Boolean;
      Sync_Pulse   : Boolean;
      Line_Num     : Double_Natural := 0;
      Num_Clicks   : Natural := 0;
      Num_Synchs   : Natural := 0;
      Num_Invalid  : Natural := 0;
   begin
      Put_Line (Routine_Name & "Source File: " & Source_File);
      Put_Line (Routine_Name & Source_File & " length: " &
         Double_Natural'Image (Source_Size));
      New_Line;
      Put_Line (Routine_Name &
       Source_File (Source_File'First + 19 .. Source_File'Last) & " size: " &
                     Double_Natural'Image (Source_Size));
      Stream_IO.Open (Source_ID, Stream_IO.In_File, Source_File);
      Data_Stream := Stream_IO.Stream (Source_ID);

      Create (Det_ID, Out_File, Det_File);
      Create (Synch_ID, Out_File, Sync_File);
      Create (Log_ID, Out_File,
       Source_File (Source_File'First + 22 .. Source_File'Last - 4) &
        "_parsing_errors.log");
      Put_Line (Log_ID, "*******  Parsing Errors  *******");

      while not Stream_IO.End_Of_File (Source_ID) and then
       Line_Num <= Num_Rows loop
        Line_Num := Line_Num + 1;

         Raw_Data_Record'Read (Data_Stream, Raw_Data);
         --  if Line_Num < 22 then
         --     null;
         --     Put_Line (Routine_Name & "Line_Num: " &
         --      Double_Natural'Image (Line_Num) & ", Raw Data Channel: " &
         --              Unsigned_Byte'Image (Raw_Data.Channel));
         --     --  Print_Raw_Data (Raw_Data);
         --  end if;

         case Raw_Data.Channel is
            when 0 => Data.Channel := Detector_Click;
            when 2 => Data.Channel := Polarizer_0;
            when 4 => Data.Channel := Polarizer_45;
            when 5 => Data.Channel := GPS_Pps;
            when 6 => Data.Channel := Sync;
            when 64 => Data.Channel := Overflow;
            when others =>
             Data.Channel := Ch_Error;
             Num_Invalid := Num_Invalid + 1;
             Ada.Text_IO.Put_Line (Log_ID, "Line: " &
                  Double_Natural'Image (Line_Num) & "," &
                  "Invalid Channel value:" &
                  Unsigned_Byte'Image (Raw_Data.Channel));
         end case;
         Data.Time_Tag := Raw_Data.Time_Tag;
         Data.Transfer_ID := Integer (Raw_Data.Transfer_ID);

         --  if Line_Num < 8 then
         --     Print_Processed_Data (Data);
         --  end if;

         Click := False;
         Sync_Pulse := False;
         case Data.Channel is
            when Detector_Click =>
               Click :=  True;
               Num_Clicks := Num_Clicks + 1;
            when Polarizer_0 => Pol_Setting := " 0";
            when Polarizer_45 => Pol_Setting := "45";
            when GPS_Pps => null;
            when Sync =>
               Sync_Pulse :=  True;
               Num_Synchs := Num_Synchs + 1;
            when Overflow => null;
            when Ch_Error => null;
         end case;

         if Sync_Pulse then
            Put (Synch_ID,
               Trim (Unsigned_8_Byte'Image (Data.Time_Tag), Both));
            New_Line (Synch_ID);
         elsif Click then
            --  Click detected for Pol_Setting at Time_Tag
            --  Put_Line (Routine_Name & "Click detected at line: " &
            --     Double_Natural'Image (Line_Num) & ", Pol_Setting: " &
            --     Pol_Setting & ", Time_Tag: " &
            --     Unsigned_8_Byte'Image (Data.Time_Tag));
            Put (Det_ID, Unsigned_8_Byte'Image (Data.Time_Tag) & "," &
                Pol_Setting );
            New_Line (Det_ID);
         end if;

         if Line_Num mod 4000000 = 0 then
            Put (".");
         end if;
      end loop;
      New_Line;

      Close (Log_ID);
      Close (Synch_ID);
      Close (Det_ID);
      Stream_IO.Close (Source_ID);

      --  Put_Line
      --    (Routine_Name & "number of clicks and synchs: "  &
      --    Integer'Image (Num_Clicks) & ", " & Integer'Image (Num_Synchs));
      Put_Line (Routine_Name & "number of invalid items: " &
      Integer'Image (Num_Invalid));
      Put_Line
        (Routine_Name & Det_File & " file length: " &
           Natural'Image (Count_Text_File_Lines (Det_File)) & " lines");

      --  Put_Line (Routine_Name & Sync_File & " file length: " &
      --       Natural'Image (Count_Text_File_Lines (Sync_File)) & " lines");
      New_Line;

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;
   end NIST_Data;

   procedure Save_Match_List (File_Name : String; Index_Pairs : Match_List) is
     use Match_Package;
      Routine_Name : constant String :=
       "Process_Sync_Data.Save_Match_List ";
      Match_ID     : File_Type;
      M_Curs       : Cursor := First (Index_Pairs);
      Rec          : Index_Record;
   begin
      Create (Match_ID, Out_File, File_Name);
      while Has_Element (M_Curs) loop
         Rec :=  Element (M_Curs);
         Put_Line (Match_ID, Double_Positive'Image (Rec.A_Index) & "," &
         Double_Positive'Image (Rec.B_Index));
         Next (M_Curs);
      end loop;

      Close (Match_ID);
      Put_Line (Routine_Name & "Data written to " & File_Name);

   end Save_Match_List;

end Process_Data;
