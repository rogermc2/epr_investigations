
with Ada.Directories; use Ada.Directories;
with Ada.Text_IO; use Ada.Text_IO;

with Printing; use Printing;
with Types; use Types;
with Process_Data; use Process_Data;

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

   Photon_A_Length   : constant Positive :=
     Positive (Size (Photon_Data_A_CSV));
   Photon_B_Length   : constant Positive :=
     Positive (Size (Photon_Data_B_CSV));
   OEM_A_Length      : constant Positive := Positive (Size (OEM_Data_A_CSV));
   OEM_B_Length      : constant Positive := Positive (Size (OEM_Data_B_CSV));
   Photon_AB_Length   : constant Positive :=
     Integer'Min (Photon_A_Length, Photon_B_Length);
   OEM_AB_Length     : constant Positive :=
     Integer'Min (OEM_A_Length, OEM_B_Length);
   --  Set photon array lengths to lesser of Photon A and B Lengths
   --  to prevent stack oveflow
   Photon_Data_A : String13_Array (1 .. Photon_AB_Length / 2);
   Photon_Data_B : String13_Array (1 .. Photon_AB_Length / 2);
   OEM_Data_A    : String4_Array (1 .. OEM_AB_Length);
   OEM_Data_B    : String4_Array (1 .. OEM_AB_Length);
   aRow          : String_46;
   Combined      : String46_Array (1 .. 10000);
begin
   --  Set stack size:  ulimit -s 64000
   --  Original photon data is sorted ascendingly
   Put_Line ("Photon_Data_A length:" & Integer'Image (Photon_A_Length));
   Put_Line ("Photon_Data_B length:" & Integer'Image (Photon_B_Length));
   Put_Line ("OEM_Data_A length:" & Integer'Image (OEM_A_Length));
   Put_Line ("OEM_Data_B length:" & Integer'Image (OEM_B_Length));

   Load_Photon_Data (Photon_Data_A_CSV, Photon_Data_A);
   Load_Photon_Data (Photon_Data_B_CSV, Photon_Data_B);

   Load_OEM_Data (OEM_Data_A_CSV, OEM_Data_A);
   Load_OEM_Data (OEM_Data_B_CSV, OEM_Data_B);

   new_Line;
   for row in Combined'Range loop
      aRow (1 .. 12) := Photon_Data_A (row)(1 .. 12);
      aRow (13) := ',';
      aRow (14 .. 25) := Photon_Data_B (row)(1 .. 12);
      aRow (26) := ',';
      aRow (27 .. 29) := OEM_Data_A (row)(1 .. 3);
      aRow (30) := ',';
      aRow (31 .. 33) := OEM_Data_B (row)(1 .. 3);
      aRow (34) := ',';
      aRow (35 .. 46) :=
        Time_Diff (Photon_Data_A (row), Photon_Data_B (row)) (1 .. 12);
      Combined (row) := aRow;
   end loop;
   Print_String46_Array ("Combined", Combined, 1, 6);

   Save_Data (Long_Dist_CSV, Combined);
   Put_Line ("Long_Dist_CSV length: " &
               Integer'Image (Integer (Size (Long_Dist_CSV))));

end Combine_CSVs;
