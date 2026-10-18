
with Ada.Text_IO; use Ada.Text_IO;

with Histogram; use Histogram;
with NIST_Printing; use NIST_Printing;
with NIST_Types; use NIST_Types;
with NIST_Utilities; use NIST_Utilities;
with Process_Data; use Process_Data;
with Types; use Types;

procedure Match is
   Routine_Name  : constant String := "Match ";
   Directory     : constant String := "../generated_nist_data/";
   A_Source      : constant String := Directory & "A.csv";
   B_Source      : constant String := Directory & "B.csv";
   A_Aligned     : constant String := Directory & "A_Aligned.csv";
   B_Aligned     : constant String := Directory & "B_Aligned.csv";
   aa            : constant String := Directory & "aa.csv";
   ab            : constant String := Directory & "ab.csv";
   ba            : constant String := Directory & "ba.csv";
   bb            : constant String := Directory & "bb.csv";
   A_Data        : Nist_Data_List;
   B_Data        : Nist_Data_List;
   Delta_Val     : Double_Natural;
   Events        : Nist_Event_List;
   Data_Size     : constant Natural := 0;
begin
   Load_NIST_Data (A_Source, A_Data, Data_Size);
   Load_NIST_Data (B_Source, B_Data, Data_Size);

   Align_Data (A_Data, B_Data);
   Save_Aligned_Data (A_Aligned, A_Data);
   Save_Aligned_Data (B_Aligned, B_Data);
   Print_NIST_Data_List ("A_Aligned", A_Data, 9, 17);
   Print_NIST_Data_List ("B_Aligned", B_Data, 9, 17);
   --  From Process:  Delta_Val := 55000;  --  max 23 at 55000, width 50000
   Delta_Val := Draw_Histogram  (A_Data, B_Data);
   Put_Line (Routine_Name & "Delta_Val" & Double_Natural'Image (Delta_Val));

   --  Use Events_1 for 03_12_CH_pockel_100kHz.run.Blind_2
   --  Use Events_2 for 02_54_CH_pockel_100kHz.run4.afterTimingfix2
   Events := Build_Event_List (A_Data, B_Data, Events_2);
   Print_NIST_Event_List ("Events", Events, 1, 6);
   Save_Events (aa, ab, ba, bb, Events);

end Match;
