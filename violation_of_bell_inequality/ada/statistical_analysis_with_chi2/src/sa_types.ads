
with Delft_Types; use Delft_Types;

package SA_Types is

   type Detections_Record is record
      Detections_00 : Delft_Sample_Data_List;
      Detections_01 : Delft_Sample_Data_List;
      Detections_10 : Delft_Sample_Data_List;
      Detections_11 : Delft_Sample_Data_List;
   end record;

   type Expectations_Record is record
      E_AA : Float;
      E_AB : Float;
      E_BA : Float;
      E_BB : Float;
   end record;

   type Means_Record is record
      Mean_A_00  : Float;
      Mean_A_01  : Float;
      Mean_A_10  : Float;
      Mean_A_11  : Float;
      Mean_B_00  : Float;
      Mean_B_01  : Float;
      Mean_B_10  : Float;
      Mean_B_11  : Float;
      Mean_AB_00 : Float;
      Mean_AB_01 : Float;
      Mean_AB_10 : Float;
      Mean_AB_11 : Float;
   end record;

end SA_Types;