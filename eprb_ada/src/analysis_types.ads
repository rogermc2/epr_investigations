
with Ada.Containers.Ordered_Maps;
with Ada.Containers.Vectors;

with Types; use Types;

package Analysis_Types is

   subtype MilliRad is Integer range -6300 .. 6300;

   type Setting_Map_Record is record
      A : MilliRad;
      B : MilliRad;
   end record;
   function "<" (L, R : Setting_Map_Record) return Boolean;
   function "=" (L, R : Setting_Map_Record) return Boolean;
   function ">" (L, R : Setting_Map_Record) return Boolean;

   package MilliRad_Map_Package is new
     Ada.Containers.Ordered_Maps (Setting_Map_Record, Positive);
   subtype MilliRad_Map is MilliRad_Map_Package.Map;

   use Float_Vector_Package;
   package Outcomes_Vector_Package is new
     Ada.Containers.Vectors (Positive, Float_Vector);
   subtype Outcomes_Vector is Outcomes_Vector_Package.Vector;

   type Outcomes_Record is record
      Setting  : Integer;
      Outcomes : Outcomes_Vector;
   end record;

   package Converted_Outcomes_Vector_Package is new
     Ada.Containers.Vectors (Positive, Outcomes_Record);
   subtype Converted_Outcomes_Vector is
     Converted_Outcomes_Vector_Package.Vector;

   type Data_Record_Package is record
      Setting_A : MilliRad;
      Setting_B : MilliRad;
      Outcomes  : Outcomes_Vector;
   end record;

end Analysis_Types;
