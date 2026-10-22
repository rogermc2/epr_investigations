
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

with Delft_Utils;
with Types; use Types;

package body Process_Data is

   type Field_Array is array (1 .. 17) of Natural;

   function Parse_Line (Line : String;  Field_Values : out Field_Array)
      return Boolean;

   procedure Get_Data (Source_File : String; Target : out Delft_Data_List) is
      Routine_Name : constant String := "Process_Data.Get_Data ";
      Source_ID    : File_Type;
      Line_Num     : Natural := 0;
      Field_Values : Field_Array := (others => 0);
      Raw_Data     : Raw_Result_Record;
   begin
      Put_Line (Routine_Name & "Source File: " & Source_File);
      New_Line;
      Open (Source_ID, In_File, Source_File);

      while not End_Of_File (Source_ID) loop
         Line_Num := Line_Num + 1;
         declare
            aline : constant String := Get_Line (Source_ID);
         begin
            --  if Parse_Line (aline, Raw_Data) then
            if Parse_Line (aline, Field_Values) then
               Raw_Data.A_Setting := Field_Values (6);
               Raw_Data.B_Setting := Field_Values (7);
               Raw_Data.A_Outcome := Field_Values (10);
               Raw_Data.B_Outcome := Field_Values (11);
               Target.Append (Raw_Data);
            end if;
         end;
      end loop;

      Close (Source_ID);

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));

   end Get_Data;

   function Parse_Line (Line : String; Field_Values : out Field_Array)
      return Boolean is
      use Delft_Utils;  --  for Trim_Both
      Routine_Name : constant String := "Process_Data.Parse_Line ";
      Pos_1        : Integer := 1;
      Pos_2        : Integer := Pos_1;
      Herald_Flag  : Boolean;
   begin
      Field_Values := (others => 0);
      --  Skip first field (datetime)
      while Line (Pos_2) /= ',' loop
         Pos_2 := Pos_2 + 1;
      end loop;
      Pos_2 := Pos_2 + 1; --  skip comma
      Pos_1 := Pos_2; 

      for Field_Index in 1 ..16 loop
         --  Find next comma
         while Pos_2 < Line'Last and then Line (Pos_2) /= ',' loop
            Pos_2 := Pos_2 + 1;
         end loop;
         --  Put_Line (Routine_Name & "Pos_1, Pos_2: " & Integer'Image (Pos_1) &
         --   Integer'Image (Pos_2));
         --  Put_Line (Routine_Name & "Field: " & Line (Pos_1 .. Pos_2 - 1));
         --  Get integer between Pos_1 and Pos_2 - 1, Pos_2 is comma
         Field_Values (Field_Index) := Integer'Value (Line (Pos_1 .. Pos_2 - 1));
         Pos_2 := Pos_2 + 1;
         Pos_1 := Pos_2;
      end loop;

      Herald_Flag := Field_Values (2) = 6 and then Field_Values (9) = 1;

      return Herald_Flag;

   exception
      when Error : others =>
         New_Line;
         Put_Line ("Exception raised in " & Routine_Name);
         Put_Line (Exception_Name (Error) & ":   " & Exception_Message (Error));
         raise;
         return False;

   end Parse_Line;

   procedure Save_Data (aa, ab, ba, bb : String; Data : Delft_Data_List) is
      use Delft_Data_Package;
      Routine_Name : constant String := "Process_Data.Save_Data ";
      Header       : constant String := "A, B";
      aa_ID        : Ada.Text_IO.File_Type;
      ab_ID        : Ada.Text_IO.File_Type;
      ba_ID        : Ada.Text_IO.File_Type;
      bb_ID        : Ada.Text_IO.File_Type;
      W_Item       : W_Record;
      Num_aa       : Natural := 0;
      Num_ab       : Natural := 0;
      Num_ba       : Natural := 0;
      Num_bb       : Natural := 0;
      Curs         : Cursor := Data.First;
      Item         : Raw_Result_Record;
      Count        : Natural := 0;

      procedure Write_Data (File : Ada.Text_IO.File_Type) is
      begin
         if W_Item.A_Result = " 0" then
            W_Item.A_Result := "-1";
         end if;
         if W_Item.B_Result = " 0" then
            W_Item.B_Result := "-1";
         end if;

         Put_Line (File, W_Item.A_Result & "," & W_Item.B_Result);

      end Write_Data;

   begin
      Create (aa_ID, Out_File, aa);
      Create (ab_ID, Out_File, ab);
      Create (ba_ID, Out_File, ba);
      Create (bb_ID, Out_File, bb);

      Put_Line (aa_ID, Header);
      Put_Line (ab_ID, Header);
      Put_Line (ba_ID, Header);
      Put_Line (bb_ID, Header);

      while Has_Element (Curs) loop
         item := Element (Curs);
         Count := Count + 1;
         W_Item.A_Result := UV'Image (item.A_Outcome);
         W_Item.B_Result := UV'Image (item.B_Outcome);
         W_Item.AB_Result := UV'Image (item.A_Outcome * item.B_Outcome);
         if item.A_Setting = 0 and then item.B_Setting = 0 then
            Num_aa := Num_aa + 1;
            W_Item.A_Setting := 'a';
            W_Item.B_Setting := 'a';
            Write_Data (aa_ID);
         elsif item.A_Setting = 0 and then item.B_Setting = 1 then
            Num_ab := Num_ab + 1;
            W_Item.A_Setting := 'a';
            W_Item.B_Setting := 'b';
            Write_Data (ab_ID);
         elsif item.A_Setting = 1 and then item.B_Setting = 0 then
            Num_ba := Num_ba + 1;
            W_Item.A_Setting := 'b';
            W_Item.B_Setting := 'a';
            Write_Data (ba_ID);
         elsif item.A_Setting = 1 and then item.B_Setting = 1 then
            Num_bb := Num_bb + 1;
            W_Item.A_Setting := 'b';
            W_Item.B_Setting := 'b';
            Write_Data (bb_ID);
         else
            Put_Line (Routine_Name & "Invalid data:");
         end if;
         Curs := Next (Curs);
      end loop;

      Close (aa_ID);
      Close (ab_ID);
      Close (ba_ID);
      Close (bb_ID);

      Put_Line (Routine_Name & "Number of coincident aa detections: " &
                  Integer'Image (Num_aa));
      Put_Line (Routine_Name & "Number of coincident ab detections: " &
                  Integer'Image (Num_ab));
      Put_Line (Routine_Name & "Number of coincident ba detections: " &
                  Integer'Image (Num_ba));
      Put_Line (Routine_Name & "Number of coincident bb detections: " &
                  Integer'Image (Num_bb));

      Put_Line ("Selected data files written to:");
      Put_Line (aa);
      Put_Line (ab);
      Put_Line (ba);
      Put_Line (bb);
      New_Line;

   exception
      when Error : others =>
         New_Line;
         Put_Line ("Exception raised in " & Routine_Name);
         Put_Line (Exception_Name (Error) & ":   " & Exception_Message (Error));
         raise;

   end Save_Data;

end Process_Data;
