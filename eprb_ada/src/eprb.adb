
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;

with Analysis; use Analysis;
with Source; use Source;
with Data_Catagorization; use Data_Catagorization;
with Detection; use Detection;
with Printing; use Printing;
with Types; use Types;

with Vector_Functions; use Vector_Functions;

procedure EPRB is
   --  Set stack size:  ulimit -s 64000 to prevent stack overflow
   use Settings_Vector_Package;
   Routine_Name      : constant String := "EPRB ";
   Source_A_File     : constant String := "data/source_A.bin";
   Source_B_File     : constant String := "data/source_B.bin";
   Duration_Val      : constant Duration := 0.01;
   Settings          : Settings_Vector :=
     Empty_Vector & 0.0 & 45.0 & 90.0 & 135.0;
   Spin              : Float := 0.5;
   Detection_A_File  : Unbounded_String;
   Detection_B_File  : Unbounded_String;
   Num_Settings      : Positive := 4;
   Out_Files         : Unbounded_String_Vector;
begin
   Put_Line ("Set stack size: ulimit -s 64000");
   To_Radians (Settings);
   --  Process_Command_Line (Duration_Val, Num_Settings, Settings, Spin);
   Put_Line ("Duration_Val: " & Duration'Image (Duration_Val));
   Print_Settings ("Settings", Settings);

   Build_Source (Duration_Val, Settings, Spin,
                 Source_A_File, Source_B_File);
   Run_Detection (Source_A_File, Settings, Detection_A_File);
   Run_Detection (Source_B_File, Settings, Detection_B_File);

   Out_Files := Catagorize (To_String (Detection_A_File),
                            To_String (Detection_B_File), Settings);
   Analyse (Out_Files, Settings);

exception
   when Error : others =>
      Put_Line (Routine_Name & "Exception information:  " &
                  Exception_Information (Error));

end EPRB;
