
with Interfaces;

with Ada.Containers.Vectors;

package Types is
   pragma Preelaborate;

   type Double is digits 15;

   subtype Byte is Interfaces.Unsigned_8;
   type Byte_Array is array (Integer range <>) of Byte;
   for Byte_Array'Alignment use 1;

   subtype String_1 is String (1 .. 1);
   subtype String_3 is String (1 .. 3);
   subtype String_4 is String (1 .. 4);
   subtype OEM_String is String (1 .. 9);
   subtype String_12 is String (1 .. 12);
   subtype String_19 is String (1 .. 19);
   subtype String_20 is String (1 .. 20);
   subtype String_21 is String (1 .. 21);
   subtype String_33 is String (1 .. 33);
   subtype String_47 is String (1 .. 47);

   type String1_Array is array (Integer range <>) of String_1;
   type String3_Array is array (Integer range <>) of String_3;
   type String20_Array is array (Integer range <>) of String_20;
   type String21_Array is array (Integer range <>) of String_21;
   type String33_Array is array (Integer range <>) of String_33;
   type String47_Array is array (Integer range <>) of String_47;

   package String21_Package is new
     Ada.Containers.Vectors (Positive, String_21);
   subtype String21_List is String21_Package.Vector;

   package String33_Package is new
     Ada.Containers.Vectors (Positive, String_33);
   subtype String33_List is String33_Package.Vector;

   type Data_Record is record
      A_Index    : Natural;
      B_Index    : Natural;
      Difference : Double;
   end record;

   package Match_Package is new
     Ada.Containers.Vectors (Natural, Data_Record);
   subtype Match_List is Match_Package.Vector;

end Types;
