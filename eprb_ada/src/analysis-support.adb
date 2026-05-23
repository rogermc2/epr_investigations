
with Utilities;

package body Analysis.Support is

   function Convert (File_A, File_B : String; Settings : Settings_Vector)
                     return Converted_Outcomes_Vector is
      use Utilities;
      use MilliRad_Map_Package;
      use Result_Vector_Package;
      use Settings_Vector_Package;
      Raw_A             : constant Result_Vector :=
        Load_Station_Results (File_A);
      Raw_B             : constant Result_Vector :=
        Load_Station_Results (File_B);
      --  Raw_Length        : constant Integer :=
      --    Integer'Min (Integer (Length (Raw_A)), Integer (Length (Raw_B)));
      Settings_Curs     : Settings_Vector_Package.Cursor := Settings.First;
      Curs_A            : Result_Vector_Package.Cursor := Raw_A.First;
      Curs_B            : Result_Vector_Package.Cursor := Raw_B.First;
      Item_A            : Result_Data;
      Item_B            : Result_Data;
      --  Result_A          : Outcomes_Record;
      --  Result_B          : Outcomes_Record;
      Vec_A             : Float_Vector;
      Vec_B             : Float_Vector;
      A_Index           : Positive;
      B_Index           : Positive;
      Settings_Map      : MilliRad_Map;
      Outcomes_A        : Outcomes_Vector;  --  Package of float vectors
      Outcomes_B        : Outcomes_Vector;
      Settings_Index    : Natural := 0;
      Converted_Results : Converted_Outcomes_Vector;
   begin

      while Has_Element (Settings_Curs) loop
         Settings_Index := Settings_Index + 1;
         Settings_Map.Include
           (MilliRad (Element (Settings_Curs) * 1000.0), Settings_Index);
         Outcomes_A.Append (Outcomes_Vector_Package.Empty_Vector);
         Outcomes_B.Append (Outcomes_Vector_Package.Empty_Vector);
         Next (Settings_Curs);
      end loop;

      while Has_Element (Curs_A) and then Has_Element (Curs_B) loop
         Item_A := Element (Curs_A);
         Item_B := Element (Curs_B);
         A_Index := Settings_Map (MilliRad (Item_A.Setting * 1000.0));
         B_Index := Settings_Map (MilliRad (Item_A.Setting * 1000.0));
         Outcomes_A (A_Index) := Item_A.Outcome;
         Outcomes_B (B_Index) := Item_B.Outcome;
         Next (Curs_A);
         Next (Curs_B);
      end loop;

      return Converted_Results;

   end Convert;

end Analysis.Support;
