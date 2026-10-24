
with Delft_Types; use Delft_Types;
with Types; use Types;

package  Delft_Utils is
   procedure Combine_Detector_Tracks
      (Old_File_Path, New_File_Path, Out_File_Path : String);
   function Get_Delft_Integer_List (Data : Delft_Sample_Data_List;
           Selection : Detect_Type) return Integer_List;
   function Sample_Mean_vs_Exp_Value (E_Val, Sample_Mean : Float) return Float;
   function Trim_Both (S : String) return String;

end Delft_Utils;