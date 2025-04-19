
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Streams;
with Ada.Streams.Stream_IO;
with Ada.Text_IO;

--  with Printing;
with Types;
with Utils;

package body Process_Data is

    --  Photon arrival times where the "arm" time has already been subtracted.
   --  IEEE-8bit double precision numbers in "Big Endian"-form naturally
   --  sorted ascendingly.
   --  Actual time resolution is 10-10seconds but accuracy is only 0.5 ns.
   --  Example: 3EC2 25E0 8677 939E => 2.16340508861703e-6

   --  Structure of a Double-Precision Floating-Point Number:
   --  Sign (1 bit): Determines if the number is positive or negative (0 for positive, 1 for negative).
   --  Exponent (11 bits): Represents the power of 2 by which the significand is multiplied.
   --  Significand (52 bits): Represents the fractional part of the number (also called the mantissa).

   procedure Photon_Data (Source_File, Photon_Times_Directory : String) is
      use Ada.Streams;
      use Ada.Text_IO;
      --  use Printing;
      use Types;
      use Utils;
      --  type  Char_64 is array (1 .. 64) of Character;
      --  pragma Unreferenced (Char_64);

      Routine_Name      : constant String := "Utils.Photon_Data ";
      Photon_Times_File : constant String :=
        Photon_Times_Directory & "Photon_Times.csv";

      Source_ID   : Stream_IO.File_Type;
      PT_ID       : Ada.Text_IO.File_Type;
      Data_Stream : Stream_IO.Stream_Access;
      Line_Num    : Natural := 0;
      Data        : Byte_Array;
      Number      : Float;
   begin
      Ada.Text_IO.Put_Line (Routine_Name & "Source File: " & Source_File);
      Ada.Text_IO.New_Line;
      Stream_IO.Open (Source_ID, Stream_IO.In_File, Source_File);
      Data_Stream := Stream_IO.Stream (Source_ID);
      Ada.Text_IO.Create (PT_ID, Ada.Text_IO.Out_File, Photon_Times_File);

      --  while Line_Num < 2 and not Stream_IO.End_Of_File (Source_ID) loop
      while not Stream_IO.End_Of_File (Source_ID) loop
         Line_Num := Line_Num + 1;
         Byte_Array'Read (Data_Stream, Data);
         Number := To_IEEE_Double_Big_Endian (Data);
         Put (PT_ID, Number'Image);
         if not Stream_IO.End_Of_File (Source_ID) then
            Put (PT_ID, ",");
         end if;
      end loop;

      Ada.Text_IO.Close (PT_ID);
      Stream_IO.Close (Source_ID);

      Ada.Text_IO.Put_Line
        (Routine_Name & "Photon times file written to " &
           Photon_Times_Directory);

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));

   end Photon_Data;

end Process_Data;
