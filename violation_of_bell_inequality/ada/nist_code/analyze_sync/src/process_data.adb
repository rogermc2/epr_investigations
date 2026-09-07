with Ada.Text_IO; use Ada.Text_IO;
with Ada.Streams.Stream_IO;

package body Process_Data is

   function Load_Raw_Data (Filename : String) return Raw_Data_List is
      use Ada.Streams.Stream_IO;
      use Raw_Data_Package;
      File_ID : Ada.Streams.Stream_IO.File_Type;
      Size    : Ada.Streams.Stream_IO.Count;
      Item    : Raw_Record;
      Data    : Raw_Data_List;
      Count   : Natural := 0;
   begin
      Open (File_ID, In_File, Filename);
      Put_Line ("Load_Raw_Data file opened: " & Filename);
      Size := Ada.Streams.Stream_IO.Size (File_ID);
      Put_Line ("File size: " & Size'Image);

      while not End_Of_File (File_ID) loop
         Raw_Record'Read (Stream (File_ID), Item);
         Data.Append (Item);
         Count := Count + 1;
         if Count mod 10000000 = 0 then
            Put (".");
         end if;
      end loop;
      New_Line;

      Close (File_ID);
      return Data;

   exception
      when others =>
         Put_Line ("Error opening or reading file: " & Filename);
         return Data;

   end Load_Raw_Data;

   --  extract syncs (where column 0 == 6)
   function Get_Syncs (Data : Raw_Data_List) return Sync_Data_List is
      use Raw_Data_Package;
      use Sync_Data_Package;
      Raw_Curs : Raw_Data_Package.Cursor := Data.First;
      Item     : Raw_Record;
      Count    : Natural := 0;
      Result   : Sync_Data_List;
      --  Idx      : Positive := 1;
   begin
      while Has_Element (Raw_Curs) loop
         Item := Element (Raw_Curs);
         if Item (0) = 6 then
            Count := Count + 1;
         end if;
         Next (Raw_Curs);
      end loop;

      Raw_Curs := Data.First;
      while Has_Element (Raw_Curs) loop
         Item := Element (Raw_Curs);
         if Item (0) = 6 then
            Result.Append (Item (1));
         end if;
         Next (Raw_Curs);
      end loop;

      return Result;

   end Get_Syncs;

   function Diff (Input : Sync_Data_List) return Sync_Data_List is
      use Sync_Data_Package;
      Curs   : Cursor := Input.First;
      Result : Sync_Data_List;
   begin
      --  if Input = null or else Input'Length <= 1 then
      if Integer (Sync_Data_Package.Length (Input)) > 1 then
         --  return new Sync_Array (1 .. 0);
      --  else
         --  Result := new Sync_Array (1 .. Input'Length - 1);
         --  for index in 1 .. Input'Length - 1 loop
         while Has_Element (Curs) loop
            --  Result (index) := Input (index + 1) - Input (index);
            if Curs /= Input.Last then
               Result.Append (Element (Next (Curs)) - Element (Curs));
            end if;
            Next (Curs);
         end loop;
      end if;
      return Result;

   end Diff;

   --  Helper for diff on indices
   function Diff_Indices (Input : Index_List) return Index_List is
      use Index_Data_Package;
      Curs   : Cursor := Input.First;
      Result : Sync_Data_List;
      Result : Index_List;
   begin
      --  if Input = null or else Input'Length <= 1 then
      --     return new Index_Array (1 .. 0);
      --  end if;

      if Integer (Index_Data_Package.Length (Input)) > 1 then
      --  Result := new Index_Array (1 .. Input'Length - 1);
      --  for index in 1 .. Input'Length - 1 loop
      --     Result (index) := Input (index + 1) - Input (index);
      --  end loop;

         while Has_Element (Curs) loop
            --  Result (index) := Input (index + 1) - Input (index);
            if Curs /= Input.Last then
               Result.Append (Element (Next (Curs)) - Element (Curs));
            end if;
            Next (Curs);
         end loop;
      end if;
      return Result;

   end Diff_Indices;

procedure Print_Raw_Data_Vector (Name : String; Data : Raw_Data_List;
      Start : Positive := 1; Finish : Natural := 0) is
   use Raw_Data_Package;
   Last      : Natural;
   Item      : Raw_Record;
   Count     : Integer := 1;
begin
   if Finish > 0 and then Finish <= Natural (Data.Last_Index) then
      Last := Finish;
   else
      Last := Natural (Data.Last_Index);
   end if;

   Put_Line (Name & ": ");
   if Start >= Data.First_Index and then Last <= Data.Last_Index then
      for Index in Start .. Last loop
         Item := Data (Index);
         for value in Item'Range loop
            Put (Unsigned_64'Image (Item (value)) & ",  ");
         end loop;
         Count := Count + 1;
         if Count > 10 then
            New_Line;
            Count := 1;
         end if;
      end loop;
   else
      Put_Line ("Print_Raw_Data_Vector called with invalid" &
         " start or finish index.");
      Put_Line ("Start: " & Integer'Image (Start) & ",  Finish: " &
                  Integer'Image (Finish));
      Put_Line ("Data.First_Index: " & Integer'Image (Data.First_Index) &
                  ",  Data.Last_Index: " & Integer'Image (Data.Last_Index));
   end if;
   New_Line;

end Print_Raw_Data_Vector;

   --  Helper for where(diff < threshold)
   --  function Where_Less (Data : Sync_Access; Threshold : Unsigned_64)
   function Where_Less (Data : Sync_Data_List; Threshold : Unsigned_64)
    return Index_Access is
      use Sync_Data_Package;
      Curs   : Cursor := Data.First;
      Idx    : Positive := 1;
      Count  : Natural := 0;
      Result : Index_Access;
   begin
      --  for index in Data'Range loop
      while Has_Element (Curs) loop
         --  if Data (index) < Threshold then
         if Element (Curs) < Threshold then
            Count := Count + 1;
         end if;
         Next (Curs);
      end loop;

      Result := new Index_Array (1 .. Count);
      --  for index in Data'Range loop
      Curs := Data.First;
      while Has_Element (Curs) loop
         --  if Data (index) < Threshold then
         if Element (Curs) < Threshold then
            Result (Idx) := Positive (Element (Curs));
            Idx := Idx + 1;
         end if;
         Next (Curs);
      end loop;

      return Result;

   end Where_Less;

   --  Helper for where (diff > threshold)
   function Where_Greater (Data : Sync_Data_List; Threshold : Unsigned_64)
    return Index_Access is
      use Sync_Data_Package;
      Curs   : Cursor := Data.First;
      Count  : Natural := 0;
      Result : Index_Access;
      Idx    : Positive := 1;
   begin
      --  for index in Data'Range loop
      while Has_Element (Curs) loop
         if Element (Curs) > Threshold then
            Count := Count + 1;
         end if;
         Next (Curs);
      end loop;

      --  Result := new Index_Array (1 .. Count);
      --  for index in Data'Range loop
      Idx := 1;
      Curs := Data.First;
      while Has_Element (Curs) loop
         if Element (Curs) > Threshold then
            Result (Idx) := Integer (Element (Curs));
            Idx := Idx + 1;
         end if;
         Next (Curs);
      end loop;

      return Result;

   end Where_Greater;

end Process_Data;
