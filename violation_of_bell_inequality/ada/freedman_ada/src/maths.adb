
package body Maths is

   function Adot (a, lambda : Real_Vector) return Float is
   begin
      return (a * lambda);  --  Dot prdoct
   end Adot;

   function AB (a, b, lambda : Real_Vector) return Float is
   begin
      return Adot (a, lambda) * Adot (b, lambda);
   end AB;

end Maths;
