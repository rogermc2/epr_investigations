
with Utils; use Utils;

procedure Longdist_OEM is

   A_Directory : constant String :=
     "../../longdist35/alice_timetags/";
   B_Directory : constant String :=
     "../../longdist35/bob_timetags/";
   A_Source    : constant String := A_Directory & "longdist35_C.dat";
   B_Source    : constant String := B_Directory & "longdist35_C.dat";
begin

   OEM_Data (A_Source, A_Directory);
   OEM_Data (B_Source, B_Directory);

end Longdist_OEM;
