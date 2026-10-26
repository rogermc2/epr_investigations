
with Ada.Text_IO; use Ada.Text_IO;

with Delft_Printing; use Delft_Printing;
with Printing; use Printing;
with Process_Data; use Process_Data;
with Types; use Types;

package body Display is

   procedure Display_Detector_Settings (Settings : Angles_Record) is
   begin
      Put_Line ("Detector settings:");
      Print_Float_Line ("a0", Float (Settings.A_0));
      Print_Float_Line ("a1", Float (Settings.A_1));
      Print_Float_Line ("b0", Float (Settings.B_0));
      Print_Float_Line ("b1", Float (Settings.B_1));
      New_Line;

   end Display_Detector_Settings;

   procedure Display_Expectations (Expectations : Expectations_Record) is
   begin
      Print_Float_Line ("E(AA)", Expectations.E_AA);
      Print_Float_Line ("E(AB)", Expectations.E_AB);
      Print_Float_Line ("E(BA)", Expectations.E_BA);
      Print_Float_Line ("E(BB)", Expectations.E_BB);
      New_Line;

   end Display_Expectations;

   procedure Display_Statistics
      (Means : Means_Record; Detections : Detections_Record;
       Expectations : Expectations_Record) is
   begin
      Print_Delft_Statistics ("00", Means.Mean_A_00, Means.Mean_B_00,
          Means.Mean_AB_00, Expectations.E_AA, Detections.Detections_00, Det_A, Det_B);
      Print_Delft_Statistics ("01", Means.Mean_A_01, Means.Mean_B_01,
            Means.Mean_AB_01, Expectations.E_AB, Detections.Detections_01, Det_A, Det_B);
      Print_Delft_Statistics ("10", Means.Mean_A_10, Means.Mean_B_10,
            Means.Mean_AB_10, Expectations.E_BA, Detections.Detections_10, Det_A, Det_B);
      Print_Delft_Statistics ("11", Means.Mean_A_11, Means.Mean_B_11,
            Means.Mean_AB_11, Expectations.E_BB, Detections.Detections_11, Det_A, Det_B);
      New_Line;

      Print_Float_Line ("Overall A Sample_Mean: ",
         (Means.Mean_A_00 + Means.Mean_A_01 +
            Means.Mean_A_10 + Means.Mean_A_11) / 4.0);
      Print_Float_Line ("Overall B Sample_Mean: ",
         (Means.Mean_B_00 + Means.Mean_B_01 +
            Means.Mean_B_10 + Means.Mean_B_11) / 4.0);
      New_Line;

   end Display_Statistics;

end Display;