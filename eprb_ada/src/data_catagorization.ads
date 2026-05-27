
with Analysis_Types; use Analysis_Types;
with Types; use Types;

package Data_Catagorization is

   function Catagorize
     (File_A, File_B : String; Settings : Settings_Vector)
      return Unbounded_String_Vector;

end Data_Catagorization;
