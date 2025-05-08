
with Interfaces;

package Types is
   pragma Preelaborate;

   type Double is digits 13;

   subtype Byte is Interfaces.Unsigned_8;
   type Byte_Array is array (Integer range <>) of Byte;
   for Byte_Array'Alignment use 1;

   subtype String_1 is String (1 .. 1);
   subtype String_4 is String (1 .. 4);
   subtype String_12 is String (1 .. 12);
   subtype String_20 is String (1 .. 20);
   subtype String_33 is String (1 .. 33);
   subtype String_46 is String (1 .. 46);

   type String1_Array is array (Integer range <>) of String_1;
   type String4_Array is array (Integer range <>) of String_4;
   type String20_Array is array (Integer range <>) of String_20;
   type String33_Array is array (Integer range <>) of String_33;
   type String46_Array is array (Integer range <>) of String_46;

end Types;
