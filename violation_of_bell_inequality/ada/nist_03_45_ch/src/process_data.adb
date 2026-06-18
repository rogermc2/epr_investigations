
--  with Interfaces; use Interfaces;
--  with Ada.Directories; use Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Streams;
with Ada.Streams.Stream_IO;
with Ada.Text_IO; use Ada.Text_IO;

--  with Types;
with Utils; use Utils;

package body Process_Data is
   type Unsigned_Byte is mod 2**8;
   type Unsigned_2_Byte is mod 2**16;
   type Unsigned_8_Byte is mod 2**64;
   type Channel_Type is (Detector_Click, Rng_Output_0, Rng_Output_1,
                         GPS_Pps, Sync, Ch_Error);

   type Raw_Data_Record is record
      Channel     : Unsigned_Byte;
      Time_Tag    : Unsigned_8_Byte;
      Transfer_ID : Unsigned_2_Byte;
   end record;

   type Data_Record is record
      Channel     : Channel_Type;
      Time_Tag    : Unsigned_8_Byte;
      Transfer_ID : Integer;
   end record;

   procedure Print_Processed_Data (Data : Data_Record);
   procedure Print_Raw_Data (Raw_Data : Raw_Data_Record);

   procedure NIST_Data (Source_File, NIST_File : String) is
      use Ada.Streams;
      Routine_Name : constant String  := "Process_Data.NIST_Data ";
      --  Source_Size  : constant Natural := Natural (Size (Source_File));
      Data_Stream  : Stream_IO.Stream_Access;
      Source_ID    : Stream_IO.File_Type;
      NIST_ID      : Ada.Text_IO.File_Type;
      Log_ID       : Ada.Text_IO.File_Type;
      Raw_Data     : Raw_Data_Record;
      Data         : Data_Record;
      Rng_Output   : Natural;
      --   P_Setting    : String (1 .. 1);
      Line_Num     : Natural := 0;
      --  Byte_Offset  : Integer := -2;
      Num_Invalid  : Natural := 0;
   begin
      Ada.Text_IO.Put_Line (Routine_Name & "Source File: " & Source_File);
      Stream_IO.Open (Source_ID, Stream_IO.In_File, Source_File);
      Data_Stream := Stream_IO.Stream (Source_ID);
      Ada.Text_IO.Create (NIST_ID, Out_File, NIST_File);
      Ada.Text_IO.Create (Log_ID, Out_File, "parsing_errors.log");
      Ada.Text_IO.Put_Line (Log_ID, "   Parsing Errors");

      while not Stream_IO.End_Of_File (Source_ID) loop
        Line_Num := Line_Num + 1;
       --  Byte_Offset := Byte_Offset + 2;

         Raw_Data_Record'Read (Data_Stream, Raw_Data);
         if Line_Num < 3 then
            Put_Line (Routine_Name & "Raw Data Time_Tag: " &
                     Unsigned_8_Byte'Image (Raw_Data.Time_Tag) &
                      ", Transfer_ID " &
                     Unsigned_2_Byte'Image (Raw_Data.Transfer_ID));
            Print_Raw_Data (Raw_Data);
         end if;

         case Raw_Data.Channel is
            when 0 => Data.Channel := Detector_Click;
            when 2 => Data.Channel := Rng_Output_0;
            when 4 => Data.Channel := Rng_Output_1;
            when 5 => Data.Channel := GPS_Pps;
            when 6 => Data.Channel := Sync;
            when others =>
             Data.Channel := Ch_Error;
             Num_Invalid := Num_Invalid + 1;
             Ada.Text_IO.Put_Line (Log_ID, "Line: " & Natural'Image (Line_Num) &
               "," & "Invalid Channel value:" &
               Unsigned_Byte'Image (Raw_Data.Channel));
         end case;
         Data.Time_Tag := Raw_Data.Time_Tag;
         Data.Transfer_ID := Integer (Raw_Data.Transfer_ID);

         if Line_Num < 3 then
            Print_Processed_Data (Data);
         end if;
         if Data.Channel = Rng_Output_0 or else Data.Channel = Rng_Output_1
          then
            if Data.Channel = Rng_Output_0 then
               Rng_Output := 0;
            else
               Rng_Output := 1;
            end if;
            Ada.Text_IO.Put (NIST_ID, Natural'Image (Rng_Output) & "," &
                             Unsigned_8_Byte'Image (Data.Time_Tag));
            Ada.Text_IO.New_Line (NIST_ID);
         end if;

         if Line_Num mod 4000000 = 0 then
            Ada.Text_IO.Put (".");
         end if;
      end loop;
      New_Line;

      Ada.Text_IO.Close (Log_ID);
      Ada.Text_IO.Close (NIST_ID);
      Stream_IO.Close (Source_ID);

      Ada.Text_IO.Put_Line
        (Routine_Name & "number of invalid items: " &
           Integer'Image (Num_Invalid));
      Ada.Text_IO.Put_Line
        (Routine_Name & "NIST file length: " &
           Natural'Image (Count_Text_File_Lines (NIST_File)) & " lines");
      Ada.Text_IO.New_Line;

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;
   end NIST_Data;

   procedure Print_Raw_Data (Raw_Data : Raw_Data_Record) is
   begin
      Put_Line ("Raw Data:");
      Put_Line ("Channel: " & Unsigned_Byte'Image (Raw_Data.Channel));
      Put_Line ("Time_Tag: " & Unsigned_8_Byte'Image (Raw_Data.Time_Tag));
      Put_Line ("Transfer_ID: " & Unsigned_2_Byte'Image (Raw_Data.Transfer_ID));
      New_Line;
   end Print_Raw_Data;

   procedure Print_Processed_Data (Data : Data_Record) is
   begin
      Put_Line ("Processed Data:");
      Put_Line ("Channel: " & Channel_Type'Image (Data.Channel));
      Put_Line ("Time_Tag: " & Unsigned_8_Byte'Image (Data.Time_Tag));
      Put_Line ("Transfer_ID: " & Integer'Image (Data.Transfer_ID));
      New_Line;
   end Print_Processed_Data;

end Process_Data;
