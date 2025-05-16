
with Types; use Types;

package Data_Selection is

   procedure Select_OEM_Data (Selected_Pairs : Match_List; OEM_A, OEM_B : String;
                              OEM_00, OEM_01, OEM_10, OEM_11 : out String);

    end Data_Selection;
