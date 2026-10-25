
with Ada.Text_IO; use Ada.Text_IO;

with Chi_Sq; use Chi_Sq;
with Delft_Printing; use Delft_Printing;
with Delft_Types; use Delft_Types;
with Printing; use Printing;
with Process_Data; use Process_Data;
with Types; use Types;

procedure Statistical_Analysis is
   AB_Dir        : constant String := "../generated_data/";
   File_Settings : constant String := AB_Dir & "settings.csv";
   File_00       : constant String := AB_Dir & "OEM_aa.csv";
   File_01       : constant String := AB_Dir & "OEM_ba.csv";
   File_10       : constant String := AB_Dir & "OEM_ab.csv";
   File_11       : constant String := AB_Dir & "OEM_bb.csv";
   Detections_00 : constant Delft_Sample_Data_List := Get_Detections (File_00);
   Detections_01 : constant Delft_Sample_Data_List := Get_Detections (File_01);
   Detections_10 : constant Delft_Sample_Data_List := Get_Detections (File_10);
   Detections_11 : constant Delft_Sample_Data_List := Get_Detections (File_11);
   E_AA          : constant Float := Statistical_EAB (A_Angle_0, B_Angle_0);
   E_AB          : constant Float := Statistical_EAB (A_Angle_0, B_Angle_1);
   E_BA          : constant Float := Statistical_EAB (A_Angle_1, B_Angle_0);
   E_BB          : constant Float := Statistical_EAB (A_Angle_1, B_Angle_1);
   Settings      : Angles_Record;
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
   Observed_Counts : Count_Array;
   Calculated_Chi  : Chi_Value;
   Resulting_P     : P_Value;
begin
   Settings := Get_Settings (File_Settings);
   New_Line;
   Put_Line ("Detector settings:");
   Print_Float_Line ("a0", Float (Settings.A_0));
   Print_Float_Line ("a1", Float (Settings.A_1));
   Print_Float_Line ("b0", Float (Settings.B_0));
   Print_Float_Line ("b1", Float (Settings.B_1));
   New_Line;
   --  Print_Delft_Sample_List ("Detections_00", Detections_00, 1, 5);
   --  Print_Delft_Sample_List ("Detections_01", Detections_01, 1, 5);
   --  Print_Delft_Sample_List ("Detections_10", Detections_10, 1, 5);
   --  Print_Delft_Sample_List ("Detections_11", Detections_11, 1, 5);

   Sample_Means (Detections_00, Mean_A_00, Mean_B_00, Mean_AB_00);
   Sample_Means (Detections_01, Mean_A_01, Mean_B_01, Mean_AB_01);
   Sample_Means (Detections_10, Mean_A_10, Mean_B_10, Mean_AB_10);
   Sample_Means (Detections_11, Mean_A_11, Mean_B_11, Mean_AB_11);

   Print_Delft_Statistics ("00", Mean_A_00, Mean_B_00, Mean_AB_00, E_AA,
                           Detections_00, Det_A, Det_B);
   Print_Delft_Statistics ("01", Mean_A_01, Mean_B_01, Mean_AB_01, E_AB,
                     Detections_01, Det_A, Det_B);
   Print_Delft_Statistics ("10", Mean_A_10, Mean_B_10, Mean_AB_10, E_BA,
                     Detections_10, Det_A, Det_B);
   Print_Delft_Statistics ("11", Mean_A_11, Mean_B_11, Mean_AB_11, E_BB,
                     Detections_11, Det_A, Det_B);
   New_Line;

   Print_Float_Line ("Overall A Sample_Mean: ",
    (Mean_A_00 + Mean_A_01 + Mean_A_10 + Mean_A_11) / 4.0);
   Print_Float_Line ("Overall B Sample_Mean: ",
    (Mean_B_00 + Mean_B_01 + Mean_B_10 + Mean_B_11) / 4.0);
   New_Line;

   Print_Float_Line ("E(AA)", E_AA);
   Print_Float_Line ("E(AB)", E_AB);
   Print_Float_Line ("E(BA)", E_BA);
   Print_Float_Line ("E(BB)", E_BB);
   New_Line;

   Put ("Null hypothesis H0: ");
   Put_Line ("Sample mean is within 5% of expected value.");
   Report_Hypothesis_Testing
      (Mean_AB_00, Mean_AB_01, Mean_AB_10, Mean_AB_11);
   New_Line;

   Print_Float_Line ("CHSH parameter S: ",
      Mean_AB_00 - Mean_AB_01 + Mean_AB_10 + Mean_AB_11);
   New_Line;

   Put_Line ("Number of AB00 detections: " &
               Integer'Image (Integer (Detections_00.Length)));
   Put_Line ("Number of AB01 detections: " &
               Integer'Image (Integer (Detections_01.Length)));
   Put_Line ("Number of AB10 detections: " &
               Integer'Image (Integer (Detections_10.Length)));
   Put_Line ("Number of AB11 detections: " &
               Integer'Image (Integer (Detections_11.Length)));
   New_Line;

   Observed_Counts := (Long_Float (Detections_00.Length),
                       Long_Float (Detections_01.Length),
                       Long_Float (Detections_10.Length),
                       Long_Float (Detections_11.Length));
   Calculated_Chi := Compute_Chi_Square (Observed_Counts);
   Resulting_P := Lookup_P_Value (Calculated_Chi);

   Print_Long_Float_Line ("Calculated Chi-Square Score",
      Long_Float (Calculated_Chi), 5, 0);
   Print_Long_Float_Line ("Resulting p-value", Long_Float (Resulting_P), 5, 0);

   Put ("Hypothesis Test: ");
   if Resulting_P >= 0.05 then
      --  The deviations are well within normal statistical fluctuations!
      Put_Line ("Accept H0 (Statistical variations are random).");
   else
      --  The p-value drops below 5%, mathematically proving a systematic flaw.
      Put_Line ("Reject H0 (Data contains systematic physical bias).");
   end if;
   New_Line;

end Statistical_Analysis;
