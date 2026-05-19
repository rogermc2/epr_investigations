
with Ada.Containers.Vectors;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package Types is

   type Float_Array is array (Positive range <>) of Float;
   type Float_Matrix is array (Positive range <>, Positive range <>)
                                    of Float;
   type Boolean_Matrix is array (Positive range <>, Positive range <>)
                                    of Boolean;

   package Boolean_Vector_Package is new
     Ada.Containers.Vectors (Positive, Boolean);
   subtype Boolean_Vector is Boolean_Vector_Package.Vector;

   package Natural_Vector_Package is new
     Ada.Containers.Vectors (Positive, Natural);
   subtype Natural_Vector is Natural_Vector_Package.Vector;

   package Float_Vector_Package is new
     Ada.Containers.Vectors (Positive, Float);
   subtype Float_Vector is Float_Vector_Package.Vector;

   type Particle_Data is record
      E      : Float;
      P      : Float;
      Spin_N : Float;
   end record;

   package Particle_Data_Package is new
     Ada.Containers.Vectors (Positive, Particle_Data);
   subtype Particle_Vector is Particle_Data_Package.Vector;

   type Particle_Record is record
      Particle : Particle_Data;
      Setting  : Float;
   end record;

   package Pairs_Vector_Package is new
     Ada.Containers.Vectors (Positive, Particle_Record);
   subtype Pairs_Vector is Pairs_Vector_Package.Vector;

   type Result_Data is record
      Setting : Float := 0.0;
      Outcome : Float := 999.9;  --  Use Float to represent sign
   end record;

   package Result_Vector_Package is new
     Ada.Containers.Vectors (Positive, Result_Data);
   subtype Result_Vector is Result_Vector_Package.Vector;

   package Settings_Vector_Package is new
     Ada.Containers.Vectors (Positive, Float);
   subtype Settings_Vector is Settings_Vector_Package.Vector;

   type Pair is record
      First  : Float;
      Second : Float;
   end record;

   package Setting_Pairs_Vector_Package is new
     Ada.Containers.Vectors (Index_Type => Positive, Element_Type => Pair);
   subtype Setting_Pairs_Vector is Setting_Pairs_Vector_Package.Vector;


   type Station_Type is record
      Name      : Unbounded_String := To_Unbounded_String ("Unspecified");
      Particles : Particle_Vector;
      Results   : Result_Vector;
   end record;

end Types;
