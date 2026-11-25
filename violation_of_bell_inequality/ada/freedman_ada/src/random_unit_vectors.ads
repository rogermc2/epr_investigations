
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;

with Maths; use Maths;

package Random_Unit_Vectors is

   function Magnitude (V : Real_Vector_3D) return Float;
   function Random_Real_Unit_Vector (G : Generator) return Real_Vector_3D;
   function Random_Complex_Unit_Vector (G : Generator)
         return Complex_Vector_3D;
   procedure Test_Random_Unit_Vectors;

end Random_Unit_Vectors;