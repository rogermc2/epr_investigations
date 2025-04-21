
with Interfaces;

with Ada.Containers.Indefinite_Vectors;

package Types is
   pragma Preelaborate;

   subtype Byte is Interfaces.Unsigned_8;
   type Byte_Array is array (Integer range <>) of Byte;
   for Byte_Array'Alignment use 1;

   package Bounded_Strings_Package is new Ada.Containers.Indefinite_Vectors
     (Positive, String);
   subtype Bounded_String_List is Bounded_Strings_Package.Vector;

end Types;
