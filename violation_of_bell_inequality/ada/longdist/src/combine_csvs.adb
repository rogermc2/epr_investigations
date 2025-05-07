
with Ada.Directories; use Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

with Combine_Data; use Combine_Data;
with Printing; use Printing;
with Types; use Types;

package body Combine_CSVs is

   procedure Combine (Photon_Data_A_CSV, Photon_Data_B_CSV,
                      OEM_Data_A_CSV, OEM_Data_B_CSV : String) is
   Routine_Name      : constant String := "Combine_CSVs.Combine ";
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
   --  Photon_Data_B : String13_Array (1 .. Photon_AB_Length / 2);
   --  OEM_Data_A    : String4_Array (1 .. OEM_AB_Length);
   --  OEM_Data_B    : String4_Array (1 .. OEM_AB_Length);
   aRow          : String_33;
   Combined      : String33_Array (1 .. 10000);
begin
   --  Set stack size:  ulimit -s 64000
   --  Original photon data is sorted ascendingly
   Put_Line ("Photon_Data_A length:" & Integer'Image (Photon_A_Length));
   Put_Line ("Photon_Data_B length:" & Integer'Image (Photon_B_Length));
   Put_Line ("OEM_Data_A length:" & Integer'Image (OEM_A_Length));
   Put_Line ("OEM_Data_B length:" & Integer'Image (OEM_B_Length));

   Load_Photon_Data (Photon_Data_A_CSV, Photon_Data_A);
   --  Load_Photon_Data (Photon_Data_B_CSV, Photon_Data_B);

   --  Load_OEM_Data (OEM_Data_A_CSV, OEM_Data_A);
   --  Load_OEM_Data (OEM_Data_B_CSV, OEM_Data_B);

   new_Line;
   for row in Combined'Range loop
      aRow (1 .. 12) := Photon_Data_A (row)(1 .. 12);
      aRow (13) := ',';
   --     aRow (14 .. 25) := Photon_Data_B (row)(1 .. 12);
   --     aRow (26) := ',';
   --     aRow (27 .. 29) := OEM_Data_A (row)(1 .. 3);
   --     aRow (30) := ',';
   --     aRow (31 .. 33) := OEM_Data_B (row)(1 .. 3);
      --  aRow (34) := ',';
      --  aRow (35 .. 46) :=
      --    Time_Diff (Photon_Data_A (row), Photon_Data_B (row)) (1 .. 12);
      Combined (row) := aRow;
   end loop;
   --  Print_String33_Array ("Combined", Combined, 1, 6);

   --  Save_Data (Long_Dist_CSV, Combined);
   --  Put_Line ("Long_Dist_CSV length: " &
   --              Integer'Image (Integer (Size (Long_Dist_CSV))));

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));

   end Combine;

end Combine_CSVs;
