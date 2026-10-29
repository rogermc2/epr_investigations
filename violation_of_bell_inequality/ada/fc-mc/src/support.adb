
with Ada.Numerics;use Ada.Numerics;

package body Support is
   function QM_Expectation (Angle : Float) return Float is
   begin
      return Angle * 2.0 * Pi;
   end QM_Expectation;

end Support;