
with Types; use Types;

package Vector_Functions is

   function Abs_Vector (Vec : Result_Vector) return Float_Vector;
   function Angles_Vector_To_Array
     (Settings : Settings_Vector) return Float_Array;
   function Coincidence (Prod : Float_Vector) return Boolean_Vector;
   function Filter_Matrix (A, B : Result_Vector; Pairs : Setting_Pairs_Vector)
                           return Float_Matrix;
   function Filter_Rows (Vec : Result_Vector; Mask : Boolean_Vector)
                         return Result_Vector;
   function Get_Settings (Res : Result_Vector) return Settings_Vector;
   function Mod_Vector (Vec_1, Vec_2 : Float_Vector) return Float_Vector;
   function Parse_Floats (Str : String) return Float_Vector;
   function Product_Column2 (Vec_1, Vec_2 : Result_Vector)
                             return Float_Vector;
   --  function Random_Choice (Settings : Settings_Vector; Size : Positive)
   --                          return Settings_Vector;
   function Sample_Mean (Vec : Float_Vector) return Float;
   --  function Setting_Pairs (Setting_A, Setting_B : Float_Vector)
   --                          return Setting_Pairs_Vector;
   function Setting_Pairs (A, B : Result_Vector) return Setting_Pairs_Vector;
   function Unique (Vec : Float_Vector) return Float_Vector;
   function Zeros_Like (Vec : Float_Vector) return Float_Vector;

end Vector_Functions;
