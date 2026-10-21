    
package body Delft_Utils is
    
    function Get_Delft_Integer_List
       (Data : Delft_Sample_Data_List; Selection : Detect_Type) return Integer_List is
      use Delft_Sample_Data_Package;
      Count   : Natural := 0;
      Curs    : Cursor := Data.First;
      Item    : Delft_Sample_Data_Record;
      theList : Integer_List;
   begin
      while Has_Element (Curs) loop
         Count := Count + 1;
         Item := Element (Curs);
         if Selection = Det_A then
            theList.Append (Item.A_Detection);
         elsif Selection = Det_B then
            theList.Append (Item.B_Detection);
         else  --  Selection = Det_Both
            theList.Append (Item.AB);
         end if;

         Curs := Next (Curs);
      end loop;

      return theList;
   end Get_Delft_Integer_List;

end Delft_Utils;