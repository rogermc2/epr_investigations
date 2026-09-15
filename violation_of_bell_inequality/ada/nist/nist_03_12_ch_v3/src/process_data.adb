
with Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Streams;
with Ada.Streams.Stream_IO;
with Ada.Text_IO; use Ada.Text_IO;

with NIST_Types; use NIST_Types;

package body Process_Data is

   procedure Load_NIST_Data
    (Source_File, Target_File : String; Num_Rows : Double_Natural := 30) is
       use Ada.Streams;
      Routine_Name : constant String  := "Process_Data.Load_NIST_Data ";
      Source_Size  : constant Double_Natural :=
       Double_Natural (Ada.Directories.Size (Source_File));
      Data_Stream  : Stream_IO.Stream_Access;
      Source_ID    : Stream_IO.File_Type;
      Log_ID       : Ada.Text_IO.File_Type;
      Target_ID    : Ada.Text_IO.File_Type;
      Raw_Data     : Raw_Data_Record;
      Data         : Data_Record;
      Pol_Setting  : String (1 .. 2);
      Clicked      : Boolean;
      Sync_Pulse   : Boolean;
      Line_Num     : Double_Natural := 0;
      Num_Clicks   : Natural := 0;
      Num_Synchs   : Natural := 0;
      Num_Invalid  : Natural := 0;
   begin
      Put_Line (Routine_Name & "Source File: " & Source_File);
      Put_Line (Routine_Name & Source_File & " length: " &
         Double_Natural'Image (Source_Size));
      New_Line;
      Put_Line (Routine_Name &
       Source_File (Source_File'First + 19 .. Source_File'Last) & " size: " &
                     Double_Natural'Image (Source_Size));
      Stream_IO.Open (Source_ID, Stream_IO.In_File, Source_File);
      Data_Stream := Stream_IO.Stream (Source_ID);

      Create (Log_ID, Out_File,
       Source_File (Source_File'First + 22 .. Source_File'Last - 4) &
        "_parsing_errors.log");
      Put_Line (Log_ID, "*******  Parsing Errors  *******");
      Create (Target_ID, Out_File, Target_File);

      while not Stream_IO.End_Of_File (Source_ID) and then
         Line_Num <= Num_Rows loop
        Line_Num := Line_Num + 1;

         Raw_Data_Record'Read (Data_Stream, Raw_Data);

         case Raw_Data.Channel is
            when 0 => Data.Channel := CLICK;
            when 2 => Data.Channel := POL_0;
            when 4 => Data.Channel := POL_45;
            when 5 => Data.Channel := GPS_PPS;
            when 6 => Data.Channel := SYNC;
            when 64 => Data.Channel := OVERFLOW;
            when others => Data.Channel := CH_ERROR;
             Num_Invalid := Num_Invalid + 1;
             Ada.Text_IO.Put_Line (Log_ID, "Line: " &
                  Double_Natural'Image (Line_Num) & "," &
                  "Invalid Channel value:" &
                  Unsigned_Byte'Image (Raw_Data.Channel));
         end case;
         Data.Time_Tag := Double_Positive (Raw_Data.Time_Tag);
         Data.Transfer_ID := Integer (Raw_Data.Transfer_ID);

         Clicked := False;
         Sync_Pulse := False;
         case Data.Channel is
            when Click =>
               Clicked :=  True;
               Num_Clicks := Num_Clicks + 1;
            when Pol_0 => Pol_Setting := " 0";
            when Pol_45 => Pol_Setting := "45";
            when GPS_Pps => null;
            when Sync =>
               Sync_Pulse :=  True;
               Num_Synchs := Num_Synchs + 1;
            when Overflow => null;
            when Ch_Error => null;
         end case;
         Put_Line (Target_ID, Channel_Type'Image (Data.Channel) & "," &
         Double_Positive'Image (Data.Time_Tag) & "," &
         Integer'Image (Data.Transfer_ID));

         if Line_Num mod 4000000 = 0 then
            Put (".");
         end if;
      end loop;
      New_Line;

      Close (Log_ID);
      Stream_IO.Close (Source_ID);
      Close (Target_ID);

      Put_Line (Routine_Name & "number of invalid items: " &
      Integer'Image (Num_Invalid));

      New_Line;

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;
   end Load_NIST_Data;

end Process_Data;
