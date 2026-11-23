with Ada.Numerics.Elementary_Functions;
with Ada.Text_IO; use Ada.Text_IO;

with Maths; use Maths;

package body Freedman_Polarizer_Model is
   use Ada.Numerics.Elementary_Functions;

   Num_Plates : constant Integer    := 10;
   N_Air      : constant Long_Float := 1.000;

   function Get_N_Glass (Arm : Polarizer_Arm) return Long_Float is
   begin
      case Arm is
         when Green_551nm  => return 1.518;
         when Violet_423nm => return 1.528;
      end case;
   end Get_N_Glass;

   function Get_Plate_Loss (Arm : Polarizer_Arm) return Long_Float is
   begin
      case Arm is
         when Green_551nm  => return 0.0030;
         when Violet_423nm => return 0.0041;
      end case;
   end Get_Plate_Loss;

   function Brewster_Angle (Arm : Polarizer_Arm) return Long_Float is
   begin
      return Long_Float (Arctan (Float (Get_N_Glass (Arm) / N_Air)));
   end Brewster_Angle;

   function Evaluate_Ray (Arm : Polarizer_Arm;
      Theta_I : Long_Float; Psi : Long_Float := 0.0)
      return Ray_Transmittance is
      N_Glass      : constant Long_Float := Get_N_Glass (Arm);
      Attenuation  : constant Long_Float := 1.0 - Get_Plate_Loss (Arm);
      Sin_I, Cos_I : Long_Float;
      Sin_T, Cos_T : Long_Float;
      Rs, Rp       : Long_Float;
      T_Plate_P    : Long_Float;
      T_Plate_S    : Long_Float;
      Cos_Psi_Sq   : Long_Float;
      Sin_Psi_Sq   : Long_Float;
      Res          : Ray_Transmittance;
   begin
      Sin_I := Long_Float (Sin (Float (Theta_I)));
      Cos_I := Long_Float (Cos (Float (Theta_I)));
      Sin_T := (N_Air / N_Glass) * Sin_I;

      if Sin_T >= 1.0 then
         Res := (Tp => 0.0, Ts => 0.0, T_Parallel => 0.0, T_Perp => 0.0);
         return Res;
      end if;

      Cos_T := Long_Float (Sqrt (Float (1.0 - Sin_T * Sin_T)));

      Rs := ((N_Air * Cos_I - N_Glass * Cos_T) / (N_Air * Cos_I + N_Glass * Cos_T)) ** 2;
      Rp := ((N_Air * Cos_T - N_Glass * Cos_I) / (N_Air * Cos_T + N_Glass * Cos_I)) ** 2;

      -- Single-plate incoherent multiple-bounce transmittance
      T_Plate_P := ((1.0 - Rp) / (1.0 + Rp)) * Attenuation;
      T_Plate_S := ((1.0 - Rs) / (1.0 + Rs)) * Attenuation;

      Res.Tp := T_Plate_P ** Num_Plates;
      Res.Ts := T_Plate_S ** Num_Plates;

      -- Project local s/p transmittances onto laboratory polarizer axes
      Cos_Psi_Sq     := Long_Float (Cos (Float (Psi))) ** 2;
      Sin_Psi_Sq     := 1.0 - Cos_Psi_Sq;
      Res.T_Parallel := Res.Tp * Cos_Psi_Sq + Res.Ts * Sin_Psi_Sq;
      Res.T_Perp     := Res.Tp * Sin_Psi_Sq + Res.Ts * Cos_Psi_Sq;

      return Res;
   end Evaluate_Ray;

   procedure Cone_To_Plate_Angles (Tilt_Angle, Alpha, Phi : Long_Float;
      Theta_I, Psi        : out Long_Float) is
      -- Ray direction unit vector k = (sin(alpha)cos(phi), sin(alpha)sin(phi), cos(alpha))
      -- Plate normal unit vector n = (sin(tilt), 0, cos(tilt))
      Kx : constant Long_Float := Long_Float (Sin (Float (Alpha))) * Long_Float (Cos (Float (Phi)));
      Ky : constant Long_Float := Long_Float (Sin (Float (Alpha))) * Long_Float (Sin (Float (Phi)));
      Kz : constant Long_Float := Long_Float (Cos (Float (Alpha)));
      Nx : constant Long_Float := Long_Float (Sin (Float (Tilt_Angle)));
      Nz : constant Long_Float := Long_Float (Cos (Float (Tilt_Angle)));

      Cos_Theta_I : Long_Float;
   begin
      -- Dot product k . n = cos(Theta_I)
      Cos_Theta_I := Kx * Nx + Kz * Nz;
      if Cos_Theta_I > 1.0 then
         Cos_Theta_I := 1.0;
      elsif Cos_Theta_I < -1.0 then
         Cos_Theta_I := -1.0;
      end if;

      Theta_I := Long_Float (Arccos (Float (Cos_Theta_I)));
      --  Azimuthal rotation of the plane of incidence (k x n) relative to the tilt plane (y-axis)
      if Abs (Ky) < 1.0E-12 and then Abs (Kx * Nz - Kz * Nx) < 1.0E-12 then
         Psi := 0.0;
      else
         Psi := Long_Float (Arctan (Float (Ky), Float (Kx * Nz - Kz * Nx)));
      end if;

   end Cone_To_Plate_Angles;

 --  procedure Generate_LUT is
  package F_IO is new Ada.Text_IO.Float_IO (Long_Float);

   -- Grid resolution (adjust as needed for your external integrator)
   Alpha_Max_Deg : constant Long_Float := 30.0;  -- Half-angle of collection cone
   Alpha_Steps   : constant Integer    := 60;    -- 0.5 deg steps (0.0 to 30.0 deg)
   Phi_Steps     : constant Integer    := 72;    -- 5.0 deg steps (0.0 to 360.0 deg)

   procedure Write_Arm_CSV (Arm : Polarizer_Arm; Filename : String) is
      File       : Ada.Text_IO.File_Type;
      Tilt_Rad   : constant Long_Float := Brewster_Angle (Arm);
      Alpha_Deg  : Long_Float;
      Phi_Deg    : Long_Float;
      Alpha_Rad  : Long_Float;
      Phi_Rad    : Long_Float;
      Theta_I    : Long_Float;
      Psi        : Long_Float;
      Result     : Ray_Transmittance;
   begin
      Ada.Text_IO.Create (File => File, Mode => Ada.Text_IO.Out_File, Name => Filename);

      -- CSV Header
      Ada.Text_IO.Put_Line
        (File, "alpha_deg,phi_deg,theta_i_deg,psi_deg,Tp,Ts,T_parallel,T_perp");

      for A_Idx in 0 .. Alpha_Steps loop
         Alpha_Deg := (Alpha_Max_Deg * Long_Float (A_Idx)) / Long_Float (Alpha_Steps);
         Alpha_Rad := Alpha_Deg * Pi / 180.0;

         for P_Idx in 0 .. Phi_Steps loop
            Phi_Deg := (360.0 * Long_Float (P_Idx)) / Long_Float (Phi_Steps);
            Phi_Rad := Phi_Deg * Pi / 180.0;

            Cone_To_Plate_Angles (
               Tilt_Angle => Tilt_Rad,
               Alpha      => Alpha_Rad,
               Phi        => Phi_Rad,
               Theta_I    => Theta_I,
               Psi        => Psi
            );

            Result := Evaluate_Ray (
               Arm     => Arm,
               Theta_I => Theta_I,
               Psi     => Psi
            );

            -- Write formatted CSV row
            F_IO.Put (File, Alpha_Deg, Fore => 1, Aft => 4, Exp => 0);
            Ada.Text_IO.Put (File, ",");
            F_IO.Put (File, Phi_Deg, Fore => 1, Aft => 4, Exp => 0);
            Ada.Text_IO.Put (File, ",");
            F_IO.Put (File, Theta_I * 180.0 / Pi, Fore => 1, Aft => 4, Exp => 0);
            Ada.Text_IO.Put (File, ",");
            F_IO.Put (File, Psi * 180.0 / Pi, Fore => 1, Aft => 4, Exp => 0);
            Ada.Text_IO.Put (File, ",");
            F_IO.Put (File, Result.Tp, Fore => 1, Aft => 6, Exp => 0);
            Ada.Text_IO.Put (File, ",");
            F_IO.Put (File, Result.Ts, Fore => 1, Aft => 6, Exp => 0);
            Ada.Text_IO.Put (File, ",");
            F_IO.Put (File, Result.T_Parallel, Fore => 1, Aft => 6, Exp => 0);
            Ada.Text_IO.Put (File, ",");
            F_IO.Put (File, Result.T_Perp, Fore => 1, Aft => 6, Exp => 0);
            Ada.Text_IO.New_Line (File);
         end loop;
      end loop;

      Ada.Text_IO.Close (File);
      Ada.Text_IO.Put_Line ("Generated: " & Filename);
   end Write_Arm_CSV;

procedure Generate_LUT is
begin
   Write_Arm_CSV (Green_551nm,  "freedman_lut_551nm.csv");
   Write_Arm_CSV (Violet_423nm, "freedman_lut_423nm.csv");
end Generate_LUT;

end Freedman_Polarizer_Model;
