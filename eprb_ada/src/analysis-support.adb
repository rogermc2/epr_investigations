
with Types; use Types;
with Utilities;

package body Analysis.Support is

   function Convert (File_A, File_B : String)
                     return Converted_Outcomes_Vector is
      use Utilities;
      use Result_Vector_Package;
      A_Results : constant Result_Vector := Load_Station_Results (File_A);
      B_Results : constant Result_Vector := Load_Station_Results (File_B);
      Curs_A    : Cursor := A_Results.First;
      Curs_B    : Cursor := B_Results.First;

      Converted_Results : Converted_Outcomes_Vector;
   begin
      while Has_Element (Curs_A) and then Has_Element (Curs_B) loop

         Next (Curs_A);
         Next (Curs_B);
      end loop;

      return Converted_Results;

   end Convert;

end Analysis.Support;
