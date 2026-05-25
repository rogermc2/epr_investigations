
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;

with Analysis; use Analysis;
with Source; use Source;
with Data_Catagorization; use Data_Catagorization;
with Detection; use Detection;
with Types; use Types;
with Utilities; use Utilities;

procedure EPRB is
   --  Set stack size:  ulimit -s 64000 to prevent stack overflow
   Routine_Name      : constant String := "EPRB ";
   Source_A_File     : constant String := "data/source_A.bin";
   Source_B_File     : constant String := "data/source_B.bin";
   Detection_A_File  : Unbounded_String;
   Detection_B_File  : Unbounded_String;
   Duration_Val      : Duration := 1.0;
   Num_Settings      : Positive;
   Settings          : Settings_Vector;
   Spin              : Float := 1.0;
begin
   Put_Line ("Set stack size: ulimit -s 64000");
   Process_Command_Line (Duration_Val, Num_Settings, Settings, Spin);
   Put_Line ("Duration_Val: " & Duration'Image (Duration_Val));
   Build_Source (Duration_Val, Num_Settings, Spin,
                 Source_A_File, Source_B_File);
   Run_Detection (Source_A_File, Settings, Detection_A_File);
   Run_Detection (Source_B_File, Settings, Detection_B_File);
   Catagorize (To_String (Detection_A_File), To_String (Detection_B_File),
               Settings);

exception
   when Error : others =>
      Put_Line (Routine_Name & "Exception information:  " &
                  Exception_Information (Error));

end EPRB;
