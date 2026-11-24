
package body Maths is

   function Adot (a, lambda : Long_3D_Vector) return Long_Float is
   begin
      return (a * lambda);  --  Dot prdoct
   end Adot;

   function AB (a, b, lambda : Long_3D_Vector) return Long_Float is
   begin
      return Adot (a, lambda) * Adot (b, lambda);
   end AB;

end Maths;
