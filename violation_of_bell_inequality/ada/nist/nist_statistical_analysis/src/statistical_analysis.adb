
with Ada.Numerics; use Ada.Numerics;  --  for Pi
with Ada.Numerics.Elementary_Functions;
use Ada.Numerics.Elementary_Functions;  -- for Cos
with Ada.Text_IO; use Ada.Text_IO;

with Process_Data; use Process_Data;
with Printing; use Printing;
with Types; use Types;

procedure Statistical_Analysis is
   --  use Sample_Data_Package;
   --  type Quantile_Table is array (Positive range <>) of Float;
   --   package Float_Estimators is new Estimators (Float, Data_Vector);
   --   package Float_Samples is new
   --     Samples (Float, Quantile_Table,  use_sub_histogram_index => False);

   AB_Dir        : constant String := "../generated_nist_data/";
   File_00       : constant String := AB_Dir & "aa.csv";
   File_01       : constant String := AB_Dir & "ba.csv";
   File_10       : constant String := AB_Dir & "ab.csv";
   File_11       : constant String := AB_Dir & "bb.csv";
   Detections_00 : constant Sample_Data_List := Get_Detections (File_00);
   Detections_01 : constant Sample_Data_List := Get_Detections (File_01);
   Detections_10 : constant Sample_Data_List := Get_Detections (File_10);
   Detections_11 : constant Sample_Data_List := Get_Detections (File_11);
   Mean_A_00     : Float;
   Mean_A_01     : Float;
   Mean_A_10     : Float;
   Mean_A_11     : Float;
   Mean_B_00     : Float;
   Mean_B_01     : Float;
   Mean_B_10     : Float;
   Mean_B_11     : Float;
   Mean_AB_00    : Float;
   Mean_AB_01    : Float;
   Mean_AB_10    : Float;
   Mean_AB_11    : Float;
   --  Valid_Data    : Sample_Data_List;
   --  False_Count   : Natural;
begin
   Sample_Means (Detections_00, Mean_A_00, Mean_B_00, Mean_AB_00);
   Sample_Means (Detections_01, Mean_A_01, Mean_B_01, Mean_AB_01);
   Sample_Means (Detections_10, Mean_A_10, Mean_B_10, Mean_AB_10);
   Sample_Means (Detections_11, Mean_A_11, Mean_B_11, Mean_AB_11);

   Print_Statistics ("00", Mean_A_00, Mean_B_00, Mean_AB_00,
                     Detections_00, Det_A, Det_B);
   Print_Statistics ("01", Mean_A_01, Mean_B_01, Mean_AB_01,
                     Detections_01, Det_A, Det_B);
   Print_Statistics ("10", Mean_A_10, Mean_B_10, Mean_AB_10,
                     Detections_10, Det_A, Det_B);
   Print_Statistics ("11", Mean_A_11, Mean_B_11, Mean_AB_11,
                     Detections_11, Det_A, Det_B);
   New_Line;
   Print_Float ("Overall a Sample_Mean: ",
    (Mean_A_00 + Mean_A_01 + Mean_A_10 + Mean_A_11) / 4.0);
   Print_Float ("Overall b Sample_Mean: ",
    (Mean_B_00 + Mean_B_01 + Mean_B_10 + Mean_B_11) / 4.0);
   New_Line;
   Put_Line ("E(AB) b = a: " & Float'Image (Statistical_EAB (0.0)));
   Put_Line ("E(AB) b = a + 45 deg.: " & Float'Image (Statistical_EAB (Pi / 4.0)));
   New_Line;
   Put_Line ("- a.b,  b = a: " & Float'Image (- Cos (0.0)));
   Put_Line ("- a.b,  b = a + 45 deg.: " & Float'Image (-Cos (Pi / 4.0)));
   New_Line;

   --  Put_Line ("Number of AB00 detections: " &
   --              Integer'Image (Integer (Length (Detections_00))));
   --  Put_Line ("Number of AB01 detections: " &
   --              Integer'Image (Integer (Length (Detections_01))));
   --  Put_Line ("Number of AB10 detections: " &
   --              Integer'Image (Integer (Length (Detections_10))));
   --  Put_Line ("Number of AB11 detections: " &
   --              Integer'Image (Integer (Length (Detections_11))));
   --  New_Line;

   --  Valid_Data := False_Positives (OEM_00, False_Count);
   --  Put_Line ("AB_00 false positives: " & Integer'Image (False_Count));
   --  Valid_Data := False_Positives (OEM_01, False_Count);
   --  Put_Line ("AB_01 false positives: " & Integer'Image (False_Count));
   --  Valid_Data := False_Positives (OEM_10, False_Count);
   --  Put_Line ("AB_10 false positives: " & Integer'Image (False_Count));
   --  Valid_Data := False_Positives (OEM_11, False_Count);
   --  Put_Line ("AB_11 false positives: " & Integer'Image (False_Count));

end Statistical_Analysis;
