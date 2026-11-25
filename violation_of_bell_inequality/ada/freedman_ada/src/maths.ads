
with Ada.Numerics.Complex_Types; use Ada.Numerics.Complex_Types;
with Ada.Numerics.Generic_Real_Arrays;

package Maths is

   package Long_Float_Arrays is
      new Ada.Numerics.Generic_Real_Arrays (Long_Float);
   subtype Long_Vector is Long_Float_Arrays.Real_Vector;
   subtype Long_Matrix is Long_Float_Arrays.Real_Matrix;

   --  Pi : constant Long_Float := 3.14159_26535_89793_23846;

   type Jones_Vector is record
      Ex : Complex;
      Ey : Complex;
   end record;
   type Jones_Matrix is array (1 .. 2, 1 .. 2) of Complex;

   type Complex_Vector_3D is array (1 .. 3) of Complex;
   type Real_Vector_3D    is array (1 .. 3) of Float;

   type Long_3D_Vector is new Long_Vector (1 .. 3);
   --  type Transmission_Operator is new Long_Matrix (1 ..2, 1 .. 2);

   function AB (a, b, lambda : Long_3D_Vector) return Long_Float;
   function To_Jones_Vector (E_3D : Complex_Vector_3D;
      K_Hat  : Real_Vector_3D;   --  Unit propagation vector
      Up_Ref : Real_Vector_3D := (0.0, 1.0, 0.0)) return Jones_Vector;

end Maths;
