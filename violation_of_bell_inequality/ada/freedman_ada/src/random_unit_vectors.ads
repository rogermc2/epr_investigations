
with Ada.Numerics.Complex_Types; use Ada.Numerics.Complex_Types;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;

with Maths; use Maths;

package Random_Unit_Vectors is

    function Random_Real_Unit_Vector (G : Generator) return Real_Vector_3D;
    function Random_Complex_Unit_Vector (G : Generator) return Complex_Vector_3D;

end Random_Unit_Vectors;