
with Ada.Containers.Vectors;

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

   type Result_Data is record
      Setting : Float := 0.0;
      Outcome : Float := 999.9;  --  Use Float to represent sign
   end record;

   package Result_Vector_Package is new
     Ada.Containers.Vectors (Positive, Result_Data);
   subtype Result_Vector is Result_Vector_Package.Vector;

end Types;
