
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
with Ada.Numerics; use Ada.Numerics;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Ada.Calendar; use Ada.Calendar;
with Ada.Text_IO; use Ada.Text_IO;

with Types; use Types;
with Utilities; use Utilities;

package body Source is

   subtype Index_Angles is Integer range 1 .. 33;
   subtype Index_Ps is Integer range 1 .. 1000;

   Gen : Generator;

   procedure Emit (Settings        : Float_Array; Ps : Float_Array;
                   Spin            : Float;
                   Left_Particles  : in out Particle_Vector;
                   Right_Particles : in out Particle_Vector);

   procedure Build_Source (Num_Particles : Positive; Duration_Val : Duration;
                           Left_File     : String; Right_File : String) is
      --  Set stack size:  ulimit -s 64000 to prevent stack overflow

      Left_Particles  : Particle_Vector;
      Right_Particles : Particle_Vector;
      Spin            : Float := 1.0;
      Angles          : Float_Array  (1 .. 33);
      Ps              : Float_Array  (1 .. 1000);
      Time_Spent      : Duration := 60.0;
      Gen             : Generator;
      --  Print procedure for progress
      --  procedure Print_Progress (ETA : Duration; Count : Natural) is
      --  begin
      --     New_Line;
      --     Put ("Time to go: " & Duration'Image (ETA));
      --     --  Put (Integer (ETA), Width => 4);
      --     --  Put (Integer (Count), Width => 8);
      --     Put_Line ("s [" & Integer'Image (Count) & " pairs generated]");
      --  end Print_Progress;

   begin
      Reset (Gen);  --  Initialize random generator
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
         Start_Time   : constant Time := Clock;
         Count        : Natural := 0;
         Current_Time : Time;
         Elapsed      : Duration := 0.0;
         ETA          : Duration;
      begin
         Put_Line ("Generating particle pairs with spin" &
                     Float'Image (Spin));
         Count := 0;
         while Elapsed < Time_Spent loop
            Current_Time := Clock;
            Elapsed := Current_Time - Start_Time;

            Emit (Angles, Ps, Spin, Left_Particles, Right_Particles);
            Count := Count + 1;

            ETA := Time_Spent - Elapsed;
            if Count mod 5000000 = 0 then
               Put ("Time to go: ");
               Put (Duration'Image (ETA));   --  , Width => 4);
               Put ("s [" &  Integer'Image (Count));  --  , Width => 8);
               Put_Line (" pairs generated]");
               Flush;
            end if;
         end loop;

         New_Line;

         --  Save arrays to files
         Save_Particles (Left_File, Left_Particles);
         Save_Particles (Right_File, Right_Particles);
         Put_Line (Integer'Image (Integer (Left_Particles.Length)) &
                     " particles in " & Left_File);
         Put_Line (Integer'Image (Integer (Right_Particles.Length)) &
                     " particles in " &
                     Right_File);
      end;

   end Build_Source;

   --  Emit procedure: chooses random angle and p, appends particles to
   --  left and right arrays
   procedure Emit (Settings        : Float_Array; Ps : Float_Array;
                   Spin            : Float;
                   Left_Particles  : in out Particle_Vector;
                   Right_Particles : in out Particle_Vector) is
      --  Routine_Name : constant String := "Source.Emit ";
      N       : constant Float := 2.0 * Spin;
      Phase   : constant Float := N * Float (Pi);
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

      E := Settings (I_Angle);
      P := Ps (I_P);

      Left_Particles.Append ((E, P, N));
      Right_Particles.Append ((E + Phase, P, N));

   end Emit;

end Source;
