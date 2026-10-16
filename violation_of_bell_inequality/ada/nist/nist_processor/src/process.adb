
with Ada.Text_IO; use Ada.Text_IO;

--  with Data_Selection; use Data_Selection;
--  with Histogram; use Histogram;
with Process_Sync_Data; use Process_Sync_Data;
with Printing; use Printing;
with Types; use Types;
with Utils; use Utils;

procedure Process is
   Routine_Name        : constant String := "Process ";
   Directory           : constant String := "../generated_nist_data/";
   --  Det_Pairs_In    : constant String := Pairs_Directory & "combined_det.csv";
   A_Source            : constant String := Directory & "A.csv";
   B_Source            : constant String := Directory & "B.csv";
   --  Sync_Pairs_In       : constant String := Pairs_Directory & "combined_sync.csv";
       Matched_Sync    : constant String := Pairs_Directory & "matched_sync.csv";
   --  Matched_Det_Pairs : constant String :=
   --   Pairs_Directory & "matched_det_pairs.csv";
   Width               : constant Natural := 50000;
   Delta_Val           : Double_Natural;
   Num_Found           : Natural;
   Selected_Det_Pairs  : Match_List;
   Selected_Sync_Pairs : Match_List;
begin
   --  Put_Line (Routine_Name & "Sync_Pairs file size:" &
   --       Integer'Image (Count_Text_File_Lines (Sync_Pairs_In)) & " lines");
   Match_Syncs (A_Source, B_Source, Matched_Sync, Width, Num_Found,
               Selected_Sync_Pairs, Delta_Val);
   if Num_Found > 0 then
      Put_Line (Routine_Name & "matched sync pairs found:" &
       Integer'Image (Num_Found));
      Print_Match_List ("Selected_Pairs", Selected_Sync_Pairs, 1, 10);
   else
      Put_Line (Routine_Name & "No matched sync pairs found!");
   end if;

   --  Put_Line (Routine_Name & "Detection_Pairs file size:" &
   --       Integer'Image (Count_Text_File_Lines (Det_Pairs_In)) & " lines");
   Delta_Val := 55000;  --  max 23 at 55000, width 50000
   if Num_Found > 0 then
      Put_Line (Routine_Name & "matched detection pairs found:" &
       Integer'Image (Num_Found));
   else
      Put_Line (Routine_Name & "No matched detection pairs found!");
   end if;

   Put_Line (Routine_Name & "Matched_Det_Pairs file size:" &
        Integer'Image (Count_Text_File_Lines (Matched_Det_Pairs)) & " lines");
   Put_Line (Routine_Name & "Selected_Det_Pairs length " & integer'Image
          (integer (Match_Package.Length (Selected_Det_Pairs))));

   --  Select_Data
   --    (OEM_A, OEM_B,, Det_aa, Det_ab, Det_ba, Det_bb,
   --     A_Counts, B_Counts, Selected_Det_Pairs

   --  Num_aa_Matches := Number_Of_Matches (Det_aa);
   --  Num_ab_Matches := Number_Of_Matches (Det_ab);
   --  Num_ba_Matches := Number_Of_Matches (Det_ba);
   --  Num_bb_Matches := Number_Of_Matches (Det_bb);

   Put_Line (Routine_Name & "width: " & Natural'Image (Width));
   --  Put_Line (Routine_Name & "delta: " & Natural'Image (Delta_Val));

end Process;
