
with Ada.Containers.Vectors;
with Ada.Unchecked_Deallocation;

package Process_Data is

   --  Define the structure for the raw data (3 uint64 values)
   type Unsigned_64 is mod 2**64;
   type Raw_Record is array (0 .. 2) of Unsigned_64;

   package Raw_Data_Package is new
       Ada.Containers.Vectors (Positive, Raw_Record);
   subtype Raw_Data_List is Raw_Data_Package.Vector;

   package Sync_Data_Package is new
       Ada.Containers.Vectors (Positive, Unsigned_64);
   subtype Sync_Data_List is Sync_Data_Package.Vector;

   --  type Sync_Array is array (Positive range <>) of Unsigned_64;
   --  type Sync_Access is access Sync_Array;

   type Index_Array is array (Positive range <>) of Positive;
   type Index_Access is access Index_Array;

   --  Memory management helpers
   --  procedure Free is new
   --     Ada.Unchecked_Deallocation (Raw_Data_Array, Raw_Data_Access);
   --  procedure Free is new Ada.Unchecked_Deallocation (Sync_Array, Sync_Access);
   --  procedure Free is new
   --     Ada.Unchecked_Deallocation (Index_Array, Index_Access);

   --  function Load_Raw_Data (Filename : String) return Raw_Data_Access;
   function Load_Raw_Data (Filename : String) return Raw_Data_List;
   --  Helper to extract syncs (where column 0 == 6)
   --  function Get_Syncs (Data : Raw_Data_Access) return Sync_Access;
   function Get_Syncs (Data : Raw_Data_List) return Sync_Data_List;
   --  Helper for diff
   function Diff (Input : Sync_Data_List) return Sync_Data_List;
   --  Helper for diff on indices
   function Diff_Indices (Input : Index_Access) return Index_Access;
   procedure Print_Raw_Data_Vector (Name  : String; Data : Raw_Data_List;
     Start : Positive := 1; Finish : Natural := 0);
   --  Helper for where(diff < threshold)
   function Where_Less (Data : Sync_Data_List; Threshold : Unsigned_64)
    return Index_Access;
   --  Helper for where(diff > threshold)
   function Where_Greater (Data : Sync_Data_List; Threshold : Unsigned_64)
    return Index_Access;

end Process_Data;
