
with Ada.Text_IO; use Ada.Text_IO;

package body Data_Selection is

   procedure Select_OEM_Data (OEM_A, OEM_B, Selected_OEM : String;
                              Selected_Indices           : Match_List) is
      use Match_Package;
      --  Routine_Name : constant String := "Data_Selection.Select_OEM_Data ";
      OEM_A_ID   : File_Type;
      OEM_B_ID   : File_Type;
      Select_ID  : File_Type;
      A_Line     : String_3;
      B_Line     : String_3;
      Indices    : Data_Record;
   begin
      Open (OEM_A_ID, In_File, OEM_A);
      Open (OEM_B_ID, In_File, OEM_B);
      Create (Select_ID, Out_File, Selected_OEM);

      for item of Selected_Indices loop
         Indices := item;
         A_Line := Get_Line (OEM_A_ID);
         B_Line := Get_Line (OEM_B_ID);
      end loop;

      Close (OEM_A_ID);
      Close (OEM_B_ID);
      Close (Select_ID);

   end Select_OEM_Data;

end Data_Selection;
