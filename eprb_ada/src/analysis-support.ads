
with Analysis_Types; use Analysis_Types;

package Analysis.Support is

   function Convert (File_A, File_B : String; Settings : Settings_Vector)
                     return Converted_Outcomes_Vector;

end Analysis.Support;
