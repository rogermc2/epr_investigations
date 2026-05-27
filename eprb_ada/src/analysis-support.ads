
with Analysis_Types; use Analysis_Types;

package Analysis.Support is

   function Parse_Data_Line (aLine : String) return Outcomes_Record;
   procedure Parse_File_Name (File_Name            : String;
                              Setting_A, Setting_B : out MilliRad);

end Analysis.Support;
