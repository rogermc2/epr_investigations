
with Nist_Types; use Nist_Types;

package Process_Data is
   --  Memory management helpers
   --  procedure Free is new
   --     Ada.Unchecked_Deallocation (Raw_Data_Array, Raw_Data_Access);
   --  procedure Free is new Ada.Unchecked_Deallocation
   --  (Sync_Array, Sync_Access);
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
   function Diff_Indices (Input : Index_List) return Index_List;
   procedure Print_Raw_Data_Vector (Name  : String; Data : Raw_Data_List;
     Start : Positive := 1; Finish : Natural := 0);
   --  Helper for where(diff < threshold)
   function Where_Less (Data : Sync_Data_List; Threshold : Unsigned_64)
    return Index_List;
   --  Helper for where(diff > threshold)
   function Where_Greater (Data : Sync_Data_List; Threshold : Unsigned_64)
    return Index_List;

end Process_Data;
