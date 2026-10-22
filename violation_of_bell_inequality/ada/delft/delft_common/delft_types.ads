
with Ada.Containers.Vectors;

with Types; use Types;

package Delft_Types is

   type Raw_Result_Record is record
      A_Setting  : UV;
      B_Setting  : UV;
      A_Outcome  : UV;
      B_Outcome  : UV;
   end record;

   package Delft_Data_Package is new
     Ada.Containers.Vectors (Positive, Raw_Result_Record);
   subtype Delft_Data_List is Delft_Data_Package.Vector;

   type Delft_Sample_Data_Record is record
      A_Detection : UV;
      B_Detection : UV;
      AB          : UV;
   end record;

   package Delft_Sample_Data_Package is new
     Ada.Containers.Vectors (Positive, Delft_Sample_Data_Record);
   subtype Delft_Sample_Data_List is Delft_Sample_Data_Package.Vector;

end Delft_Types;