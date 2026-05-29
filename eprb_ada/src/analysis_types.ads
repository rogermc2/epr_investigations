
with Ada.Containers.Ordered_Maps;
with Ada.Containers.Vectors;
with Ada.Text_IO;

package Analysis_Types is

   subtype MilliRad is Integer range -6300 .. 6300;
   type File_Array is array (Positive range <>) of Ada.Text_IO.File_Type;

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
      Outcome_A : Integer;
      Outcome_B : Integer;
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

   type Analysis_Record is record
      N_A       : Natural := 0;
      N_B       : Natural := 0;
      N_AB      : Natural := 0;
      A_Mean    : Float := 0.0;
      B_Mean    : Float := 0.0;
      AB_Mean   : Float := 0.0;
      Npp       : Natural := 0;
      Npm       : Natural := 0;
      Nmp       : Natural := 0;
      Nmm       : Natural := 0;
      E_QM      : Float := 0.0;
      E_Stat    : Float := 0.0;
      Setting_A : MilliRad;
      Setting_B : MilliRad;
   end record;

   package Analysis_Vector_Package is new
     Ada.Containers.Vectors (Positive, Analysis_Record);
   subtype Analysis_Vector is Analysis_Vector_Package.Vector;

end Analysis_Types;
