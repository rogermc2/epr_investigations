
with Ada.Text_IO; use Ada.Text_IO;

--  with Data_Selection; use Data_Selection;
with NIST_Types; use NIST_Types;
with NIST_Utilities; use NIST_Utilities;
with Printing; use Printing;
with Process_Sync_Data; use Process_Sync_Data;
with Types; use Types;

procedure Match is
   Routine_Name      : constant String := "Match ";
   Pairs_Directory   : constant String := "../generated_nist_data/";
   --  A_Det_In          : constant String := Pairs_Directory & "A_Det.csv";
   --  B_Det_In          : constant String := Pairs_Directory & "B_Det.csv";
   A_Sync_In         : constant String := Pairs_Directory & "A_Sync.csv";
   B_Sync_In         : constant String := Pairs_Directory & "B_Sync.csv";
   Matched_Sync      : constant String := Pairs_Directory & "matched_sync.csv";
   --  Matched_Det_Pairs : constant String :=
   --   Pairs_Directory & "matched_det_pairs.csv";
   --  Det_aa              : constant String := Pairs_Directory & "aa.csv";
   --  Det_ab              : constant String := Pairs_Directory & "ab.csv";
   --  Det_ba              : constant String := Pairs_Directory & "ba.csv";
   --  Det_bb              : constant String := Pairs_Directory & "bb.csv";
   Width               : constant Natural := 50000;
   A_Sync_Data         : Setting_Time_Vector;
   B_Sync_Data         : Setting_Time_Vector;
   --  A_Det_Data          : Setting_Time_Vector;
   --  B_Det_Data          : Setting_Time_Vector;
   A_Gt_B              : Boolean;
   Align_Delta         : Double_Natural;
   Align_Offset        : Double_Natural;
   Delta_Val           : Double_Natural;
   Num_Found           : Natural;
   --  A_Counts            : xxCounts;
   --  B_Counts            : xxCounts;
   --  Min_Width       : Float;
   --  Max_Width       : Float;
   --  Num_Matches         : Natural;
   --  Num_aa_Matches      : Natural;
   --  Num_ab_Matches      : Natural;
   --  Num_ba_Matches      : Natural;
   --  Num_bb_Matches      : Natural;
   --  Selected_Det_Pairs  : Match_List;
   Selected_Sync_Pairs : Match_List;
begin
   --  Put_Line (Routine_Name & "Sync_Pairs file size:" &
   --       Integer'Image (Count_Text_File_Lines (Sync_Pairs_In)) & " lines");

   Load_Sync_Data (A_Sync_In, A_Sync_Data);
   Load_Sync_Data (B_Sync_In, B_Sync_Data);
   Load_Sync_Data
      (B_Sync_In, B_Sync_Data);
   Align_Sync_Data (A_Sync_Data, B_Sync_Data, Align_Delta, Align_Offset, A_Gt_B);
   Match_Syncs (A_Sync_Data, B_Sync_Data, Matched_Sync, Width, Num_Found,
               Selected_Sync_Pairs, Align_Delta, Align_Offset, Delta_Val, A_Gt_B);
   if Num_Found > 0 then
      Put_Line (Routine_Name & "matched sync pairs found:" &
       Integer'Image (Num_Found));
      Print_Match_List ("Selected_Pairs", Selected_Sync_Pairs, 1, 10);
   else
      Put_Line (Routine_Name & "No matched sync pairs found!");
   end if;

   --  Put_Line (Routine_Name & "Detection_Pairs file size:" &
   --       Integer'Image (Count_Text_File_Lines (Det_Pairs_In)) & " lines");
   --  Delta_Val := 55000;  --  max 23 at 55000, width 50000
   --  Match_Detection_Times (A_Det_In, B_Det_In, Matched_Det_Pairs, Width,
   --  Align_Delta, Align_Offset, A_Gt_B,
   --   Delta_Val, Num_Matches, Selected_Det_Pairs);
   --  if Num_Matches > 0 then
   --     Put_Line (Routine_Name & "matched detection pairs found:" &
   --      Integer'Image (Num_Matches));
   --  else
   --     Put_Line (Routine_Name & "No matched detection pairs found!");
   --  end if;

   --  Put_Line (Routine_Name & "Matched_Det_Pairs file size:" &
   --       Integer'Image (Count_Text_File_Lines (Matched_Det_Pairs)) & " lines");
   --  Put_Line (Routine_Name & "Selected_Det_Pairs length " & integer'Image
   --         (integer (Match_Package.Length (Selected_Det_Pairs))));
   --  --  Num_Matches := Number_Of_Matches (Matched_Det);

   --  Select_Data (Matched_Det_Pairs, Det_aa, Det_ab, Det_ba, Det_bb,
   --       A_Counts, B_Counts, Selected_Det_Pairs);

   Put_Line (Routine_Name & "width: " & Natural'Image (Width));
   --  Put_Line (Routine_Name & "delta: " & Natural'Image (Delta_Val));

end Match;
