
with Ada.Containers.Vectors;

with Types; use Types;

Package Analysis_Types is

   subtype MilliRad is Integer range -6300 .. 6300;

   package Outcomes_Vector_Package is new
     Ada.Containers.Vectors (Positive, Float);
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
