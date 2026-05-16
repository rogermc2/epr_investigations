
with Ada.Containers.Vectors;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package Types is

   subtype Settings_Type is Float;
   type Float_Array is array (Positive range <>) of Float;

   package Boolean_Vector_Package is new
     Ada.Containers.Vectors (Positive, Boolean);
   subtype Boolean_Vector is Boolean_Vector_Package.Vector;

   package Float_Vector_Package is new
     Ada.Containers.Vectors (Positive, Float);
   subtype Float_Vector is Float_Vector_Package.Vector;

   type Particle_Data is record
      E      : Float;
      P      : Float;
      Spin_N : Float;
   end record;

   package Particle_Vector_Package is new
     Ada.Containers.Vectors (Positive, Particle_Data);
   subtype Particle_Vector is Particle_Vector_Package.Vector;

   type Particle_Record is record
      Particle : Particle_Data;
      Setting  : Settings_Type;
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
   use Result_Vector_Package;

   package Result_Matrix_Package is new
     Ada.Containers.Vectors (Positive, Result_Vector);
   subtype Result_Matrix is Result_Matrix_Package.Vector;


   package Settings_Vector_Package is new
     Ada.Containers.Vectors (Positive, Settings_Type);
   subtype Settings_Vector is Settings_Vector_Package.Vector;

   type Station_Type is record
      Name      : Unbounded_String := To_Unbounded_String ("Unspecified");
      Particles : Particle_Vector;
      Results   : Result_Vector;
   end record;

end Types;
