
with Interfaces;

with Ada.Directories; use Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Streams;
with Ada.Streams.Stream_IO;
with Ada.Text_IO;

with Types; use Types;
with Utils; use Utils;

package body Process_Data is

   procedure OEM_Data (Source_File, OEM_File : String) is
      use Interfaces;
      use Ada.Streams;
      use Ada.Text_IO;
      Routine_Name : constant String  := "Process_Data.OEM_Data ";
      Source_Size  : constant Natural := Natural (Size (Source_File));
      Data_Stream  : Stream_IO.Stream_Access;
      Source_ID    : Stream_IO.File_Type;
      OEM_ID       : Ada.Text_IO.File_Type;
      Data         : Int_16;
      P_Setting    : String (1 .. 1);
      Line_Num     : Natural := 0;
      Num_Invalid  : Natural := 0;
   begin
      Ada.Text_IO.Put_Line (Routine_Name & "Source File: " & Source_File);
      Stream_IO.Open (Source_ID, Stream_IO.In_File, Source_File);
      Data_Stream := Stream_IO.Stream (Source_ID);
      Ada.Text_IO.Create (OEM_ID, Out_File, OEM_File);

      while Line_Num < Source_Size - 1 and then
        not Stream_IO.End_Of_File (Source_ID) loop
         Line_Num := Line_Num + 1;
         Int_16'Read (Data_Stream, Data);
         --  if Line_Num <= 8 then
         --     Ada.Text_IO.Put_Line
         --       (Routine_Name & "line " & Integer'Image (Line_Num) &
         --          " Data: " & Int_16'Image (Data));
         --  end if;

         --  Big-Endian (BE) stores the most significant byte first.
         --  Apparatus settings and outcomes for each photon detection is
         --  encoded as follows:
         --  16-bit integers, each number showing: the detector
         --  (0=vertical, 1=horizontal with respect to the polarizer)
         --  that fired in its MSB and position of the switch,
         --  0 = no rotation (a), 1 = 45 deg. rotation (b) in the next to MSB.
         if Data = 0 or else Data = 256 then       --  MSB - 1 => 0 or 10
            P_Setting := "a";
         elsif Data = 512 or else Data = 768 then  --  MSB => 1 or 3
            P_Setting := "b";
         end if;

         if Data = 0 or else Data = 512 then
            Ada.Text_IO.Put_Line (OEM_ID, P_Setting & ",+1");
         elsif Data = 256 or else Data = 768 then
            Ada.Text_IO.Put_Line (OEM_ID, P_Setting & ",-1");
         elsif Data /= 0 and then Data /= 256 and then
           Data /= 512 and then Data /= 768
         then
            Num_Invalid := Num_Invalid + 1;
            if Num_Invalid < 12 then
               Ada.Text_IO.Put_Line
                 (Routine_Name & "line " & Integer'Image (Line_Num) &
                    " Invalid Val: " & Int_16'Image (Data));
            end if;
         end if;

      end loop;

      Ada.Text_IO.Close (OEM_ID);
      Stream_IO.Close (Source_ID);

      Ada.Text_IO.Put_Line
        (Routine_Name & "Number of invalid items: " &
           Integer'Image (Num_Invalid));
      Ada.Text_IO.Put_Line
        (Routine_Name & "OEM file written to " & OEM_File);
      Ada.Text_IO.Put_Line
        (Routine_Name & "OEM file length: " &
           Natural'Image (Count_Text_File_Lines (OEM_File)) & " lines");
      Ada.Text_IO.New_Line;

   exception
      when Error : others =>
         Put_Line (Routine_Name & "Line_Num" & Integer'Image (Line_Num));
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;
   end OEM_Data;

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

   procedure Photon_Data (Source_File, Target_File : String) is
      use Ada.Streams;
      use Ada.Text_IO;
      Routine_Name : constant String := "Process_Data.Photon_Data ";
      Source_ID    : Stream_IO.File_Type;
      PT_ID        : Ada.Text_IO.File_Type;
      Data_Stream  : Stream_IO.Stream_Access;
      Line_Num     : Natural := 0;
      Data         : Byte_Array (1 .. 8);
      Number       : Double;
   begin
      Ada.Text_IO.Put_Line (Routine_Name & "Source File: " & Source_File);
      Ada.Text_IO.New_Line;
      Stream_IO.Open (Source_ID, Stream_IO.In_File, Source_File);
      Data_Stream := Stream_IO.Stream (Source_ID);
      Ada.Text_IO.Create (PT_ID, Ada.Text_IO.Out_File, Target_File);

      while not Stream_IO.End_Of_File (Source_ID) loop
         Line_Num := Line_Num + 1;
         Byte_Array'Read (Data_Stream, Data);
         Number := To_IEEE_Double_Big_Endian (Data);
         --  if Line_Num < 4 then
         --     Put_Line (Routine_Name & "Number: " & Double'Image (Number));
         --  end if;
         Put_Line (PT_ID, Double'Image (Number));
      end loop;

      Ada.Text_IO.Close (PT_ID);
      Stream_IO.Close (Source_ID);

      Ada.Text_IO.Put_Line
        (Routine_Name & "Photon times file written to " & Target_File);
      Ada.Text_IO.Put_Line
        (Routine_Name & "Photon times file length: " &
           Natural'Image (Count_Text_File_Lines (Target_File)) & " lines");

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));

   end Photon_Data;

end Process_Data;
