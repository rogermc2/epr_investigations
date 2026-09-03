
with Ada.Text_IO; use Ada.Text_IO;

with Data_Selection; use Data_Selection;
with Printing; use Printing;
with Process_Detection_Data; use Process_Detection_Data;
with Process_Sync_Data; use Process_Sync_Data;
with Types; use Types;
with Utils; use Utils;

procedure Match_Times is
   Routine_Name    : constant String := "Match_Times ";
   Pairs_Directory : constant String := "../generated_nist_data/";
   Det_Pairs_In    : constant String := Pairs_Directory & "combined_det.csv";
   Sync_Pairs_In   : constant String := Pairs_Directory & "combined_sync.csv";
   Matched_Sync    : constant String := Pairs_Directory & "matched_sync.csv";
   Matched_Indices  : constant String :=
    Pairs_Directory & "matched_det_indices.csv";
   Det_aa          : constant String := Pairs_Directory & "aa.csv";
   Det_ab          : constant String := Pairs_Directory & "ab.csv";
   Det_ba          : constant String := Pairs_Directory & "ba.csv";
   Det_bb          : constant String := Pairs_Directory & "bb.csv";
   Width           : constant Natural := 50000;
   Delta_Val       : Double_Natural;
   Num_Found        : Natural;
   A_Counts         : xxCounts;
   B_Counts         : xxCounts;
   --  Min_Width        : Float;
   --  Max_Width        : Float;
   --  Num_Matches         : Natural;
   --  Num_aa_Matches      : Natural;
   --  Num_ab_Matches      : Natural;
   --  Num_ba_Matches      : Natural;
   --  Num_bb_Matches      : Natural;
   Selected_Det_Pairs  : Match_List;
   Selected_Sync_Pairs : Match_List;
begin
   --  Put_Line (Routine_Name & "Sync_Pairs file size:" &
   --       Integer'Image (Count_Text_File_Lines (Sync_Pairs_In)) & " lines");
   Match_Syncs (Sync_Pairs_In, Matched_Sync, Width, Num_Found,
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
   Match_Detection_Times (Det_Pairs_In, Matched_Indices, Width, Delta_Val,
   Num_Found, Selected_Det_Pairs);
   Put_Line (Routine_Name & "Matched_Det_Indices file size:" &
        Integer'Image (Count_Text_File_Lines (Matched_Indices)) & " lines");
   Put_Line (Routine_Name & "Selected_Det_Pairs length " &
          integer'Image
          (integer (Match_Package.Length (Selected_Det_Pairs))));
   --  Num_Matches := Number_Of_Matches (Matched_Det);

   --  Select_Data (Matched_Det, Det_aa, Det_ab, Det_ba, Det_bb,
   --   A_Counts, B_Counts, Selected_Det_Pairs);

   --  Num_aa_Matches := Number_Of_Matches (Matched_Det);
   --  Num_ab_Matches := Number_Of_Matches (OEM_ab);
   --  Num_ba_Matches := Number_Of_Matches (OEM_ba);
   --  Num_bb_Matches := Number_Of_Matches (OEM_bb);
   --  Put_Line (Routine_Name & "Number of detection matches :" &
   --             Integer'Image (Num_Matches));
   --  Put_Line (Routine_Name & "Number of ab matches :" &
   --           Integer'Image (Num_ab_Matches));
   --  Put_Line (Routine_Name & "Number of ba matches :" &
   --         Integer'Image (Num_ba_Matches));
   --  Put_Line (Routine_Name & "Number of bb matches :" &
   --           Integer'Image (Num_bb_Matches));
   --  New_Line;
   --  Find_Raw_Window_Width (Photon_Times_A, Photon_Times_B, Delta_Val,
   --                         Min_Width, Max_Width);

   --  Put_Line (Routine_Name & "raw data minimum and maximum widths: " &
   --              Natural'Image (Min_Width) & ", " & Natural'Image (Max_Width));
   --  Put_Line (Routine_Name & "coincidence test width :" &
   --              Natural'Image (Width) & " ns");
   --  Print_xxCounts ("A counts", A_Counts);
   --  Print_xxCounts ("B counts", B_Counts);
   --  Set stack size:  ulimit -s 64000 to prevent Combine stack overflow
   --  Combine (OEM_aa, OEM_ab, OEM_ba, OEM_bb,
   --   To_String (Combined_Data), Data_Length);
   Put_Line (Routine_Name & "width: " & Natural'Image (Width));
   --  Put_Line (Routine_Name & "delta: " & Natural'Image (Delta_Val));

end Match_Times;
