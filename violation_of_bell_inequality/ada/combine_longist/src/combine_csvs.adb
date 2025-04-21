
with Ada.Directories; use Ada.Directories;
with Ada.Text_IO; use Ada.Text_IO;

with Printing; use Printing;
with Types; use Types;
with Utils; use Utils;

procedure Combine_CSVs is
   A_Directory : constant String :=
     "../../longdist35/alice_timetags/";
   B_Directory : constant String :=
     "../../longdist35/bob_timetags/";
   Photon_Data_A_CSV : constant String := A_Directory & "Photon_Times.csv";
   Photon_Data_B_CSV : constant String := B_Directory & "Photon_Times.csv";
   OEM_Data_A_CSV    : constant String := A_Directory & "OEM.csv";
   OEM_Data_B_CSV    : constant String := B_Directory & "OEM.csv";
   Long_Dist_CSV     : constant String := "../Long_Dist.csv";

   Photon_Data_A : String13_Array (1 .. Positive (Size (Photon_Data_A_CSV))/10);
   Photon_Data_B : String13_Array (1 .. Positive (Size (Photon_Data_B_CSV))/10);
   OEM_Data_A    : String3_Array (1 .. Positive (Size (OEM_Data_A_CSV)));
   OEM_Data_B    : String3_Array (1 .. Positive (Size (OEM_Data_B_CSV)));
   aRow          : String_30;
   Combined      : String30_Array (1 .. 1000);
begin
   --  Set stack size:  ulimit -s 64000
   Put_Line ("Loading Photon_Data_A");
   Load_Photon_Data (Photon_Data_A_CSV, Photon_Data_A);
   Load_Photon_Data (Photon_Data_B_CSV, Photon_Data_B);
   Print_String13_Array ("Photon_Data_A", Photon_Data_A, 1, 1);

   Load_OEM_Data (OEM_Data_A_CSV, OEM_Data_A);
   Load_OEM_Data (OEM_Data_B_CSV, OEM_Data_B);
   Print_String3_Array ("Photon_Data_A", OEM_Data_A, 1, 1);

   new_Line;
   for row in Combined'Range loop
      aRow (1 .. 12) := Photon_Data_A (row)(1 .. 12);
      aRow (13) := ',';
      aRow (14 .. 25) := Photon_Data_B (row)(1 .. 12);
      aRow (26) := ',';
      aRow (27 .. 28) := OEM_Data_A (row)(1 .. 2);
      aRow (29) := ',';
      aRow (30 .. 31) := OEM_Data_B (row)(1 .. 2);
      Combined (row) := aRow;
   end loop;
   Print_String30_Array ("Combined", Combined, 1, 1);

   Save_Data (Long_Dist_CSV, Combined);

end Combine_CSVs;
