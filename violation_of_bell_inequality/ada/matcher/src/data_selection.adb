
--  with Ada.Directories; use Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Direct_IO;
with Ada.Text_IO; use Ada.Text_IO;

with Utils; use Utils;

package body Data_Selection is

   --  Direct_IO line includes line terminator; hence process string_4 as String_5.
   package Direct_String_5 is new Ada.Direct_IO (String_5);

   procedure Print_W_Record (Message : String; Data : W_Record);

   procedure Count_xx (Counts : in out xxCounts; aline : String) is
      Item : constant String_4 := aline (aline'First .. aline'First + 3);
   begin
      if Item (1) = 'a' and then Item (3 .. 4) = "+1" then
         Counts.av_Count := Counts.av_Count + 1;
      elsif Item (1) = 'a' and then Item (3 .. 4) = "-1" then
         Counts.ah_Count := Counts.ah_Count + 1;
      elsif Item (1) = 'b' and then Item (3 .. 4) = "+1" then
         Counts.bv_Count := Counts.bv_Count + 1;
      elsif Item (1) = 'b' and then Item (3 .. 4) = "-1" then
         Counts.bh_Count := Counts.bh_Count + 1;
      end if;

   end Count_xx;

   procedure Print_xxCounts (Message : String; Data : xxCounts) is
   begin
      Put_Line (Message & ": ");
      Put ("av: " & Integer'Image (Data.av_Count));
      Put (",  ah: " & Integer'Image (Data.ah_Count));
      Put (",  bv: " & Integer'Image (Data.bv_Count));
      Put (",  bh: " & Integer'Image (Data.bh_Count));
      New_Line;

   end Print_xxCounts;

   procedure Print_W_Record (Message : String; Data : W_Record) is
   begin
      Put_Line (Message & ": ");
      Put_Line ("A_Setting: " & Data.A_Setting & ", A_Result: " & Data.A_Result);
      Put_Line ("B_Setting: " & Data.B_Setting & ", B_Result: " & Data.B_Result);
      Put_Line ("AB_Result: " & Data.AB_Result);

   end Print_W_Record;

   procedure Select_OEM_Data
   --  File Names
     (OEM_A, OEM_B, OEM_aa, OEM_ab,
      OEM_ba, OEM_bb    : String;
      A_Count, B_Count  : out xxCounts; Selected_Pairs : Match_List) is
      use Match_Package;
      use Direct_String_5;
      Routine_Name : constant String := "Data_Selection.Select_OEM_Data ";
      OEM_Header   : constant String := "A Det,B Det";
      A_Size       : constant Natural := Count_Text_File_Lines (OEM_A);
      B_Size       : constant Natural := Count_Text_File_Lines (OEM_B);
      OEM_A_ID     : Direct_String_5.File_Type;
      OEM_B_ID     : Direct_String_5.File_Type;
      OEM_aa_ID    : Ada.Text_IO.File_Type;
      OEM_ab_ID    : Ada.Text_IO.File_Type;
      OEM_ba_ID    : Ada.Text_IO.File_Type;
      OEM_bb_ID    : Ada.Text_IO.File_Type;
      OEM_A_Line   : String_5;
      OEM_B_Line   : String_5;
      Indices      : Index_Record;
      W_Item       : W_Record;
      Num_aa       : Natural := 0;
      Num_ab       : Natural := 0;
      Num_ba       : Natural := 0;
      Num_bb       : Natural := 0;
      Curs         : Cursor := Selected_Pairs.First;
      Item         : Index_Record;
      W            : W_List;
      Count        : Natural := 0;
      Bad_aa       : Natural := 0;

      procedure Write_Data (File : Ada.Text_IO.File_Type) is
      begin
         W_Item.A_Result := OEM_A_Line (3 .. 4);
         W_Item.B_Result := OEM_B_Line (3 .. 4);
         W_Item.AB_Result := Integer'Image
           (Integer'Value (W_Item.A_Result) * Integer'Value (W_Item.B_Result));
         if W_Item.AB_Result = " 1" then
            W_Item.AB_Result := "+1";
         end if;
         Put_Line (File, W_Item.A_Result & "," & W_Item.B_Result & "," &
                     W_Item.AB_Result);

      end Write_Data;

   begin
      Put_Line (Routine_Name & "A and B file lengths: " &
                  Natural'Image (A_Size) & ", " & Natural'Image (B_Size) &
                  "  lines");
      Open (OEM_A_ID, In_File, OEM_A);
      Open (OEM_B_ID, In_File, OEM_B);

      Create (OEM_aa_ID, Out_File, OEM_aa);
      Create (OEM_ab_ID, Out_File, OEM_ab);
      Create (OEM_ba_ID, Out_File, OEM_ba);
      Create (OEM_bb_ID, Out_File, OEM_bb);

      Put_Line (OEM_aa_ID, OEM_Header);
      Put_Line (OEM_ab_ID, OEM_Header);
      Put_Line (OEM_ba_ID, OEM_Header);
      Put_Line (OEM_bb_ID, OEM_Header);
      Put_Line (Routine_Name & "Selected_Pairs length " &
                  integer'Image
                  (integer (Match_Package.Length (Selected_Pairs))));

      --  Process Selected_Pairs
      while Has_Element (Curs) loop
         item := Element (Curs);
         Count := Count + 1;
         Indices := Item;
         Read (OEM_A_ID, OEM_A_Line, Direct_String_5.Positive_Count (item.A_Index));
         Read (OEM_B_ID, OEM_B_Line, Direct_String_5.Positive_Count (item.B_Index));

         Count_xx (A_Count, OEM_A_Line);
         Count_xx (B_Count, OEM_B_Line);

         if OEM_A_Line (1) = 'a' and then OEM_B_Line (1) = 'a' then
            Num_aa := Num_aa + 1;
            W_Item.A_Setting := 'a';
            W_Item.B_Setting := 'a';
            Write_Data (OEM_aa_ID);
            if W_Item.A_Result = W_Item.B_Result then
               Bad_aa := Bad_aa + 1;
            end if;
         elsif OEM_A_Line (1) = 'a' and then OEM_B_Line (1) = 'b' then
            Num_ab := Num_ab + 1;
            W_Item.A_Setting := 'a';
            W_Item.B_Setting := 'b';
            Write_Data (OEM_ab_ID);
         elsif OEM_A_Line (1) = 'b' and then OEM_B_Line (1) = 'a' then
            Num_ba := Num_ba + 1;
            W_Item.A_Setting := 'b';
            W_Item.B_Setting := 'a';
            Write_Data (OEM_ba_ID);
         elsif OEM_A_Line (1) = 'b' and then OEM_B_Line (1) = 'b' then
            Num_bb := Num_bb + 1;
            W_Item.A_Setting := 'b';
            W_Item.B_Setting := 'b';
            Write_Data (OEM_bb_ID);
         else
            Put_Line (Routine_Name & "Invalid data:");
            Put ("OEM_A index: '" & Double_Positive'Image (item.A_Index));
            Put_Line (" OEM_A_Line: '" & OEM_A_Line & "'");
            Put ("OEM_B index: '" & Double_Positive'Image (item.B_Index));
            Put_Line (" OEM_B_Line: '" & OEM_B_Line & "'");
         end if;
         W.Append (W_Item);
         Curs := Next (Curs);
      end loop;

      Close (OEM_A_ID);
      Close (OEM_B_ID);
      Close (OEM_aa_ID);
      Close (OEM_ab_ID);
      Close (OEM_ba_ID);
      Close (OEM_bb_ID);

      Put_Line (Routine_Name & "OEM_aa length: " &
                  Integer'Image (Count_Text_File_Lines (OEM_aa)));
      Put_Line (Routine_Name & "**** bad aa Count:"  & Integer'Image (Bad_aa));

      Put_Line (Routine_Name & "Number of coincident aa detections: " &
                  Integer'Image (Num_aa));
      Put_Line (Routine_Name & "Number of coincident ab detections: " &
                  Integer'Image (Num_ab));
      Put_Line (Routine_Name & "Number of coincident ba detections: " &
                  Integer'Image (Num_ba));
      Put_Line (Routine_Name & "Number of coincident bb detections: " &
                  Integer'Image (Num_bb));

      Put_Line (Routine_Name & "W length: " &
                  Integer'Image (Integer (W.Length)));
      Put_Line ("OEM selected data files written to:");
      Put_Line (OEM_aa);
      Put_Line (OEM_ab);
      Put_Line (OEM_ba);
      Put_Line (OEM_bb);
      New_Line;

   exception
      when Error : others =>
         Close (OEM_A_ID);
         Close (OEM_B_ID);
         New_Line;
         Put_Line ("Exception raised in " & Routine_Name);
         Put_Line (Exception_Name (Error) & ":   " & Exception_Message (Error));
         raise;

   end Select_OEM_Data;

end Data_Selection;
