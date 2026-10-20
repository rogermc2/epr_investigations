
with Ada.Containers.Vectors;
package Delft_Types is

   type Raw_Result_Record is record
      A_Setting  : Integer;
      B_Setting  : Integer;
      A_Result   : Integer;
      B_Result   : Integer;
   end record;

   package Delft_Data_Package is new
     Ada.Containers.Vectors (Positive, Raw_Result_Record);
   subtype Delft_Data_List is Delft_Data_Package.Vector;

end Delft_Types;