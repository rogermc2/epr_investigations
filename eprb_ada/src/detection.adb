
with Interfaces.C;

with Ada.Calendar; use Ada.Calendar;
with Ada.Command_Line; use Ada.Command_Line;
with Ada.Numerics.Elementary_Functions;
with Ada.Numerics; use Ada.Numerics;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;

with Maths; use Maths;
with Types; use Types;
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
         use Particle_Vector_Package;
         Angles_Vector : constant Particle_Vector :=
           Load_Particles (File_Name);
         Vector_Length : constant Natural := Natural (Length (Angles_Vector));
         Station       : Station_Type (Vector_Length);
      begin
         Station.Name := Name;
         Station.Particles := Load_Particles (File_Name);

         return Station;
      end;

   end Get_Particles;

   procedure Run_Detection (File_Name : String; Station : in out Station_Type;
                            Angles    : Float_Array) is
      --  Infos      : Record_Array (1 .. Station.Particles'Length);
      Results    : Result_Vector;
      Start_Time : Time;
      End_Time   : Time;
   begin
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
            Infos_Array (I).Setting := Random_Choice (Angles);
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

   end Run_Detection;

   function Process_Command_Line return Float_Vector is
      Arg_Count     : constant Integer := Argument_Count;
      Angles_Vector : Float_Vector;
   begin
      if Arg_Count < 1 then
         Put_Line ("Usage: ");
         Put_Line (" station <ArmSrcFile> setting1,setting2,setting3,...");
      else
         New_Line;
         if Arg_Count = 1 then
            Angles_Vector := Linear_Space (0.0, 2.0 * Pi, 33);
         else
            --  parse angles from second argument
            declare
               use Float_Vector_Package;
               Angles_Str    : constant String := Argument (2);
               Parsed_Floats : constant Float_Vector :=
                 Parse_Floats (Angles_Str);
               Temp_Vector   : Float_Vector;
            begin
               for I in Parsed_Floats.First_Index ..
                 Parsed_Floats.Last_Index loop
                  Temp_Vector.Append
                    (To_Radians (Parsed_Floats.Element (I)));
               end loop;
               Angles_Vector := Temp_Vector;
            end;
         end if;
      end if;

      return Angles_Vector;

   end Process_Command_Line;

   procedure Station_Detection (File_Name : String) is
      Num_Particles : constant Natural := File_Length (File_Name);
      Angles_Vector : constant Float_Vector := Process_Command_Line;
      Station       : Station_Type (Num_Particles);
   begin
      declare
         Angles_Array : constant Float_Array :=
           Angles_Vector_To_Array (Angles_Vector);
      begin
         Run_Detection (File_Name, Station, Angles_Array);
      end;

      Station := Get_Particles (File_Name);

   end Station_Detection;

end Detection;
