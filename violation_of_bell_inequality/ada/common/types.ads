
with Interfaces;

with Ada.Containers.Vectors;

package Types is
   pragma Preelaborate;

   ns : constant Float := 10.0 ** (-9);
   type Double is digits 15;  --  Float type
   type Double_Integer is range -2**63 .. (2**63 - 1);
   type Double_Natural is range 0 .. (2**63 - 1);

   subtype Byte is Interfaces.Unsigned_8;
   subtype Int_16 is Interfaces.Unsigned_16;
   subtype UV is integer range -1 .. 1;

   type Byte_Array is array (Integer range <>) of Byte;
   for Byte_Array'Alignment use 1;

   subtype String_1 is String (1 .. 1);
   subtype String_2 is String (1 .. 2);
   subtype String_3 is String (1 .. 3);
   subtype String_4 is String (1 .. 4);
   subtype String_5 is String (1 .. 5);
   subtype String_8  is String (1 .. 8);
   subtype String_9  is String (1 .. 9);
   subtype String_11 is String (1 .. 11);
   subtype String_12 is String (1 .. 12);
   subtype String_18 is String (1 .. 18);
   subtype String_19 is String (1 .. 19);
   subtype String_20 is String (1 .. 20);
   subtype String_21 is String (1 .. 21);
   subtype String_22 is String (1 .. 22);
   subtype String_23 is String (1 .. 23);
   subtype String_33 is String (1 .. 33);
   subtype String_40 is String (1 .. 40);
   subtype String_53 is String (1 .. 53);

   type String1_Array is array (Integer range <>) of String_1;
   type String3_Array is array (Integer range <>) of String_3;
   type String4_Array is array (Integer range <>) of String_4;
   type String5_Array is array (Integer range <>) of String_5;
   type String8_Array is array (Integer range <>) of String_8;
   type String19_Array is array (Integer range <>) of String_19;
   type StringD19_Array is array (Double_Natural range <>) of String_19;
   type String20_Array is array (Integer range <>) of String_20;
   type String21_Array is array (Integer range <>) of String_21;
   type String22_Array is array (Integer range <>) of String_22;
   type String23_Array is array (Integer range <>) of String_23;
   type String33_Array is array (Integer range <>) of String_33;
   type String40_Array is array (Integer range <>) of String_40;
   type StringD40_Array is array (Double_Natural range <>) of String_40;
   type String53_Array is array (Integer range <>) of String_53;

   package String19_Package is new
     Ada.Containers.Vectors (Positive, String_19);
   subtype String19_List is String19_Package.Vector;

   package String21_Package is new
     Ada.Containers.Vectors (Positive, String_21);
   subtype String21_List is String21_Package.Vector;

   package String33_Package is new
     Ada.Containers.Vectors (Positive, String_33);
   subtype String33_List is String33_Package.Vector;

   type Detect_Type is (Det_A, Det_B, Det_Both);

   type W_Record is record
      A_Setting  : Character;
      B_Setting  : Character;
      A_Result   : String_2;
      B_Result   : String_2;
      AB_Result  : String_2;
   end record;

   package W_Package is new
     Ada.Containers.Vectors (Natural, W_Record);
   subtype W_List is W_Package.Vector;

   type Setting_Time_Record is record
      Setting : Natural;
      Time    : Double_Natural;
   end record;

   package Setting_Time_Package is new
     Ada.Containers.Vectors (Positive, Setting_Time_Record);
   subtype Setting_Time_Vector is Setting_Time_Package.Vector;

   type Index_Record is record
      A_Index    : Natural;
      B_Index    : Natural;
   end record;

   package Match_Package is new
     Ada.Containers.Vectors (Positive, Index_Record);
   subtype Match_List is Match_Package.Vector;

   type Sample_Data_Record is record
      A_Detection : UV;
      B_Detection : UV;
      AB          : UV;
   end record;

   package Sample_Data_Package is new
     Ada.Containers.Vectors (Positive, Sample_Data_Record);
   subtype Sample_Data_List is Sample_Data_Package.Vector;

   package Integer_List_Package is new
     Ada.Containers.Vectors (Positive, Integer);
   subtype Integer_List is Integer_List_Package.Vector;

   package Double_Integer_Package is new
     Ada.Containers.Vectors (Positive, Double_Integer);
   subtype Double_Integer_Vector is Double_Integer_Package.Vector;

end Types;
