
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

with Delft_Printing; use Delft_Printing;
with Delft_Types; use Delft_Types;
with Delft_Utils; use Delft_Utils;
with Process_Data; use Process_Data;
with Utils; use Utils;

procedure Delft is
   Routine_Name     : constant String := "Delft ";
   Source_Directory : constant String := "../../../../delft_data/data/";
   Target_Directory : constant String := "../generated_delft_data/";
   Source_1         : constant String :=
      Source_Directory & "bell_open_data_2_old_detector.txt";
   Source_2         : constant String :=
      Source_Directory & "bell_open_data_2_new_detector.txt";
   Source_Combined  : constant String :=
      Source_Directory & "bell_open_data_2_combined_detector.txt";
   Settings         : constant String := Target_Directory & "settings.csv";
   aa               : constant String := Target_Directory & "aa.csv";
   ab               : constant String := Target_Directory & "ab.csv";
   ba               : constant String := Target_Directory & "ba.csv";
   bb               : constant String := Target_Directory & "bb.csv";
   Data             : Delft_Data_List;
begin
   Combine_Detector_Tracks (Source_1, Source_2, Source_Combined);
   Put_Line (Routine_Name & "Source lengths: " &
                  Integer'Image (Count_Text_File_Lines (Source_1)) &
                  Integer'Image (Count_Text_File_Lines (Source_2)) &
                  Integer'Image (Count_Text_File_Lines (Source_Combined)));
   Get_Data (Source_Combined, Settings, Data);
   --  Print_Delft_Data_List ("Data", Data);
   Save_Data (aa, ab, ba, bb, Data);

exception
   when Error : others =>
      Put_Line (Routine_Name & "Exception information:  " &
                  Exception_Information (Error));

end Delft;
