
with Ada.Numerics;
with Ada.Text_IO; use Ada.Text_IO;

with Printing; use Printing;

package body Process_Data is

   function Sample_Val (Result : Character) return UV;

   function Check
     (OEM_ID                  : File_Type; Eq : Boolean;
      True_Count, False_Count : out Natural) return Sample_Data_List is
      A_Result         : Character;
      B_Result         : Character;
      Sample           : Sample_Data_Record;
      Valid_Detections : Sample_Data_List;
   begin
      False_Count := 0;
      True_Count := 0;
      while not End_Of_File (OEM_ID) loop
         declare
            aLine : constant String := Get_Line (OEM_ID);
         begin
            A_Result := aLine (1);
            B_Result := aLine (3);
         end;

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

   function Statistical_EAB (theta : Float) return Float is
      use Ada.Numerics;
   begin
      return 2.0 * theta / Pi - 1.0;
   end Statistical_EAB;

   function False_Positives
    (Dir, OEM_File : String;  False_Count, True_Count : out Natural)
      return Sample_Data_List is
      Routine_Name     : constant String := "Process_Data.False_Positives ";
      OEM_ID           : File_Type;
      Valid_Detections : Sample_Data_List;
   begin
      Open (OEM_ID, In_File, OEM_File);
      if OEM_File = Dir & "aa.csv" then
         Valid_Detections := Check (OEM_ID, True, False_Count, True_Count);
      elsif OEM_File = Dir &  "ab.csv" then
         Valid_Detections := Check (OEM_ID, False, False_Count, True_Count);
      elsif OEM_File  = Dir &  "ba.csv" then
         Valid_Detections := Check (OEM_ID, False, False_Count, True_Count);
      elsif OEM_File = Dir &  "bb.csv" then
         Valid_Detections := Check (OEM_ID, True, False_Count, True_Count);
      else
         Put_Line (Routine_Name & "invalid file: " & OEM_File);
      end if;

      Close (OEM_ID);

      return Valid_Detections;

   end False_Positives;

   function Get_Detections (Detection_Data : String)
      return Sample_Data_List is
      Routine_Name : constant String := "Process_Data.Get_Detections ";
      Data_ID      : File_Type;
      A_Result     : Character;
      B_Result     : Character;
      Sample       : Sample_Data_Record;
      Detections   : Sample_Data_List;
   begin
      Open (Data_ID, In_File, Detection_Data);
      while not End_Of_File (Data_ID) loop
         declare
            aLine : constant String := Get_Line (Data_ID);
         begin
            A_Result := aLine (1);
            B_Result := aLine (3);
         end;
         Sample.A_Detection := Sample_Val (A_Result);
         Sample.B_Detection := Sample_Val (B_Result);
         Sample.AB := Sample.A_Detection * Sample.B_Detection;
         Detections.Append (Sample);
      end loop;
      Close (Data_ID);

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
      Print_Sample_Data_List ("Sample_Means, Data", Data, 1, 5);
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

   function Sample_Val (Result : Character) return UV is
      Val : UV;
   begin
      if Result = '+' then
         Val := 1;
      elsif Result = '0' then
         Val := -1;
      else
         Put_Line ("Process_Data.Sample_Val, invalid data: " & Result);
      end if;

      return Val;

   end Sample_Val;

end Process_Data;
