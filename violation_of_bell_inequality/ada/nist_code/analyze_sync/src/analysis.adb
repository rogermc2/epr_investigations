
with Ada.Text_IO; use Ada.Text_IO;

package body Analysis is

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