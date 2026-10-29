
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;

package body Support is
   function QM_Expectation (Angle : Float) return Float is
   begin
      return Cos (Angle) ** 2;
   end QM_Expectation;

end Support;