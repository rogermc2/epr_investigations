
with Interfaces.C;

with Ada.Calendar; use Ada.Calendar;
with Ada.Command_Line; use Ada.Command_Line;
with Ada.Numerics.Elementary_Functions;
with Ada.Numerics; use Ada.Numerics;
with Ada.Numerics.Float_Random;
with Ada.Streams.Stream_IO;
with Ada.Streams;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO; use Ada.Text_IO;

with Maths; use Maths;
with Types; use Types;
with Utilities; use Utilities;

package body Detection is

   type Record_Array is array (Positive range <>) of Particle_Record;

   --  Random number generator for angles
   Gen : Float_Random.Generator;

   function Get_Particles (File_Name : String) return Station_Type is
      --  Angles_Array : constant Float_Array :=
      --    Angles_Vector_To_Array (Angles_Vector);
      Name : Unbounded_String;
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

   procedure Station_Detection (File_Name : String) is
      Num_Particles : constant Natural := File_Length (File_Name);
      --  Detect particle function
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

      --  Procedure to save results to a file  (binary)
      procedure Save (Station : Station_Type; File_Name : String) is
         use Ada.Streams.Stream_IO;
         use Result_Vector_Package;
         File_ID    : Ada.Streams.Stream_IO.File_Type;
         Out_Stream : Stream_Access;
         Curs       : Cursor := Station.Results.First;
      begin
         Create (File_ID, Out_File, File_Name);
         Out_Stream := Stream (File_ID);
         while Has_Element (Curs) loop
            --  Write Setting and Outcome as Float values
            Float'Write (Out_Stream, Element (Curs).Setting);
            Float'Write (Out_Stream, Element (Curs).Outcome);
            Next (Curs);
         end loop;
         Close (File_ID);

      end Save;

      --  Generate random choice from angles array
      function Random_Choice (Angles : Float_Array) return Float is
         Index : Integer :=
           Integer (Float (Angles'Length) * Float_Random.Random (Gen)) + 1;
      begin
         if Index > Angles'Length then
            Index := Angles'Length;
         elsif Index < 1 then
            Index := 1;
         end if;
         return Angles (Index);
      end Random_Choice;

      --  Run detection procedure
      procedure Run (Station : in out Station_Type;
                     Angles  : Float_Array) is
         --  Infos      : Record_Array (1 .. Station.Particles'Length);
         Results    : Result_Vector;
         Start_Time : Time;
         End_Time   : Time;
      begin
         Put_Line ("Detecting particles for arm " & To_String (Station.Name));
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

      end Run;

      Arg_Count     : constant Integer := Argument_Count;
      Angles_Vector : Float_Vector;
      Station       : Station_Type (Num_Particles);
      Name          : Unbounded_String := To_Unbounded_String ("Unknown");

   begin
      if Arg_Count < 1 then
         Put_Line ("Usage: ");
         Put_Line (" station <ArmSrcFile> setting1,setting2,setting3,...");
         return;
      end if;

      New_Line;
      if Arg_Count = 1 then
         Angles_Vector := Linear_Space (0.0, 2.0 * Pi, 33);
      else
         --  parse angles from second argument
         declare
            Angles_Str    : constant String := Argument (2);
            Parsed_Floats : Float_Vector;
         begin
            Parsed_Floats := Parse_Floats (Angles_Str);
            --  convert degrees to radians
            declare
               use Float_Vector_Package;
               Temp_Vector : Float_Vector;
            begin
               for I in Parsed_Floats.First_Index ..
                 Parsed_Floats.Last_Index loop
                  Temp_Vector.Append
                    (To_Radians (Parsed_Floats.Element (I)));
               end loop;
               Angles_Vector := Temp_Vector;
            end;
         end;
      end if;

      declare
         Angles_Array : constant Float_Array :=
           Angles_Vector_To_Array (Angles_Vector);
      begin
         --  Load particles
         --  Particles := Load_Particles (File_Name);

         --  Determine name
         if File_Name = "data/source_left.bin" then
            Name := To_Unbounded_String ("A");
         elsif File_Name = "data/source_right.bin" then
            Name := To_Unbounded_String ("B");
         end if;

         Station.Name := Name;
         Station.Particles := Load_Particles (File_Name);

         --  Run detection
         Run (Station, Angles_Array);
      end;

      Station := Get_Particles (File_Name);
      --  Run detection
      --  Run (Station, Angles_Array);

   end Station_Detection;

end Detection;
