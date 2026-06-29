
with Ada.Text_IO; use Ada.Text_IO;
--  with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

--  with Data_Selection; use Data_Selection;
--  with Printing; use Printing;
with Process_Detection_Data; use Process_Detection_Data;
with Process_Sync_Data; use Process_Sync_Data;
with Types; use Types;
with Utils; use Utils;

procedure Match_Sync_Times is
   Routine_Name    : constant String := "Match_Sync_Times ";
   Pairs_Directory : constant String := "../nist_03_12_ch/";
   Detection_Pairs : constant String := Pairs_Directory & "combined_det.csv";
   Sync_Pairs      : constant String := Pairs_Directory & "combined_sync.csv";
   Matched_Sync    : constant String := Pairs_Directory & "matched_sync.csv";
   Matched_Det     : constant String := Pairs_Directory & "matched_det.csv";
   Width           : constant Natural := 1000;
   Delta_Val       : Double_Natural;
   --  **** For normal use set Data_Length to 0
   Data_Length      : constant Natural := 0;
   Num_Found        : Natural;
   --  A_Counts         : xxCounts;
   --  B_Counts         : xxCounts;
   --  Min_Width        : Float;
   --  Max_Width        : Float;
   --  aa_Matches       : Natural;
   --  ab_Matches       : Natural;
   --  ba_Matches       : Natural;
   --  bb_Matches       : Natural;
   Selected_Det_Pairs    : Match_List;
   Selected_Sync_Pairs   : Match_List;
begin
   --  Put_Line (Routine_Name & "Det_Pairs file size:" &
   --       Integer'Image (Count_Text_File_Lines (Det_Pairs)) & " lines");
   Put_Line (Routine_Name & "Sync_Pairs file size:" &
        Integer'Image (Count_Text_File_Lines (Sync_Pairs)) & " lines");
   --  for del in 0 .. Delta_Val loop
   --     if del mod 100000 = 0 then
   --         Put_Line ("del: " & Integer'Image (del));
         --  Match_Syncs (Det_Pairs, Matched_Det, Delta_Val, Width, Num_Found,
         --   Selected_Det_Pairs, Data_Length);
         --  Put_Line ("Num_Found: " & Integer'Image (Num_Found));
         --   New_Line;
   --      end if;
   --  end loop;

   Match_Syncs (Sync_Pairs, Matched_Sync, Width, Num_Found,
               Selected_Sync_Pairs, Delta_Val, Data_Length);

   if Num_Found > 0 then
      Put_Line (Routine_Name & "matched sync pairs found:" &
       Integer'Image (Num_Found));
      --  Print_Match_List ("Selected_Pairs", Selected_Sync_Pairs, 1, 10);
   else
      Put_Line (Routine_Name & "No matched sync pairs found!");
   end if;

   Match_Data_Times (Detection_Pairs, Matched_Det, Delta_Val);
   --  aa_Matches := Number_Of_Matches (OEM_aa);
   --  ab_Matches := Number_Of_Matches (OEM_ab);
   --  ba_Matches := Number_Of_Matches (OEM_ba);
   --  bb_Matches := Number_Of_Matches (OEM_bb);
   --  Put_Line (Routine_Name & "Number of aa matches :" &
   --              Integer'Image (aa_Matches));
   --  Put_Line (Routine_Name & "Number of ab matches :" &
   --              Integer'Image (ab_Matches));
   --  Put_Line (Routine_Name & "Number of ba matches :" &
   --              Integer'Image (ba_Matches));
   --  Put_Line (Routine_Name & "Number of bb matches :" &
   --              Integer'Image (bb_Matches));
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

end Match_Sync_Times;
