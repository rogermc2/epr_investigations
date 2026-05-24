
with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Containers.Vectors;

with Types; use Types;

Package Analysis_Types is

   subtype MilliRad is Integer range -6300 .. 6300;

   type Setting_Map_Record is record
      A  : MilliRad;
      B : MilliRad;
   end record;

   package MilliRad_Map_Package is new
     Ada.Containers.Indefinite_Ordered_Maps (Setting_Map_Record, Positive);
   subtype MilliRad_Map is MilliRad_Map_Package.Map;

   package Outcomes_Vector_Package is new
     Ada.Containers.Vectors (Positive, Float_Vector_Package.Vector);
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
