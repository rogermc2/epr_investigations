
with Ada.Directories; use Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

with Types; use Types;

package body Process_Data is

   procedure Load_Data (CSV_Data : String; Data : out String33_List) is
      use String33_Package;
      File_ID  : File_Type;
      --  aLine    : String_33;
   begin
      Open (File_ID, In_File, CSV_Data);
      while not End_Of_File (File_ID) loop
         Data.Append (Get_Line (File_ID));
      end loop;

      Close (File_ID);

   end Load_Data;

   procedure Match_Photon_Times (CSV_A, CSV_B, CSV_Match : String) is
      Routine_Name : constant String := "Process_Data.Match_Photon_Times ";
      Match_ID : File_Type;
      A_Data   : String33_List;
      B_Data   : String33_List;
   begin
      Load_Data (CSV_A, A_Data);
      Load_Data (CSV_B, B_Data);

      Create (Match_ID, Out_File, CSV_Match);

      Ada.Text_IO.Close (Match_ID);

      Ada.Text_IO.Put_Line (Routine_Name & "CSV_Match file written to " &
                              CSV_Match);
      Ada.Text_IO.Put_Line
        (Routine_Name & "CSV_Match file length: " &
           Natural'Image (Natural (Size (CSV_Match))));

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));

   end Match_Photon_Times;

end Process_Data;
