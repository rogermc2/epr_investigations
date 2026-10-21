
with Ada.Containers.Vectors;

with Types; use Types;

package Delft_Types is

   type Raw_Result_Record is record
      A_Setting  : UV;
      B_Setting  : UV;
      A_Result   : UV;
      B_Result   : UV;
   end record;

   package Delft_Data_Package is new
     Ada.Containers.Vectors (Positive, Raw_Result_Record);
   subtype Delft_Data_List is Delft_Data_Package.Vector;

end Delft_Types;