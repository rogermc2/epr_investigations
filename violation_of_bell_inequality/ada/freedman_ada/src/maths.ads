
with  Ada.Numerics.Generic_Real_Arrays;

package Maths is

   package Long_Float_Arrays is
      new Ada.Numerics.Generic_Real_Arrays (Long_Float);
   subtype Long_Vector is Long_Float_Arrays.Real_Vector;
   subtype Long_Matrix is Long_Float_Arrays.Real_Matrix;

   Pi : constant Long_Float := 3.14159_26535_89793_23846;

   type Long_3D_Vector is new Long_Vector (1 .. 3);
   type Transmission_Operator is new Long_Matrix (1 ..2, 1 .. 2);

   function AB (a, b, lambda : Long_3D_Vector) return Long_Float;

end Maths;
