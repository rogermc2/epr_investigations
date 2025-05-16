
with Ada.Containers.Vectors;

package Process_Data is
   type Sample_Data_Record is record
        A_Detection : Natural;
        B_Detection : Natural;
      end record;

   package Sample_Data_Package is new
     Ada.Containers.Vectors (Positive, Sample_Data_Record);
   subtype Sample_Data_List is Sample_Data_Package.Vector;

   function Get_Sample_Data (OEM : String) return Sample_Data_List;

end Process_Data;
