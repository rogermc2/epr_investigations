
with Ada.Directories; use Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Streams;
with Ada.Streams.Stream_IO;
with Ada.Text_IO;

package body Utils is

   --  -------------------------------------------------------------------------

   --  function Hex (aByte : Byte) return String is
   --     use Interfaces;
   --     Hex_Chars   : constant array (Unsigned_8 range 0 .. 15) of Character :=
   --       ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D',
   --       'E', 'F');
   --     Half_Byte_1 : constant Unsigned_8 := aByte mod 16;
   --     Half_Byte_2 : constant Unsigned_8 := aByte / 16;
   --  begin
   --     return Hex_Chars (Half_Byte_2) & Hex_Chars (Half_Byte_1);
   --  end Hex;

   --  -------------------------------------------------------------------------

   procedure OEM_Data (Source_File, OEM_Directory : String) is
      use Interfaces;
      use Ada.Streams;
      use Ada.Text_IO;
      Routine_Name : constant String  := "Utils.OEM_Data ";
      OEM_File     : constant String  := OEM_Directory & "OEM.csv";
      Source_Size  : constant Natural := Natural (Size (Source_File));
      Data_Stream  : Stream_IO.Stream_Access;
      Source_ID    : Stream_IO.File_Type;
      OEM_ID       : Ada.Text_IO.File_Type;
      Line_Num     : Natural := 1;
      Data         : Byte_Array (1 .. 2);
      Num_Invalid  : Natural := 0;
   begin
      Ada.Text_IO.Put_Line (Routine_Name & "Source File: " & Source_File);
      Stream_IO.Open (Source_ID, Stream_IO.In_File, Source_File);
      Data_Stream := Stream_IO.Stream (Source_ID);
      Ada.Text_IO.Create (OEM_ID, Out_File, OEM_File);

      while Line_Num < Source_Size and then
        not Stream_IO.End_Of_File (Source_ID) loop
         Byte_Array'Read (Data_Stream, Data);

         if Data (2) = 0 then
            Ada.Text_IO.Put (OEM_ID, "0,0");

         elsif Data (2) = 1 then
            Ada.Text_IO.Put (OEM_ID, "0,1");

         elsif Data (2) = 2 then
            Ada.Text_IO.Put (OEM_ID, "1,0");

         elsif Data (2) = 3 then
            Ada.Text_IO.Put (OEM_ID, "1,1");
         else
            Num_Invalid := Num_Invalid + 1;
            if Num_Invalid < 5 then
               Ada.Text_IO.Put_Line
                 (Routine_Name & "line " & Integer'Image (Line_Num) &
                    " Invalid Val: " & Byte'Image (Data (2)));
            end if;
         end if;

         if not Stream_IO.End_Of_File (Source_ID) then
            Ada.Text_IO.Put (OEM_ID, ",");
         end if;

         Line_Num := Line_Num + 1;
         Ada.Text_IO.New_Line (OEM_ID);
      end loop;

      Ada.Text_IO.Close (OEM_ID);
      Stream_IO.Close (Source_ID);

      Ada.Text_IO.Put_Line
        (Routine_Name & "Number of invalid items: " &
           Integer'Image (Num_Invalid));
      Ada.Text_IO.Put_Line
        (Routine_Name & "OEM files written to " & OEM_Directory);
      Ada.Text_IO.Put_Line
        (Routine_Name & "OEM file length: " &
           Natural'Image (Natural (Size (OEM_Directory & "OEM.csv"))));
      Ada.Text_IO.New_Line;

   exception
      when Error : others =>
         Put_Line (Routine_Name & "Line_Num" & Integer'Image (Line_Num));
         Put_Line (Routine_Name & Exception_Information (Error));
         raise;
   end OEM_Data;

   --  -------------------------------------------------------------------------

   procedure Swap_Endian (Data : in out Interfaces.Unsigned_16) is
      use Interfaces;
      Right_Byte   : constant Unsigned_16 := Data and 16#FF#;
   begin
      Data := Shift_Left (Right_Byte, 8) +
        Shift_Right (Data and 16#FF00#, 8);

   end Swap_Endian;

   --  -------------------------------------------------------------------------

   function To_IEEE_Double_Big_Endian (Data : Types.Byte_Array) return Float is
      use Interfaces;
      Bias        : constant Integer := 1023;
      Raw_Value   : Unsigned_64 := 0;
      Sign        : Unsigned_8;
      Exponent    : Unsigned_16;
      Fraction    : Float;
      Float_Val   : Float;
   begin
      --  Combine 8 bytes into a single 64-bit integer
      for I in 1 .. 8 loop
         Raw_Value := Shift_Left (Raw_Value, 8) + Unsigned_64 (Data (I));
      end loop;
      --  Ada.Text_IO.Put_Line
      --    ("Raw_Value: " & Unsigned_64'Image (Raw_Value));

      --  Structure of a Double-Precision Floating-Point Number:
      --  Sign (1 bit): Determines if the number is positive or negative (0 for positive, 1 for negative).
      --  Exponent (11 bits): Represents the power of 2 by which the significand is multiplied.
      --  Fraction (52 bits): Represents the fractional part of the number (also called the mantissa).
      Sign := Unsigned_8 (Shift_Right (Raw_Value, 63) and 1);
      --  Extract exponent (bits 52-62)
      Exponent := Unsigned_16 ((Shift_Right (Raw_Value, 52) and 16#7FF#));
      --  Extract fraction (mantissa) (bits 0-51)
      Fraction := Float (Raw_Value and 16#FFFFFFFFFFFFF#) / 2.0 ** 52;

      if Exponent = 0 then
         --  Subnormal number (denormalized)
         Float_Val := Fraction * 2.0 ** (1 - Bias);
      elsif Exponent = 16#7FF# then
         --  NaN (Not a Number)
         if Fraction = 0.0 then
            Float_Val := Float'Last;
         else
            --  NaN (Not a Number)
            Float_Val := Float'Last;
         end if;
      else
         Float_Val := (1.0 + Fraction) * 2.0 ** (Integer (Exponent) - Bias);
      end if;

      if Sign = 1 then
         Float_Val := -Float_Val;
      end if;

      return Float_Val;

   end To_IEEE_Double_Big_Endian;

   --  -------------------------------------------------------------------------

end Utils;
