
with Interfaces;

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
