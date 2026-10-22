
with Delft_Types; use Delft_Types;
with Types; use Types;

package  Delft_Utils is

    function Get_Delft_Integer_List (Data : Delft_Sample_Data_List;
           Selection : Detect_Type) return Integer_List;
   function Trim_Both (S : String) return String;

end Delft_Utils;