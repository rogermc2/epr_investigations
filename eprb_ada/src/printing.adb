
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Float_Text_IO;

with Maths;
--  with Utilities;

package body Printing is

   --  ------------------------------------------------------------------

   procedure Print_Analysis_Data (Analysis_Data : Analysis_Vector) is
      use Analysis_Vector_Package;
      Curs   : Cursor := Analysis_Data.First;
      Item   : Analysis_Record;
      Header : constant String :=
        "A Setting B Setting  Mean A Mean B Mean AB " &
        "Mean Stat Mean QM Npp Npm  Nmp  Nmm";
   begin
      Put_Line ("Analysis Data");
      Put_Line (Header);
      while Has_Element (Curs) loop
         Item := Element (Curs);
         Print_Analysis_Item (Analysis_Data => Item);
         Next (Curs);
      end loop;

   end Print_Analysis_Data;

   --  ------------------------------------------------------------------------

   procedure Print_Analysis_Item (Name          : String := "";
                                  Analysis_Data : Analysis_Record;
                                  Print_Header  : Boolean := False) is
      use Maths;
      use Ada.Float_Text_IO;
      Header : constant String :=
        "A Setting B Setting Mean A  Mean B Mean AB " &
        "Mean Stat Mean QM Npp  Npm  Nmp  Nmm";
      A      : constant Float := To_Degrees (Analysis_Data.Setting_A);
      B      : constant Float := To_Degrees (Analysis_Data.Setting_B);
   begin
      if Name /= "" then
         Put_Line (Name & ":");
      end if;

      if Print_Header then
         Put_Line (Header);
      end if;

      Put (" ");
      Put (Item => A, Fore => 1, Aft => 2, Exp => 0);
      if A = 0.00 then
         Put  ("      ");
      else
         Put  ("    ");
      end if;
      Put (Item => B, Fore => 1, Aft => 2, Exp => 0);
      if B = 0.00 then
         Put  ("      ");
      else
         Put  ("    ");
      end if;

      Put (Analysis_Data.A_Mean, 1, 2, 0);
      Put ("   ");
      Put (Analysis_Data.B_Mean, 1, 2, 0);
      Put ("     ");
      Put (Analysis_Data.AB_Mean, 1, 2, 0);
      Put ("    ");
      Put (Analysis_Data.E_Stat, 1, 2, 0);
      Put ("     ");
      Put (Analysis_Data.E_QM, 1, 2, 0);
      Put ("  ");
      Put (Natural'Image (Analysis_Data.Npp) & "  ");
      Put (Natural'Image (Analysis_Data.Npm) & "  ");
      Put (Natural'Image (Analysis_Data.Nmp) & "  ");
      Put_Line (Natural'Image (Analysis_Data.Nmm) & "  ");

   end Print_Analysis_Item;

   --  ------------------------------------------------------------------------

   procedure Print_Data_Record (Name : String; Data : Data_Record) is
      use Outcome_Vector_Package;
   begin
      Put_Line (Name);
      Put_Line ("Setting_A: " & Integer'Image (Data.Setting_A) &
                  "  Setting_B: " & Integer'Image (Data.Setting_B)  &
                  "  Data.Outcomes length: " &
                  Integer'Image (Integer (Length (Data.Outcomes))));
      New_Line;

   end Print_Data_Record;

   --  ------------------------------------------------------------------------

   procedure Print_Outcome_Vector
     (Name   : String; Data : Outcome_Vector; Start : Positive := 1;
      Finish : Natural := 0) is
      use Outcome_Vector_Package;
      Curs      : Cursor := Data.First;
      Item      : Outcomes_Record;
      Last      : Natural;
      Count     : Natural := 0;
   begin
      if Finish > 0 then
         Last := Finish;
      else
         Last := Natural (Data.Last_Index);
      end if;

      Put_Line (Name);
      while Has_Element (Curs) loop
         Count := Count + 1;
         if Count >= Start and then Count <= Last then
            Item := Data (Curs);
            Put_Line ("Outcomes A and B: " & Integer'Image (Item.Outcome_A) &
                        ", " & Integer'Image (Item.Outcome_B));
         end if;
         Next (Curs);
      end loop;
      New_Line;

   end Print_Outcome_Vector;

   --  ------------------------------------------------------------------------

   procedure Print_Particles
     (Name  : String; Data : Particle_Vector;
      Start : Positive := 1; Finish : Natural := 0) is
      use Particle_Data_Package;
      Last : Natural;
      Item : Particle_Data;
   begin
      if Finish > 0 then
         Last := Finish;
      else
         Last := Natural (Length (Data));
      end if;

      Put_Line (Name & ": ");
      if Start >= Data.First_Index and then
        Finish <= Data.Last_Index
      then
         for Index in Start .. Last loop
            Item := Data (Index);
            Put_Line ("Pol, Prob, Spin_2: " & Float'Image (Item.Pol) & "  " &
                        Float'Image (Item.Prob) & "  " &
                        Float'Image (Item.Spin_2));
         end loop;
      else
         Put_Line
           ("Print_Particles called with invalid start or finish index.");
      end if;
      New_Line;

   end Print_Particles;

   --  ------------------------------------------------------------------------

   procedure Print_Result_Vector
     (Name   : String; Data : Result_Vector; Start : Positive := 1;
      Finish : Natural := 0) is
      use Result_Vector_Package;
      Curs      : Cursor := Data.First;
      Item      : Result_Data;
      Last      : Natural;
      Count     : Natural := 0;
   begin
      if Finish > 0 then
         Last := Finish;
      else
         Last := Natural (Data.Last_Index);
      end if;

      Put_Line (Name);
      while Has_Element (Curs) loop
         Count := Count + 1;
         if Count >= Start and then Count <= Last then
            Item := Data (Curs);
            Put_Line ("Setting: " & Float'Image (Item.Setting) &
                        "  Outcome: " & Integer'Image (Item.Outcome));
         end if;
         Next (Curs);
      end loop;
      New_Line;

   end Print_Result_Vector;

   --  ------------------------------------------------------------------------

   --  procedure Print_Statistics
   --    (Message : String; Mean_A, Mean_B, Mean_AB : Float;
   --     Detections : Sample_Data_List; Det_A, Det_B : Detect_Type) is
   --     use Maths;
   --     use Utils;
   --  begin
   --     Put_Line (Message & ": ");
   --
   --     Put (" Sample_Mean A: " & Float'Image (Mean_A));
   --     Put_Line ("   Sample SD A: " & Float'Image (Sample_Std_Deviation
   --               (Get_Integer_List (Detections, Det_A), Mean_A)));
   --     Put (" Sample_Mean B: " & Float'Image (Mean_B));
   --     Put_Line ("   Sample SD B: " & Float'Image (Sample_Std_Deviation
   --               (Get_Integer_List (Detections, Det_B), Mean_B)));
   --     Put (" Sample_Mean AB: " & Float'Image (Mean_AB));
   --     Put_Line ("   Sample SD AB: " & Float'Image (Sample_Std_Deviation
   --               (Get_Integer_List (Detections, Det_B), Mean_AB)));
   --
   --  end Print_Statistics;

   --  ------------------------------------------------------------------------

end Printing;
