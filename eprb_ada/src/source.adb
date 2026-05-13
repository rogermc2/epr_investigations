
with Ada.Text_IO;               use Ada.Text_IO;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
with Ada.Numerics;              use Ada.Numerics;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Ada.Calendar;              use Ada.Calendar;
with Ada.Command_Line;          use Ada.Command_Line;
with Ada.Streams;               --  For binary file writing
with Ada.Streams.Stream_IO;
with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;

package body Source is

   procedure Build_Source (Num_Particles : Positive) is
      --  Set stack size:  ulimit -s 64000 to prevent stack overflow

      type Particle is record
         E     : Float;
         P     : Float;
         SpinN : Float;
      end record;

      type Particle_Array is array  (Positive range <>) of Particle;

      Gen : Generator;

      Left_Particles  : Particle_Array  (1 .. Num_Particles);
      Right_Particles : Particle_Array  (1 .. Num_Particles);
      Left_Count      : Natural := 0;
      Right_Count     : Natural := 0;
      Time_Spent      : Duration := 60.0;
      Spin            : Float := 1.0;
      N               : Float;
      Phase           : Float;
      Angles          : array  (1 .. 33) of Float;
      Ps              : array  (1 .. 1000) of Float;

      --  Helper function to create linearly spaced array
      --  function Linspace  (Start_Val, End_Val : Float; Num : Positive)
      --                      return Float_Array is
      --     Step   : constant Float :=
      --  (End_Val - Start_Val) / Float (Num - 1);
      --      Result : Float_Array  (1 .. Num);
      --  begin
      --     for I in Result'Range loop
      --        Result (I) := Start_Val + Step * Float (I - 1);
      --     end loop;
      --     return Result;
      --  end Linspace;

      --  We will implement Linspace manually here for Angles and Ps
      --  For simplicity, define local arrays for Angles and Ps
      subtype Index_Angles is Integer range 1 .. 33;
      subtype Index_Ps is Integer range 1 .. 1000;

      --  We will fill Angles and Ps in initialization
      --  Emit procedure: chooses random angle and p, appends particles to
      --  left and right arrays
      procedure Emit is
         E       : Float;
         P       : Float;
         Rand    : Integer := 0;
         I_Angle : Index_Angles;
         I_P     : Index_Ps;
      begin
         while Rand < 1 or else Rand > 33 loop
            Rand := Integer (Float_Random.Random (Gen) * 33.0) + 1;
         end loop;
         I_Angle := Rand;

         Rand := 0;
         while Rand < 1 or else Rand > 1000 loop
            Rand := Integer (Float_Random.Random (Gen) * 1000.0) + 1;
         end loop;
         I_P := Rand;

         E := Angles (I_Angle);
         P := Ps (I_P);

         if Left_Count < Left_Particles'Length then
            Left_Count := Left_Count + 1;
            Left_Particles (Left_Count) :=  (E => E, P => P, SpinN => N);
         end if;

         if Right_Count < Right_Particles'Length then
            Right_Count := Right_Count + 1;
            Right_Particles (Right_Count) :=
              (E => E + Phase, P => P, SpinN => N);
         end if;

      end Emit;

      --  Save procedure: saves particle array to a binary file
      --  (simple binary dump)
      procedure Save (Filename : String; Particles : Particle_Array) is
         use Ada.Streams.Stream_IO;
         File_ID    : Ada.Streams.Stream_IO.File_Type;
         Out_Stream : Stream_Access;
      begin
         Create (File_ID, Out_File, Filename);
         Out_Stream := Stream (File_ID);
         for I in Particles'Range loop
            Particle'Write (Out_Stream, Particles (I));
         end loop;
         Close (File_ID);

      end Save;

      --  Print procedure for progress
      --  procedure Print_Progress (ETA : Duration; Count : Natural) is
      --  begin
      --     New_Line;
      --     Put ("ETA: " & Duration'Image (ETA));
      --     --  Put (Integer (ETA), Width => 4);
      --     --  Put (Integer (Count), Width => 8);
      --     Put_Line ("s [" & Integer'Image (Count) & " pairs generated]");
      --  end Print_Progress;

   begin
      Reset (Gen);  --  Initialize random generator

      --  Parse command line arguments for duration and spin
      declare
         Arg_Count    : constant Natural := Argument_Count;
         Arg1         : Unbounded_String := To_Unbounded_String ("");
         Arg2         : Unbounded_String := Arg1;
         Spin_Val     : Float := 1.0;
         Duration_Val : Duration := 60.0;
      begin
         if Arg_Count < 1 then
            Put_Line ("Usage: source <duration in seconds> <spin>");
            return;
         else
            Arg1 := To_Unbounded_String (Argument (1));
            if Arg_Count >= 2 then
               Arg2 := To_Unbounded_String (Argument (2));
            end if;
            --  Convert Arg1 to Duration_Val
            declare
               Val : constant Float := Float'Value (To_String (Arg1));
               --  Last : Positive;
            begin
               Duration_Val := Duration (Val);

            exception
               when others =>
                  Put_Line ("Eprb_Ada  Invalid duration argument");
                  return;
            end;

            if Arg_Count >= 2 then
               declare
                  Val : Float;
               begin
                  Val := Float'Value (To_String (Arg2));
                  Spin_Val := Val;
               exception
                  when others =>
                     Spin_Val := 1.0;
               end;
            end if;
         end if;

         Spin := Spin_Val;
         Time_Spent := Duration_Val;
      end;

      --  Initialize N and Phase
      N := 2.0 * Spin;
      Phase := N * Float (Pi);

      --  Initialize Angles array  (linspace 0 to 2*pi, 33 points)
      for I in Angles'Range loop
         Angles (I) := 2.0 * Float (Pi) * Float (I - 1) / 32.0;
      end loop;

      --  Initialize Ps array: 0.5 * sin (linspace (0, pi/2, 1000))^2
      for I in Ps'Range loop
         declare
            X : constant Float := Float (Pi) / 2.0 * Float (I - 1) / 999.0;
            S : constant Float := Sin (X);
         begin
            Ps (I) := 0.5 * S ** 2;
         end;
      end loop;

      declare
         Left_File    : constant String := "data/source_left.bin";
         Right_File   : constant String := "data/source_right.bin";
         Start_Time   : constant Time := Clock;
         Count        : Natural := 0;
         Current_Time : Time;
         Elapsed      : Duration;
         ETA          : Duration;
      begin
         Put_Line ("Generating particle spin" & Float'Image (Spin) &
                     " particle pairs");
         Count := 0;
         loop
            Current_Time := Clock;
            Elapsed := Current_Time - Start_Time;
            exit when Elapsed >= Time_Spent;

            Emit;
            Count := Count + 1;

            ETA := Time_Spent - Elapsed;
            if Count mod 5000000 = 0 then
               Put ("ETA: " & Duration'Image (ETA));   --  , Width => 4);
               Put ("s [" &  Integer'Image (Count));  --  , Width => 8);
               Put_Line (" pairs generated]");
               Flush;
            end if;
         end loop;

         New_Line;

         --  Save arrays to files
         Save (Left_File, Left_Particles);
         Save (Right_File, Right_Particles);
         Put_Line (Integer'Image (Left_Count) & " particles in " &
                     Left_File);
         Put_Line (Integer'Image (Right_Count) & " particles in " &
                     Right_File);
      end;

   end Build_Source;

end Source;
