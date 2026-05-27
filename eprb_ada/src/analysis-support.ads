
with Analysis_Types; use Analysis_Types;

package Analysis.Support is

   --  function Convert (File_A, File_B : String; Settings : Settings_Vector)
   --                    return Outcomes_Matrix;
   procedure Parse_File_Name (File_Name : String;
                          Setting_A, Setting_B : out MilliRad);

end Analysis.Support;
