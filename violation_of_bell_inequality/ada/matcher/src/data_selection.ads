
with Ada.Containers.Vectors;

with Types; use Types;

package Data_Selection is

   type Match_Record is record
      A_Index    : Natural;
      B_Index    : Natural;
   end record;

   package Match_Package is new
     Ada.Containers.Vectors (Natural, Match_Record);
   subtype Match_List is Match_Package.Vector;

   procedure Pair_Indices (Match_CSV : String; U, V : Double;
                           Selected : out Match_List);
   procedure Select_OEM_Data (OEM_A, OEM_B, Selected_OEM : String;
                              Selected_Indices : Match_List);

    end Data_Selection;
