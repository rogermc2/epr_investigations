
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
   AC_Target        : constant String := "../A_OEM.csv";
   BC_Target        : constant String := "../B_OEM.csv";
   Data             : Delft_Data_List;
begin
   Get_Data (Source, Data);
   Print_Delft_Data_List ("Data", Data, 1, 8);

exception
   when Error : others =>
      Put_Line (Routine_Name & "Exception information:  " &
                  Exception_Information (Error));

end Delft;
