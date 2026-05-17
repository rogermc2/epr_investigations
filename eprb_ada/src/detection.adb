with Interfaces.C;

with Ada.Calendar;          use Ada.Calendar;
with Ada.Numerics.Elementary_Functions;
with Ada.Numerics;          use Ada.Numerics;
with Ada.Text_IO;           use Ada.Text_IO;

with Maths;     use Maths;
with Utilities; use Utilities;
with Vector_Functions;

package body Detection is

   function Detect_Particle
     (Particle : Particle_Data; Setting : Float) return Result_Data
   is
      use Interfaces.C;
      use Ada.Numerics.Elementary_Functions;
      C      : double;
      Result : Float;
   begin
      C :=
        double ((-1) ** Natural (Particle.Spin_N)) *
          double (Cos (Particle.Spin_N * (Setting - Particle.E)));
      if double (Particle.P) < abs (C) then
         Result := Float (Sign (C));
      else
         Result := 999.9;
      end if;

      return (Setting, Result);

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

   function Load_Infos (Particles : Particle_Vector;
                       Settings : Settings_Vector) return Pairs_Vector is
      --  infos = zip(particles,
      --  numpy.random.choice(angles, size=len(particles)))
      use Particle_Data_Package;
      use Settings_Vector_Package;
      Random_Settings : constant Settings_Vector :=
        Random_Choice (Settings);
      Curs            : Particle_Data_Package.Cursor := Particles.First;
      Item            : Particle_Data;
      Infos           : Pairs_Vector;
   begin
      while Has_Element (Curs) loop
         Item := Particles.Element (To_Index (Curs));
         if Integer (To_Index (Curs)) <=
           Integer (Length (Random_Settings))
         then
            Infos.Append
              ((Item, Random_Settings.Element (To_Index (Curs))));
         else
            Infos.Append
              ((Item, Random_Settings.Last_Element));
         end if;
         Next (Curs);
      end loop;

      return Infos;

   end Load_Infos;

   procedure Run_Detection (File_Name : String; Settings : Settings_Vector;
                            Out_File : out Unbounded_String) is
      use Particle_Data_Package;
      use Vector_Functions;
      Routine_Name   : constant String      := "Detection.Run_Detection ";
      Num_Particles  : constant Natural     := File_Length (File_Name);
      Settings_Array : constant Float_Array :=
        Angles_Vector_To_Array (Settings);
      Station        : Station_Type         := Get_Particles (File_Name);
      --  Curs           : Particle_Data_Package.Cursor :=
      --    Station.Particles.First;
      Infos          : Pairs_Vector;
      Results        : Result_Vector;
      Particles      : Particle_Vector;
      Start_Time     : Time;
      End_Time       : Time;
   begin
      if Num_Particles > 0 then
         Put_Line (Routine_Name & "Detecting particles for arm " &
                     To_String (Station.Name));
         Start_Time := Clock;

         --  while Has_Element (Curs) loop
         --     Particles.Append
         --       (Detect_Particle
         --          (Element (Curs), Random_Choice (Settings_Array)));
         --     Next (Curs);
         --  end loop;
         Put_Line (Routine_Name & "Particles loaded");
         Infos := Load_Infos (Station.Particles, Settings);
         End_Time := Clock;

         Put_Line
           (Integer'Image (Integer (Station.Particles.Length)) &
              " particles detected in " &
              Float'Image (Float (End_Time - Start_Time)) & " seconds.");

         Station.Results := Results;
         Out_File := Station.Name & To_Unbounded_String (".bin");
         Save ("data/" & To_String (Out_File), Station);
      else
         Put_Line (Routine_Name & "empty file: " & File_Name);
      end if;

   end Run_Detection;

end Detection;
