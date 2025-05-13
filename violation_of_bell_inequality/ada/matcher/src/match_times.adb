
with Process_Data; use Process_Data;
with Data_Selection; use Data_Selection;

procedure Match_Times is
   A_Directory : constant String :=
     "../../longdist35/alice_timetags/";
   B_Directory : constant String :=
     "../../longdist35/bob_timetags/";
   Photon_Times_A  : constant String := A_Directory & "Photon_Times.csv";
   Photon_Times_B  : constant String := B_Directory & "Photon_Times.csv";
   Matched_Times   : constant String := "../Matched_Times.csv";
   Selected_Pairs  : Match_List;
  begin
   Match_Photon_Times (Photon_Times_A, Photon_Times_B, Matched_Times);
   Select_Pairs (Matched_Times, Selected_Pairs);

end Match_Times;
