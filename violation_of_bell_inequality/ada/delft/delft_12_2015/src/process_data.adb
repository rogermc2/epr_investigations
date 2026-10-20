
   with Interfaces; use Interfaces;

--  with Ada.Directories; use Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions;
--  with Ada.Strings.Maps;
with Ada.Text_IO; use Ada.Text_IO;

with Types; use Types;
with Utils; use Utils;

package body Process_Data is

   type Field_Array is array (1 .. 17) of Natural;

   procedure Parse_Delft_CSV_Line (Line : String;
      Data : out Raw_Result_Record);

   procedure Get_Data (Source_File : String; Target : out Delft_Data_List) is
      Routine_Name : constant String := "Process_Data.Get_Data ";
      Source_ID    : File_Type;
      Line_Num     : Natural := 0;
      Raw_Data     : Raw_Result_Record;
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
            Target.Append (Raw_Data);
         end;
      end loop;

      Close (Source_ID);

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));

   end Get_Data;

   procedure Normalize_Delft_Outcomes (Raw_A_Count, Raw_B_Count : Integer;
      A_Discrete, B_Discrete : out UV) is
      --  Under the Delft experimental rules, any raw readout pulse count
      --  crossing the dark noise floor (> 0) represents a successful
      --  Spin-Up event.
      Readout_Threshold : constant Integer := 0;
   begin
      if Raw_A_Count > Readout_Threshold then
         --  Bright State: Fluorescent photons detected -> Spin-Up
         A_Discrete := 1;
      else
         --  Dark State: Zero counts or background noise -> Spin-Down
         A_Discrete := -1;
      end if;

      if Raw_B_Count > Readout_Threshold then
         --  Bright State: Fluorescent photons detected -> Spin-Up
         B_Discrete := 1;
      else
         --  Dark State: Zero counts or background noise -> Spin-Down
         B_Discrete := -1;
      end if;

   end Normalize_Delft_Outcomes;

   procedure Parse_Delft_CSV_Line (Line : String; Data : out Raw_Result_Record) is
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
