
--  with Ada.Numerics; use Ada.Numerics;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;

with Analysis.Support; use Analysis.Support;
with Analysis_Types; use Analysis_Types;
--  with Display; use Display;
with Maths; use Maths;
--  with Utilities; use Utilities;
--  with Vector_Functions; use Vector_Functions;

package body Analysis is

   --  procedure Correlation (A, B : Result_Vector;
   --  Unique_Diff : Float_Vector;
   --                         Eab  : out Float_Vector);
   --  procedure Expectation (A, B  : Result_Vector;
   --  Unique_Diff : Float_Vector;
   --                         Eab   : in out Float_Vector);

   procedure Process_Pair (Outcome_Pair : Outcomes_Record;
                           Analysis_Data : in out  Analysis_Vector);

   procedure Analyse (File_Names : Unbounded_String_Vector;
                      Settings   : Settings_Vector) is
      --  use Analysis_Vector_Package;
      use Settings_Vector_Package;
      use Unbounded_String_Package;
      Routine_Name  : constant String := "Analysis.Analyse ";
      Num_Files     : constant Positive := Positive (Length (File_Names));
      File_Curs     : Unbounded_String_Package.Cursor := File_Names.First;
      Setting_Curs  : Settings_Vector_Package.Cursor := Settings.First;
      File_ID       : File_Type;
      Setting_A     : MilliRad;
      Setting_B     : MilliRad;
      Analysis_Data : Analysis_Vector;
      Data          : Analysis_Record;
      Outcome_Pair  : Outcomes_Record;
      --  Angle_Resolution : constant Float := 3.75;
      --  Coincidences     : Boolean_Vector;
      --  Settings_Diff    : Float_Vector;    --  AB
      --  Unique_Diff      : Float_Vector;
      --  Eab              : Float_Vector;
   begin
      Put_Line ("Starting analysis.");
      while Has_Element (File_Curs) loop
         Put_Line (Routine_Name & "File name: " &
                     To_String (Element (File_Curs)));
         Open (File_ID, In_File, To_String (Element (File_Curs)));
         Parse_File_Name (To_String (Element (File_Curs)),
                          Setting_A, Setting_B);
         --  Put_Line ("Setting_A: " & MilliRad'Image (Setting_A));
         --  Put_Line ("Setting_B: " & MilliRad'Image (Setting_B));
         Data.Setting_A := Setting_A;
         Data.Setting_B := Setting_B;
         while not End_Of_File (File_ID) loop
            declare
               aLine : String := Get_Line (File_ID);
            begin
               Outcome_Pair := Parse_Data_Line (aLine);
               Process_Pair (Outcome_Pair, Analysis_Data);
            end;
         end loop;
         Close (File_ID);
         Next (File_Curs);
      end loop;

      --  Correlation (A, B, Unique_Diff, Eab);
      --  Expectation (A, B, Unique_Diff, Eab);

      Put_Line ("Analysis complete.");

      --  Display_Results (A, B);

   end Analyse;

   procedure Correlation (A, B : Result_Vector; Unique_Diff : Float_Vector;
                          Eab  : out Float_Vector) is
      use Float_Vector_Package;
      Size        : constant Positive := Integer (Length (Unique_Diff));
      Ax          : Float;
      Bx          : Float;
      A_Deg       : Float;
      B_Deg       : Float;
      Result_A    : Result_Data;
      Result_B    : Result_Data;
      Sel         : Boolean_Vector;
      Curs_1      : Float_Vector_Package.Cursor := Unique_Diff.First;
      Curs_2      : Float_Vector_Package.Cursor := Unique_Diff.First;
      Corr_Matrix : Float_Matrix (1 .. Size, 1 .. Size) :=
        (others => (others => 0.0));
      Index_X     : Natural := 0;
      Index_Y     : Natural := 0;
   begin
      while Has_Element (Curs_1) loop
         Index_X := Index_X + 1;
         Ax := Element  (Curs_1);
         Sel := Boolean_Vector_Package.Empty_Vector;
         while Has_Element (Curs_2) loop
            Index_Y := Index_Y + 1;
            Bx := Element  (Curs_2);           --  Abdeg
            for k in 1 .. Size loop
               Result_A := A (k);
               Result_B := B (k);
               A_Deg := Result_A.Setting;
               B_Deg := Result_B.Setting;
               Sel.Append ((A_Deg = Ax and then B_Deg = Bx) or else
                             (B_Deg = Ax and then A_Deg = Bx) or else
                             (360.0 - A_Deg = Ax and then 360.0 - B_Deg = Bx)
                           or else
                             (360.0 - B_Deg = Ax and then 360.0 - A_Deg = Bx));
            end loop;

            if Sum_Boolean (Sel) > 0 then
               Corr_Matrix (Index_X, Index_Y) := Mean_Product (Sel, A, B);
            else
               Corr_Matrix (Index_Y, Index_X) :=
                 Corr_Matrix (Index_X, Index_Y);
            end if;
            Next (Curs_2);
         end loop;
         Next (Curs_1);
      end loop;

   end Correlation;

   procedure Expectation (A, B : Result_Vector; Unique_Diff : Float_Vector;
                          Eab  : in out Float_Vector) is
      use Boolean_Vector_Package;
      use Float_Vector_Package;
      Curs_1 : Float_Vector_Package.Cursor := Unique_Diff.First;
      Curs_2 : Float_Vector_Package.Cursor := Unique_Diff.First;
      Ax     : Float;
      Nab    : Natural_Vector;
      Sel    : Boolean_Vector;
   begin
      while Has_Element (Curs_1) loop
         Ax := Element (Curs_1);
         Curs_2 := Unique_Diff.First;
         while Has_Element (Curs_2) loop
            Sel.Append (Element (Curs_2) = Ax or else
                        Element (Curs_2) = 360.0 - Ax);
            Next (Curs_2);
         end loop;

         Nab.Append (Sum_Boolean (Sel));
         if Nab.Last_Element > 0 then
            Float_Vector_Package.Append (Eab, Mean_Product (Sel, A, B));
         else
            Float_Vector_Package.Append (Eab, 0.0);
         end if;
         Next (Curs_1);
      end loop;

   end Expectation;

   procedure Process_Pair (Outcome_Pair : Outcomes_Record;
                           Analysis_Data : in out  Analysis_Vector) is

   begin
      null;

   end Process_Pair;

end Analysis;
