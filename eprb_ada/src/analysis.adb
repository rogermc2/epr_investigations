
--  with Ada.Float_Text_IO;
with Ada.Numerics; use Ada.Numerics;
with Ada.Numerics.Elementary_Functions;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;

with Analysis.Support; use Analysis.Support;
with Analysis_Types; use Analysis_Types;
--  with Display; use Display;
--  with Maths; use Maths;
with Printing; use Printing;
--  with Utilities; use Utilities;
--  with Vector_Functions; use Vector_Functions;

package body Analysis is

   procedure Process_Data (Outcomes      : Outcome_Vector;
                           Analysis_Data : in out  Analysis_Record);
   pragma Inline (Process_Data);

   procedure Use_Probilities (Analysis_Data : Analysis_Vector);

   procedure Analyse (File_Names : Unbounded_String_Vector) is
      use Unbounded_String_Package;
      Routine_Name  : constant String := "Analysis.Analyse ";
      File_Curs     : Unbounded_String_Package.Cursor := File_Names.First;
      File_ID       : File_Type;
      Setting_A     : MilliRad;
      Setting_B     : MilliRad;
      Outcome_Pair  : Outcomes_Record;
      Outcomes      : Outcome_Vector;
      Analysis_Data : Analysis_Vector;
      Data          : Analysis_Record;
      Count         : Natural := 0;
   begin
      Put_Line ("Starting analysis.");
      while Has_Element (File_Curs) loop
         Put_Line (Routine_Name & "File name: " &
                     To_String (Element (File_Curs)));
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

      New_Line;
      Print_Analysis_Data (Analysis_Data);

      Use_Probilities (Analysis_Data);

      Put_Line ("Analysis complete.");

      --  Display_Results (A, B);

   end Analyse;

   procedure Process_Data (Outcomes      : Outcome_Vector;
                           Analysis_Data : in out Analysis_Record) is
      --  use Ada.Float_Text_IO;
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
      --  Print_Outcome_Vector ("Analysis.Process_Data", Outcomes, 1, 6);
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

      --  Print_Analysis_Item
      --  ("Process_Data, Analysis_Data", Analysis_Data, True);

   end Process_Data;

   procedure Use_Probilities (Analysis_Data : Analysis_Vector) is
      use Analysis_Vector_Package;
      Curs : Cursor := Analysis_Data.First;

      procedure Probability_Analysis (Data : Analysis_Record) is
         Sum_N : constant Float :=
           Float (Data.Npp + Data.Npm + Data.Nmp + Data.Nmm);
         Ppp   : constant Float := Float (Data.Npp) / Sum_N;
         Ppm   : constant Float := Float (Data.Npm) / Sum_N;
         Pmp   : constant Float := Float (Data.Nmp) / Sum_N;
         Pmm   : constant Float := Float (Data.Nmm) / Sum_N;
      begin
         null;
      end Probability_Analysis;

   begin
      while Has_Element (Curs) loop
         Probability_Analysis (Element (Curs));
         Next (Curs);
      end loop;

   end Use_Probilities;

end Analysis;
