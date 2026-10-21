
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

with Delft_Printing; use Delft_Printing;
with Delft_Types; use Delft_Types;
with Process_Data; use Process_Data;
with Utils; use Utils;

procedure Delft is
   Routine_Name     : constant String := "Delft ";
   Source_Directory : constant String := "../../../../delft_data/data/";
   Target_Directory : constant String := "../generated_delft_data/";
   Source           : constant String :=
      Source_Directory & "bell_open_data_2_new_detector.txt";
   aa               : constant String := Target_Directory & "aa.csv";
   ab               : constant String := Target_Directory & "ab.csv";
   ba               : constant String := Target_Directory & "ba.csv";
   bb               : constant String := Target_Directory & "bb.csv";
   Data             : Delft_Data_List;
begin
   Put_Line (Routine_Name & "Source length: " &
                  Integer'Image (Count_Text_File_Lines (Source)));
   Get_Data (Source, Data);
   Print_Delft_Data_List ("Data", Data, 1, 10);
   Save_Data (aa, ab, ba, bb, Data);

exception
   when Error : others =>
      Put_Line (Routine_Name & "Exception information:  " &
                  Exception_Information (Error));

end Delft;
