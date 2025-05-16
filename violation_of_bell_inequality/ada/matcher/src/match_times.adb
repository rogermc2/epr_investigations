
with Ada.Directories; use Ada.Directories;
with Ada.Text_IO; use Ada.Text_IO;

with Data_Selection; use Data_Selection;
with Process_Data; use Process_Data;
with Types; use Types;

procedure Match_Times is
   Routine_Name    : constant String := "Match_Times ";
   A_Directory     : constant String := "../";
   B_Directory     : constant String := "../";
   Photon_Times_A  : constant String := A_Directory & "A_Photon_Times.csv";
   Photon_Times_B  : constant String := B_Directory & "B_Photon_Times.csv";
   OEM_A           : constant String := A_Directory & "A_OEM.csv";
   OEM_B           : constant String := B_Directory & "B_OEM.csv";
   OEM_00          : String := A_Directory & "OEM_00.csv";
   OEM_01          : String := A_Directory & "OEM_10.csv";
   OEM_10          : String := A_Directory & "OEM_01.csv";
   OEM_11          : String := A_Directory & "OEM_11.csv";
   Width           : constant Double := Double (4.0 * 10.0 ** (-9));
   Delta_A         : constant Double := (3.8 * 10.0 ** (-9));
   Selected_Pairs  : Match_List;
  begin
   Put_Line (Routine_Name & "Photon_Times_A file size:" &
                  Integer'Image (Integer (Size (Photon_Times_A))) & " bytes");
   Put_Line (Routine_Name & "Photon_Times_B file size:" &
                  Integer'Image (Integer (Size (Photon_Times_B))) & " bytes");
   Match_Photon_Times (Photon_Times_A, Photon_Times_B,
                       Delta_A, Width, Selected_Pairs);
   Select_OEM_Data (Selected_Pairs, OEM_A, OEM_B, OEM_00, OEM_01, OEM_10, OEM_11);

end Match_Times;
