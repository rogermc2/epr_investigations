
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

package body Utils is

   function Count_Text_File_Lines (File_Name  : String) return Natural is
      File       : File_Type;
      Line_Count : Natural := 0;
   begin
      Put_Line ("Utils.Count_Text_File_Lines opening " & File_Name);
      Open (File, In_File, File_Name);

      while not End_Of_File (File) loop
         Skip_Line (File);
         Line_Count := Line_Count + 1;
      end loop;

      Close (File);
      return Line_Count;

   exception
      when Error : others =>
         Put_Line ("Utils.Count_Text_File_Lines Exception information:  " &
                     Exception_Information (Error));
      return Line_Count;

   end Count_Text_File_Lines;

   function Get_Integer_List (Data : Sample_Data_List;
                              Selection : Detect_Type) return Integer_List is
      use Sample_Data_Package;
      Count   : Natural := 0;
      Curs    : Cursor := Data.First;
      Item    : Sample_Data_Record;
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

   end Get_Integer_List;

--  ------------------------------------------------------------------

--  function Hex (aByte : Byte) return String is
--     use Interfaces;
--     Hex_Chars   : constant array (Unsigned_8 range 0 .. 15) of Character
--     := ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
--       'A', 'B', 'C', 'D', 'E', 'F');
--     Half_Byte_1 : constant Unsigned_8 := aByte mod 16;
--     Half_Byte_2 : constant Unsigned_8 := aByte / 16;
--  begin
--     return Hex_Chars (Half_Byte_2) & Hex_Chars (Half_Byte_1);
--  end Hex;

--  --------------------------------------------------------------------

procedure Swap_Endian (Data : in out Interfaces.Unsigned_16) is
   use Interfaces;
   Right_Byte   : constant Unsigned_16 := Data and 16#FF#;
begin
   Data := Shift_Left (Right_Byte, 8) +
     Shift_Right (Data and 16#FF00#, 8);

end Swap_Endian;

--  ---------------------------------------------------------------------

function To_IEEE_Double_Big_Endian
  (Data : Types.Byte_Array) return Double is
   use Interfaces;
   Bias        : constant Integer := 1023;
   Raw_Value   : Unsigned_64 := 0;
   Sign        : Unsigned_8;
   Exponent    : Unsigned_16;
   Fraction    : Double;
   Float_Val   : Double;
begin
   --  Combine 8 bytes into a single 64-bit integer
   for I in 1 .. 8 loop
      Raw_Value := Shift_Left (Raw_Value, 8) + Unsigned_64 (Data (I));
   end loop;
   --  Ada.Text_IO.Put_Line
   --    ("Raw_Value: " & Unsigned_64'Image (Raw_Value));

   --  Structure of a Double-Precision Floating-Point Number:
   --  Sign (1 bit): Determines if the number is positive or negative
   --  (0 for positive, 1 for negative).
   --  Exponent (11 bits): Represents the power of 2 by which the
   --  significand is multiplied.
   --  Fraction (52 bits): Represents the fractional part of the number
   --  (also called the mantissa).
   Sign := Unsigned_8 (Shift_Right (Raw_Value, 63) and 1);
   --  Extract exponent (bits 52-62)
   Exponent := Unsigned_16 ((Shift_Right (Raw_Value, 52) and 16#7FF#));
   --  Extract fraction (mantissa) (bits 0-51)
   Fraction := Double (Raw_Value and 16#FFFFFFFFFFFFF#) / 2.0 ** 52;

   if Exponent = 0 then
      --  Subnormal number (denormalized)
      Float_Val := Fraction * 2.0 ** (1 - Bias);
   elsif Exponent = 16#7FF# then
      --  NaN (Not a Number)
      if Fraction = 0.0 then
         Float_Val := Double'Last;
      else
         --  NaN (Not a Number)
         Float_Val := Double'Last;
      end if;
   else
      Float_Val := (1.0 + Fraction) * 2.0 ** (Integer (Exponent) - Bias);
   end if;

   if Sign = 1 then
      Float_Val := -Float_Val;
   end if;

   return Float_Val;

end To_IEEE_Double_Big_Endian;

end Utils;
