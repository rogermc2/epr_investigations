
with Ada.Text_IO; use Ada.Text_IO;

with Source; use Source;
with Detection; use Detection;

procedure EPRB_Ada is
   --  Set stack size:  ulimit -s 64000 to prevent stack overflow

   Left_Source_File  : constant String := "data/source_left.bin";
   Right_Source_File : constant String := "data/source_right.bin";
   Num_Particles     : constant Positive := 1000000;
begin
   Put_Line ("Set stack size: ulimit -s 64000");
   Build_Source (Num_Particles, Left_Source_File, Right_Source_File);
   Station_Detection (Left_Source_File);
   Station_Detection (Right_Source_File);

end EPRB_Ada;
