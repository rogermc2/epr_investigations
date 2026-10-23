
with Ada.Strings;
with Ada.Strings.Fixed;

package body Delft_Utils is

    function Get_Delft_Integer_List
       (Data : Delft_Sample_Data_List; Selection : Detect_Type) return Integer_List is
      use Delft_Sample_Data_Package;
      Count   : Natural := 0;
      Curs    : Cursor := Data.First;
      Item    : Delft_Sample_Data_Record;
      theList : Integer_List;
   begin
      while Has_Element (Curs) loop
         Count := Count + 1;
         Item := Element (Curs);
         if Selection = Det_A then
            theList.Append (Item.A_Detection);
         elsif Selection = Det_B then
            theList.Append (Item.B_Detection);
         else  --  Selection = Det_Both
            theList.Append (Item.AB);
         end if;

         Curs := Next (Curs);
      end loop;

      return theList;
   end Get_Delft_Integer_List;

   function Sample_Mean_vs_Exp_Value (E_Val, Sample_Mean : Float)
            return Float is
   begin
    return 100.0 * (abs (Sample_Mean - E_Val)) / abs (E_Val);  --  per cent

   end Sample_Mean_vs_Exp_Value;

   function Trim_Both (S : String) return String is
   begin
      return Ada.Strings.Fixed.Trim (S, Ada.Strings.Both);
   end Trim_Both;

end Delft_Utils;