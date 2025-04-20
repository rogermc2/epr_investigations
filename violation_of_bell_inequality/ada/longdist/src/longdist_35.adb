
with Process_Data; use Process_Data;
with Utils; use Utils;

procedure Longdist_35 is
   A_Directory : constant String :=
     "../../longdist35/alice_timetags/";
   B_Directory : constant String :=
     "../../longdist35/bob_timetags/";
   AV_Source    : constant String := A_Directory & "longdist35_V.dat";
   BV_Source    : constant String := B_Directory & "longdist35_V.dat";
   AC_Source    : constant String := A_Directory & "longdist35_C.dat";
   BC_Source    : constant String := B_Directory & "longdist35_C.dat";
begin
   Photon_Data (AV_Source, A_Directory);
   Photon_Data (BV_Source, B_Directory);

   OEM_Data (AC_Source, A_Directory);
   OEM_Data (BC_Source, B_Directory);

end Longdist_35;
