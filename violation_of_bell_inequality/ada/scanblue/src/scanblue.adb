
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

with Combine_CSVs; use Combine_CSVs;
with Process_Data; use Process_Data;
with Utils; use Utils;

procedure Scanblue is
   Routine_Name : constant String := "Scanblue ";
   A_Directory  : constant String :=
     "../../scanblue/alice_timetags/";
   B_Directory  : constant String :=
     "../../scanblue/bob_timetags/";
   AV_Source     : constant String := A_Directory & "scanblue_V.dat";
   BV_Source     : constant String := B_Directory & "lscanblue_V.dat";
   AC_Source     : constant String := A_Directory & "scanblue_C.dat";
   BC_Source     : constant String := B_Directory & "scanblue_C.dat";
   AV_Target     : constant String := "../A_Photon_Times.csv";
   BV_Target     : constant String := "../B_Photon_Times.csv";
   AC_Target     : constant String := "../A_OEM.csv";
   BC_Target     : constant String := "../B_OEM.csv";
   --  Combined_Data : constant String := "../Long_Dist.csv";
begin
   Photon_Data (AV_Source, AV_Target);
   Photon_Data (BV_Source, BV_Target);

   OEM_Data (AC_Source, AC_Target);
   OEM_Data (BC_Source, BC_Target);
   --  Set stack size:  ulimit -s 64000 to prevent Combine stack overflow
   --  Combine (AV_Target, BV_Target, AC_Target, BC_Target, Combined_Data, 30000);

   Put_Line ("Number of A detections: " &
               Integer'Image (Count_Text_File_Lines (AC_Target)));
   Put_Line ("Number of B detections: " &
               Integer'Image (Count_Text_File_Lines (BC_Target)));

exception
   when Error : others =>
      Put_Line (Routine_Name & "Exception information:  " &
                  Exception_Information (Error));

end Scanblue;
