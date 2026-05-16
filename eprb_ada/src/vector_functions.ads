
with Types; use Types;

package Vector_Functions is

   function Abs_Vector (Vec : Result_Vector; Col : Positive)
                        return Float_Vector;
   function Angles_Vector_To_Array
     (Settings : Settings_Vector) return Float_Array;
   function Coincidence (Prod : Float_Vector) return Boolean_Vector;
   --  function Get_Column (Arr : Result_Vector; Col : Positive)
   --                       return Float_Vector;
   function Mod_Vector (Vec_1, Vec_2 : Float_Vector) return Float_Vector;
   function Parse_Floats (Str : String) return Float_Vector;
   --  function Random_Choice (Settings : Settings_Vector; Size : Positive)
   --                          return Settings_Vector;
   function Sample_Mean (Vec : Float_Vector) return Float;
   function Unique (Arr : Float_Vector) return Float_Vector;
   function Zeros_Like (Arr : Float_Vector) return Float_Vector;

end Vector_Functions;
