
with Ada.Directories; use Ada.Directories;
with Ada.Text_IO; use Ada.Text_IO;

with Printing; use Printing;
with Types; use Types;
with Utils; use Utils;

procedure Combine_Csvs is
   A_Directory : constant String :=
     "../../longdist35/alice_timetags/";
   B_Directory : constant String :=
     "../../longdist35/bob_timetags/";
   Photon_Data_A_CSV : constant String := A_Directory & "Photon_Times.csv";
   Photon_Data_B_CSV : constant String := B_Directory & "Photon_Times.csv";
   OEM_Data_A_CSV    : constant String := A_Directory & "OEM.csv";
   OEM_Data_B_CSV    : constant String := B_Directory & "OEM.csv";
   Long_Dist_CSV     : constant String := "../Long_Dist.csv";

   Photon_Data_A : String1_Array (1 .. Positive (Size (Photon_Data_A_CSV)));
   Photon_Data_B : String1_Array (1 .. Positive (Size (Photon_Data_B_CSV)));
   OEM_Data_A    : String2_Array (1 .. Positive (Size (OEM_Data_A_CSV)));
   OEM_Data_B    : String2_Array (1 .. Positive (Size (OEM_Data_B_CSV)));
   Combined      : String6_Array (1 .. 1000);
begin
   --  Set stack size:  ulimit -s 20000
   Load_Photon_Data (Photon_Data_A_CSV, Photon_Data_A);
   Load_Photon_Data (Photon_Data_B_CSV, Photon_Data_B);

   Load_OEM_Data (OEM_Data_A_CSV, OEM_Data_A);
   Load_OEM_Data (OEM_Data_B_CSV, OEM_Data_B);

   for row in Combined'Range loop
      Combined (row) := Photon_Data_A (row) & Photon_Data_B (row) &
      OEM_Data_A (row) & OEM_Data_B (row);
   end loop;
   Print_String6_Array ("Combined", Combined, 1, 4);

   Save_Data (Long_Dist_CSV, Combined);

end Combine_Csvs;
