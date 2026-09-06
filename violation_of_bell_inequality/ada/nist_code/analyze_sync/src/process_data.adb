with Ada.Text_IO;
with Ada.Direct_IO;

package body Process_Data is

   --  function Load_Raw_Data (Filename : String) return Raw_Data_Access is
   function Load_Raw_Data (Filename : String) return Raw_Data_List is
      use Raw_Data_Package;
      package Raw_IO is new Ada.Direct_IO (Raw_Record);
      File_ID : Raw_IO.File_Type;
      --  File_ID : Raw_IO.File_Type;
      --  Size    : Raw_IO.Count;
      --  Data : Raw_Data_Access;
      Item : Raw_Record;
      Data : Raw_Data_List;
   begin
      Raw_IO.Open (File_ID, Raw_IO.In_File, Filename);
      --  Size := Raw_IO.Size (File);

      while not Raw_IO.End_Of_File (File_ID) loop
         Raw_IO.Read (File_ID, Item);
         Data.Append (Item);
      end loop;
         --  declare
         --     Temp : Raw_Record;
         --  begin
         --     Raw_IO.Read (File, Temp);
         --     Data.Append (Temp);
         --  end;
      --  end loop;

      --  declare
      --     Data : Raw_Data_Array (1 .. Positive (Size));
      --  begin
      --  for index in 1 .. Size loop
      --     Raw_IO.Read (File, Data (Positive (index)));
      --  end loop;

      Raw_IO.Close (File_ID);
      return Data;
      --  end;

   exception
      when others =>
         Ada.Text_IO.Put_Line ("Error opening or reading file: " & Filename);
         return Data;
         --  return null;
   end Load_Raw_Data;

   --  extract syncs (where column 0 == 6)
   function Get_Syncs (Data : Raw_Data_List) return Sync_Access is
      use Raw_Data_Package;
      Raw_Curs : Cursor := Data.First;
      Item     : Raw_Record;
      Count    : Natural := 0;
      Result   : Sync_Access;
      Idx      : Positive := 1;
   begin
      --  for index in Data'Range loop
      --     if Data (index)(0) = 6 then
      --        Count := Count + 1;
      --     end if;
      --  end loop;
      while Has_Element (Raw_Curs) loop
         Item := Element (Raw_Curs);
         if Item (0) = 6 then
            Count := Count + 1;
         end if;
         Next (Raw_Curs);
      end loop;

      Result := new Sync_Array (1 .. Count);
      --  for index in Data'Range loop
      --     if Data (index)(0) = 6 then
      --        Result (Idx) := Data (index)(1);
      --        Idx := Idx + 1;
      --     end if;
      --  end loop;
      Raw_Curs := Data.First;
      while Has_Element (Raw_Curs) loop
         Item := Element (Raw_Curs);
         if Item (0) = 6 then
            Result (Idx) := Item (1);
            Idx := Idx + 1;
         end if;
         Next (Raw_Curs);
      end loop;

      return Result;

   end Get_Syncs;

   function Diff (Input : Sync_Access) return Sync_Access is
      Result : Sync_Access;
   begin
      if Input = null or else Input'Length <= 1 then
         return new Sync_Array (1 .. 0);
      end if;

      Result := new Sync_Array (1 .. Input'Length - 1);
      for index in 1 .. Input'Length - 1 loop
         Result (index) := Input (index + 1) - Input (index);
      end loop;
      return Result;

   end Diff;

   --  Helper for diff on indices
   function Diff_Indices (Input : Index_Access) return Index_Access is
      Result : Index_Access;
   begin
      if Input = null or else Input'Length <= 1 then
         return new Index_Array (1 .. 0);
      end if;

      Result := new Index_Array (1 .. Input'Length - 1);
      for index in 1 .. Input'Length - 1 loop
         Result (index) := Input (index + 1) - Input (index);
      end loop;
      return Result;

   end Diff_Indices;

   --  Helper for where(diff < threshold)
   function Where_Less (Data : Sync_Access; Threshold : Unsigned_64)
    return Index_Access is
      Count : Natural := 0; Result : Index_Access; Idx : Positive := 1;
   begin
      for index in Data'Range loop
         if Data (index) < Threshold then
            Count := Count + 1;
         end if;
      end loop;

      Result := new Index_Array (1 .. Count);
      for index in Data'Range loop
         if Data (index) < Threshold then
            Result (Idx) := index;
            Idx := Idx + 1;
         end if;
      end loop;
      return Result;

   end Where_Less;

   --  Helper for where (diff > threshold)
   function Where_Greater (Data : Sync_Access; Threshold : Unsigned_64)
    return Index_Access is
      Count  : Natural := 0;
      Result : Index_Access;
      Idx    : Positive := 1;
   begin
      for index in Data'Range loop
         if Data (index) > Threshold then
            Count := Count + 1;
         end if;
      end loop;

      Result := new Index_Array (1 .. Count);
      for index in Data'Range loop
         if Data (index) > Threshold then
            Result (Idx) := index;
            Idx := Idx + 1;
         end if;
      end loop;
      return Result;

   end Where_Greater;

end Process_Data;
