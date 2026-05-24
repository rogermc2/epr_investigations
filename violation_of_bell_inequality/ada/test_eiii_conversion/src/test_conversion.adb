
with Utils; use Utils;

procedure Test_Conversion is

   A_Directory : constant String :=
     "../../longdist35/alice_timetags/";
   A_Source    : constant String := A_Directory & "longdist35_V.dat";
   A_Target    : constant String := A_Directory & "longdist35_V.txt";
begin
   Convert_To_Text (A_Source, A_Target);
   Photon_Data (A_Target, A_Directory);

end Test_Conversion;
