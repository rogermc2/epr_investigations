
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
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

   type Outcomes_Record is record
      Outcome_A : Float;
      Outcome_B : Float;
   end record;

   package Outcome_Vector_Package is new
     Ada.Containers.Vectors (Positive, Outcomes_Record);
   subtype Outcome_Vector is Outcome_Vector_Package.Vector;

   use Outcome_Vector_Package;
   type Data_Record is record
      Setting_A : MilliRad;
      Setting_B : MilliRad;
      Outcomes  : Outcome_Vector;
   end record;

   package Outcomes_Matrix_Package is new
     Ada.Containers.Vectors (Positive, Data_Record);
   subtype Outcomes_Matrix is Outcomes_Matrix_Package.Vector;

   package File_Vector_Package is new
     Ada.Containers.Vectors (Positive, Unbounded_String);
   subtype File_Vector is File_Vector_Package.Vector;

end Analysis_Types;
