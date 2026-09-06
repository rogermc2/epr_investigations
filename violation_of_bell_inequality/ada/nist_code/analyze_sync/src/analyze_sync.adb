with Ada.Text_IO;
with Ada.Direct_IO;
--  with Ada.Streams.Stream_IO;
with Ada.Unchecked_Deallocation;

with Process_Data;  use Process_Data;

procedure Analyze_Sync is

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

   --  File path constants
   File_Extension_Alice : constant String :=
    "02_31_CH_pockel_100kHz.run.ClassicalRNGXOR_3";
   File_Extension_Bob   : constant String :=
    "02_31_CH_pockel_100kHz.run.ClassicalRNGXOR_3";
   Base_Path            : constant String := "../Data";
   --   Base_Path            : constant String :=
   --   "O:\Public\optical_tes\belltestdata\Data\2015-09-17-late-night\";

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

   --  Variables for Alice
   Alice_Raw        : Raw_Data_Access;
   Syncs_Alice      : Sync_Access;
   Syncs_Diff_Alice : Sync_Access;

   --  Variables for Bob
   Bob_Raw          : Raw_Data_Access;
   Syncs_Bob        : Sync_Access;
   Syncs_Diff_Bob   : Sync_Access;

   --  Temporary storage for filtering
   Indices_Alice    : Index_Access;
   Indices_Bob      : Index_Access;
   Diff_Indices_Res : Index_Access;

begin
   --  Alice: opening file
   Ada.Text_IO.Put_Line ("Alice: opening file");
   Alice_Raw :=
    Load_Raw_Data (Base_Path & File_Extension_Alice & ".alice.dat");

   --  print (np.where(alice_raw[:,1] == 0))
   Ada.Text_IO.Put ("(array([");
   declare
      First : Boolean := True;
   begin
      for I in Alice_Raw'Range loop
         if Alice_Raw (I)(1) = 0 then
            if not First then
               Ada.Text_IO.Put (", ");
            end if;
            Ada.Text_IO.Put (I'Image);
            First := False;
         end if;
      end loop;
   end;
   Ada.Text_IO.Put_Line ("], dtype=int64),)");

   --  Alice: finding syncs
   Ada.Text_IO.Put_Line ("Alice: finding syncs");
   Syncs_Alice := Get_Syncs (Alice_Raw);
   Free (Alice_Raw); --  del alice_raw

   --  Alice: calculating sync differences
   Ada.Text_IO.Put_Line ("Alice: calculating sync differences");
   Syncs_Diff_Alice := Diff (Syncs_Alice);

   --  Bob: opening file
   Ada.Text_IO.Put_Line ("Bob: opening file");
   Bob_Raw :=
      Load_Raw_Data (Base_Path & File_Extension_Bob & ".bob.dat");

   --  Bob: finding syncs
   Ada.Text_IO.Put_Line ("Bob: finding syncs");
   Syncs_Bob := Get_Syncs (Bob_Raw);
   Free (Bob_Raw); --  del bob_raw

   --  Bob: calculating sync differences
   Ada.Text_IO.Put_Line ("Bob: calculating sync differences");
   Syncs_Diff_Bob := Diff (Syncs_Bob);

   --  Low values
   Ada.Text_IO.New_Line (2);
   Ada.Text_IO.Put_Line ("Checking low values");
   Ada.Text_IO.New_Line;
   Ada.Text_IO.Put_Line ("Sync values where the difference is < 129,000");

   --  Alice low values
   Ada.Text_IO.Put ("[");
   declare
      First : Boolean := True;
   begin
      for I in Syncs_Diff_Alice'Range loop
         if Syncs_Diff_Alice (I) < 129000 then
            if not First then
               Ada.Text_IO.Put (" ");
            end if;
            Ada.Text_IO.Put (Syncs_Diff_Alice (I)'Image);
            First := False;
         end if;
      end loop;
   end;
   Ada.Text_IO.Put_Line ("]");

   --  Bob low values
   Ada.Text_IO.Put ("[");
   declare
      First : Boolean := True;
   begin
      for I in Syncs_Diff_Bob'Range loop
         if Syncs_Diff_Bob (I) < 129000 then
            if not First then
               Ada.Text_IO.Put (" ");
            end if;
            Ada.Text_IO.Put (Syncs_Diff_Bob (I)'Image);
            First := False;
         end if;
      end loop;
   end;
   Ada.Text_IO.Put_Line ("]");

   Ada.Text_IO.New_Line;
   Ada.Text_IO.Put_Line ("Number of low difference values");

   --  Alice count low
   declare
      Count : Natural := 0;
   begin
      for I in Syncs_Diff_Alice'Range loop
         if Syncs_Diff_Alice (I) < 129000 then
            Count := Count + 1;
         end if;
      end loop;
      Ada.Text_IO.Put_Line (Count'Image);
   end;

   --  Bob count low
   declare
      Count : Natural := 0;
   begin
      for I in Syncs_Diff_Bob'Range loop
         if Syncs_Diff_Bob (I) < 129000 then
            Count := Count + 1;
         end if;
      end loop;
      Ada.Text_IO.Put_Line (Count'Image);
   end;

   Ada.Text_IO.New_Line;
   Ada.Text_IO.Put_Line ("Spacing between the low sync values");

   --  Alice spacing low
   Indices_Alice := Where_Less (Syncs_Diff_Alice, 129000);
   Diff_Indices_Res := Diff_Indices (Indices_Alice);
   Ada.Text_IO.Put ("[array([");
   for I in Diff_Indices_Res'Range loop
      Ada.Text_IO.Put (Diff_Indices_Res (I)'Image);
      if I /= Diff_Indices_Res'Last then
         Ada.Text_IO.Put (", ");
      end if;
   end loop;

   Ada.Text_IO.Put_Line ("], dtype=int64)]");
   Free (Indices_Alice);
   Free (Diff_Indices_Res);

   --  Bob spacing low
   Indices_Bob := Where_Less (Syncs_Diff_Bob, 129000);
   Diff_Indices_Res := Diff_Indices (Indices_Bob);
   Ada.Text_IO.Put ("[array([");
   for I in Diff_Indices_Res'Range loop
      Ada.Text_IO.Put (Diff_Indices_Res (I)'Image);
      if I /= Diff_Indices_Res'Last then
         Ada.Text_IO.Put (", ");
      end if;
   end loop;

   Ada.Text_IO.Put_Line ("], dtype=int64)]");
   Free (Indices_Bob);
   Free (Diff_Indices_Res);

   --  Large values
   Ada.Text_IO.New_Line (2);
   Ada.Text_IO.Put_Line ("Checking large values");
   Ada.Text_IO.New_Line;
   Ada.Text_IO.Put_Line ("Sync values where the difference is > 129,200");

   --  Alice large values
   Ada.Text_IO.Put ("[");
   declare
      First : Boolean := True;
   begin
      for I in Syncs_Diff_Alice'Range loop
         if Syncs_Diff_Alice (I) > 129200 then
            if not First then
               Ada.Text_IO.Put (" ");
            end if;
            Ada.Text_IO.Put (Syncs_Diff_Alice (I)'Image);
            First := False;
         end if;
      end loop;
   end;
   Ada.Text_IO.Put_Line ("]");

   --  Bob large values
   Ada.Text_IO.Put ("[");
   declare
      First : Boolean := True;
   begin
      for I in Syncs_Diff_Bob'Range loop
         if Syncs_Diff_Bob (I) > 129200 then
            if not First then
               Ada.Text_IO.Put (" ");
            end if;
            Ada.Text_IO.Put (Syncs_Diff_Bob (I)'Image);
            First := False;
         end if;
      end loop;
   end;
   Ada.Text_IO.Put_Line ("]");

   Ada.Text_IO.New_Line;
   Ada.Text_IO.Put_Line ("Number of large difference values");

   --  Alice count large
   declare
      Count : Natural := 0;
   begin
      for I in Syncs_Diff_Alice'Range loop
         if Syncs_Diff_Alice (I) > 129200 then
            Count := Count + 1;
         end if;
      end loop;
      Ada.Text_IO.Put_Line (Count'Image);
   end;

   --  Bob count large
   declare
      Count : Natural := 0;
   begin
      for I in Syncs_Diff_Bob'Range loop
         if Syncs_Diff_Bob (I) > 129200 then
            Count := Count + 1;
         end if;
      end loop;
      Ada.Text_IO.Put_Line (Count'Image);
   end;

   Ada.Text_IO.New_Line;
   Ada.Text_IO.Put_Line ("Spacing between the large sync values");

   --  Alice spacing large
   Indices_Alice := Where_Greater (Syncs_Diff_Alice, 129200);
   Diff_Indices_Res := Diff_Indices (Indices_Alice);
   Ada.Text_IO.Put ("[array([");
   for I in Diff_Indices_Res'Range loop
      Ada.Text_IO.Put (Diff_Indices_Res (I)'Image);
      if I /= Diff_Indices_Res'Last then
         Ada.Text_IO.Put (", ");
      end if;
   end loop;

   Ada.Text_IO.Put_Line ("], dtype=int64)]");
   Free (Indices_Alice);
   Free (Diff_Indices_Res);

   --  Bob spacing large
   Indices_Bob := Where_Greater (Syncs_Diff_Bob, 129200);
   Diff_Indices_Res := Diff_Indices (Indices_Bob);
   Ada.Text_IO.Put ("[array([");
   for I in Diff_Indices_Res'Range loop
      Ada.Text_IO.Put (Diff_Indices_Res (I)'Image);
      if I /= Diff_Indices_Res'Last then
         Ada.Text_IO.Put (", ");
      end if;
   end loop;

   Ada.Text_IO.Put_Line ("], dtype=int64)]");
   Free (Indices_Bob);
   Free (Diff_Indices_Res);

   --  Cleanup
   Free (Syncs_Alice);
   Free (Syncs_Diff_Alice);
   Free (Syncs_Bob);
   Free (Syncs_Diff_Bob);

end Analyze_Sync;
