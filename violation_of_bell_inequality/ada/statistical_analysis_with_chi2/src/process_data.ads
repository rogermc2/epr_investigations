
with Delft_Types; use Delft_Types;
with SA_Types; use SA_Types;

package Process_Data is

   function False_Positives
      (Dir, OEM_File : String; False_Count, True_Count : out Natural)
       return Delft_Sample_Data_List;
   function Get_Detections (Detection_Data : String)
       return Delft_Sample_Data_List;
   function Get_Settings (File_Name : String) return Angles_Record;
   procedure Report_Hypothesis_Testing
       (Means : Means_Record; Expectations : Expectations_Record);
   procedure Sample_Means (Data : Delft_Sample_Data_List;
                           Mean_A, Mean_B, Mean_AB : out Float);

end Process_Data;
