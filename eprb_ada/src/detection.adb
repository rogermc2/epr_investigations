
with Interfaces.C;

with Ada.Calendar; use Ada.Calendar;
with Ada.Command_Line; use Ada.Command_Line;
with Ada.Containers;
--  with Ada.Containers.Vectors;
--  with Ada.Containers.Doubly_Linked_Lists;
with Ada.Containers.Indefinite_Vectors;
--  with Ada.Containers.Indefinite_Doubly_Linked_Lists;
--  with Ada.Directories; use Ada.Directories;
--  with Ada.Exceptions;
--  with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Ada.Numerics.Elementary_Functions;
--  with Ada.Numerics.Generic_Elementary_Functions;
with Ada.Numerics;  use Ada.Numerics;
with Ada.Numerics.Float_Random;
with Ada.Streams.Stream_IO;
with Ada.Streams;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
--  with Ada.Strings.Unbounded.Text_IO;
--  with Ada.Task_Identification;
--  with Ada.Synchronous_Task_Control;
--  with Ada.Task_Attributes;
--  with Ada.Task_Attributes.Dispatching;
--  with Ada.Task_Attributes.Dispatching.Task_Attributes;
--  with Ada.Task_Attributes.Dispatching.Task_Attributes.Dispatching;
with Ada.Text_IO;               use Ada.Text_IO;

package body Detection is

   type Float_Array is array (Positive range <>) of Float;

   type Particle_Data is record
      E : Float := 0.0;
      P : Float := 0.0;
      N : Integer := 0;
   end record;
   type Particle_Array is array (Positive range <>) of Particle_Data;

   type Result_Data is record
      Setting : Float := 0.0;
      Outcome : Float := 999.9;  --  Use Float to represent sign
   end record;
   type Result_Array is array (Positive range <>) of Result_Data;

   type Station_Type (Num_Particles : Positive) is record
      Name      : Unbounded_String := To_Unbounded_String ("Unspecified");
      Particles : Particle_Array (1 .. Num_Particles);
      Results   : Result_Array (1 .. Num_Particles);
   end record;

   type Particle_Record is record
      Particle : Particle_Data;
      Setting  : Float;
   end record;
   type Record_Array is array (Positive range <>) of Particle_Record;

   --  Random number generator for angles
   Gen : Float_Random.Generator;

   package Float_Vector_Package is new
     Ada.Containers.Indefinite_Vectors (Positive, Float);
   subtype Float_Vector is Float_Vector_Package.Vector;

   procedure Station_Detection  (Num_Particles : Positive) is
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
         C := double ((-1) ** Particle.N) *
           double (Cos (Float (Particle.N) * (Setting - Particle.E)));
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
         File_ID    : Ada.Streams.Stream_IO.File_Type;
         Out_Stream : Stream_Access;
      begin
         Create (File_ID, Out_File, File_Name);
         Out_Stream := Stream (File_ID);
         for I in Station.Results'Range loop
            --  Write Setting and Outcome as Float values
            Float'Write (Out_Stream, Station.Results (I).Setting);
            Float'Write (Out_Stream, Station.Results (I).Outcome);
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
         Results    : Result_Array (1 .. Station.Particles'Length);
         Start_Time : Time;
         End_Time   : Time;
      begin
         Put_Line ("Detecting particles for arm " & To_String (Station.Name));
         Start_Time := Clock;

         --  Prepare infos array
         declare
            subtype Index_Type is
              Positive range 1 .. Station.Particles'Length;

            Infos_Array : Record_Array (Index_Type);
            --  Particle    : Particle_Data;
            --  Setting     : Float;
         begin
            for I in Index_Type loop
               Infos_Array (I).Particle := Station.Particles (I);
               Infos_Array (I).Setting := Random_Choice (Angles);
            end loop;

            --  Sequential processing  (no multiprocessing in Ada standard)
            for I in Index_Type loop
               Results (I) := Detect_Particle
                 (Infos_Array (I).Particle, Infos_Array (I).Setting);
            end loop;
         end;

         End_Time := Clock;
         Put_Line ("Done: " & Integer'Image (Station.Particles'Length) &
                     " particles detected in " &
                     Float'Image (Float (End_Time - Start_Time)) & " sec!");

         Station.Results := Results;
         --  Note: gzip not implemented here, just filename
         --  Save (Station, Station.Name & ".npy.gz");
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
            --     Val_IO := 0.0;
            Val_IO := Float'Value (Val_Str);
            --  exception
            --     when others =>
            --        Val_IO := 0.0;
            --  end;

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

      --  Load particles from file  (dummy implementation)
      --  function Load_Particles (File_Name : String) return Particle_Array is
      function Load_Particles return Particle_Array is
         --  This is a stub: real load and gzip not implemented
         --  Return dummy data for demonstration
         Dummy : Particle_Array (1 .. Num_Particles);
      begin
         Dummy (1) :=  (E => 0.0, P => 0.5, N => 1);
         Dummy (2) :=  (E => 1.0, P => 0.3, N => 2);
         Dummy (3) :=  (E => 2.0, P => 0.7, N => 3);
         return Dummy;
      end Load_Particles;

      --  Convert degrees to radians
      function To_Radians (Degrees : Float) return Float is
         Pi : constant Float := 3.14159265358979323846;
      begin
         return Degrees * Pi / 180.0;
      end To_Radians;

      function Linspace (Start_Val, End_Val : Float; Num : Positive)
                         return Float_Vector is
         Step   : constant Float :=  (End_Val - Start_Val) / Float (Num - 1);
         Result : Float_Vector;
      begin
         for I in 0 .. Num - 1 loop
            Result.Append (Start_Val + Step * Float (I));
         end loop;

         return Result;
      end Linspace;

      --  Main program
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

      declare
         File_Name : constant String := Argument (1);
      begin
         if Arg_Count = 1 then
            --  angles = numpy.linspace (0, 2*pi, 33)
            Angles_Vector := Linspace (0.0, 2.0 * 3.14159265358979323846, 33);
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
            Station.Particles := Load_Particles;

            --  Determine name
            if File_Name = "data/source_left.bin" then
               Name := To_Unbounded_String ("A");
            elsif File_Name = "data/source_right.bin" then
               Name := To_Unbounded_String ("B");
            end if;

            Station.Name := Name;

            --  Run detection
            Run (Station, Angles_Array);
         end;
      end;

   end Station_Detection;

end Detection;
