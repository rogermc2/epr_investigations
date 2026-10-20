
package Delft_Types is

   type Raw_Result_Record is record
      A_Setting  : Integer;
      B_Setting  : Integer;
      A_Result   : Integer;
      B_Result   : Integer;
   end record;

   type Field_Array is array (1 .. 17) of Natural;

end Delft_Types;