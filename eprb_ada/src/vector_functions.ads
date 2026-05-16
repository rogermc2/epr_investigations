
with Types; use Types;

package Vector_Functions is

   function Abs_Array (Arr : Raw_Data_Array; Col : Positive)
                    return Float_Array;
   function Angles_Vector_To_Array
     (Angles_Vector : Float_Vector) return Float_Array;
   function Coincidence (Prod : Float_Array) return Boolean_Array;
   function Get_Column (Arr : Raw_Data_Array; Col : Positive)
                        return Float_Array;
   function Mod_Array (Arr1, Arr2 : Float_Array) return Float_Array;
   function Parse_Floats (Str : String) return Float_Vector;
   function Unique (Arr : Float_Array) return Float_Array;
   function Zeros_Like (Arr : Float_Array) return Float_Array

end Vector_Functions;
