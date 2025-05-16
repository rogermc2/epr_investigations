
with Ada.Direct_IO;
with Ada.Text_IO; use Ada.Text_IO;

package body Data_Selection is

   package Natural_IO is new Ada.Direct_IO (Natural);

   procedure Select_OEM_Data (Selected_Pairs : Match_List; OEM_A, OEM_B : String;
                              OEM_00, OEM_01, OEM_10, OEM_11 : out String) is
      use Natural_IO;
      use Match_Package;
      --  Routine_Name : constant String := "Data_Selection.Select_OEM_Data ";
      OEM_A_ID   : Natural_IO.File_Type;
      OEM_B_ID   : Natural_IO.File_Type;
      OEM_00_ID  : Ada.Text_IO.File_Type;
      OEM_01_ID  : Ada.Text_IO.File_Type;
      OEM_10_ID  : Ada.Text_IO.File_Type;
      OEM_11_ID  : Ada.Text_IO.File_Type;
      OEM_A_Line : String_3;
      OEM_B_Line : String_3;
      Indices    : Data_Record;
      A_Index    : Natural_IO.Positive_Count;
      B_Index    : Natural_IO.Positive_Count;
   begin
      Open (OEM_A_ID, In_File, OEM_A);
      Open (OEM_B_ID, In_File, OEM_B);
      Create (OEM_00_ID, Out_File, OEM_00);
      Create (OEM_01_ID, Out_File, OEM_01);
      Create (OEM_10_ID, Out_File, OEM_10);
      Create (OEM_11_ID, Out_File, OEM_11);

      for item of Selected_Pairs loop
         Indices := item;
         A_Index :=  Natural_IO.Positive_Count (item.A_Index);
         B_Index :=  Natural_IO.Positive_Count (item.B_Index);
         Set_Index (OEM_A_ID, To => A_Index);
         Set_Index (OEM_B_ID, To => B_Index);
         OEM_A_Line := Get_Line;
         OEM_B_Line := Get_Line;
         if OEM_A_Line (1) = '0' and then OEM_B_Line (1) = '0' then
            Put_Line (OEM_00_ID, OEM_A_Line (2) & OEM_B_Line (2));
         end if;
      end loop;

      Close (OEM_A_ID);
      Close (OEM_B_ID);
      Close (OEM_00_ID);
      Close (OEM_01_ID);
      Close (OEM_10_ID);
      Close (OEM_11_ID);

   end Select_OEM_Data;

end Data_Selection;
