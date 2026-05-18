
with Ada.Numerics; use Ada.Numerics;

with Maths; use Maths;
with Types; use Types;
with Utilities; use Utilities;
with Vector_Functions; use Vector_Functions;

package body Analysis is

   procedure Analyse (A_File_Name, B_File_Name : Unbounded_String) is
      use Result_Vector_Package;
      Angle_Resolution : constant Float := 3.75;
      Particle_Spin    : constant Float := 1.0;
      Raw_A            : constant Result_Vector :=
        Load_Station_Results (A_File_Name);
      Raw_B            : constant Result_Vector :=
        Load_Station_Results (B_File_Name);
      A                : Result_Vector := Filter_Rows (Raw_A, Coinc);
      B                : Result_Vector := Filter_Rows (Raw_B, Coinc);
      Length           : constant Integer'Min (Integer (Length (Raw_A)),
                                               Integer (Length (Raw_B)));
      Curs_A           : Cursor := Raw_A.First;
      Curs_B           : Cursor := Raw_A.First;
      Result_A         : Result_Data;
      Result_B         : Result_Data;
      Coincidences     : Boolean_Vector;
      Settings_Diff    : Float_Vector;    --  AB
      Unique_Diff      : Float_Vector;
   begin
      for index in 1 .. Length loop
         Result_A := Element (Curs_A);
         Result_B := Element (Curs_B);
         Coincidences.Append (Result_B.Outcome * Result_A.Outcome = 1.0);
         Settings_Diff.Append
           (Float'Remainder (Result_B.Setting - Result_A.Setting), 2.0 * Pi);
         Next (Curs_A);
         Next (Curs_B);
      end loop;

      A := Filter_Rows (Raw_A, Coinc);
      B := Filter_Rows (Raw_B, Coinc);
      Unique_Diff := Unique (Settings_Diff);

   end Analyse;

end Analysis;
