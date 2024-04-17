
with Utils; use Utils;

procedure Photon_Times is

   A_Directory : constant String :=
     "../../longdist35/alice_timetags/";
   B_Directory : constant String :=
     "../../longdist35/bob_timetags/";
   A_Source    : constant String := A_Directory & "longdist35_V.dat";
   A_Target    : constant String := A_Directory & "longdist35_V.txt";
   B_Source    : constant String := B_Directory & "longdist35_V.dat";
   B_Target    : constant String := B_Directory & "longdist35_V.txt";
begin
   Convert_To_Text (A_Source, A_Target);
   Convert_To_Text (B_Source, B_Target);

   Photon_Data (A_Target, A_Directory);
   Photon_Data (B_Target, B_Directory);

end Photon_Times;
