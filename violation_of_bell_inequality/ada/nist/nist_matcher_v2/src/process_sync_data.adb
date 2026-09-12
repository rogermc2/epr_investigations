
--  with Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

with Histogram;
--  with NIST_Types; use NIST_Types;
--  with NIST_Utilities; use NIST_Utilities;

package body Process_Sync_Data is

   procedure Save_Match_List (File_Name : String; Index_Pairs : Match_List);

   procedure Load_Sync_Data
      (CSV_Data : String; Sync_Data : in out Double_Natural_Vector;
         Num_Rows : Double_Natural) is
      use Double_Natural_Package;
      Routine_Name : constant String := "Process_Sync_Data.Load_Sync_Data ";
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
      Put_Line (Routine_Name & "Count " & Double_Natural'Image (Count));
      Put_Line (Routine_Name & "Sync_Data loaded from " & CSV_Data);
      New_Line;

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
      D_Width      : constant Double_Natural := Double_Natural (Width);
      B_Curs       : Double_Natural_Package.Cursor := B_Sync_Data.First;
      Count        : Natural := 0;

         procedure Find_Sync_Match (A_Curs : Double_Natural_Package.Cursor) is
         A_Item    : constant Double_Natural := Element (A_Curs);
         A_Time    : constant Double_Natural := A_Item + D_Width;
         B_Val_Min : constant Double_Natural := A_Time - D_Width;
         Item      : Index_Record;
         B_Time    : Double_Natural;
         Match     : Boolean := False;
         begin
            Count := Count + 1;
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
                     if Num_Found < 6 then
                        Put_Line (Routine_Name & "Find_Match, A, B index:" &
                        Double_Positive'Image (Item.A_Index) & ",  " &
                                    Double_Positive'Image (Item.B_Index));
                     end if;
                  end if;
               end if;
            end if;

         exception
            when Error : others =>
               Put_Line (Routine_Name & Exception_Information (Error));
               raise;

         end Find_Sync_Match;

   begin
      Num_Found := 0;

      --  If Align_Sync_Data is not called for Sync data, Draw_Histagram will
      --  exhibit a Bin index out of range error.
      --  Align_Timing_Data is called to align two data sets
      --  to the same time frame.
      --  The histogram is drawn to verify the alignment.
      Offset := Draw_Histogram  (A_Sync_Data, B_Sync_Data);

      B_Curs := First (B_Sync_Data);
      --  Next (B_Curs);  --  Skip header
      A_Sync_Data.Iterate (Find_Sync_Match'Access);
      New_Line;

      Save_Match_List (Matched_Sync_CSV, Selected_Pairs);

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
         Put_Line (Match_ID, Double_Positive'Image (Rec.A_Index) & ", " &
         Double_Positive'Image (Rec.B_Index));
         Next (M_Curs);
      end loop;

      Close (Match_ID);
      Put_Line (Routine_Name & "Data written to " & File_Name);

   end Save_Match_List;

end Process_Sync_Data;
