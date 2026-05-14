
with Interfaces.C;

with Ada.Calendar; use Ada.Calendar;
with Ada.Numerics.Elementary_Functions;
with Ada.Numerics; use Ada.Numerics;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;

with Maths; use Maths;
with Utilities; use Utilities;

package body Detection is

   type Record_Array is array (Positive range <>) of Particle_Record;

   function Detect_Particle (Particle : Particle_Data; Setting : Float)
                             return Result_Data is
      use Interfaces.C;
      use Ada.Numerics.Elementary_Functions;
      C      : double;
      Result : Float;
   begin
      --  Put_Line ("Detect_Particle Particle.N: " &
      --              Integer'Image (Particle.N));
      C := double ((-1) ** Natural (Particle.Spin_N)) *
        double (Cos (Particle.Spin_N * (Setting - Particle.E)));
      if double (Particle.P) < abs (C) then
         Result := Float (Sign (C));
      else
         Result := 999.9;
      end if;

      return  (Setting => Setting, Outcome => Result);

   end Detect_Particle;

   function Get_Particles (File_Name : String) return Station_Type is
      Name  : Unbounded_String := To_Unbounded_String ("Unknown");
   begin
      if File_Name = "data/source_left.bin" then
         Name := To_Unbounded_String ("A");
      elsif File_Name = "data/source_right.bin" then
         Name := To_Unbounded_String ("B");
      end if;

      declare
         Station       : Station_Type;
      begin
         Station.Name := Name;
         Station.Particles := Load_Particles (File_Name);

         return Station;
      end;

   end Get_Particles;

   procedure Run_Detection (Settings : Float_Vector; File_Name : String) is
      use Float_Vector_Package;
      Routine_Name  : constant String := "Detection.Run_Detection ";
      --  Infos      : Record_Array (1 .. Station.Particles'Length);
      Num_Particles : constant Natural := File_Length (File_Name);
      Angles_Vector : constant Float_Vector := Process_Command_Line;
      --  Vector_Length : constant Natural := Natural (Length (Angles_Vector));
      Angles_Array  : constant Float_Array :=
        Angles_Vector_To_Array (Angles_Vector);
      --  Angles        : Float_Array (1 .. Vector_Length);
      Station       : Station_Type := Get_Particles (File_Name);
      Results       : Result_Vector;
      Start_Time    : Time;
      End_Time      : Time;
   begin
      if Num_Particles > 0 then
         Put_Line ("Detecting particles for arm " & To_String (Station.Name));
         Station :=  Get_Particles (File_Name);
         Start_Time := Clock;

         --  Prepare infos array
         declare
            use Result_Vector_Package;
            subtype Index_Type is
              Positive range 1 .. Integer (Station.Particles.Length);

            Infos_Array : Record_Array (Index_Type);
         begin
            for I in Index_Type loop
               Infos_Array (I).Particle := Station.Particles (I);
               Infos_Array (I).Setting := Random_Choice (Angles_Array);
            end loop;

            for I in Infos_Array'Range loop
               Append (Results, Detect_Particle
                       (Infos_Array (I).Particle, Infos_Array (I).Setting));
            end loop;
         end;

         End_Time := Clock;
         Put_Line
           ("Done: " & Integer'Image (Integer (Station.Particles.Length)) &
              " particles detected in " &
              Float'Image (Float (End_Time - Start_Time)) & " seconds.");

         Station.Results := Results;
         Save (Station, "data/" & To_String (Station.Name) & ".bin");
      else
         Put_Line (Routine_Name & "empty file: " & File_Name);
      end if;

   end Run_Detection;

end Detection;
