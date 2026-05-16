
with Types; use Types;

package Vector_Functions is

   function Abs_Vector (Vec : Result_Vector; Col : Positive)
                        return Float_Vector;
   function Angles_Vector_To_Array
     (Angles_Vector : Float_Vector) return Float_Array;
   function Coincidence (Prod : Float_Vector) return Boolean_Vector;
   function Get_Column (Arr : Result_Vector; Col : Positive)
                        return Float_Vector;
   function Mod_Array (Arr1, Arr2 : Float_Vector) return Float_Vector;
   function Parse_Floats (Str : String) return Float_Vector;
   function Unique (Arr : Float_Vector) return Float_Vector;
   function Zeros_Like (Arr : Float_Vector) return Float_Vector;

end Vector_Functions;
