
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

with Combine_CSVs; use Combine_CSVs;
with Process_Data; use Process_Data;
with Utils; use Utils;

procedure Get_Data is
   Routine_Name : constant String := "Get_Data ";
   A_Directory  : constant String :=
     "../../../nist_data/";
   B_Directory  : constant String := A_Directory;
   A_Source     : constant String := A_Directory & "03_45_CH_pockel_100kHz_RandomPumpWP0or8_alice.dat";
   B_Source     : constant String := B_Directory & "03_45_CH_pockel_100kHz_RandomPumpWP0or8_bob.dat";
   A_Target     : constant String := "../A.csv";
   B_Target     : constant String := "../B.csv";
   Combined_Data : constant String := "../combined.csv";
begin
   NIST_Data (A_Source, A_Target);
   NIST_Data (B_Source, B_Target);
   --  Set stack size:  ulimit -s 64000 to prevent Combine stack overflow
   Combine_Nist (A_Target, B_Target, Combined_Data, 30000);
   --  Put_Line (Routine_Name
   --   & "Combine_Nist done, calling Count_Text_File_Lines (A_Target)");

   Put_Line ("Number of A detections: " &
               Integer'Image (Count_Text_File_Lines (A_Target)));
   Put_Line ("Number of B detections: " &
               Integer'Image (Count_Text_File_Lines (B_Target)));

exception
   when Error : others =>
      Put_Line (Routine_Name & "Exception information:  " &
                  Exception_Information (Error));

end Get_Data;
