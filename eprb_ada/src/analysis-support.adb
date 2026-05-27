
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Strings.Fixed; use Ada.Strings.Fixed;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;

--  with Printing; use Printing;
--  with Utilities;

package body Analysis.Support is

   function Parse_Data_Line (aLine : String) return Outcomes_Record is
      Outcomes : Outcomes_Record;
   begin
      return Outcomes;
   end Parse_Data_Line;

   procedure Parse_File_Name
     (File_Name : String; Setting_A, Setting_B : out MilliRad) is
      Routine_Name : constant String := "Analysis.Support.Parse_File_Name ";
      Pos_1        : constant Natural := Index (File_Name, "/");
      Pos_2        : constant Natural := Index (File_Name, "_");
      A_String     : constant String := File_Name (Pos_1 + 1 .. Pos_2 - 1);
      Pos_3        : constant Natural :=
        Index (File_Name (Pos_2 + 1 .. File_Name'Last), "_");
      B_String     : constant String := File_Name (Pos_2 + 1 .. Pos_3 - 1);
   begin
      --  Put_Line (Routine_Name & "File_Name: " & File_Name);
      --  Put_Line (Routine_Name & "A_String: " & A_String);
      --  Put_Line (Routine_Name & "B_String: " & B_String);
      Setting_A :=  MilliRad'Value (A_String);
      Setting_B :=  MilliRad'Value  (B_String);

   exception
      when Error : others =>
         Put_Line
           (Routine_Name & "Exception information:  " &
              Exception_Information (Error));
         raise;

   end Parse_File_Name;

end Analysis.Support;
