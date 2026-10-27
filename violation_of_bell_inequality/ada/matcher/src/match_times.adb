
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with Data_Selection; use Data_Selection;
with Process_Data; use Process_Data;
with Types; use Types;
with Utils; use Utils;

procedure Match_Times is
   Routine_Name     : constant String := "Match_Times ";
   A_Directory      : constant String := "../";
   B_Directory      : constant String := A_Directory;
   Result_Directory : constant String := "../generated_data/";
   Settings_File    : constant String := Result_Directory & "settings.csv";
   Photon_Times_A   : constant String := A_Directory & "A_Photon_Times.csv";
   Photon_Times_B   : constant String := B_Directory & "B_Photon_Times.csv";
   OEM_A            : constant String := A_Directory & "A_OEM.csv";
   OEM_B            : constant String := B_Directory & "B_OEM.csv";
   Pairs            : constant String := B_Directory & "Selected_Pairs.csv";
   OEM_aa           : constant String := Result_Directory & "OEM_aa.csv";
   OEM_ab           : constant String := Result_Directory & "OEM_ab.csv";
   OEM_ba           : constant String := Result_Directory & "OEM_ba.csv";
   OEM_bb           : constant String := Result_Directory & "OEM_bb.csv";
   Combined_Ns_5    : constant String := "../Combined_Ns_5.csv";
   Combined_Ns_50   : constant String := "../Combined_Ns_50.csv";
   Combined_Other   : constant String := "../Combined.csv";
   Combined_Data    : Unbounded_String;
   --  From A Close Look at the EPR Data of Weihs et al:
   --  G. Weihs used detection windows of 4-6 ns to identify coincidences.
   --  I find better results with windows 40-50 ns wide.

   Width            : constant Float := 2.0 * ns;
   Shift            : constant Float := 3.8 * ns;
   --  **** For normal use set Data_Length to 0
   Data_Length      : constant Natural := 0;
   Num_Found        : Natural;
   A_Counts         : xxCounts;
   B_Counts         : xxCounts;
   Min_Width        : Float;
   Max_Width        : Float;
   aa_Matches       : Natural;
   ab_Matches       : Natural;
   ba_Matches       : Natural;
   bb_Matches       : Natural;
   Selected_Pairs   : Match_List;
begin
   -- Set detector positions
   Set_Angles (0.0, 45.0, 0.0, 45.0);
   if Width = 5.0 * ns then
      Combined_Data := To_Unbounded_String (Combined_Ns_5);
   elsif Width = 50.0 * ns then
      Combined_Data := To_Unbounded_String (Combined_Ns_50);
   else
      Combined_Data := To_Unbounded_String (Combined_Other);
   end if;

   Put_Line
     (Routine_Name & "Photon_Times_A file size:" &
        Integer'Image (Count_Text_File_Lines (Photon_Times_A)) & " lines");
   Put_Line
     (Routine_Name & "Photon_Times_B file size:" &
        Integer'Image (Count_Text_File_Lines (Photon_Times_B)) & " lines");

   Match_Photon_Times (Photon_Times_A, Photon_Times_B, Pairs,
                       Shift, Width, Num_Found, Selected_Pairs, Data_Length);
   Select_OEM_Data (OEM_A, OEM_B, OEM_aa, OEM_ab, OEM_ba, OEM_bb,
         Settings_File, A_Counts, B_Counts, Selected_Pairs);
   New_Line;

   aa_Matches := Number_Of_Matches (OEM_aa);
   ab_Matches := Number_Of_Matches (OEM_ab);
   ba_Matches := Number_Of_Matches (OEM_ba);
   bb_Matches := Number_Of_Matches (OEM_bb);
   Put_Line (Routine_Name & "Number of aa matches :" &
               Integer'Image (aa_Matches));
   Put_Line (Routine_Name & "Number of ab matches :" &
               Integer'Image (ab_Matches));
   Put_Line (Routine_Name & "Number of ba matches :" &
               Integer'Image (ba_Matches));
   Put_Line (Routine_Name & "Number of bb matches :" &
               Integer'Image (bb_Matches));
   New_Line;
   Find_Raw_Window_Width (Photon_Times_A, Photon_Times_B, Shift,
                          Min_Width, Max_Width);

   Put_Line (Routine_Name & "raw data minimum and maximum widths: " &
               Float'Image (Min_Width) & ", " & Float'Image (Max_Width));
   Put_Line (Routine_Name & "coincidence test width :" &
               Float'Image (Width) & " ns");
   Print_xxCounts ("A counts", A_Counts);
   Print_xxCounts ("B counts", B_Counts);
   --  Set stack size: ulimit -s 64000 if needed
   --   to prevent Combine stack overflow
   --  Combine (OEM_aa, OEM_ab, OEM_ba, OEM_bb,
   --   To_String (Combined_Data), Data_Length);
   Put_Line (Routine_Name & "Width: " & Float'Image (Width) & " ns");
   Put_Line (Routine_Name & "Shift: " & Float'Image (Shift) & " ns");

end Match_Times;
