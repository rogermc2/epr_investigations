
with Types; use Types;
with Utils; use Utils;

procedure Longdist is
   Hex_Source   : constant String :=
                    "../longdist35/alice_timetags/longdist35_Corig.dat";
   Text_Target  : constant String :=
                    "../longdist35/alice_timetags/longdist35_C.txt";
   Hex_Data     : Bounded_String_List;
begin

   Hex_Data := Load_Data (Hex_Source);
   Save_Data (Text_Target, Hex_Data);

end Longdist;
