
with Interfaces.C; use Interfaces.C;

with Types; use Types;

package Maths is

   function Linear_Space (Start_Val, End_Val : Float; Num : Positive)
                             return Float_Vector;
   function Sign (X : Interfaces.C.double) return Integer;
   function To_Radians (Degrees : Float) return Float;

end Maths;
