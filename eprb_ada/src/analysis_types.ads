
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
      N_A       : Natural;
      N_B       : Natural;
      N_AB      : Natural;
      N_A_Sum   : Integer;
      N_B_Sum   : Integer;
      N_AB_Sum  : Integer;
      Npp       : Natural;
      Npm       : Natural;
      Nmp       : Natural;
      Nmm       : Natural;
      Setting_A : MilliRad;
      Setting_B : MilliRad;
   end record;

   package Analysis_Vector_Package is new
     Ada.Containers.Vectors (Positive, Analysis_Record);
   subtype Analysis_Vector is Analysis_Vector_Package.Vector;

end Analysis_Types;
