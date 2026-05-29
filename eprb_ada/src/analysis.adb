
with Ada.Float_Text_IO;
with Ada.Numerics; use Ada.Numerics;
with Ada.Numerics.Elementary_Functions;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;

with Analysis.Support; use Analysis.Support;
with Analysis_Types; use Analysis_Types;
--  with Display; use Display;
with Maths; use Maths;
with Printing; use Printing;
--  with Utilities; use Utilities;
--  with Vector_Functions; use Vector_Functions;

package body Analysis is

   --  procedure Correlation (A, B : Result_Vector;
   --  Unique_Diff : Float_Vector;
   --                         Eab  : out Float_Vector);
   --  procedure Expectation (A, B  : Result_Vector;
   --  Unique_Diff : Float_Vector;
   --                         Eab   : in out Float_Vector);

   procedure Process_Data (Outcomes      : Outcome_Vector;
                           Analysis_Data : in out  Analysis_Record);
   pragma Inline (Process_Data);

   procedure Analyse (File_Names : Unbounded_String_Vector;
                      Settings   : Settings_Vector) is
      --  use Analysis_Vector_Package;
      --  use Settings_Vector_Package;
      use Unbounded_String_Package;
      Routine_Name  : constant String := "Analysis.Analyse ";
      --  Num_Files     : constant Positive := Positive (Length (File_Names));
      File_Curs     : Unbounded_String_Package.Cursor := File_Names.First;
      --  Setting_Curs  : Settings_Vector_Package.Cursor := Settings.First;
      File_ID       : File_Type;
      Setting_A     : MilliRad;
      Setting_B     : MilliRad;
      Outcome_Pair  : Outcomes_Record;
      Outcomes      : Outcome_Vector;
      Analysis_Data : Analysis_Vector;
      Data          : Analysis_Record;
      Count         : Natural := 0;
      --  Angle_Resolution : constant Float := 3.75;
      --  Coincidences     : Boolean_Vector;
      --  Settings_Diff    : Float_Vector;    --  AB
      --  Eab              : Float_Vector;
   begin
      Put_Line ("Starting analysis.");
      while Has_Element (File_Curs) loop
         --  Put_Line (Routine_Name & "File name: " &
         --              To_String (Element (File_Curs)));
         Open (File_ID, In_File, To_String (Element (File_Curs)));
         Parse_File_Name (To_String (Element (File_Curs)),
                          Setting_A, Setting_B);
         Outcomes := Outcome_Vector_Package.Empty_Vector;
         while not End_Of_File (File_ID) loop
            declare
               aLine : constant String := Get_Line (File_ID);
            begin
               Outcome_Pair := Parse_Data_Line (aLine);
               Outcomes.Append (Outcome_Pair);
            end;

            Count := Count + 1;
            if Count mod 1000 = 0 then
               Put (".");
            end if;
         end loop;
         New_Line;
         Close (File_ID);

         Data.Setting_A := Setting_A;
         Data.Setting_B := Setting_B;
         Process_Data (Outcomes, Data);
         --  Print_Analysis_Item (Routine_Name & "Processed Data", Data);
         Analysis_Data.Append (Data);
         Next (File_Curs);
      end loop;
      Print_Analysis_Data (Analysis_Data);

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

   procedure Process_Data (Outcomes      : Outcome_Vector;
                           Analysis_Data : in out Analysis_Record) is
      use Ada.Float_Text_IO;
      use Ada.Numerics.Elementary_Functions;
      use Outcome_Vector_Package;
      Set_Diff  : constant Float :=
        Float
          (abs (Analysis_Data.Setting_B - Analysis_Data.Setting_A)) / 1000.0;
      Curs      : Cursor := Outcomes.First;
      anOutcome : Outcomes_Record;
      A         : Integer;
      B         : Integer;
      Num_A     : Natural := 0;
      Num_B     : Natural := 0;
      Num_AB    : Natural := 0;
      Npp       : Natural := 0;
      Npm       : Natural := 0;
      Nmp       : Natural := 0;
      Nmm       : Natural := 0;
      A_Sum     : Integer := 0;
      B_Sum     : Integer := 0;
      AB_Sum    : Integer := 0;
   begin
      Print_Outcome_Vector ("Analysis.Process_Data", Outcomes, 1, 6);
      Analysis_Data.E_QM := -Cos (Set_Diff);
      Analysis_Data.E_Stat := 2.0 * Set_Diff / Pi - 1.0;

      while Has_Element (Curs) loop
         anOutcome := Element (Curs);
         A := anOutcome.Outcome_A;
         B := anOutcome.Outcome_B;
         if A /= 0 then
            Num_A := Num_A + 1;
            A_Sum := A_Sum + A;
            if B /= 0 then
               Num_AB := Num_AB + 1;
               AB_Sum := AB_Sum + A * B;
               if A > 0 then
                  if B > 0 then
                     Npp := Npp + 1;
                  elsif B < 0 then
                     Npm := Npm + 1;
                  end if;
               elsif A < 0 then
                  if B > 0 then
                     Nmp := Nmp + 1;
                  elsif B < 0 then
                     Nmm := Nmm + 1;
                  end if;
               end if;
            end if;
         end if;

         if B /= 0 then
            Num_B := Num_B + 1;
            B_Sum := B_Sum + B;
         end if;

         Next (Curs);

      end loop;

      if Num_A > 0 then
         Analysis_Data.A_Mean := Float (A_Sum) / Float (Num_A);
      else
         Analysis_Data.A_Mean := 0.0;
      end if;
      if Num_B > 0 then
         Analysis_Data.B_Mean := Float (B_Sum) / Float (Num_B);
      else
         Analysis_Data.B_Mean := 0.0;
      end if;
      if Num_AB > 0 then
         Analysis_Data.AB_Mean := Float (AB_Sum) / Float (Num_AB);
      else
         Analysis_Data.AB_Mean := 0.0;
      end if;
      Analysis_Data.Npp := Npp;
      Analysis_Data.Npm := Npm;
      Analysis_Data.Nmp := Nmp;
      Analysis_Data.Nmm := Nmm;
      Put ("Set_Diff: ");
      Put (Set_Diff, 1, 2, 0);
      Put (" rad, ");
      Put (To_Degrees (Set_Diff), 1, 2, 0);
      Put_Line (" degrees");
      Print_Analysis_Item ("Process_Data, Analysis_Data", Analysis_Data, True);

   end Process_Data;

end Analysis;
