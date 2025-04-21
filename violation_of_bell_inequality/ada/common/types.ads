
with Interfaces;

with Ada.Containers.Indefinite_Vectors;
with Ada.Strings.Unbounded;

package Types is
   pragma Preelaborate;

   subtype Byte is Interfaces.Unsigned_8;
   type Byte_Array is array (Integer range <>) of Byte;
   for Byte_Array'Alignment use 1;

   subtype String_1 is String (1 .. 1);
   subtype String_2 is String (1 .. 2);
   subtype String_6 is String (1 .. 6);
   subtype String_13 is String (1 .. 13);

   type String1_Array is array (Integer range <>) of String_1;
   type String2_Array is array (Integer range <>) of String_2;
   type String6_Array is array (Integer range <>) of String_6;
   type String13_Array is array (Integer range <>) of String_13;

   type UB_String_Array is Array (Integer range <>) of
   Ada.Strings.Unbounded.Unbounded_String;

end Types;
