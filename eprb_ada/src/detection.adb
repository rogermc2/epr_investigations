
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

with Types; use Types;
with Utilities; use Utilities;

package body Detection is

   type Station_Type (Num_Particles : Positive) is record
      Name      : Unbounded_String := To_Unbounded_String ("Unspecified");
      Particles : Particle_Vector;
      Results   : Result_Vector;
   end record;

   type Particle_Record is record
      Particle : Particle_Data;
      Setting  : Float;
   end record;
   type Record_Array is array (Positive range <>) of Particle_Record;

   --  Random number generator for angles
   Gen : Float_Random.Generator;

   procedure Station_Detection (File_Name : String) is
      Num_Particles : constant Natural := File_Length (File_Name);
      --  NaN representation
      --  function NaN return Float is
      --     use Ada.Numerics.Elementary_Functions;
      --     X : constant Float := 0.0 / 0.0;
      --  begin
      --     return X;
      --  exception
      --     when others => return 0.0 / 0.0;
      --  end NaN;

      function Sign (X : Interfaces.C.double) return Integer is
         use Interfaces.C;
      begin
         if X > 0.0 then
            return 1;
         elsif X < 0.0 then
            return -1;
         else
            return 0;
         end if;

      end Sign;

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
         --  for I in Station.Results'Range loop
         while Has_Element (Curs) loop
            --  Write Setting and Outcome as Float values
            --  Float'Write (Out_Stream, Station.Results (I).Setting);
            --  Float'Write (Out_Stream, Station.Results (I).Outcome);
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

            --  Sequential processing  (no multiprocessing in Ada standard)
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
         --  Note: gzip not implemented here, just filename
         Save (Station, "data/" & To_String (Station.Name) & ".bin");

      end Run;

      --  Helper to parse comma separated floats from string
      function Parse_Floats (Str : String) return Float_Vector is
         use Float_Vector_Package;
         Result    : Float_Vector;
         Start_Pos : Natural := 0;
         Comma_Pos : Natural := 0;
         --  Val       : Float;

         procedure Form_Value (Val_Str : String) is
            --  Val_Str : String := Sub_Str;
            --  Val_Pos : Positive := Val_Str'First;
            --  Val_End : Positive := Val_Str'Last;
            Val_IO : Float := 0.0;
            --  Last : Positive;
         begin
            --  declare
            --     package Float_IO is new Ada.Float_Text_IO (Float);
            --     use Float_IO;
            --  begin
            Val_IO := Float'Value (Val_Str);

            Result.Append (Val_IO);
         end Form_Value;

      begin
         loop
            Comma_Pos := 0;
            for I in Start_Pos .. Str'Length loop
               if Str (I) = ',' then
                  Comma_Pos := I;
                  exit;
               end if;
            end loop;

            if Comma_Pos = 0 then
               declare
                  Sub_Str : constant String := Str (Start_Pos .. Str'Last);
               begin
                  Form_Value (Sub_Str);
               end;
            else
               declare
                  Sub_Str : constant String :=
                    Str (Start_Pos .. Comma_Pos - 1);
               begin
                  Form_Value (Sub_Str);
               end;
            end if;

            if Comma_Pos = 0 then
               exit;
            else
               Start_Pos := Comma_Pos + 1;
            end if;
         end loop;

         return Result;

      end Parse_Floats;

      --  Convert degrees to radians
      function To_Radians (Degrees : Float) return Float is
         --  Pi : constant Float := 3.14159265358979323846;
      begin
         return Degrees * Pi / 180.0;
      end To_Radians;

      function Linear_Space (Start_Val, End_Val : Float; Num : Positive)
                             return Float_Vector is
         Step   : constant Float :=  (End_Val - Start_Val) / Float (Num - 1);
         Result : Float_Vector;
      begin
         for I in 0 .. Num - 1 loop
            Result.Append (Start_Val + Step * Float (I));
         end loop;

         return Result;
      end Linear_Space;

      Arg_Count     : constant Integer := Argument_Count;
      Angles_Vector : Float_Vector;
      --  Angles_Array  : Float_Array;
      --  Particles     : Particle_Array (1 .. Num_Particles);
      Station       : Station_Type (Num_Particles);
      Name          : Unbounded_String := To_Unbounded_String ("Unknown");

      --  Convert Angles_Vector to array for easier indexing
      function Angles_Vector_To_Array
        (aVector : Float_Vector) return Float_Array is
         Len        : constant Positive := Integer (aVector.Length);
         Temp_Array : Float_Array  (1 .. Len);
      begin
         for I in 1 .. Len loop
            Temp_Array (I) := Angles_Vector.Element (I);
         end loop;
         return Temp_Array;

      end Angles_Vector_To_Array;

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
            --  package Float_Vector is new
            --    Ada.Containers.Indefinite_Vectors (Float);
         begin
            Parsed_Floats := Parse_Floats (Angles_Str);
            --  convert degrees to radians
            declare
               --  package Float_Vector is new
               --    Ada.Containers.Indefinite_Vectors (Float);
               --  Temp_Vector : Float_Vector.Vector;
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

      --  Convert Angles_Vector to array for easier indexing
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

   end Station_Detection;

end Detection;
