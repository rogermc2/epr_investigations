
with Delft_Types; use Delft_Types;
with Types; use Types;

package Process_Data is

   function Statistical_EAB (theta : float) return Float;
   function False_Positives
      (Dir, OEM_File : String; False_Count, True_Count : out Natural)
       return Delft_Sample_Data_List;
   function Get_Detections (Detection_Data : String)
       return Delft_Sample_Data_List;
   procedure Sample_Means (Data : Delft_Sample_Data_List;
                           Mean_A, Mean_B, Mean_AB : out Float);

end Process_Data;
