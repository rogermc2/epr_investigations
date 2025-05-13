
with Ada.Containers.Vectors;

package Data_Selection is

   type Match_Record is record
      A_Index    : Natural;
      B_Index    : Natural;
   end record;

   package Match_Package is new
     Ada.Containers.Vectors (Natural, Match_Record);
   subtype Match_List is Match_Package.Vector;

   procedure Select_Pairs (Match_CSV : String; C : out Match_List);

    end Data_Selection;
