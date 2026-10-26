
with Delft_Types; use Delft_Types;
with SA_Types; use SA_Types;

package Display is

   procedure Display_Detector_Settings  (Settings : Angles_Record);
   procedure Display_Expectations (Expectations : Expectations_Record);
   procedure Display_Number_Of_Detections (Detections : Detections_Record);
   procedure Display_Statistics
      (Means : Means_Record; Detections : Detections_Record;
      Expectations : Expectations_Record);
   procedure Get_And_Display_Sample_Means
       (Detections : Detections_Record; Means : out Means_Record);

end Display;