
--  with Ada.Text_IO; use Ada.Text_IO;

--  with Data_Selection; use Data_Selection;
with NIST_Types; use NIST_Types;
--  with NIST_Utilities; use NIST_Utilities;
--  with NIST_Printing; use NIST_Printing;
--  with Printing; use Printing;
--  with Process_Detection_Data; use Process_Detection_Data;
with Process_Data; use Process_Data;
--  with Types; use Types;
--  with Utils; use Utils;

procedure Match is
   --  Routine_Name      : constant String := "Match ";
   --  Pairs_Directory   : constant String := "../generated_nist_data/";
   A_In_Directory   : constant String := "../../../../nist_data/";
   B_In_Directory   : constant String := A_In_Directory;
   --  Target_Dir    : constant String := "../generated_nist_data/";
   A_Source      : constant String := A_In_Directory &
    "03_12_CH_pockel_100kHz.run.Blind_2.alice.dat.compressed";
   B_Source      : constant String := B_In_Directory &
   "03_12_CH_pockel_100kHz.run.Blind_2.bob.dat.compressed";
   --  Matched_Sync      : constant String := Pairs_Directory & "matched_sync.csv";
   --  Matched_Det_Pairs : constant String :=
   --   Pairs_Directory & "matched_det_pairs.csv";
   --  Det_aa              : constant String := Pairs_Directory & "aa.csv";
   --  Det_ab              : constant String := Pairs_Directory & "ab.csv";
   --  Det_ba              : constant String := Pairs_Directory & "ba.csv";
   --  Det_bb              : constant String := Pairs_Directory & "bb.csv";
   --  Width               : constant Natural := 11;
   --  Num_Rows            : constant Types.Double_Natural := 30000;
   A_Data              : Nist_Data_List;
   B_Data              : Nist_Data_List;
   --  Delta_Time          : Double_Natural;
   --  Num_Found           : Natural;
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
   --  Selected_Sync_Pairs : Match_List;
begin
   Load_NIST_Data (A_Source, A_Data);
   Load_NIST_Data (B_Source, B_Data);

   --  Align_Data (A_Sync_Data, B_Sync_Data, A_Det_Data, B_Det_Data);
   --  Match_Syncs (A_Sync_Data, B_Sync_Data, Matched_Sync, Width, Num_Found,
   --              Selected_Sync_Pairs, Delta_Time);
   --  Print_Match_List ("Selected_Sync_Pairs", Selected_Sync_Pairs, 1000, 1010);
   --  Print_Double_Natural_Vector ("A_Sync_Data", A_Sync_Data, 1, 5);
   --  Print_Double_Natural_Vector ("B_Sync_Data", B_Sync_Data, 1, 5);
   --  if Num_Found > 0 then
   --     Put_Line (Routine_Name & "matched sync pairs found:" &
   --      Integer'Image (Num_Found));
   --     Print_Match_List ("Selected_Pairs", Selected_Sync_Pairs, 1, 10);
   --  else
   --     Put_Line (Routine_Name & "No matched sync pairs found!");
   --  end if;

   --  Put_Line (Routine_Name & "Detection A and B file sizes:" &
   --       Integer'Image (Count_Text_File_Lines (A_Det_In))  & "," &
   --       Integer'Image (Count_Text_File_Lines (B_Det_In)) & " lines");

   --  Match_Detection_Times (A_Det_Data, B_Det_Data, Matched_Det_Pairs, Width,
   --  Delta_Time, Num_Matches);
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

   --  Put_Line (Routine_Name & "width: " & Natural'Image (Width));
   --  Put_Line (Routine_Name & "delta: " & Natural'Image (Delta_Val));

end Match;
