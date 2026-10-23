
with Delft_Types; use Delft_Types;
with Types; use Types;

package Delft_Printing is

   procedure Print_Delft_Data_List (Name : String; Data : Delft_Data_List;
                               Start : Positive := 1; Finish : Natural := 0);
   procedure Print_Delft_Sample_List (Name : String; Data : Delft_Sample_Data_List;
                               Start : Positive := 1; Finish : Natural := 0);
   procedure Print_Delft_Statistics
     (Message : String; Mean_A, Mean_B, Mean_AB, Exp_Val : Float;
      Detections : Delft_Sample_Data_List; Det_A, Det_B : Detect_Type);

end Delft_Printing;