
with Types; use Types;

package Data_Selection is

   type xxCounts is record
      av_Count    : Natural := 0;
      ah_Count    : Natural := 0;
      bv_Count    : Natural := 0;
      bh_Count    : Natural := 0;
   end record;

   procedure Print_xxCounts (Message : String; Data : xxCounts);
   procedure Select_OEM_Data
     (OEM_A, OEM_B, OEM_aa, OEM_ab, OEM_ba, OEM_bb : String;
      A_Count, B_Count : out xxCounts; Selected_Pairs : Match_List);

end Data_Selection;
