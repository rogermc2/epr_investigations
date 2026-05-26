
with Interfaces.C; use Interfaces.C;

with Types; use Types;

package Maths is

   function Linear_Space (Start_Val, End_Val : Float; Num : Positive)
                          return Float_Vector;
   function Mean_Product (A, B : Float_Vector) return Float;
   function Mean_Product
     (Selector : Boolean_Vector; A, B : Result_Vector) return Float;
   function Random_Index (Max : Positive) return Positive;
   function Random_Settings_Choice (Settings : Settings_Vector)
                                    return Settings_Vector;
   function QM_Func (A, Spin : Float) return Float;
   function Sign (X : Interfaces.C.double) return Integer;
   function Sum_Boolean (Vec : Boolean_Vector) return Natural;
   function To_Degrees (Radians : Float) return Float;
   function To_Radians (Degrees : Float) return Float;

end Maths;
