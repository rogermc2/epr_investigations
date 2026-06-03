
with Ada.Numerics;
with Ada.Strings;
with Ada.Strings.Fixed;
with Ada.Strings.Maps;
with Ada.Text_IO; use Ada.Text_IO;

package body Process_Data is

   function Sample_Val (Result : String_2) return UV;

   function Check
     (OEM_ID                  : File_Type; Eq  : Boolean;
      True_Count, False_Count : out Natural) return Sample_Data_List is
      aLine            : String_8;
      A_Result         : String_2;
      B_Result         : String_2;
      Sample           : Sample_Data_Record;
      Valid_Detections : Sample_Data_List;
   begin
      False_Count := 0;
      True_Count := 0;
      while not End_Of_File (OEM_ID) loop
         aLine := Get_Line (OEM_ID);
         A_Result := aLine (1 .. 2);
         B_Result := aLine (4 .. 5);
         if Eq then
            if A_Result = B_Result then
               True_Count := True_Count + 1;
               Sample.A_Detection := Sample_Val (A_Result);
               Sample.B_Detection := Sample_Val (B_Result);
               Sample.AB := Sample.A_Detection * Sample.B_Detection;
               Valid_Detections.Append (Sample);
            else
               False_Count := False_Count + 1;
            end if;
         else  -- not Eq
            if A_Result /= B_Result then
               True_Count := True_Count + 1;
               Sample.A_Detection := Sample_Val (A_Result);
               Sample.B_Detection := Sample_Val (B_Result);
               Sample.AB := Sample.A_Detection * Sample.B_Detection;
               Valid_Detections.Append (Sample);
            else
               False_Count := False_Count + 1;
            end if;
         end if;
      end loop;

      return Valid_Detections;

   end Check;

   function EAB (theta : Float) return Float is
      use Ada.Numerics;
   begin
      return 2.0 * theta / Pi - 1.0;
   end EAB;

   function False_Positives (OEM_File : String;  False_Count : out Natural)
                             return Sample_Data_List is
      use Ada.Strings;
      use Ada.Strings.Fixed;
      use Ada.Strings.Maps;
      Routine_Name     : constant String := "Process_Data.False_Positives ";
      OEM_ID           : File_Type;
      First            : Positive;
      Last             : Natural;
      Header           : String_11;
      True_Count       : Natural;
      Valid_Detections : Sample_Data_List;
   begin
      Open (OEM_ID, In_File, OEM_File);
      Header := Get_Line (OEM_ID);  --  Header
      Find_Token (OEM_File, To_Set ("OEM"), Inside, First, Last);
      if OEM_File (Last + 2 .. Last + 3) = "aa" then
         Valid_Detections := Check (OEM_ID, True, False_Count, True_Count);
      elsif OEM_File (Last + 2 .. Last + 3) = "ab" then
         Valid_Detections := Check (OEM_ID, False, False_Count, True_Count);
      elsif OEM_File (Last + 2 .. Last + 3) = "ba" then
         Valid_Detections := Check (OEM_ID, False, False_Count, True_Count);
      elsif OEM_File (Last + 2 .. Last + 3) = "bb" then
         Valid_Detections := Check (OEM_ID, True, False_Count, True_Count);
      else
         Put_Line (Routine_Name & "invalid file: " & OEM_File);
      end if;

      Close (OEM_ID);

      return Valid_Detections;

   end False_Positives;

   function Get_Detections (OEM, a_File, b_File : String) return Sample_Data_List is
      OEM_ID     : File_Type;
      a_ID       : File_Type;
      b_ID       : File_Type;
      Header     : String_11;
      aLine      : String_8;
      A_Result   : String_2;
      B_Result   : String_2;
      Sample     : Sample_Data_Record;
      Detections : Sample_Data_List;
   begin
      Open (OEM_ID, In_File, OEM);
      Create (a_ID, Out_File, a_File);
      Create (b_ID, Out_File, b_File);
      Header := Get_Line (OEM_ID);  --  Header

      while not End_Of_File (OEM_ID) loop
         aLine := Get_Line (OEM_ID);
         A_Result := aLine (1 .. 2);
         B_Result := aLine (4 .. 5);
         Put_Line (a_ID, A_Result);
         Put_Line (b_ID, B_Result);
         Sample.A_Detection := Sample_Val (A_Result);
         Sample.B_Detection := Sample_Val (B_Result);
         Sample.AB := Sample.A_Detection * Sample.B_Detection;
         Detections.Append (Sample);
      end loop;
      Close (OEM_ID);
      Close (a_ID);
      Close (b_ID);

      return Detections;

   end Get_Detections;

   procedure Sample_Means (Data                    : Sample_Data_List;
                           Mean_A, Mean_B, Mean_AB : out Float) is
      use Sample_Data_Package;
      A      : UV;
      B      : UV;
      Sum_A  : Integer := 0;
      Sum_B  : Integer := 0;
      Sum_AB : Integer := 0;
      Count  : Natural := 0;
      Curs   : Cursor := Data.First;
      Item   : Sample_Data_Record;
   begin
      while Has_Element (Curs) loop
         Item := Element (Curs);
         Count := Count + 1;
         A := Item.A_Detection;
         B := Item.B_Detection;
         Sum_A := Sum_A + A;
         Sum_B := Sum_B + B;
         Sum_AB := Sum_AB + A * B;
         Curs := Next (Curs);
      end loop;

      Mean_A := Float (Sum_A) / Float (Count);
      Mean_B := Float (Sum_B) / Float (Count);
      Mean_AB := Float (Sum_AB) / Float (Count);

   end Sample_Means;

   function Sample_Val (Result : String_2) return UV is
      Val : UV;
   begin
      if Result = "+1" then
         Val := 1;
      elsif Result = "-1" then
         Val := -1;
      else
         Put_Line ("Process_Data.Sample_Val, invalid data: " & Result);
      end if;

      return Val;

   end Sample_Val;

end Process_Data;
