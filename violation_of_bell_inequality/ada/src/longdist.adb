
with Types; use Types;
with Utils; use Utils;

procedure Longdist is

   procedure Convert_To_Text (Hex_Source_File, Text_Target_File : String) is
   Hex_Data : Bounded_String_List;
begin
   Hex_Data := Load_Data (Hex_Source_File);
   Save_Data (Text_Target_File, Hex_Data);
   end Convert_To_Text;

   A_Source   : constant String :=
                    "../longdist35/alice_timetags/longdist35_Corig.dat";
   A_Target  : constant String :=
                    "../longdist35/alice_timetags/longdist35_C.txt";
   B_Source   : constant String :=
                    "../longdist35/bob_timetags/longdist35_C.dat";
   B_Target  : constant String :=
                    "../longdist35/bob_timetags/longdist35_C.txt";
begin
   Convert_To_Text (A_Source, A_Target);
   Convert_To_Text (B_Source, B_Target);

end Longdist;
