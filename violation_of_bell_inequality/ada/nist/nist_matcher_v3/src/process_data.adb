
--  with Ada.Assertions; use Ada.Assertions;
with Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Strings;
with Ada.Strings.Fixed ;
with Ada.Text_IO; use Ada.Text_IO;

with Histogram;
--  with Printing; use Printing;

package body Process_Data is

   procedure Save_Match_List (File_Name : String; Index_Pairs : Match_List);

   procedure Load_NIST_Data (Source_File : String;
    NIST_Data : out Nist_Data_List) is
      use Ada.Strings;
      use Ada.Strings.Fixed;
      use Nist_Data_Package;
      Routine_Name : constant String  := "Process_Data.Load_NIST_Data ";
      Source_Size  : constant Double_Natural :=
         Double_Natural (Ada.Directories.Size (Source_File));
      Source_ID    : File_Type;
      Data         : Data_Record;
      Line_Num     : Double_Natural := 0;
   begin
      Put_Line (Routine_Name & "Source File: " & Source_File);
      Put_Line (Routine_Name & Source_File & " length: " &
         Double_Natural'Image (Source_Size));
      New_Line;
      Put_Line (Routine_Name &
       Source_File (Source_File'First + 19 .. Source_File'Last) & " size: " &
                     Double_Natural'Image (Source_Size));
      Open (Source_ID, In_File, Source_File);

      while not End_Of_File (Source_ID) loop
        Line_Num := Line_Num + 1;
         declare
            aline : constant String := Get_Line (Source_ID);
            Pos_1 : constant Natural :=
             Index (aLine (aLine'First .. aLine'Last), ",");
            Pos_2 : constant Natural :=
             Index (aLine (Pos_1 + 1 .. aLine'Last), ",");
         begin
            if Pos_1 - aline'First > 1 then
               Data.Channel :=
               Channel_Type'Value (aline (aline'First .. Pos_1 - 1));
               Data.Time_Tag :=
                  Double_Positive'Value (aline (Pos_1 + 1 .. Pos_2 - 1));
               Data.Transfer_ID := Integer'Value (aline (Pos_2 + 1 .. aLine'Last));
               --  Assert (Data.Time_Tag > 0, "Data.Time_Tag invalid: " &
               --  Double_Positive'Image (Data.Time_Tag));
            else
               Put_Line (Routine_Name & "aline'First, Pos_1: " &
               Integer'Image (aline'First) & "," & Integer'Image (Pos_1));
            end if;
        end;

         if Data.Channel /= Overflow then
            NIST_Data.Append (Data);
         end if;

         if Line_Num mod 4000000 = 0 then
            Put (".");
         end if;
      end loop;
      New_Line;

      Close (Source_ID);

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;
   end Load_NIST_Data;

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
