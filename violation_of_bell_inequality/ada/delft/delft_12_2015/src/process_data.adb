
with Ada.Exceptions; use Ada.Exceptions;
--  with Ada.Numerics; use Ada.Numerics;
with Ada.Text_IO; use Ada.Text_IO;

with Types; use Types;

package body Process_Data is

   type Field_Array is array (1 .. 17) of Natural;

   function Parse_Line (Line : String;  Field_Values : out Field_Array)
      return Boolean;
   procedure Process_Angles (Rnd_A, Rnd_B : Integer;
         A_Rad, B_Rad : out Angle_Kind);

   procedure  Add_Selected_Trial (aline : String;
       Target : in out Delft_Data_List) is
      --  Routine_Name : constant String := "Process_Data.Add_Selected_Trial ";
      Results      : Result_Record;
      Field_Values : Field_Array := (others => 0);
   begin
      if Parse_Line (aline, Field_Values) then
         Process_Angles (Field_Values (6), Field_Values (8),
            Results.A_Setting, Results.B_Setting);

         --  A readout click at time (ns), 0 if none
         if Field_Values (11) > 0 then
            Results.A_Outcome := 1;
         else
            Results.A_Outcome := -1;
         end if;
         --  B readout click at time (ns), 0 if none
         if Field_Values (12) > 0 then
            Results.B_Outcome := 1;
         else
            Results.B_Outcome := -1;
         end if;
         Target.Append (Results);
      end if;

   end Add_Selected_Trial;

   procedure Get_Data (Source_File, Settings_File : String;
    Target : out Delft_Data_List) is
      Routine_Name : constant String := "Process_Data.Get_Data ";
      Angles       : Angles_Record;
      Source_ID    : File_Type;
      Settings_ID  : File_Type;
      --  Line_Num     : Natural := 0;
   begin
      --  Put_Line (Routine_Name & "Source File: " & Source_File);

      Create (Settings_ID, Out_File, Settings_File);
      Put_Line (Settings_ID, Long_Float'Image (Angles.A_0));
      Put_Line (Settings_ID, Long_Float'Image (Angles.A_1));
      Put_Line (Settings_ID, Long_Float'Image (Angles.B_0));
      Put_Line (Settings_ID, Long_Float'Image (Angles.B_1));
      Close (Settings_ID);

      Open (Source_ID, In_File, Source_File);

      while not End_Of_File (Source_ID) loop
         --  Line_Num := Line_Num + 1;
         Add_Selected_Trial (Get_Line (Source_ID), Target);
      end loop;

      Close (Source_ID);   

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));

   end Get_Data;

   --  Parse_Line splits a comma-separated line and stores fields
   --  2..17 (file columns 1..16) in Values.
   --  The first field (datetime) is skipped, as it is not used in the analysis.
   function Parse_Line (Line : String; Field_Values : out Field_Array)
      return Boolean is
      Routine_Name : constant String := "Process_Data.Parse_Line ";
      Pos_1        : Integer := 1;
      Pos_2        : Integer := Pos_1;
      Herald_Flag  : Boolean;
   begin
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

         Field_Values (Field_Index) := Integer'Value (Line (Pos_1 .. Pos_2 - 1));
         Pos_2 := Pos_2 + 1;
         Pos_1 := Pos_2;
      end loop;

      Herald_Flag := Field_Values (2) = 6 and then Field_Values (4) > 0
                     and then Field_Values (5) > 0;

      return Herald_Flag;

   exception
      when Error : others =>
         New_Line;
         Put_Line ("Exception raised in " & Routine_Name);
         Put_Line (Exception_Name (Error) & ":   " & Exception_Message (Error));
         raise;
         return False;

   end Parse_Line;

   procedure Process_Angles (Rnd_A, Rnd_B : Integer;
         A_Rad, B_Rad : out Angle_Kind) is
      --  A_Angle_0  : constant Long_Float := 0.0;
      --  A_Angle_1  : constant Long_Float := Pi / 2.0;
      --  B_Angle_0  : constant Long_Float := Pi / 8.0;
      --  B_Angle_1  : constant Long_Float := (3.0 * Pi) / 8.0;
   begin
      if Rnd_A = 0 then
         A_Rad := A1;
      else
         A_Rad := A2;
      end if;

      if Rnd_B = 0 then
         B_Rad := B1;
      else
         B_Rad := B2;
      end if;

   end Process_Angles;

   procedure Save_Data (aa, ab, ba, bb : String; Data : Delft_Data_List) is
      use Delft_Data_Package;
      Routine_Name : constant String := "Process_Data.Save_Data ";
      Header       : constant String := "A, B";
      aa_ID        : File_Type;
      ab_ID        : File_Type;
      ba_ID        : File_Type;
      bb_ID        : File_Type;
      A_Result     : String_2;
      B_Result     : String_2;
      Num_aa       : Natural := 0;
      Num_ab       : Natural := 0;
      Num_ba       : Natural := 0;
      Num_bb       : Natural := 0;
      Curs         : Cursor := Data.First;
      Item         : Result_Record;
      Count        : Natural := 0;

      procedure Write_Data (File : Ada.Text_IO.File_Type) is
      begin
         if A_Result = " 0" then
            A_Result := "-1";
         end if;
         if B_Result = " 0" then
            B_Result := "-1";
         end if;

         --  Put_Line (Routine_Name & "Item A and B Settings: " &
         --     Angle_Kind'Image (Item.A_Setting) &
         --     Angle_Kind'Image (Item.B_Setting));

         Put_Line (File, A_Result & "," & B_Result);

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
         A_Result := UV'Image (item.A_Outcome);
         B_Result := UV'Image (item.B_Outcome);
         if item.A_Setting = A1 and then item.B_Setting = B1 then
            Num_aa := Num_aa + 1;
            Write_Data (aa_ID);
         elsif item.A_Setting = A1 and then item.B_Setting = B2 then
            Num_ab := Num_ab + 1;
            Write_Data (ab_ID);
         elsif item.A_Setting = A2 and then item.B_Setting = B1 then
            Num_ba := Num_ba + 1;
            Write_Data (ba_ID);
         elsif item.A_Setting = A2 and then item.B_Setting = B2 then
            Num_bb := Num_bb + 1;
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
