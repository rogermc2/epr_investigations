
with  Ada.Numerics.Real_Arrays; use Ada.Numerics.Real_Arrays;

package Maths is

   type Vector_3D is record
      X, Y, Z : Float;
   end record;
   
   function AB (a, b, lambda : Real_Vector) return Float;

end Maths;
