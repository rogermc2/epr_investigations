
with Ada.Numerics; use Ada.Numerics;  --  for Pi
with Ada.Numerics.Elementary_Functions;
use Ada.Numerics.Elementary_Functions;  -- for Cos
with Ada.Text_IO; use Ada.Text_IO;

with Process_Data; use Process_Data;
with Printing; use Printing;
with Types; use Types;

procedure Statistical_Analysis is
   use Sample_Data_Package;
   --  type Quantile_Table is array (Positive range <>) of Float;
   --   package Float_Estimators is new Estimators (Float, Data_Vector);
   --   package Float_Samples is new
   --     Samples (Float, Quantile_Table,  use_sub_histogram_index => False);

   Single_Dir    : constant String := "../";
   AB_Dir        : constant String := "../../Spyder/epr_1/";
   OEM_00        : constant String := AB_Dir & "OEM_aa.csv";
   OEM_01        : constant String := AB_Dir & "OEM_ba.csv";
   OEM_10        : constant String := AB_Dir & "OEM_ab.csv";
   OEM_11        : constant String := AB_Dir & "OEM_bb.csv";
   a00_Data      : constant String := Single_Dir & "a00.csv";
   b00_Data      : constant String := Single_Dir & "b00.csv";
   a01_Data      : constant String := Single_Dir & "a01.csv";
   b01_Data      : constant String := Single_Dir & "b01.csv";
   a10_Data      : constant String := Single_Dir & "a10.csv";
   b10_Data      : constant String := Single_Dir & "b10.csv";
   a11_Data      : constant String := Single_Dir & "a11.csv";
   b11_Data      : constant String := Single_Dir & "b11.csv";

   Detections_00     : constant Sample_Data_List := Get_Detections (OEM_00, a00_Data, b00_data);
   Detections_01     : constant Sample_Data_List := Get_Detections (OEM_01, a01_Data, b01_data);
   Detections_10     : constant Sample_Data_List := Get_Detections (OEM_10, a10_Data, b10_data);
   Detections_11     : constant Sample_Data_List := Get_Detections (OEM_11, a11_Data, b11_data);
   Mean_A_00         : Float;
   Mean_A_01         : Float;
   Mean_A_10         : Float;
   Mean_A_11         : Float;
   Mean_B_00         : Float;
   Mean_B_01         : Float;
   Mean_B_10         : Float;
   Mean_B_11         : Float;
   Mean_AB_00        : Float;
   Mean_AB_01        : Float;
   Mean_AB_10        : Float;
   Mean_AB_11        : Float;
   Valid_Data        : Sample_Data_List;
   False_Count       : Natural;
begin
   Sample_Means (Detections_00, Mean_A_00, Mean_B_00, Mean_AB_00);
   Sample_Means (Detections_01, Mean_A_01, Mean_B_01, Mean_AB_01);
   Sample_Means (Detections_10, Mean_A_10, Mean_B_10, Mean_AB_10);
   Sample_Means (Detections_11, Mean_A_11, Mean_B_11, Mean_AB_11);

   Print_Statistics ("OEMA_00", Mean_A_00, Mean_B_00, Mean_AB_00,
                     Detections_00, Det_A, Det_B);
   Print_Statistics ("OEMA_01", Mean_A_01, Mean_B_01, Mean_AB_01,
                     Detections_01, Det_A, Det_B);
   Print_Statistics ("OEMA_10", Mean_A_10, Mean_B_10, Mean_AB_10,
                     Detections_10, Det_A, Det_B);
   Print_Statistics ("OEMA_11", Mean_A_11, Mean_B_11, Mean_AB_11,
                     Detections_11, Det_A, Det_B);

   Put_Line ("Overall A Sample_Mean: " &
               Float'Image
               ((Mean_A_00 + Mean_A_01 + Mean_A_10 + Mean_A_11) / 4.0));
   Put_Line ("Overall B Sample_Mean: " &
               Float'Image
               ((Mean_B_00 + Mean_B_01 + Mean_B_10 + Mean_B_11) / 4.0));

   New_Line;
   Put_Line ("E(AB) b = a: " & Float'Image (EAB (0.0)));
   Put_Line ("E(AB) b = a + 45 deg.: " & Float'Image (EAB (Pi / 4.0)));
   New_Line;
   Put_Line ("- a.b,  b = a: " & Float'Image (- Cos (0.0)));
   Put_Line ("- a.b,  b = a + 45 deg.: " & Float'Image (-Cos (Pi / 4.0)));
   New_Line;

   Put_Line ("Number of AB00 detections: " &
               Integer'Image (Integer (Length (Detections_00))));
   Put_Line ("Number of AB01 detections: " &
               Integer'Image (Integer (Length (Detections_01))));
   Put_Line ("Number of AB10 detections: " &
               Integer'Image (Integer (Length (Detections_10))));
   Put_Line ("Number of AB11 detections: " &
               Integer'Image (Integer (Length (Detections_11))));
   New_Line;

   Valid_Data := False_Positives (OEM_00, False_Count);
   Put_Line ("AB_00 false positives: " & Integer'Image (False_Count));
   Valid_Data := False_Positives (OEM_01, False_Count);
   Put_Line ("AB_01 false positives: " & Integer'Image (False_Count));
   Valid_Data := False_Positives (OEM_10, False_Count);
   Put_Line ("AB_10 false positives: " & Integer'Image (False_Count));
   Valid_Data := False_Positives (OEM_11, False_Count);
   Put_Line ("AB_11 false positives: " & Integer'Image (False_Count));

end Statistical_Analysis;
