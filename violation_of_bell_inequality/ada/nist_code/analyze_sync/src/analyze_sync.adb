with Ada.Text_IO;

with Process_Data;  use Process_Data;

procedure Analyze_Sync is

   --  type Index_Array is array (Positive range <>) of Positive;
   --  type Index_Access is access Index_Array;
   --  File path constants
   File_Extension_Alice : constant String :=
    "02_31_CH_pockel_100kHz.run.ClassicalRNGXOR_3";
   File_Extension_Bob   : constant String :=
     "02_31_CH_pockel_100kHz.run.ClassicalRNGXOR_3";
   Base_Path            : constant String := "../data/";
   --  Base_Path            : constant String :=
   --   "O:\Public\optical_tes\belltestdata\Data\2015-09-17-late-night\";

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
