
--  with Ada.Text_IO; use Ada.Text_IO;

--  with Data_Selection; use Data_Selection;
with NIST_Types; use NIST_Types;
with NIST_Utilities; use NIST_Utilities;
with NIST_Printing; use NIST_Printing;
--  with Printing; use Printing;
--  with Process_Detection_Data; use Process_Detection_Data;
with Process_Data; use Process_Data;
--  with Types; use Types;
--  with Utils; use Utils;

procedure Match is
   --  Routine_Name      : constant String := "Match ";
   In_Directory  : constant String := "../generated_nist_data/";
   A_Source      : constant String := In_Directory & "A.csv";
   B_Source      : constant String := In_Directory & "B.csv";
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
   Events              : Nist_Event_List;
   --  Num_Found           : Natural;
   --  A_Counts            : xxCounts;
   --  B_Counts            : xxCounts;
   --  Num_Matches         : Natural;
   --  Num_aa_Matches      : Natural;
   --  Num_ab_Matches      : Natural;
   --  Num_ba_Matches      : Natural;
   --  Num_bb_Matches      : Natural;
begin
   Load_NIST_Data (A_Source, A_Data);
   Load_NIST_Data (B_Source, B_Data);

   Align_Data (A_Data, B_Data);
   Build_Event_List (A_Data, B_Data, Events);
   Print_NIST_Data_List ("A_Data", A_Data, 88, 94);
   Print_NIST_Data_List ("B_Data", B_Data, 88, 94);

end Match;
