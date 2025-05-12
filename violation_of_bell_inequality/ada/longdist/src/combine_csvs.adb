
with Ada.Directories; use Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

with Combine_Data; use Combine_Data;
with Printing; use Printing;
with Types; use Types;

package body Combine_CSVs is

   procedure Add_Photon_Data
     (Data_CSV : String; Combined : in out String47_Array; A : Boolean;
      AB_Length    : Positive) is
      Data         : String20_Array (1 .. AB_Length);
      aRow         : String_47 := (others => '$');
      Item_Start   : Positive;
      Item_End     : Positive;
   begin
      if A then
         Item_Start := 1;
         Item_End := 19;
      else
         Item_Start := 21;
         Item_End := 39;
      end if;

      Load_Photon_Data (Data_CSV, Data);
      New_Line;

      for row in Combined'Range loop
         --  if row < 4 then
         --     Put_Line ("Add_Photon_Data.Data " & Integer'Image (row) &
         --               ":  " & String (Data (row)));
         --  end if;
         if not A then
            aRow := Combined (row);
         end if;
         aRow (Item_Start .. Item_End) := Data (row)(1 .. 19);
         aRow (Item_End + 1) := ',';
         Combined (row) := aRow;
      end loop;

   end Add_Photon_Data;

   procedure Combine (Photon_Data_A_CSV, Photon_Data_B_CSV,
                      OEM_Data_A_CSV, OEM_Data_B_CSV : String) is
      Routine_Name      : constant String := "Combine_CSVs.Combine ";
      Long_Dist_CSV     : constant String := "../Long_Dist.csv";

      Photon_A_Length   : constant Positive :=
        Positive (Size (Photon_Data_A_CSV));
      Photon_B_Length   : constant Positive :=
        Positive (Size (Photon_Data_B_CSV));
      Portion           : constant Positive := 8;
      OEM_A_Length      : constant Positive := Positive (Size (OEM_Data_A_CSV));
      OEM_B_Length      : constant Positive := Positive (Size (OEM_Data_B_CSV));
      Photon_AB_Length  : constant Positive :=
        Integer'Min (Photon_A_Length, Photon_B_Length) / Portion;
      OEM_AB_Length     : constant Positive :=
        Integer'Min (OEM_A_Length, OEM_B_Length) / Portion;
      Combined_Length   : constant Positive :=
        Integer'Min (Photon_AB_Length, OEM_AB_Length);
      --  Set photon array lengths to lesser of Photon A and B Lengths
      --  to prevent stack oveflow
      OEM_Data_A    : String4_Array (1 .. OEM_AB_Length);
      OEM_Data_B    : String4_Array (1 .. OEM_AB_Length);
      aRow          : String_47 := (others => '#');
      Combined      : String47_Array (1 .. Combined_Length) :=
      (others => (others => '#'));
   begin
      --  Set stack size:  ulimit -s 64000
      --  Original photon data is sorted ascendingly
      Put_Line ("Photon_Data_A length:" & Integer'Image (Photon_A_Length));
      Put_Line ("Photon_Data_B length:" & Integer'Image (Photon_B_Length));
      Put_Line ("OEM_Data_A length:" & Integer'Image (OEM_A_Length));
      Put_Line ("OEM_Data_B length:" & Integer'Image (OEM_B_Length));

      Load_OEM_Data (OEM_Data_A_CSV, OEM_Data_A);
      Load_OEM_Data (OEM_Data_B_CSV, OEM_Data_B);

      new_Line;
      Add_Photon_Data (Photon_Data_A_CSV, Combined, True, Photon_AB_Length);
      Add_Photon_Data (Photon_Data_B_CSV, Combined, False, Photon_AB_Length);

      for row in Combined'Range loop
         aRow := Combined (row);
         aRow (41 .. 43) := OEM_Data_A (row)(1 .. 3);
         aRow (44) := ',';
         aRow (45 .. 47) := OEM_Data_B (row)(1 .. 3);
         Combined (row) := aRow;
      end loop;
      Print_String47_Array ("Combined", Combined, 1, 6);

      Save_Data (Long_Dist_CSV, Combined);
      Put_Line ("Long_Dist_CSV length: " &
                  Integer'Image (Integer (Size (Long_Dist_CSV))));

   exception
      when Error : others =>
         Put_Line (Routine_Name & Exception_Information (Error));

   end Combine;

end Combine_CSVs;
