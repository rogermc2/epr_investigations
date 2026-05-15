
with Ada.Text_IO; use Ada.Text_IO;

with Source; use Source;
with Detection; use Detection;
with Types; use Types;
with Utilities; use Utilities;

procedure EPRB is
   --  Set stack size:  ulimit -s 64000 to prevent stack overflow

   Left_Source_File  : constant String := "data/source_left.bin";
   Right_Source_File : constant String := "data/source_right.bin";
   Num_Particles     : constant Positive := 1000000;
   Duration_Val      : Duration;
   Settings          : Float_Vector;
   Spin              : Float := 1.0;
begin
   Put_Line ("Set stack size: ulimit -s 64000");
   Process_Command_Line (Duration_Val, Settings, Spin);
   Build_Source (Num_Particles, Duration_Val, Spin,
                 Left_Source_File, Right_Source_File);
   Run_Detection (Settings, Left_Source_File);
   Run_Detection (Settings, Right_Source_File);

end EPRB;
