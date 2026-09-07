
with Ada.Containers.Vectors;

package Nist_Types is

   type Unsigned_64 is mod 2**64;
   type Raw_Record is array (0 .. 2) of Unsigned_64;

   package Raw_Data_Package is new
       Ada.Containers.Vectors (Positive, Raw_Record);
   subtype Raw_Data_List is Raw_Data_Package.Vector;

   package Sync_Data_Package is new
       Ada.Containers.Vectors (Positive, Unsigned_64);
   subtype Sync_Data_List is Sync_Data_Package.Vector;

   --  type Sync_Array is array (Positive range <>) of Unsigned_64;
   --  type Sync_Access is access Sync_Array;

   package Index_Data_Package is new
       Ada.Containers.Vectors (Positive, Positive);
   subtype Index_List is Index_Data_Package.Vector;
   --  type Index_Array is array (Positive range <>) of Positive;
   --  type Index_Access is access Index_Array;

end Nist_Types;