
with Interfaces;

with Ada.Containers.Vectors;

package Types is
   pragma Preelaborate;

   type Double is digits 13;

   subtype Byte is Interfaces.Unsigned_8;
   type Byte_Array is array (Integer range <>) of Byte;
   for Byte_Array'Alignment use 1;

   subtype String_1 is String (1 .. 1);
   subtype String_4 is String (1 .. 4);
   subtype String_12 is String (1 .. 12);
   subtype String_19 is String (1 .. 19);
   subtype String_20 is String (1 .. 20);
   subtype String_33 is String (1 .. 33);
   subtype String_47 is String (1 .. 47);

   type String1_Array is array (Integer range <>) of String_1;
   type String4_Array is array (Integer range <>) of String_4;
   type String20_Array is array (Integer range <>) of String_20;
   type String33_Array is array (Integer range <>) of String_33;
   type String47_Array is array (Integer range <>) of String_47;

   package String19_Package is new
     Ada.Containers.Vectors (Natural, String_19);
   subtype String19_List is String19_Package.Vector;

   package String33_Package is new
     Ada.Containers.Vectors (Positive, String_33);
   subtype String33_List is String33_Package.Vector;

end Types;
