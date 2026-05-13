
with Source; use Source;
with Detection; use Detection;

procedure EPRB_Ada is
   --  Set stack size:  ulimit -s 64000 to prevent stack overflow

   Num_Particles   : constant Positive := 1000000;
begin
   Build_Source (Num_Particles);
   Station_Detection (Num_Particles);

end EPRB_Ada;
