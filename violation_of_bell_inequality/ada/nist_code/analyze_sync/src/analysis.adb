
with Ada.Text_IO; use Ada.Text_IO;

with Process_Data;

package body Analysis is

   procedure Low_Count (Syncs_Diff : Sync_Data_List) is
      use Sync_Data_Package;
      Diff_Curs : Cursor := Syncs_Diff.First;
      Count     : Natural := 0;
      First     : Boolean := True;
   begin
      while Has_Element (Diff_Curs) loop
         if Element (Diff_Curs) < 129000 then
               Count := Count + 1;
         end if;
         Next (Diff_Curs);
      end loop;
      Put_Line ("Low count: " & Integer'Image (Count));

   end Low_Count;

   procedure Low_Spacing (Syncs_Diff : Sync_Data_List;
                           Diff_Indices : Index_List) is
      use Process_Data;
      use Index_Data_Package;
      Diff_Curs : Cursor := Diff_Indices.First;
      Indices : Index_List;
   begin
      Indices := Where_Less (Syncs_Diff, 129000);
      --  Diff_Indices_Alice := Diff_Indices (Diff_Indices);
      Put ("[array([");
      --  for index in Diff_Indices_Res'Range loop
      while Has_Element (Diff_Curs) loop
            Put (Index_Data_Package.Extended_Index'Image
            (To_Index (Diff_Curs)));
         if Diff_Curs /= Diff_Indices.Last then
            Put (", ");
         end if;
         Next (Diff_Curs);
      end loop;

      Ada.Text_IO.Put_Line ("], dtype=int64)]");

   end Low_Spacing;

   procedure Low_Values (Syncs, Syncs_Diff : Sync_Data_List) is
      use Sync_Data_Package;
      Syncs_Curs : Cursor := Syncs.First;
      Diff_Curs  : Cursor := Syncs_Diff.First;
      First      : Boolean := True;
   begin
      Put ("[");
   --  declare
   --     First : Boolean := True;
   --  begin
   --     for index in Syncs_Diff_Alice'Range loop
   --        if Syncs_Diff_Alice (index) < 129000 then
   --           if not First then
   --              Put (" ");
   --           end if;
   --           Put (Syncs_Diff_Alice (index)'Image);
   --           First := False;
   --        end if;
   --     end loop;
   --  end;

   while Has_Element (Diff_Curs) loop
      if Element (Diff_Curs) < 129000  then
         if not First then
               Put (", ");
         end if;

         Put (Sync_Data_Package.Extended_Index'Image
         (To_Index (Syncs_Diff_Curs)));
         First := False;
      end if;

      Next (Diff_Curs);
      end loop;

      Put_Line ("]");

    end Low_Values;

end Analysis;