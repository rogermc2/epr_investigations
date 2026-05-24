
with Types; use Types;

package Process_Data is

   function EAB (theta : float) return float;
   function False_Positives (OEM_File : String; False_Count : out Natural)
                             return Sample_Data_List;
   function Get_Detections (OEM, a_File, b_File : String) return Sample_Data_List;
   procedure Sample_Means (Data : Sample_Data_List;
                           Mean_A, Mean_B, Mean_AB : out Float);

end Process_Data;
