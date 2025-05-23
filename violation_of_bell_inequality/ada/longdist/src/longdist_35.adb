
with Process_Data; use Process_Data;
--  with Combine_CSVs; use Combine_CSVs;

procedure Longdist_35 is
   A_Directory : constant String :=
     "../../longdist35/alice_timetags/";
   B_Directory : constant String :=
     "../../longdist35/bob_timetags/";
   AV_Source    : constant String := A_Directory & "longdist35_V.dat";
   BV_Source    : constant String := B_Directory & "longdist35_V.dat";
   AC_Source    : constant String := A_Directory & "longdist35_C.dat";
   BC_Source    : constant String := B_Directory & "longdist35_C.dat";
   AV_Target    : constant String := "../A_Photon_Times.csv";
   BV_Target    : constant String := "../B_Photon_Times.csv";
   AC_Target    : constant String := "../A_OEM.csv";
   BC_Target    : constant String := "../B_OEM.csv";
begin
   Photon_Data (AV_Source, AV_Target);
   Photon_Data (BV_Source, BV_Target);

   OEM_Data (AC_Source, AC_Target);
   OEM_Data (BC_Source, BC_Target);

   --  Combine (AV_Target, BV_Target, AC_Target, BC_Target);

end Longdist_35;
