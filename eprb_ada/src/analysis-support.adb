
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

with Utilities;

package body Analysis.Support is

   function Convert (File_A, File_B : String; Settings : Settings_Vector)
                     return Converted_Outcomes_Vector is
      use Utilities;
      use MilliRad_Map_Package;
      use Result_Vector_Package;
      use Settings_Vector_Package;
      Routine_Name      : constant String := "Analysis.Support.Convert ";
      Raw_A             : constant Result_Vector :=
        Load_Station_Results (File_A);
      Raw_B             : constant Result_Vector :=
        Load_Station_Results (File_B);
      --  Raw_Length        : constant Integer :=
      --    Integer'Min (Integer (Length (Raw_A)), Integer (Length (Raw_B)));
      Curs_A            : Result_Vector_Package.Cursor := Raw_A.First;
      Curs_B            : Result_Vector_Package.Cursor := Raw_B.First;
      Curs_S_Outer      : Settings_Vector_Package.Cursor := Settings.First;
      Curs_S_Inner      : Settings_Vector_Package.Cursor := Settings.First;
      Item_A            : Result_Data;
      Item_B            : Result_Data;
      Vec_A             : Float_Vector;
      Vec_B             : Float_Vector;
      A_Index           : MilliRad;
      B_Index           : MilliRad;
      Key               : Setting_Map_Record;
      Settings_Map      : MilliRad_Map;
      Outcomes_A        : Outcomes_Vector;  --  Package of float vectors
      Outcomes_B        : Outcomes_Vector;
      Outcome_Vector_A  : Float_Vector;
      Outcome_Vector_B  : Float_Vector;
      Settings_Index    : Natural := 0;
      Outcomes_Index    : Positive;
      Converted_Results : Converted_Outcomes_Vector;
   begin
      Put_Line (Routine_Name);
      while Has_Element (Curs_S_Outer) loop
         Key.A := MilliRad (Element (Curs_S_Outer) * 1000.0);
         Curs_S_Inner := Settings.First;
         while Has_Element (Curs_S_Inner) loop
            Settings_Index := Settings_Index + 1;
            Key.B := MilliRad (Element (Curs_S_Inner) * 1000.0);
            Settings_Map.Include (Key, Settings_Index);
            Outcomes_A.Append (Outcomes_Vector_Package.Empty_Vector);
            Outcomes_B.Append (Outcomes_Vector_Package.Empty_Vector);
            Next (Curs_S_Inner);
         end loop;
         Next (Curs_S_Outer);
      end loop;

      Put_Line (Routine_Name & "Outcomes_A.Length: " &
                  Integer'Image (Integer (Outcomes_A.Length)));

      while Has_Element (Curs_A) and then Has_Element (Curs_B) loop
         Item_A := Element (Curs_A);
         Item_B := Element (Curs_B);
         A_Index := MilliRad (Item_A.Setting * 1000.0);
         B_Index := MilliRad (Item_A.Setting * 1000.0);
         Key := (A_Index, B_Index);
         Outcomes_Index := Settings_Map (Key);
         Outcome_Vector_A (Outcomes_Index) := Item_A.Outcome;
         Outcome_Vector_B (Outcomes_Index) := Item_B.Outcome;
         Next (Curs_A);
         Next (Curs_B);
      end loop;

      Put_Line (Routine_Name & Integer'Image (Integer (Outcomes_A.Length)));

      return Converted_Results;

   exception
      when others =>
         Put_Line (Routine_Name & "exception");
         raise;

   end Convert;

end Analysis.Support;
