with Ada.Text_IO;
with Ada.Numerics.Elementary_Functions;

package body Polarizer is

    package F_IO is new Ada.Text_IO.Float_IO (Long_Float);
    use Ada.Numerics.Elementary_Functions;

    Pi : constant Long_Float := 3.14159_26535_89793_23846;

    type Polarizer_Config is record
            Name           : String (1 .. 22);
            Wavelength_Nm  : Long_Float;
            --  Refractive index at wavelength (e.g., borosilicate/crown glass)
            N_Glass        : Long_Float;
            --  Absorption + surface scatter loss per 0.3 mm plate
            Plate_Loss     : Long_Float;
            --  Freedman's reported parallel transmittance
            Measured_Eps_M  : Long_Float;
            --  Freedman's reported perpendicular transmittance
            Measured_Eps_perp : Long_Float;
    end record;

   --  Specifications from Freedman's 1972 Thesis / PRL 28, 938
   Num_Plates : constant Integer    := 10;    -- Ten 0.3-mm-thick glass sheets
   N_Air      : constant Long_Float := 1.000;

   Configs : constant array (1 .. 2) of Polarizer_Config := (
      (Name           => "Polarizer 1 (Green)   ",
       Wavelength_Nm  => 551.3,
       N_Glass        => 1.518, -- Typical crown/coverglass index at 551.3 nm
       Plate_Loss     => 0.0030,
       Measured_Eps_M => 0.970,
       Measured_Eps_perp => 0.038),
      (Name           => "Polarizer 2 (Violet)  ",
       Wavelength_Nm  => 422.7,
       N_Glass        => 1.528, -- Slightly higher dispersion at 422.7 nm
       Plate_Loss     => 0.0041,
       Measured_Eps_M => 0.960,
       Measured_Eps_perp => 0.037)
   );

   --  Calculate single-interface Fresnel reflectance
   procedure Fresnel_Reflectance (
      N1, N2  : Long_Float;
      Theta_I : Long_Float;
      Rs, Rp  : out Long_Float
   ) is
      Sin_T        : Long_Float;
      Cos_I, Cos_T : Long_Float;
   begin
      Sin_T := (N1 / N2) * Long_Float (Sin (Float (Theta_I)));
      Cos_I := Long_Float (Cos (Float (Theta_I)));
      Cos_T := Long_Float (Sqrt (Float (1.0 - Sin_T * Sin_T)));

      Rs := ((N1 * Cos_I - N2 * Cos_T) / (N1 * Cos_I + N2 * Cos_T)) ** 2;
      Rp := ((N1 * Cos_T - N2 * Cos_I) / (N1 * Cos_T + N2 * Cos_I)) ** 2;
   end Fresnel_Reflectance;

   --  Simulate a single 0.3 mm plate with multiple
   --  incoherent internal reflections
   procedure Simulate_Stack (
        Cfg            : Polarizer_Config;
        --  Offset from exact Brewster's angle (radians)
        Angle_Offset   : Long_Float;
        Brewster_Deg   : out Long_Float;
         --  Parallel (p-polarized) transmittance
        Eps_M          : out Long_Float;
         --  Perpendicular (s-polarized) transmittance
        Eps_perp       : out Long_Float
   ) is
      Theta_B      : Long_Float;
      Theta_I      : Long_Float;
      Rs, Rp       : Long_Float;
      T_Plate_P    : Long_Float;
      T_Plate_S    : Long_Float;
      Attenuation  : Long_Float;
   begin
      Theta_B      := Long_Float (Arctan (Float (Cfg.N_Glass / N_Air)));
      Brewster_Deg := Theta_B * 180.0 / Pi;
      Theta_I      := Theta_B + Angle_Offset;

      Fresnel_Reflectance (N_Air, Cfg.N_Glass, Theta_I, Rs, Rp);

      --  Incoherent sum of infinite internal bounces inside a thick plate:
      --  T = (1 - R) / (1 + R)
      --  Multiplied by single-pass bulk/surface transmission (1 - Plate_Loss)
      Attenuation := 1.0 - Cfg.Plate_Loss;
      T_Plate_P   := ((1.0 - Rp) / (1.0 + Rp)) * Attenuation;
      T_Plate_S   := ((1.0 - Rs) / (1.0 + Rs)) * Attenuation;

      --  Total transmittance through N independent plates
      --  (ignoring inter-plate reflections due to tilt/spacing)
      Eps_M := T_Plate_P ** Num_Plates;
      Eps_perp := T_Plate_S ** Num_Plates;

    end Simulate_Stack;

    procedure Test_Polarize is
        Brewster_Deg : Long_Float;
        Sim_Eps_M    : Long_Float;
        Sim_Eps_perp : Long_Float;
        Extinction   : Long_Float;
    begin
        Ada.Text_IO.Put_Line ("=== Freedman & Clauser (1972)" &
         " 10-Plate Polarizer Simulation ===");
        Ada.Text_IO.New_Line;

        for I in Configs'Range loop
            --  Simulate at exact Brewster's angle (offset = 0.0)
            Simulate_Stack (Configs (I), 0.0, Brewster_Deg,
                Sim_Eps_M, Sim_Eps_perp);
            Extinction := Sim_Eps_M / Sim_Eps_perp;

            Ada.Text_IO.Put_Line (Configs (I).Name);
            Ada.Text_IO.Put ("  Wavelength:         ");
            F_IO.Put (Configs (I).Wavelength_Nm, 3, 1, 0);
            Ada.Text_IO.Put_Line (" nm");

            Ada.Text_IO.Put ("  Brewster's Angle:   ");
            F_IO.Put (Brewster_Deg, Fore => 2, Aft => 2, Exp => 0);
            Ada.Text_IO.Put_Line (" deg");

            Ada.Text_IO.Put ("  Simulated eps_M:    ");
            F_IO.Put (Sim_Eps_M, Fore => 1, Aft => 4, Exp => 0);
            Ada.Text_IO.Put ("  (Measured: ");
            F_IO.Put (Configs (I).Measured_Eps_M, 1, 3, 0);
            Ada.Text_IO.Put_Line (")");

            Ada.Text_IO.Put ("  Simulated eps_m:    ");
            F_IO.Put (Sim_Eps_perp, Fore => 1, Aft => 4, Exp => 0);
            Ada.Text_IO.Put ("  (Measured: ");
            F_IO.Put (Configs (I).Measured_Eps_perp, 1, 3, 0);
            Ada.Text_IO.Put_Line (")");

            Ada.Text_IO.Put ("  Extinction Ratio:   ");
            F_IO.Put (Extinction, Fore => 2, Aft => 1, Exp => 0);
            Ada.Text_IO.Put_Line (" : 1");
            Ada.Text_IO.New_Line;
        end loop;

    end Test_Polarize;

end Polarizer;
