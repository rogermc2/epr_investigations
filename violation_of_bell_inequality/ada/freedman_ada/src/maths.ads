
with  Ada.Numerics.Real_Arrays; use Ada.Numerics.Real_Arrays;

package Maths is

   Pi : constant Long_Float := 3.14159_26535_89793_23846;

   type Vector_3D is record
      X, Y, Z : Float;
   end record;

   function AB (a, b, lambda : Real_Vector) return Float;

end Maths;
