
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

--  with Data_Selection; use Data_Selection;
with Process_Data; use Process_Data;
with Types; use Types;
with Utils; use Utils;

procedure Match_Times is
   Routine_Name     : constant String := "Match_Times ";
   Pairs_Directory : constant String := "../nist_03_45_ch";
   Pairs_CSV        : constant String := Pairs_Directory & "combined.csv";
   Ns_5            : constant String := "../ns_5.csv";
   Other           : constant String := "../other.csv";
   Data            : Unbounded_String;

   Width            : constant Float := 5.0 * ns;
   Delta_Val        : constant Float := 0.0 * ns;
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
   Selected_Pairs   : Match_List;
begin
   if Width = 5.0 * ns then
      Data := To_Unbounded_String (Ns_5);
   else
      Data := To_Unbounded_String (Other);
   end if;

   Put_Line
     (Routine_Name & "Pairs file size:" &
        Integer'Image (Count_Text_File_Lines (Pairs_CSV)) & " lines");

   Match_Photon_Times (Pairs_CSV, Delta_Val, Width, Num_Found,
                      Selected_Pairs, Data_Length);
   New_Line;

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
   --              Float'Image (Min_Width) & ", " & Float'Image (Max_Width));
   --  Put_Line (Routine_Name & "coincidence test width :" &
   --              Float'Image (Width) & " ns");
   --  Print_xxCounts ("A counts", A_Counts);
   --  Print_xxCounts ("B counts", B_Counts);
   --  Set stack size:  ulimit -s 64000 to prevent Combine stack overflow
   --  Combine (OEM_aa, OEM_ab, OEM_ba, OEM_bb,
   --   To_String (Combined_Data), Data_Length);
   Put_Line (Routine_Name & "width: " & Float'Image (Width) & " ns");
   Put_Line (Routine_Name & "delta: " & Float'Image (Delta_Val) & " ns");

end Match_Times;
