
with Ada.Text_IO; use Ada.Text_IO;

with Analysis; use Analysis;
with Nist_Types; use Nist_Types;
with Process_Data;  use Process_Data;

procedure Analyze_Sync is
   use Raw_Data_Package;
   use Sync_Data_Package;
   File_Extension_Alice : constant String :=
    "23_55_CH_pockel_100kHz.run.ClassicalRNGXOR";
   --   "02_31_CH_pockel_100kHz.run.ClassicalRNGXOR_3";
   File_Extension_Bob : constant String :=
     "23_55_CH_pockel_100kHz.run.ClassicalRNGXOR";
   --    "02_31_CH_pockel_100kHz.run.ClassicalRNGXOR_3";
   Base_Path          : constant String := "../data/";
   Alice_Raw          : Raw_Data_List;
   Alice_Curs         : Raw_Data_Package.Cursor := Alice_Raw.First;
   --  Syncs_Alice        : Sync_Access;
   Syncs_Alice        : Sync_Data_List;
   Syncs_Alice_Curs   : Sync_Data_Package.Cursor := Syncs_Alice.First;
   --  Syncs_Diff_Alice   : Sync_Access;
   Syncs_Diff_Alice   : Sync_Data_List;
   Syncs_Alice_Diff_Curs  : Sync_Data_Package.Cursor := Syncs_Diff_Alice.First;
   Bob_Raw            : Raw_Data_List;
   Bob_Curs           : Raw_Data_Package.Cursor := Bob_Raw.First;
   --  Syncs_Bob          : Sync_Access;
   Syncs_Bob          : Sync_Data_List;
   --  Syncs_Diff_Bob     : Sync_Access;
   Syncs_Diff_Bob     : Sync_Data_List;
   --  Syncs_Bob          : Sync_Access;
   --  Syncs_Diff_Bob     : Sync_Access;
   Syncs_Bob_Diff_Curs    : Sync_Data_Package.Cursor := Syncs_Diff_Bob.First;

   --  Temporary storage for filtering
   --  Indices_Alice    : Index_Access;
   --  Indices_Bob      : Index_Access;
   --  Diff_Indices_Res : Index_Access;
   Indices_Alice      : Index_List;
   Indices_Alice_Curs : Index_Data_Package.Cursor := Indices_Alice.First;
   Indices_Bob        : Index_List;
   Indices_Bob_Curs   : Index_Data_Package.Cursor := Indices_Bob.First;
   Diff_Indices_Alice : Index_List;
   Diff_Alice_Curs    : Index_Data_Package.Cursor := Diff_Indices_Alice.First;
   Diff_Indices_Bob   : Index_List;
   Diff_Bob_Curs      : Index_Data_Package.Cursor := Diff_Indices_Bob.First;
   Diff_Indices_Res   : Index_List;
   Diff_Res_Curs      : Index_Data_Package.Cursor := Diff_Indices_Res.First;
   First              : Boolean := True;
   Count              : Natural := 0;
begin
   Put_Line ("Alice: opening file");
   Alice_Raw :=
    Load_Raw_Data (Base_Path & File_Extension_Alice & ".alice.dat");

   --  print (where(alice_raw[:,1] == 0))
   Put ("(array([");
   while Has_Element (Alice_Curs) loop
      if Element (Alice_Curs) (1) = 0 then
         if not First then
            Put (", ");
         end if;

         Put (Raw_Data_Package.Extended_Index'Image (To_Index (Alice_Curs)));
         First := False;
         Next (Alice_Curs);
      end if;
   end loop;
   Put_Line ("], dtype=int64),)");

   --  Alice: finding syncs
   Put_Line ("Alice: finding syncs");
   Syncs_Alice := Get_Syncs (Alice_Raw);

   --  Alice: calculating sync differences
   Put_Line ("Alice: calculating sync differences");
   Syncs_Diff_Alice := Diff (Syncs_Alice);

   --  Bob: opening file
   Put_Line ("Bob: opening file");
   Bob_Raw :=
      Load_Raw_Data (Base_Path & File_Extension_Bob & ".bob.dat");

   Put_Line ("Bob: finding syncs");
   Syncs_Bob := Get_Syncs (Bob_Raw);

   --  Bob: calculating sync differences
   Put_Line ("Bob: calculating sync differences");
   Syncs_Diff_Bob := Diff (Syncs_Bob);

   --  Low values
   New_Line (2);
   Put_Line ("Checking low values");
   New_Line;

   Put_Line ("Sync values where the difference is < 129,000");
   Low_Values (Syncs_Alice, Syncs_Diff_Alice);

   --  Bob low values
   Low_Values (Syncs_Bob, Syncs_Diff_Bob);
   New_Line;

   Put_Line ("Number of low difference values");
   Low_Count (Syncs_Diff_Alice);
   Low_Count (Syncs_Diff_Bob);

   New_Line;
   Put_Line ("Spacing between the low sync values");

   --  Alice spacing low
   Low_Spacing (Syncs_Diff_Alice, Diff_Indices_Alice);
   --  Indices_Alice := Where_Less (Syncs_Diff_Alice, 129000);
   --  Diff_Indices_Alice := Diff_Indices (Indices_Alice);
   --  Put ("[array([");
   --  for index in Diff_Indices_Res'Range loop
   --  Diff_Alice_Curs := Indices_Alice.First;
   --  while Has_Element (Diff_Alice_Curs) loop
   --     --  Put (Element (Indices_Diff_Curs)'Image);
   --        Put (Index_Data_Package.Extended_Index'Image
   --        (To_Index (Diff_Alice_Curs)));
   --     if Diff_Alice_Curs /= Diff_Indices.Last then
   --        Put (", ");
   --     end if;
   --     Next (Diff_Alice_Curs);
   --  end loop;

   --  Ada.Text_IO.Put_Line ("], dtype=int64)]");
   --  Free (Indices_Alice);
   --  Free (Diff_Indices_Res);

   --  Bob spacing low
   Low_Spacing (Syncs_Diff_Bob, Diff_Indices_Bob);
   --  Indices_Bob := Where_Less (Syncs_Diff_Bob, 129000);
   --  Diff_Indices_Res := Diff_Indices (Indices_Bob);
   --  Put ("[array([");
   --  --  for index in Diff_Indices_Res'Range loop
   --  while Has_Element (Indices_Bob_Curs) loop
   --     Put (Diff_Indices_Res (index)'Image);
   --     if index /= Diff_Indices_Res'Last then
   --        Put (", ");
   --     end if;
   --  end loop;

   --  Put_Line ("], dtype=int64)]");
   --  Free (Indices_Bob);
   --  Free (Diff_Indices_Res);

   --  Large values
   New_Line (2);
   Put_Line ("Checking large values");
   New_Line;
   Put_Line ("Sync values where the difference is > 129,200");

   --  Alice large values
   Put ("[");
   --  declare
   First := True;
   --  begin
      --  for index in Syncs_Diff_Alice'Range loop
   while Has_Element (Syncs_Alice_Diff_Curs) loop
      if Element (Syncs_Alice_Diff_Curs) > 129200 then
         if not First then
            Put (" ");
         end if;
         Put (Element (Syncs_Alice_Diff_Curs)'Image);
         First := False;
      end if;
      Next (Syncs_Alice_Diff_Curs);
   end loop;
   --  end;
   Put_Line ("]");

   --  Bob large values
   Put ("[");

   --  declare
   First := True;
   --  begin
   --  for index in Syncs_Diff_Bob'Range loop
   Syncs_Bob_Diff_Curs := Syncs_Diff_Bob.First;
   while Has_Element (Syncs_Bob_Diff_Curs) loop
      if Element (Syncs_Bob_Diff_Curs) > 129200 then
         if not First then
            Put (" ");
         end if;
         Put (Element (Syncs_Bob_Diff_Curs)'Image);
         First := False;
      end if;
      Next (Syncs_Bob_Diff_Curs);
   end loop;
   --  end;
   Put_Line ("]");

   New_Line;
   Put_Line ("Number of large difference values");

   --  Alice count large
   --  declare
   Count := 0;
   Syncs_Alice_Diff_Curs := Syncs_Diff_Alice.First;
   --  begin
      --  for index in Syncs_Diff_Alice'Range loop
   while Has_Element (Syncs_Alice_Diff_Curs) loop
      if Element (Syncs_Alice_Diff_Curs) > 129200 then
         Count := Count + 1;
      end if;
      Next (Syncs_Alice_Diff_Curs);
   end loop;
   Put_Line (Count'Image);
   --  end;

   --  Bob count large
   --  declare
   Count := 0;
   --  begin
   Syncs_Bob_Diff_Curs := Syncs_Diff_Bob.First;
   while Has_Element (Syncs_Bob_Diff_Curs) loop
      if Element (Syncs_Bob_Diff_Curs) > 129200 then
         Count := Count + 1;
      end if;
      Next (Syncs_Bob_Diff_Curs);
   end loop;
   Put_Line (Count'Image);
   --  end;

   New_Line;
   Put_Line ("Spacing between the large sync values");

   --  Alice spacing large
   Indices_Alice := Where_Greater (Syncs_Diff_Alice, 129200);
   Diff_Indices_Res := Diff_Indices (Indices_Alice);
   Put ("[array([");
   for index in Diff_Indices_Res'Range loop
      Put (Diff_Indices_Res (index)'Image);
      if index /= Diff_Indices_Res'Last then
         Put (", ");
      end if;
   end loop;

   Put_Line ("], dtype=int64)]");
   --  Free (Indices_Alice);
   --  Free (Diff_Indices_Res);

   --  Bob spacing large
   Indices_Bob := Where_Greater (Syncs_Diff_Bob, 129200);
   Diff_Indices_Res := Diff_Indices (Indices_Bob);
   Put ("[array([");
   for index in Diff_Indices_Res'Range loop
      Put (Diff_Indices_Res (index)'Image);
      if index /= Diff_Indices_Res'Last then
         Put (", ");
      end if;
   end loop;

   Put_Line ("], dtype=int64)]");
   --  Free (Indices_Bob);
   --  Free (Diff_Indices_Res);

   --  Cleanup
   --  Free (Syncs_Alice);
   --  Free (Syncs_Diff_Alice);
   --  Free (Syncs_Bob);
   --  Free (Syncs_Diff_Bob);

end Analyze_Sync;
