
--  with Ada.Numerics; use Ada.Numerics;  --  for Pi
--  use Ada.Numerics.Elementary_Functions;  -- for Cos
with Ada.Text_IO; use Ada.Text_IO;

with Delft_Printing; use Delft_Printing;
with Delft_Types; use Delft_Types;
with Printing; use Printing;
with Process_Data; use Process_Data;
with Types; use Types;

procedure Statistical_Analysis is
   AB_Dir        : constant String := "../generated_delft_data/";
   File_00       : constant String := AB_Dir & "aa.csv";
   File_01       : constant String := AB_Dir & "ba.csv";
   File_10       : constant String := AB_Dir & "ab.csv";
   File_11       : constant String := AB_Dir & "bb.csv";
   Detections_00 : constant Delft_Sample_Data_List := Get_Detections (File_00);
   Detections_01 : constant Delft_Sample_Data_List := Get_Detections (File_01);
   Detections_10 : constant Delft_Sample_Data_List := Get_Detections (File_10);
   Detections_11 : constant Delft_Sample_Data_List := Get_Detections (File_11);
   E_AA          : constant Float :=
      Statistical_EAB (Float (abs (A_Angle_0 - B_Angle_0)));
   E_AB          : constant Float :=
      Statistical_EAB (Float (abs (A_Angle_0 - B_Angle_1)));
   E_BA          : constant Float :=
      Statistical_EAB (Float (abs (A_Angle_1 - B_Angle_0)));
   E_BB          : constant Float :=
      Statistical_EAB (Float (abs (A_Angle_1 - B_Angle_1)));
   Mean_A_00     : Float;
   Mean_A_01     : Float;
   Mean_A_10     : Float;
   Mean_A_11     : Float;
   Mean_B_00     : Float;
   Mean_B_01     : Float;
   Mean_B_10     : Float;
   Mean_B_11     : Float;
   Mean_AB_00    : Float;
   Mean_AB_01    : Float;
   Mean_AB_10    : Float;
   Mean_AB_11    : Float;
   False_Data    : Delft_Sample_Data_List;
   False_Count   : Natural;
   True_Count    : Natural;
begin
    Put ("Null hypothesis, H0: ");
    Put_Line ("Sample mean is within 3% of expected value.");
   --  Print_Delft_Sample_List ("Detections_00", Detections_00, 1, 5);
   --  Print_Delft_Sample_List ("Detections_01", Detections_01, 1, 5);
   --  Print_Delft_Sample_List ("Detections_10", Detections_10, 1, 5);
   --  Print_Delft_Sample_List ("Detections_11", Detections_11, 1, 5);
   Sample_Means (Detections_00, Mean_A_00, Mean_B_00, Mean_AB_00);
   Sample_Means (Detections_01, Mean_A_01, Mean_B_01, Mean_AB_01);
   Sample_Means (Detections_10, Mean_A_10, Mean_B_10, Mean_AB_10);
   Sample_Means (Detections_11, Mean_A_11, Mean_B_11, Mean_AB_11);

   Print_Delft_Statistics ("00", Mean_A_00, Mean_B_00, Mean_AB_00,
                     Detections_00, Det_A, Det_B);
   Print_Delft_Statistics ("01", Mean_A_01, Mean_B_01, Mean_AB_01,
                     Detections_01, Det_A, Det_B);
   Print_Delft_Statistics ("10", Mean_A_10, Mean_B_10, Mean_AB_10,
                     Detections_10, Det_A, Det_B);
   Print_Delft_Statistics ("11", Mean_A_11, Mean_B_11, Mean_AB_11,
                     Detections_11, Det_A, Det_B);
   New_Line;

   Print_Float_Line ("Overall A Sample_Mean: ",
    (Mean_A_00 + Mean_A_01 + Mean_A_10 + Mean_A_11) / 4.0);
   Print_Float_Line ("Overall B Sample_Mean: ",
    (Mean_B_00 + Mean_B_01 + Mean_B_10 + Mean_B_11) / 4.0);
   New_Line;

   Print_Float_Line ("E(AA)", E_AA);
   Print_Float_Line ("E(AB)", E_AB);
   Print_Float_Line ("E(BA)", E_BA);
   Print_Float_Line ("E(BB)", E_BB);
   New_Line;

   Print_Float_Line ("CHSH parameter S: ",
      Mean_AB_00 - Mean_AB_01 + Mean_AB_10 + Mean_AB_11);
   New_Line;

   Put_Line ("Number of AB00 detections: " &
               Integer'Image (Integer (Detections_00.Length)));
   Put_Line ("Number of AB01 detections: " &
               Integer'Image (Integer (Detections_01.Length)));
   Put_Line ("Number of AB10 detections: " &
               Integer'Image (Integer (Detections_10.Length)));
   Put_Line ("Number of AB11 detections: " &
               Integer'Image (Integer (Detections_11.Length)));

   False_Data := False_Positives (AB_Dir, File_00, False_Count, True_Count);
   if False_Count > 0 then
      Put ("00 False positives: " & Integer'Image (False_Count) & " (");
      Print_Float ("", Float (False_Count * 100) / Float (False_Count + True_Count), 1, 0);
      Put_Line ("% )");
      Print_Delft_Sample_List ("00 False_Data", False_Data, 1, 10);
   else
      Put_Line ("00 False positives: 0");
   end if;

   False_Data := False_Positives (AB_Dir, File_11, False_Count, True_Count);
   if False_Count > 0 then
      Put ("11 False positives: " & Integer'Image (False_Count) & " (");
      Print_Float ("", Float (False_Count * 100) / Float (False_Count + True_Count), 1, 0);
      Put_Line ("% )");
      Print_Delft_Sample_List ("11 False_Data", False_Data, 1, 10);
   else
      Put_Line ("11 False positives: 0");
   end if;

   False_Data := False_Positives (AB_Dir, File_10, False_Count, True_Count);
   if False_Count > 0 then
      Put ("10 False positives: " & Integer'Image (False_Count) & " (");
      Print_Float ("", Float (False_Count * 100) / Float (False_Count + True_Count), 1, 0);
      Put_Line ("% )");
      Print_Delft_Sample_List ("10 False_Data", False_Data, 1, 10);
   else
      Put_Line ("10 False positives: 0");
   end if;

   False_Data := False_Positives (AB_Dir, File_01, False_Count, True_Count);
   if False_Count > 0 then
      Put ("01 False positives: " & Integer'Image (False_Count) & " (");
      Print_Float ("", Float (False_Count * 100) / Float (False_Count + True_Count), 1, 0);
      Put_Line ("% )");
      Print_Delft_Sample_List ("01 False_Data", False_Data, 1, 10);
   else
      Put_Line ("01 False positives: 0");
   end if;

end Statistical_Analysis;
