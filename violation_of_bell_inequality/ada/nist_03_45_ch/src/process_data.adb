
--  Data analysis flow:
--  1) Convert raw data files to ‘compressed’ files
--  a. 8 byte channel -> 1 byte
--  b. 8 byte timetag -> 8 byte timetag
--  c. 8 byte transfer number -> 2 byte integer

--  2) Create hdf5 file with sync pulse information
--  a. Use GPS signals to identify when to start correlating Alice and Bob
--  data
--  b. Start on first sync after a common pulse-per-second GPS signal from
--  Alice and Bob has been identified
--  c. We will use data before the common GPS signal to estimate rates to
--  determine the stopping point in the data analysis to compute p-value
--  d. Identify bad trials due to problems with the data taking such as
--  i. Laser losing modelock
--  ii. Refrigerator warming up
--  iii. Keep trials where there is a massive time jump in timetags
--  momentarily. This seems to be a problem with the operating
--  system (Windows) and the timetagger driver.
--  iv. Keep the trial with the first bad sync because we didn’t know
--  the trial would be bad

--  3) Create hdf5 file with setting information
--  a. Occasionally both the “0” and “1” setting fires. Map this to “0” in the
--  analysis

--  4) Create hdf5 file with information about clicks in the detectors, pockel cell slot
--  number, coincidences, etc. Merge with other hdf5 files

--  5) Convert hdf5 file to text formats for further processing into hypothesis
--  testing.

--  with Ada.Directories; use Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Streams;
with Ada.Streams.Stream_IO;
with Ada.Text_IO;

--  with Types; use Types;
with Utils; use Utils;

package body Process_Data is

   type Unsigned_8_Byte is mod 2**64;
   type Channel_Type is (Detector_Click, Rng_Output_0, Rng_Output_1,
                         GPS_Pps, Sync);

   type Raw_Data_Record is record
      Channel     : Unsigned_8_Byte;
      Time_Tag    : Unsigned_8_Byte;
      Transfer_ID : Unsigned_8_Byte;
   end record;

   type Data_Record is record
      Channel     : Channel_Type;
      Time_Tag    : Long_Integer;
      Transfer_ID : Integer;
   end record;

   procedure NIST_Data (Source_File, NIST_File : String) is
      use Ada.Streams;
      use Ada.Text_IO;
      Routine_Name : constant String  := "Process_Data.NIST_Data ";
      --  Source_Size  : constant Natural := Natural (Size (Source_File));
      Data_Stream  : Stream_IO.Stream_Access;
      Source_ID    : Stream_IO.File_Type;
      NIST_ID      : Ada.Text_IO.File_Type;
      Raw_Data     : Raw_Data_Record;
      Data         : Data_Record;
      --   P_Setting    : String (1 .. 1);
      --  Line_Num     : Natural := 0;
      --  Byte_Offset  : Integer := -2;
      Num_Invalid  : Natural := 0;
   begin
      Ada.Text_IO.Put_Line (Routine_Name & "Source File: " & Source_File);
      Stream_IO.Open (Source_ID, Stream_IO.In_File, Source_File);
      Data_Stream := Stream_IO.Stream (Source_ID);
      Ada.Text_IO.Create (NIST_ID, Out_File, NIST_File);

      --  while Line_Num < Source_Size - 1 and then
        while not Stream_IO.End_Of_File (Source_ID) loop
        --  Line_Num := Line_Num + 1;
       --  Byte_Offset := Byte_Offset + 2;

         Raw_Data_Record'Read (Data_Stream, Raw_Data);
         case Raw_Data.Channel is
            when 0 => Data.Channel := Detector_Click;
            when 2 => Data.Channel := Rng_Output_0;
            when 4 => Data.Channel := Rng_Output_1;
            when 5 => Data.Channel := GPS_Pps;
            when 6 => Data.Channel := Sync;
            when others => Num_Invalid := Num_Invalid + 1;
         end case;
         Data.Time_Tag := Long_Integer (Raw_Data.Time_Tag);
         Data.Transfer_ID := Integer (Raw_Data.Transfer_ID);
         Put_Line (Routine_Name & "Raw Data Time_Tag: " &
                   Unsigned_8_Byte'Image (Raw_Data.Time_Tag) &
                  ", Transfer_ID " &
                   Unsigned_8_Byte'Image (Raw_Data.Transfer_ID));

          Ada.Text_IO.Put (NIST_ID, Channel_Type'Image (Data.Channel) & "," &
                            Long_Integer'Image (Data.Time_Tag) & "," &
                            Integer'Image (Data.Transfer_ID));
          Ada.Text_IO.New_Line (NIST_ID);
         Data.Transfer_ID := Integer (Raw_Data.Transfer_ID);

         --  if Line_Num > 0 and then Line_Num < 8 then
         --     Ada.Text_IO.Put_Line
        --        (Routine_Name & "line, byte " & Integer'Image (Line_Num) & " " &
       --           Integer'Image (Byte_Offset) & " Data: " & Int_16'Image (Data));
         --  end if;

         --  Big-Endian (BE) stores the most significant byte first
      end loop;

      Ada.Text_IO.Close (NIST_ID);
      Stream_IO.Close (Source_ID);

      Ada.Text_IO.Put_Line
        (Routine_Name & "Number of invalid items: " &
           Integer'Image (Num_Invalid));
      --  Ada.Text_IO.Put_Line
      --  (Routine_Name & "NIST file written to " & NIST_ID);
      Ada.Text_IO.Put_Line
        (Routine_Name & "NIST file length: " &
           Natural'Image (Count_Text_File_Lines (NIST_File)) & " lines");
      Ada.Text_IO.New_Line;

   exception
      when Error : others =>
        --  Put_Line (Routine_Name & "Line_Num" & Integer'Image (Line_Num));
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;
   end NIST_Data;

   --  -----------------------------------------------------------------------

   --  Photon arrival times where the "arm" time has already been subtracted.
   --  IEEE-8bit double precision numbers in "Big Endian"-form naturally
   --  sorted ascendingly.
   --  Actual time resolution is 10-10seconds but accuracy is only 0.5 ns.
   --  Example: 3EC2 25E0 8677 939E => 2.16340508861703e-6

   --  Structure of a Double-Precision Floating-Point Number:
   --  Sign (1 bit): Determines if the number is positive or negative
   --  (0 for positive, 1 for negative).
   --  Exponent (11 bits):
   --      Represents the power of 2 by which the significand is multiplied.
   --  Significand (52 bits):
   --      Represents the fractional part of the number (also called mantissa)

end Process_Data;
