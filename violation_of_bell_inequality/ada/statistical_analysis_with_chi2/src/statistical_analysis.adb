
with Ada.Text_IO; use Ada.Text_IO;

with Chi_Sq; use Chi_Sq;
with Delft_Types; use Delft_Types;
with Display; use Display;
with SA_Types; use SA_Types;
with Printing; use Printing;
with Process_Data; use Process_Data;

procedure Statistical_Analysis is
   AB_Dir          : constant String := "../generated_data/";
   File_Settings   : constant String := AB_Dir & "settings.csv";
   File_00         : constant String := AB_Dir & "OEM_aa.csv";
   File_01         : constant String := AB_Dir & "OEM_ba.csv";
   File_10         : constant String := AB_Dir & "OEM_ab.csv";
   File_11         : constant String := AB_Dir & "OEM_bb.csv";
   Settings        : Angles_Record;
   Detections      : Detections_Record;
   Means           : Means_Record;
   Expectations    : Expectations_Record;
   Observed_Counts : Count_Array;
   Calculated_Chi  : Chi_Value;
   Resulting_P     : P_Value;
begin
   New_Line;
   Settings := Get_Settings (File_Settings);
   Detections.Detections_00 := Get_Detections (File_00);
   Detections.Detections_01 := Get_Detections (File_01);
   Detections.Detections_10 := Get_Detections (File_10);
   Detections.Detections_11  := Get_Detections (File_11);

   Expectations.E_AA := Statistical_EAB (A_Angle_0, B_Angle_0);
   Expectations.E_AB := Statistical_EAB (A_Angle_0, B_Angle_1);
   Expectations.E_BA := Statistical_EAB (A_Angle_1, B_Angle_0);
   Expectations.E_BB := Statistical_EAB (A_Angle_1, B_Angle_1);

   Display_Detector_Settings (Settings);
   Display_Number_Of_Detections (Detections);

   --  Print_Delft_Sample_List ("Detections_00", Detections_00, 1, 5);
   --  Print_Delft_Sample_List ("Detections_01", Detections_01, 1, 5);
   --  Print_Delft_Sample_List ("Detections_10", Detections_10, 1, 5);
   --  Print_Delft_Sample_List ("Detections_11", Detections_11, 1, 5);
   Get_And_Display_Sample_Means (Detections, Means);
   Display_Statistics (Means, Detections, Expectations);
   Display_Expectations (Expectations);

   Put ("Null hypothesis H0: ");
   Put_Line ("Sample mean is within 5% of expected value.");
   Report_Hypothesis_Testing
      (Means.Mean_AB_00, Means.Mean_AB_01, Means.Mean_AB_10, Means.Mean_AB_11);
   New_Line;

   Print_Float_Line
      ("CHSH parameter S: ", Means.Mean_AB_00 - Means.Mean_AB_01 +
          Means.Mean_AB_10 + Means.Mean_AB_11);
   New_Line;

   Observed_Counts := (Long_Float (Detections.Detections_00.Length),
                       Long_Float (Detections.Detections_01.Length),
                       Long_Float (Detections.Detections_10.Length),
                       Long_Float (Detections.Detections_11.Length));
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
