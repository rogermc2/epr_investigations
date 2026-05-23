
with Types; use Types;
with Utilities;

package body Analysis.Support is

   function Convert (File_A, File_B : String)
                     return Converted_Outcomes_Vector is
      use Utilities;
      use Result_Vector_Package;
      A_Results         : constant Result_Vector :=
        Load_Station_Results (File_A);
      B_Results         : constant Result_Vector :=
        Load_Station_Results (File_B);
      Curs_A            : Cursor := A_Results.First;
      Curs_B            : Cursor := B_Results.First;
      Item_A            : Result_Data;
      Item_B            : Result_Data;
      Result_A          : Outcomes_Record;
      Result_B          : Outcomes_Record;
      Vec_A             : Float_Vector;
      Vec_B             : Float_Vector;
      Converted_Results : Converted_Outcomes_Vector;
   begin
      while Has_Element (Curs_A) and then Has_Element (Curs_B) loop
         Item_A := Element (Curs_A);
         Item_B := Element (Curs_B);
         Result_A.Setting := MilliRad (Item_A.Setting * 1000.0);
         Result_B.Setting := MilliRad (Item_B.Setting * 1000.0);
         Vec_A.Append (Item_A.Outcome);
         Vec_B.Append (Item_B.Outcome);
         Next (Curs_A);
         Next (Curs_B);
      end loop;

      return Converted_Results;

   end Convert;

end Analysis.Support;
