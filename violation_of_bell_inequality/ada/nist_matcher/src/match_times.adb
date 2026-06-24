
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

--  with Data_Selection; use Data_Selection;
with Printing; use Printing;
with Process_Data; use Process_Data;
with Types; use Types;
with Utils; use Utils;

procedure Match_Times is
   Routine_Name     : constant String := "Match_Times ";
   Pairs_Directory : constant String := "../nist_03_45_ch/";
   Pairs_CSV        : constant String := Pairs_Directory & "combined.csv";
   Ns_5            : constant String := "../ns_5.csv";
   Other           : constant String := "../other.csv";
   Data            : Unbounded_String;

   Width            : constant Natural := 100000;
   Delta_Val        :  Natural := 3;
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
   if Width = 50000 then
      Data := To_Unbounded_String (Ns_5);
   else
      Data := To_Unbounded_String (Other);
   end if;

   Put_Line (Routine_Name & "Pairs file size:" &
        Integer'Image (Count_Text_File_Lines (Pairs_CSV)) & " lines");

   --  for del in 0 .. Delta_Val loop
   --     if del mod 100000 = 0 then
   --         Put_Line ("del: " & Integer'Image (del));
         Match_Data_Times (Pairs_CSV, Other, Delta_Val, Width, Num_Found, Selected_Pairs,
                     Data_Length);
         Put_Line ("Num_Found: " & Integer'Image (Num_Found));
          New_Line;
   --      end if;
   --  end loop;

   --  if Num_Found > 0 then
   --  Put_Line (Routine_Name & "Pairs found:" & Integer'Image (Num_Found));
   --     Print_Match_List ("Selected_Pairs", Selected_Pairs, 1, 10);
   --  else
   --     Put_Line (Routine_Name & "No matched pairs found!");
   --  end if;

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
   Put_Line (Routine_Name & "delta: " & Natural'Image (Delta_Val));

end Match_Times;
