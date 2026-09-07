
with Nist_Types; use Nist_Types;

package Analysis is

   procedure High_Count (Syncs_Diff : Sync_Data_List);
   procedure Low_Count (Syncs_Diff : Sync_Data_List);
   procedure Low_Spacing (Syncs_Diff : Sync_Data_List;
                           Diff_Indices : Index_List);
   procedure Low_Values (Syncs, Syncs_Diff : Sync_Data_List);
   procedure High_Values (Syncs, Syncs_Diff : Sync_Data_List);

end Analysis;