
with Interfaces;

with Ada.Containers.Indefinite_Vectors;
with Ada.Strings.Unbounded;

package Types is
   pragma Preelaborate;

   subtype Byte is Interfaces.Unsigned_8;
   type Byte_Array is array (Integer range <>) of Byte;
   for Byte_Array'Alignment use 1;

   subtype String_1 is String (1 .. 1);
   subtype String_4 is String (1 .. 4);
   subtype String_12 is String (1 .. 12);
   subtype String_13 is String (1 .. 13);
   subtype String_33 is String (1 .. 33);
   subtype String_46 is String (1 .. 46);

   type String1_Array is array (Integer range <>) of String_1;
   type String4_Array is array (Integer range <>) of String_4;
   type String13_Array is array (Integer range <>) of String_13;
   type String33_Array is array (Integer range <>) of String_33;
   type String46_Array is array (Integer range <>) of String_46;

   --  type UB_String_Array is Array (Integer range <>) of
   --  Ada.Strings.Unbounded.Unbounded_String;

end Types;
