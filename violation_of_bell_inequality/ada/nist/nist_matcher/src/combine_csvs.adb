
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

with Combine_Data; use Combine_Data;
with Printing; use Printing;
with Types; use Types;

with Utils; use Utils;

package body Combine_CSVs is

   procedure Combine
     (OEM_aa, OEM_ab, OEM_ba, OEM_bb,
      Combined_CSV : String; Test_Rows : Natural := 0) is
      Routine_Name  : constant String := "Combine_CSVs.Combine ";
      OEM_aa_Length : constant Positive := Count_Text_File_Lines (OEM_aa);
      OEM_ab_Length : constant Positive := Count_Text_File_Lines (OEM_ab);
      OEM_ba_Length : constant Positive := Count_Text_File_Lines (OEM_ba);
      OEM_bb_Length : constant Positive := Count_Text_File_Lines (OEM_bb);
      Header        : constant String := "Aa,Ba,Aa,Bb,Ab,Ba,Ab,Bb";
      Min_Rows      : Natural := OEM_aa_Length;
      aRow          : String_23 := (others => '#');
   begin
      --  Set stack size:  ulimit -s 64000
      --  Original photon data is sorted ascendingly
      Put_Line (Routine_Name & "OEM_aa length:" &
                  Integer'Image (OEM_aa_Length));
      Put_Line (Routine_Name & "OEM_ab length:" &
                  Integer'Image (OEM_ab_Length));
      Put_Line (Routine_Name & "OEM_ba length:" &
                  Integer'Image (OEM_ba_Length));
      Put_Line (Routine_Name & "OEM_bb length:" &
                  Integer'Image (OEM_bb_Length));

      if OEM_ab_Length < Min_Rows then
         Min_Rows := OEM_ab_Length;
      end if;
      if OEM_ba_Length < Min_Rows then
         Min_Rows := OEM_ba_Length;
      end if;
      if OEM_bb_Length < Min_Rows then
         Min_Rows := OEM_bb_Length;
      end if;
      if Test_Rows > 0 and then Min_Rows > Test_Rows then
         Min_Rows := Test_Rows;
      end if;

      if Min_Rows < 2 then
         Min_Rows := 1;
         Put_Line  (Routine_Name & "A data file is empty");
      end if;

      Min_Rows := Min_Rows - 1;  --  Exclude header
      --  Put_Line  (Routine_Name & "Test_Rows: " & Integer'Image (Test_Rows));
      --  Put_Line  (Routine_Name & "Min_Rows: " & Integer'Image (Min_Rows));

      declare
         aa_Data  : String8_Array (1 .. Min_Rows);
         ab_Data  : String8_Array (1 .. Min_Rows);
         ba_Data  : String8_Array (1 .. Min_Rows);
         bb_Data  : String8_Array (1 .. Min_Rows);
         Combined : String23_Array (1 .. Min_Rows + 1) :=
           (others => (others => '#'));
      begin
         Combined (1) := Header;
         --  Data array doesn't include header.
         Load_Data (OEM_aa, aa_Data);
         Load_Data (OEM_ab, ab_Data);
         Load_Data (OEM_ba, ba_Data);
         Load_Data (OEM_bb, bb_Data);

         for row in 1 .. Min_Rows  loop
            aRow (1 .. 5) := aa_Data (row) (1 .. 5);
            aRow (6 .. 6) := ",";
            aRow (7 .. 11) := ab_Data (row) (1 .. 5);
            aRow (12 .. 12) := ",";
            aRow (13 .. 17) := ba_Data (row) (1 .. 5);
            aRow (18 .. 18) := ",";
            aRow (19 .. 23) := bb_Data (row) (1 .. 5);
            Combined (row + 1) := aRow;
         end loop;

         if Min_Rows > 4 then
            Print_String23_Array
              (Routine_Name & "Combined", Combined, Min_Rows - 4, Min_Rows - 1);
         else
            Print_String23_Array (Routine_Name & "Combined", Combined);
         end if;

         Save_Data (Combined_CSV, Combined);
      end;  -- declare block
      Put_Line
        (Routine_Name & "Combined_CSV length: " &
           Integer'Image (Count_Text_File_Lines (Combined_CSV)) & " lines");

   exception
      when Error : others =>
         Put_Line (Routine_Name & "Exception information:  " &
                     Exception_Information (Error));

   end Combine;

end Combine_CSVs;
