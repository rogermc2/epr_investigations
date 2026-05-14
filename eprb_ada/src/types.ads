
with Ada.Containers.Vectors;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package Types is

   type Float_Array is array (Positive range <>) of Float;

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
      Setting  : Float;
   end record;

   type Result_Data is record
      Setting : Float := 0.0;
      Outcome : Float := 999.9;  --  Use Float to represent sign
   end record;

   package Result_Vector_Package is new
     Ada.Containers.Vectors (Positive, Result_Data);
   subtype Result_Vector is Result_Vector_Package.Vector;

   type Station_Type is record
      Name      : Unbounded_String := To_Unbounded_String ("Unspecified");
      Particles : Particle_Vector;
      Results   : Result_Vector;
   end record;

end Types;
