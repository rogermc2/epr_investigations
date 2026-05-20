
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with Analysis; use Analysis;
with Source; use Source;
with Detection; use Detection;
with Types; use Types;
with Utilities; use Utilities;

procedure EPRB is
   --  Set stack size:  ulimit -s 64000 to prevent stack overflow
   Source_A_File     : constant String := "data/source_A.bin";
   Source_B_File     : constant String := "data/source_B.bin";
   Detection_A_File  : Unbounded_String;
   Detection_B_File  : Unbounded_String;
   Duration_Val      : Duration;
   Settings          : Settings_Vector;
   Spin              : Float := 1.0;
begin
   Put_Line ("Set stack size: ulimit -s 64000");
   Process_Command_Line (Duration_Val, Settings, Spin);
   Build_Source (Duration_Val, Spin,
                 Source_A_File, Source_B_File);
   Run_Detection (Source_A_File, Settings, Detection_A_File);
   Run_Detection (Source_B_File, Settings, Detection_B_File);
   Analyse (Detection_A_File, Detection_B_File);

end EPRB;
