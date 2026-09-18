
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
   Directory     : constant String := "../generated_nist_data/";
   A_Source      : constant String := Directory & "A.csv";
   B_Source      : constant String := Directory & "B.csv";
   aa            : constant String := Directory & "aa.csv";
   ab            : constant String := Directory & "ab.csv";
   ba            : constant String := Directory & "ba.csv";
   bb            : constant String := Directory & "bb.csv";
   --  Num_Rows            : constant Types.Double_Natural := 30000;
   A_Data        : Nist_Data_List;
   B_Data        : Nist_Data_List;
   Events        : Nist_Event_List;
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
   Save_Events (aa, ab, ba, bb, Events);

end Match;
