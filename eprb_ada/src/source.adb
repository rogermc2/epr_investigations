
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
with Ada.Numerics; use Ada.Numerics;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Ada.Calendar; use Ada.Calendar;
with Ada.Text_IO; use Ada.Text_IO;

--  with Printing; use Printing;
with Utilities; use Utilities;

package body Source is

   --  subtype Index_Probs is Integer range 1 .. 1000;

   Gen : Generator;

   procedure Emit (Settings        : Settings_Vector;
                   Probs           : Float_Array;
                   Spin            : Float;
                   Left_Particles  : in out Particle_Vector;
                   Right_Particles : in out Particle_Vector);

   procedure Build_Source
     (Duration_Val : Duration; Settings : Settings_Vector; Spin : Float;
      Left_File    : String; Right_File : String) is
      --  Set stack size:  ulimit -s 64000 to prevent stack overflow
      --  Routine_Name    : constant String := "Source.Build_Source ";
      Left_Particles  : Particle_Vector;
      Right_Particles : Particle_Vector;
      Probs           : Float_Array  (1 .. 1000);
      Start_Time      : Time;
      Count           : Natural := 0;
      Elapsed         : Duration := 0.0;
   begin
      Reset (Gen);  --  Initialize random generator
      --  Initialize Probs array: 0.5 * sin (linspace (0, pi/2, 1000))^2
      for I in Probs'Range loop
            Probs (I) :=
              0.5 * Sin (Pi / 2.0 * Float (I - 1) / 999.0) ** 2;
      end loop;

      Put_Line ("Generating particle pairs with spin" &
                  Float'Image (Spin));
      Start_Time := Clock;
      while Elapsed < Duration_Val loop
         Elapsed := Clock - Start_Time;
         Emit (Settings, Probs, Spin, Left_Particles, Right_Particles);
         Count := Count + 1;

         if Count mod 5000000 = 0 then
            Put ("Time to go: ");
            Put (Duration'Image (Duration_Val - Elapsed));
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
      Put_Line ("Source processing complete.");
      New_Line;
      --  Print_Particles
      --    (Routine_Name & "Left Particles", Left_Particles, 1, 8);
      --  Print_Particles
      --    (Routine_Name & "Right Particles", Right_Particles, 1, 8);

   end Build_Source;

   --  Emit procedure: chooses random angle and p and appends particles to
   --  left and right arrays
   procedure Emit (Settings        : Settings_Vector;
                   Probs           : Float_Array; Spin : Float;
                   Left_Particles  : in out Particle_Vector;
                   Right_Particles : in out Particle_Vector) is
      use Settings_Vector_Package;
      Num_Settings : constant Positive := Integer (Length (Settings));
      subtype Index_Angles is Integer range 1 .. Num_Settings;
      --  Routine_Name : constant String := "Source.Emit ";
      --  S_2     : constant Float := 2.0 * Spin;
      Phase   : constant Float := 2.0 * Spin * Pi;
      Pol     : Float;
      Prob    : Float;
      Rand    : Integer := 0;
      I_Angle : Index_Angles;
      --  I_Pol   : Index_Probs;
   begin
      --  Set random settings index
      while Rand < 1 or else Rand > Num_Settings loop
         Rand :=
           Integer (Float_Random.Random (Gen) * Float (Num_Settings)) + 1;
      end loop;
      I_Angle := Rand;

      --  Set random angle of polarization
      --  Rand := 0;
      --  while Rand < 1 or else Rand > 1000 loop
      --     Rand := Integer (Float_Random.Random (Gen) * 1000.0) + 1;
      --  end loop;
      --  I_Pol := Rand;

      --  Float_Random.Random returns a float in the range 0.0 .. 1.0
      Pol :=  Float_Random.Random (Gen) * 2.0 * Pi;
      --  Put_Line ("Emit Pol: " & Float'Image (Pol));

      --  Pol := Settings (I_Angle);
      --  Prob := Probs (I_Pol);
      Prob := Probs (I_Angle);

      Left_Particles.Append ((Pol, Prob, Spin));
      Right_Particles.Append ((Pol + Phase, Prob, Spin));

   end Emit;

end Source;
