
with Ada.Exceptions; use Ada.Exceptions;

with Ada.Strings;
with Ada.Strings.Fixed;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;

--  with Printing; use Printing;
with Utilities;

package body Data_Catagorization is

   function Catagorize
     (File_A, File_B : String; Settings : Settings_Vector)
      return Unbounded_String_Vector is
      use Ada.Strings;
      use Ada.Strings.Fixed;
      use Utilities;
      use MilliRad_Map_Package;
      use Result_Vector_Package;
      use Settings_Vector_Package;
      use Unbounded_String_Package;
      Routine_Name   : constant String :=
        "Data_Catagorization.Catagorize ";
      Raw_A          : constant Result_Vector :=
        Load_Station_Results (File_A);
      Raw_B          : constant Result_Vector :=
        Load_Station_Results (File_B);
      Num_Settings   : constant Positive := Positive (Length (Settings));
      Files          : File_Array (1 .. 2 * Num_Settings + 1);
      Curs_A         : Result_Vector_Package.Cursor := Raw_A.First;
      Curs_B         : Result_Vector_Package.Cursor := Raw_B.First;
      Curs_S_Outer   : Settings_Vector_Package.Cursor := Settings.First;
      Curs_S_Inner   : Settings_Vector_Package.Cursor := Settings.First;
      Item_A         : Result_Data;
      Item_B         : Result_Data;
      A_Index        : MilliRad;
      B_Index        : MilliRad;
      Key            : Setting_Map_Record;
      Settings_Map   : MilliRad_Map;
      Settings_Index : Natural := 0;
      Count          : Natural := 0;
      Out_Name       : Unbounded_String;
      Out_File_Names : Unbounded_String_Vector;
   begin
      while Has_Element (Curs_S_Outer) loop
         Key.A := MilliRad (Element (Curs_S_Outer) * 1000.0);
         Curs_S_Inner := Settings.First;
         while Has_Element (Curs_S_Inner) loop
            Put_Line (Routine_Name & "Inner: " &
                        Float'Image (Element (Curs_S_Inner)));
            Key.B := MilliRad (Element (Curs_S_Inner) * 1000.0);
            Put_Line (Routine_Name & "Key.B set");
            if not Settings_Map.Contains (Key) then
               Settings_Index := Settings_Index + 1;
               Settings_Map.Include (Key, Settings_Index);
               Out_Name := To_Unbounded_String
                 ("data/" & Trim (Integer'Image (Key.A), Left) & "_" &
                    Trim (Integer'Image (Key.B), Left) &
                    "_Data.csv");
               Out_File_Names.Append (Out_Name);
               Create (Files (Settings_Index), Out_File, To_String (Out_Name));
            end if;
            Next (Curs_S_Inner);
         end loop;
         Next (Curs_S_Outer);
      end loop;

      --  Print_Result_Vector ("Raw_A", Raw_A, 10, 20);
      --  Print_Result_Vector ("Raw_B", Raw_B, 10, 20);
      while Has_Element (Curs_A) and then Has_Element (Curs_B) loop
         Count := Count + 1;
         Item_A := Element (Curs_A);
         Item_B := Element (Curs_B);
         A_Index := MilliRad (Item_A.Setting * 1000.0);
         B_Index := MilliRad (Item_B.Setting * 1000.0);
         Key := (A_Index, B_Index);
         Put_Line (Files (Settings_Map (Key)),
                   (Integer'Image (Item_A.Outcome) & "," &
                      Integer'Image (Item_B.Outcome)));
         Next (Curs_A);
         Next (Curs_B);
      end loop;
      New_Line;

      for index in Files'Range loop
         Close (Files (index));
      end loop;

      Put_Line ("Catagorization complete.");

      return Out_File_Names;

   exception
      when Error : others =>
         Put_Line (Routine_Name & "Exception information:  " &
                     Exception_Information (Error));
         raise;

   end Catagorize;

end Data_Catagorization;
