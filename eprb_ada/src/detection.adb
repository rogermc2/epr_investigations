with Interfaces.C;

with Ada.Calendar;          use Ada.Calendar;
with Ada.Numerics.Elementary_Functions;
with Ada.Numerics;          use Ada.Numerics;
with Ada.Text_IO;           use Ada.Text_IO;

with Maths;     use Maths;
with Utilities; use Utilities;

package body Detection is

   function Detect_Particle
     (Particle : Particle_Data; Setting : Float) return Result_Data
   is
      use Interfaces.C;
      use Ada.Numerics.Elementary_Functions;
      C       : double;
      Outcome : Float;
   begin
      C :=
        double ((-1) ** Natural (Particle.Spin_N)) *
          double (Cos (Particle.Spin_N * (Setting - Particle.E)));

      if double (Particle.P) < abs (C) then
         if C > 0.0 then
            Outcome := 1.0;
         elsif C < 0.0 then
            Outcome := 1.0;
         else
            Outcome := 0.0;
         end if;
      else
         Outcome := 999.9;
      end if;

      return (Setting, Outcome);

   end Detect_Particle;

   function Get_Particles (File_Name : String) return Station_Type is
      Name    : Unbounded_String := To_Unbounded_String ("Unknown");
      Station : Station_Type;
   begin
      if File_Name = "data/source_A.bin" then
         Name := To_Unbounded_String ("A");
      elsif File_Name = "data/source_B.bin" then
         Name := To_Unbounded_String ("B");
      else
         Put_Line ("Get_Particles unknown file name: '" & File_Name & "'");
      end if;

      Station.Name := Name;
      Station.Particles := Load_Particles (File_Name);

      return Station;

   end Get_Particles;

   function Load_Results
     (Particles : Particle_Vector; Settings  : Settings_Vector)
      return Result_Vector is
      --  infos = zip(particles,
      --  numpy.random.choice(angles, size=len(particles))
      use Particle_Data_Package;
      use Settings_Vector_Package;
      Random_Settings : constant Settings_Vector :=
        Random_Choice (Settings);
      Curs_1          : Particle_Data_Package.Cursor := Particles.First;
      Item            : Particle_Data;
      Infos           : Pairs_Vector;
      Results         : Result_Vector;
   begin
      while Has_Element (Curs_1) loop
         Item := Particles.Element (To_Index (Curs_1));
         if Integer (To_Index (Curs_1)) <=
           Integer (Length (Random_Settings))
         then
            Infos.Append
              ((Item, Random_Settings.Element (To_Index (Curs_1))));
         else
            Infos.Append
              ((Item, Random_Settings.Last_Element));
         end if;
         Next (Curs_1);
      end loop;

      declare
         use Pairs_Vector_Package;
         Curs_2   : Pairs_Vector_Package.Cursor := Infos.First;
         Item     : Particle_Record;
         Result   : Result_Data;
      begin
         while Has_Element (Curs_2) loop
            Item := Element (Curs_2);
            Result := Detect_Particle (Item.Particle, Item.Setting);
            Result_Vector_Package.Append (Results, Result);
            Next (Curs_2);
         end loop;
      end;

      return Results;

   end Load_Results;

   procedure Run_Detection (File_Name : String; Settings : Settings_Vector;
                            Out_File  : out Unbounded_String) is
      use Particle_Data_Package;
      Routine_Name   : constant String      := "Detection.Run_Detection ";
      Num_Particles  : constant Natural     := File_Length (File_Name);
      --  Settings_Array : constant Float_Array :=
      --    Angles_Vector_To_Array (Settings);
      Station        : Station_Type         := Get_Particles (File_Name);
      Results        : Result_Vector;
      Start_Time     : Time;
      End_Time       : Time;
   begin
      if Num_Particles > 0 then
         Put_Line (Routine_Name & "Detecting particles for arm " &
                     To_String (Station.Name));
         Start_Time := Clock;
         Results := Load_Results (Station.Particles, Settings);
         --  Results ncontains the detection results
         End_Time := Clock;

         Put_Line
           (Integer'Image (Integer (Station.Particles.Length)) &
              " particles detected in " &
              Float'Image (Float (End_Time - Start_Time)) & " seconds.");

         Station.Results := Results;
         Out_File := Station.Name & To_Unbounded_String (".bin");
         Save ("data/" & To_String (Out_File), Station);
         Put_Line ("Data saved to: " & To_String (Out_File));
      else
         Put_Line (Routine_Name & "empty file: " & File_Name);
      end if;

   end Run_Detection;

end Detection;
