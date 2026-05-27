
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Strings.Fixed; use Ada.Strings.Fixed;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;

--  with Printing; use Printing;
--  with Utilities;

package body Analysis.Support is

   --  function Convert (File_A, File_B : String; Settings : Settings_Vector)
   --                    return Outcomes_Matrix is
   --     use Utilities;
   --     use MilliRad_Map_Package;
   --     use Result_Vector_Package;
   --     use Settings_Vector_Package;
   --     Routine_Name      : constant String := "Analysis.Support.Convert ";
   --     Raw_A             : constant Result_Vector :=
   --       Load_Station_Results (File_A);
   --     Raw_B             : constant Result_Vector :=
   --       Load_Station_Results (File_B);
   --     --  Raw_Length        : constant Integer :=
   --     --    Integer'Min
   --  (Integer (Length (Raw_A)), Integer (Length (Raw_B)));
   --     --  Num_Settings      : constant Positive :=
   --     --  Positive (Length (Settings));
   --     Curs_A            : Result_Vector_Package.Cursor := Raw_A.First;
   --     Curs_B            : Result_Vector_Package.Cursor := Raw_B.First;
   --     Curs_S_Outer      : Settings_Vector_Package.Cursor := Settings.First;
   --     Curs_S_Inner      : Settings_Vector_Package.Cursor := Settings.First;
   --     Item_A            : Result_Data;
   --     Item_B            : Result_Data;
   --     A_Index           : MilliRad;
   --     B_Index           : MilliRad;
   --     Key               : Setting_Map_Record;
   --     Settings_Map      : MilliRad_Map;
   --     Outcome_Vectors   : Outcomes_Matrix;  --  Package of float vectors
   --     Data              : Data_Record;
   --     Outcome_Pair      : Outcomes_Record;
   --     Settings_Index    : Natural := 0;
   --     Outcomes_Index    : Positive;
   --     Count             : Natural := 0;
   --  begin
   --     while Has_Element (Curs_S_Outer) loop
   --        Key.A := MilliRad (Element (Curs_S_Outer) * 1000.0);
   --        Curs_S_Inner := Settings.First;
   --        while Has_Element (Curs_S_Inner) loop
   --           Key.B := MilliRad (Element (Curs_S_Inner) * 1000.0);
   --           if not Settings_Map.Contains (Key) then
   --              Settings_Index := Settings_Index + 1;
   --              Settings_Map.Include (Key, Settings_Index);
   --              Data := (Key.A, Key.B, Outcome_Vector_Package.Empty_Vector);
   --              Outcome_Vectors.Append (Data);
   --           end if;
   --           Next (Curs_S_Inner);
   --        end loop;
   --        Next (Curs_S_Outer);
   --     end loop;
   --
   --     while Has_Element (Curs_A) and then Has_Element (Curs_B) loop
   --        Count := Count + 1;
   --        Item_A := Element (Curs_A);
   --        Item_B := Element (Curs_B);
   --        A_Index := MilliRad (Item_A.Setting * 1000.0);
   --        B_Index := MilliRad (Item_B.Setting * 1000.0);
   --        Key := (A_Index, B_Index);
   --        Outcomes_Index := Settings_Map (Key);
   --        if Count < 5 then
   --           Put_Line ("Outcomes_Index: " &
   --                       Integer'Image (Integer (Outcomes_Index)));
   --           New_Line;
   --        end if;
   --
   --        if Outcomes_Index > 9 then
   --           Put_Line ("Invalid Outcome_Vectors Index" &
   --                       Integer'Image (Outcomes_Index));
   --        end if;
   --        Data := Outcome_Vectors (Outcomes_Index);
   --        if Count < 5 then
   --           Print_Data_Record ("Data in", Data);
   --        end if;
   --        Outcome_Pair := (Item_A.Outcome, Item_B.Outcome);
   --        Data.Outcomes.Append (Outcome_Pair);
   --        if Count < 10 then
   --           Print_Data_Record ("Data out", Data);
   --           Put_Line ("Outcome_Vectors Index: " &
   --                       Integer'Image (Outcomes_Index));
   --        end if;
   --
   --        Outcome_Vectors.Replace_Element (Outcomes_Index, Data);
   --        if Count < 10 then
   --           Put_Line ("Outcome_Vectors Index" &
   --                       Integer'Image (Outcomes_Index) & " updated");
   --           Put_Line ("Outcome_Vectors Length" &
   --                       Integer'Image (Integer (Outcome_Vectors.Length)));
   --           New_Line;
   --        end if;
   --        if Count mod 10000 = 0 then
   --           Put (".");
   --        end if;
   --        Next (Curs_A);
   --        Next (Curs_B);
   --     end loop;
   --
   --     Put_Line (Routine_Name & "Outcome_Vectors Length" &
   --                 Integer'Image (Integer (Outcome_Vectors.Length)));
   --
   --     return Outcome_Vectors;
   --
   --  exception
   --     when Error : others =>
   --        Put_Line (Routine_Name & "Exception information:  " &
   --                    Exception_Information (Error));
   --        raise;
   --
   --  end Convert;

   procedure Parse_File_Name
     (File_Name : String; Setting_A, Setting_B : out MilliRad) is
      A_String : Unbounded_String;
      B_String : Unbounded_String;
      Pos_1    : constant Natural := Index (File_Name, "_");
      Pos_2    : Natural;
   begin
      A_String := To_Unbounded_String
        (File_Name (File_Name'First .. Pos_1 - 1));
      Pos_2 :=  Index (File_Name, "_");
      B_String := To_Unbounded_String (File_Name (Pos_1 + 1 .. Pos_2 - 1));
      Setting_A :=  MilliRad'Value (To_String (A_String));
      Setting_B :=  MilliRad'Value (To_String (B_String));

   exception
      when Error : others =>
         Put_Line
           ("Analysis.Support.Parse_File_Name Exception information:  " &
              Exception_Information (Error));
         raise;

   end Parse_File_Name;

end Analysis.Support;
