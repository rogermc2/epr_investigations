
with Delft_Types; use Delft_Types;

package Delft_Printing is

   procedure Print_Delft_Data_List (Name : String; Data : Delft_Data_List;
                               Start : Positive := 1; Finish : Natural := 0);

end Delft_Printing;