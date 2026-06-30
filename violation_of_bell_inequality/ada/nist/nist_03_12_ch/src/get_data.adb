
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

with Combine_CSVs; use Combine_CSVs;
with Process_Data; use Process_Data;
with Types;
with Utils; use Utils;

procedure Get_Data is
   Routine_Name  : constant String := "Get_Data ";
   A_Directory   : constant String := "../../../../nist_data/";
   B_Directory   : constant String := A_Directory;
   Target_Dir    : constant String := "../generated_nist_data/";
   A_Source      : constant String := A_Directory & "03_12_CH_pockel_100kHz.run.Blind_2.alice.dat.compressed";
   B_Source      : constant String := B_Directory & "03_12_CH_pockel_100kHz.run.Blind_2.bob.dat.compressed";
   A_Det_Target  : constant String := Target_Dir & "A_Det.csv";
   B_Det_Target  : constant String := Target_Dir & "B_Det.csv";
   A_Sync_Target : constant String := Target_Dir & "A_Sync.csv";
   B_Sync_Target : constant String := Target_Dir & "B_Sync.csv";
   Combined_Data : constant String := Target_Dir & "combined_det.csv";
   Combined_Sync : constant String := Target_Dir & "combined_sync.csv";
   Num_Rows      : constant Types.Double_Natural := 30000;
begin
   NIST_Data (A_Source, A_Det_Target, A_Sync_Target, Num_Rows);
   NIST_Data (B_Source, B_Det_Target, B_Sync_Target, Num_Rows);
   New_Line;
   --  If needed, set stack size:  ulimit -s 64000
   --  to prevent Combine stack overflow
   Combine_Nist_Det (A_Det_Target, B_Det_Target, Combined_Data, Num_Rows);
   New_Line;
   Combine_Nist_Synch (A_Sync_Target, B_Sync_Target, Combined_Sync, Num_Rows);
   New_Line;

   Put_Line ("Number of A and B detections: " &
               Integer'Image (Count_Text_File_Lines (A_Det_Target)) & ",  "&
               Integer'Image (Count_Text_File_Lines (B_Det_Target)));
   Put_Line ("Number of A and B synchs: " &
               Integer'Image (Count_Text_File_Lines (A_Sync_Target)) & ",  "&
               Integer'Image (Count_Text_File_Lines (B_Sync_Target)));

exception
   when Error : others =>
      Put_Line (Routine_Name & "Exception information:  " &
                  Exception_Information (Error));

end Get_Data;
