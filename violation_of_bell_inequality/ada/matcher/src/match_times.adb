
with Process_Data; use Process_Data;

procedure Match_Times is
   A_Directory : constant String :=
     "../../longdist35/alice_timetags/";
   B_Directory : constant String :=
     "../../longdist35/bob_timetags/";
   Photon_Times_A  : constant String := A_Directory & "Photon_Times.csv";
   Photon_Times_B  : constant String := B_Directory & "Photon_Times.csv";
   Matched_Times   : constant String := "../Matched_Times.csv";
  begin
   Match_Photon_Times (Photon_Times_A, Photon_Times_B, Matched_Times);

end Match_Times;
