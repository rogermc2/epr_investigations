
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Strings;
with Ada.Strings.Fixed;
with Ada.Text_IO; use Ada.Text_IO;

package body Delft_Utils is

   procedure Combine_Detector_Tracks
      (Old_File_Path, New_File_Path, Out_File_Path : String) is
      Input_ID      : File_Type;
      Output_ID     : File_Type;
      Line_Buffer   : String (1 .. 1024);
      Line_Length   : Natural;
   begin
      Create (Output_ID, Out_File, Out_File_Path);
      --  Put_Line ("Appending old detector tracks: " & Old_File_Path);
      Open (Input_ID, In_File, Old_File_Path);
      while not End_Of_File (Input_ID) loop
         Get_Line (Input_ID, Line_Buffer, Line_Length);
         if Line_Length > 0 then
            Put_Line (Output_ID, Line_Buffer (1 .. Line_Length));
         end if;
      end loop;

      Close (Input_ID);

      --  Put_Line ("Appending new detector tracks");
      Open (Input_ID, In_File, New_File_Path);
      while not End_Of_File (Input_ID) loop
         Get_Line (Input_ID, Line_Buffer, Line_Length);
         if Line_Length > 0 then
            Put_Line (Output_ID, Line_Buffer (1 .. Line_Length));
         end if;
      end loop;

      Close (Input_ID);
      Close (Output_ID);
      Put_Line (" Combined master track generated at: " & Out_File_Path);

   exception
      when Error : Name_Error =>
         Put_Line ("Combine_Detector_Tracks, file Append Error: One of the target input files could not be located.");
         Put_Line (Exception_Message (Error));
      when Error : others =>
         Put_Line ("Combine_Detector_Tracks, an unexpected file stream error occurred during append operations.");
         Put_Line (Exception_Message (Error));

   end Combine_Detector_Tracks;

   function Get_Delft_Integer_List
       (Data : Delft_Sample_Data_List; Selection : Detect_Type) return Integer_List is
      use Delft_Sample_Data_Package;
      Count   : Natural := 0;
      Curs    : Cursor := Data.First;
      Item    : Delft_Sample_Data_Record;
      theList : Integer_List;
   begin
      while Has_Element (Curs) loop
         Count := Count + 1;
         Item := Element (Curs);
         if Selection = Det_A then
            theList.Append (Item.A_Detection);
         elsif Selection = Det_B then
            theList.Append (Item.B_Detection);
         else  --  Selection = Det_Both
            theList.Append (Item.AB);
         end if;

         Curs := Next (Curs);
      end loop;

      return theList;
   end Get_Delft_Integer_List;

   function Sample_Mean_vs_Exp_Value (E_Val, Sample_Mean : Float)
            return Float is
   begin
    return 100.0 * (abs (Sample_Mean - E_Val)) / abs (E_Val);  --  per cent

   end Sample_Mean_vs_Exp_Value;

   function Trim_Both (S : String) return String is
   begin
      return Ada.Strings.Fixed.Trim (S, Ada.Strings.Both);
   end Trim_Both;

end Delft_Utils;