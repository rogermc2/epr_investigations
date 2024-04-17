
with Utils; use Utils;

procedure Longdist is

   A_Directory : constant String :=
     "../longdist35/alice_timetags/";
   B_Directory : constant String :=
     "../longdist35/bob_timetags/";
   A_Source    : constant String := A_Directory & "longdist35_Corig.dat";
   A_Target    : constant String := A_Directory & "longdist35_C.txt";
   B_Source    : constant String := B_Directory & "longdist35_C.dat";
   B_Target    : constant String := B_Directory & "longdist35_C.txt";
begin
   Convert_To_Text (A_Source, A_Target);
   Convert_To_Text (B_Source, B_Target);

   OEM_Data (A_Target, A_Directory);
   OEM_Data (B_Target, B_Directory);

end Longdist;
