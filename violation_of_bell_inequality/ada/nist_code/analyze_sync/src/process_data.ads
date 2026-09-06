
with Ada.Unchecked_Deallocation;

package Process_Data is

   --  Define the structure for the raw data (3 uint64 values)
   type Unsigned_64 is mod 2**64;
   type Raw_Record is array (0 .. 2) of Unsigned_64;

   --  Dynamic array types for processing
   type Raw_Data_Array is array (Positive range <>) of Raw_Record;
   type Raw_Data_Access is access Raw_Data_Array;

   type Sync_Array is array (Positive range <>) of Unsigned_64;
   type Sync_Access is access Sync_Array;

   type Index_Array is array (Positive range <>) of Positive;
   type Index_Access is access Index_Array;

   --  Memory management helpers
   procedure Free is new
      Ada.Unchecked_Deallocation (Raw_Data_Array, Raw_Data_Access);
   procedure Free is new Ada.Unchecked_Deallocation (Sync_Array, Sync_Access);
   procedure Free is new
      Ada.Unchecked_Deallocation (Index_Array, Index_Access);

   --  Helper to read the binary file into memory
   function Load_Raw_Data (Filename : String) return Raw_Data_Access;

   --  Helper to extract syncs (where column 0 == 6)
   function Get_Syncs (Data : Raw_Data_Access) return Sync_Access;

   --  Helper for np.diff
   function Diff (Input : Sync_Access) return Sync_Access;

   --  Helper for np.diff on indices
   function Diff_Indices (Input : Index_Access) return Index_Access;

   --  Helper for np.where(diff < threshold)
   function Where_Less (Data : Sync_Access; Threshold : Unsigned_64)
    return Index_Access;

   --  Helper for np.where(diff > threshold)
   function Where_Greater (Data : Sync_Access; Threshold : Unsigned_64)
    return Index_Access;

end Process_Data;
