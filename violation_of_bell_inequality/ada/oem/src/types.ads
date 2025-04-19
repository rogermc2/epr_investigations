
with Interfaces;

with Ada.Containers.Doubly_Linked_Lists;
with Ada.Containers.Indefinite_Doubly_Linked_Lists;
with Ada.Containers.Indefinite_Vectors;
with Ada.Containers.Vectors;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package Types is
   pragma Preelaborate;

   subtype Byte is Interfaces.Unsigned_8;
   type Byte_Array is array (Integer range <>) of Byte;
   for Byte_Array'Alignment use 1;

   package Integer_Package is new
      Ada.Containers.Vectors (Positive, Integer);
   subtype Integer_List is Integer_Package.Vector;
    package Integer_Sorting is new Integer_Package.Generic_Sorting ("<");
   type Array_Of_Integer_Lists is array (Integer range <>) of Integer_List;

   use Integer_Package;
   package Integer_Package_2D is new
      Ada.Containers.Vectors (Positive, Integer_List);
   subtype Integer_List_2D is Integer_Package_2D.Vector;

   function Transpose (Values : Integer_List_2D) return  Integer_List_2D;
   pragma Inline (Transpose);

   package Integer_DLL_Package is new
     Ada.Containers.Doubly_Linked_Lists (Integer);
   subtype Integer_DL_List is Integer_DLL_Package.List;

--      package Real_Float_Arrays is new Ada.Numerics.Generic_Real_Arrays (Float);
--      subtype Real_Float_Matrix is Real_Float_Arrays.Real_Matrix;
--      subtype Real_Float_Vector is Real_Float_Arrays.Real_Vector;

   package Character_Package is new Ada.Containers.Vectors
     (Positive, Character);
   subtype Character_List is Character_Package.Vector;

   package Bounded_Strings_Package is new Ada.Containers.Indefinite_Vectors
     (Positive, String);
   subtype Bounded_String_List is Bounded_Strings_Package.Vector;

   package Unbounded_Package is new Ada.Containers.Vectors
     (Positive, Unbounded_String);
   subtype Unbounded_List is Unbounded_Package.Vector;
   package Unbounded_Sorting is new Unbounded_Package.Generic_Sorting ("<");

   use Unbounded_Package;
   package Unbounded_Package_2D is new
     Ada.Containers.Vectors (Positive, Unbounded_List);
   subtype Unbounded_List_2D is Unbounded_Package_2D.Vector;

   package Raw_Data_Package is new Ada.Containers.Vectors
     (Positive, Unbounded_List);
   subtype Raw_Data_Vector is Raw_Data_Package.Vector;

   type Data_Rows is array (Integer range <>) of Unbounded_String;

   package Indefinite_String_Package is new
     Ada.Containers.Indefinite_Doubly_Linked_Lists (String);
   subtype Indef_String_List is Indefinite_String_Package.List;

   package String_Package is new Ada.Containers.Doubly_Linked_Lists
     (Ada.Strings.Unbounded.Unbounded_String);
   subtype String_List is String_Package.List;

   use String_Package;
   package String_List_Package is new Ada.Containers.Doubly_Linked_Lists
     (String_List);
   subtype String_Multi_List is String_List_Package.List;

   package String_Vector_Package is new Ada.Containers.Vectors
     (Positive, Ada.Strings.Unbounded.Unbounded_String);
   subtype String_Vector is String_Vector_Package.Vector;

   package Strings_Package is new Ada.Containers.Doubly_Linked_Lists
     (Unbounded_String);
   subtype Strings_List is Strings_Package.List;

end Types;
