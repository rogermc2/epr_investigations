
--  with Interfaces;

--  with Ada.Directories; use Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions;
--  with Ada.Strings.Maps;
with Ada.Text_IO; use Ada.Text_IO;

with Delft_Types; use Delft_Types;
with Types; use Types;
with Utils; use Utils;

package body Process_Data is

   procedure Parse_Delft_CSV_Line (Line : String;
      Data : out Raw_Result_Record);

   procedure Get_Data (Source_File, Target_File : String) is
      Routine_Name : constant String := "Process_Data.Get_Data ";
      Source_ID    : File_Type;
      PT_ID        : File_Type;
      Line_Num     : Natural := 0;
      Raw_Data     : Raw_Result_Record;
      Data         : Byte_Array (1 .. 8);
      Number       : Double;
   begin
      Put_Line (Routine_Name & "Source File: " & Source_File);
      New_Line;
      Open (Source_ID, In_File, Source_File);

      while not End_Of_File (Source_ID) loop
         Line_Num := Line_Num + 1;
         declare
            aline : constant String := Get_Line (Source_ID);
         begin
            Parse_Delft_CSV_Line (aline, Raw_Data);
         end;
      end loop;

      Close (Source_ID);

      Create (PT_ID, Out_File, Target_File);
      
      Close (PT_ID);

      Put_Line (Routine_Name & "Photon times file written to " & Target_File);
      Put_Line (Routine_Name & "Photon times file length: " &
           Natural'Image (Count_Text_File_Lines (Target_File)) & " lines");

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));

   end Get_Data;

   procedure Parse_Delft_CSV_Line (Line : String; Data : out Raw_Result_Record) is
      First_Comma     : Natural := 0;
      Comma_Count     : Natural := 0;
      Idx             : Positive := Line'First;
      Comma_Positions : Field_Array := (others => 0);
   begin
      while Idx <= Line'Last loop
         if Line(Idx) = ',' then
            Comma_Count := Comma_Count + 1;
            if Comma_Count <= 17 then
               Comma_Positions(Comma_Count) := Idx;
            end if;
         end if;
         Idx := Idx + 1;
      end loop;

      Data.A_Setting :=
       Integer'Value (Line(Comma_Positions(2) + 1 .. Comma_Positions (3) - 1));
      --  Column 4 (A Outcome) lives between the 3rd and 4th comma
      Data.A_Result :=
         Integer'Value (Line(Comma_Positions(3) + 1 .. Comma_Positions(4) - 1));
      --  Column 5 (B Setting) lives between the 4th and 5th comma
      Data.B_Setting :=
         Integer'Value (Line(Comma_Positions(4) + 1 .. Comma_Positions(5) - 1));
      --  Column 6 (B Outcome) lives between the 5th and 6th comma
      Data.B_Result :=
         Integer'Value (Line(Comma_Positions(5) + 1 .. Comma_Positions(6) - 1));

   end Parse_Delft_CSV_Line;

end Process_Data;
