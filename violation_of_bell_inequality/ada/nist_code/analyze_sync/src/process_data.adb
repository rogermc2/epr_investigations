with Ada.Text_IO;
with Ada.Direct_IO;
--  with Ada.Streams.Stream_IO;

package body Process_Data is

   --  Helper to read the binary file into memory
   function Load_Raw_Data (Filename : String) return Raw_Data_Access is
      package Raw_IO is new Ada.Direct_IO (Raw_Record);
      File     : Raw_IO.File_Type;
      Size     : Raw_IO.Count;
      Data     : Raw_Data_Access;
   begin
      Raw_IO.Open (File, Raw_IO.In_File, Filename);
      Size := Raw_IO.Size (File);
      Data := new Raw_Data_Array (1 .. Positive (Size));
      for I in 1 .. Size loop
         Raw_IO.Read (File, Data (Positive (I)));
      end loop;
      Raw_IO.Close (File);
      return Data;
   exception
      when others =>
         Ada.Text_IO.Put_Line ("Error opening or reading file: " & Filename);
         return null;
   end Load_Raw_Data;

   --  Helper to extract syncs (where column 0 == 6)
   function Get_Syncs (Data : Raw_Data_Access) return Sync_Access is
      Count : Natural := 0;
      Result : Sync_Access;
      Idx    : Positive := 1;
   begin
      for I in Data'Range loop
         if Data (I)(0) = 6 then
            Count := Count + 1;
         end if;
      end loop;

      Result := new Sync_Array (1 .. Count);
      for I in Data'Range loop
         if Data (I)(0) = 6 then
            Result (Idx) := Data (I)(1);
            Idx := Idx + 1;
         end if;
      end loop;
      return Result;
   end Get_Syncs;

   --  Helper for np.diff
   function Diff (Input : Sync_Access) return Sync_Access is
      Result : Sync_Access;
   begin
      if Input = null or else Input'Length <= 1 then
         return new Sync_Array (1 .. 0);
      end if;
      Result := new Sync_Array (1 .. Input'Length - 1);
      for I in 1 .. Input'Length - 1 loop
         Result (I) := Input (I + 1) - Input (I);
      end loop;
      return Result;
   end Diff;

   --  Helper for np.diff on indices
   function Diff_Indices (Input : Index_Access) return Index_Access is
      Result : Index_Access;
   begin
      if Input = null or else Input'Length <= 1 then
         return new Index_Array (1 .. 0);
      end if;
      Result := new Index_Array (1 .. Input'Length - 1);
      for I in 1 .. Input'Length - 1 loop
         Result (I) := Input (I + 1) - Input (I);
      end loop;
      return Result;
   end Diff_Indices;

   --  Helper for np.where(diff < threshold)
   function Where_Less (Data : Sync_Access; Threshold : Unsigned_64)
    return Index_Access is
      Count : Natural := 0;
      Result : Index_Access;
      Idx    : Positive := 1;
   begin
      for I in Data'Range loop
         if Data (I) < Threshold then
            Count := Count + 1;
         end if;
      end loop;
      Result := new Index_Array (1 .. Count);
      for I in Data'Range loop
         if Data (I) < Threshold then
            Result (Idx) := I;
            Idx := Idx + 1;
         end if;
      end loop;
      return Result;
   end Where_Less;

   --  Helper for np.where(diff > threshold)
   function Where_Greater (Data : Sync_Access; Threshold : Unsigned_64)
    return Index_Access is
      Count : Natural := 0;
      Result : Index_Access;
      Idx    : Positive := 1;
   begin
      for I in Data'Range loop
         if Data (I) > Threshold then
            Count := Count + 1;
         end if;
      end loop;
      Result := new Index_Array (1 .. Count);
      for I in Data'Range loop
         if Data (I) > Threshold then
            Result (Idx) := I;
            Idx := Idx + 1;
         end if;
      end loop;
      return Result;
   end Where_Greater;

end Process_Data;
