
with Process_Data; use Process_Data;

procedure Photon_Times is
   A_Directory : constant String :=
     "../../longdist35/alice_timetags/";
   B_Directory : constant String :=
     "../../longdist35/bob_timetags/";
   A_Source    : constant String := A_Directory & "longdist35_V.dat";
   B_Source    : constant String := B_Directory & "longdist35_V.dat";
begin
   Photon_Data (A_Source, A_Directory);
   Photon_Data (B_Source, B_Directory);

end Photon_Times;
