--  Freedman_Polarizer_Model exposes exact single-ray functions for arbitrary
--  incidence angles (theta {i}) and azimuthal tilt angles (φ).
--  When a ray enters a tilted pile-of-plates polarizer inside a finite
--  collection cone, two geometric effects occur simultaneously:
--  1. Effective Incidence Angle (\(\theta _{i}\)): The ray strikes the
--     plate normal at an angle shifted from Brewster's angle (theta {B}).
--  2. Plane-of-Incidence Rotation (ψ): Off-axis rays have a rotated plane
--     of incidence relative to the polarizer's nominal axis,
--     mixing T{p} and T_{s} into effective laboratory-frame transmittances
--     T{parallel} and T{perp}.

package Freedman_Polarizer_Model is

   Alpha_Steps : constant Integer := 60; -- 0.5 deg steps (0.0 to 30.0 deg)
   Phi_Steps   : constant Integer := 72;  -- 5.0 deg steps (0.0 to 360.0 deg)

   type Polarizer_Arm is (Green_551nm, Violet_423nm);

   type Ray_Transmittance is record
      --  Pure p-polarized transmittance in ray's local plane
      Tp         : Long_Float;
      --  Pure s-polarized transmittance in ray's local plane
      Ts         : Long_Float;
      --  Effective transmittance aligned with polarizer axis
      T_Parallel : Long_Float;
      --  Effective transmittance orthogonal to polarizer axis
      T_Perp     : Long_Float;
   end record;

   type LU_Record is record
      Alpha_Deg   : Long_Float;
      Phi_Deg     : Long_Float;
      Theta_I_Deg : Long_Float;
      Psi_Deg     : Long_Float;
      Tp          : Long_Float;
      Ts          : Long_Float;
      T_Parallel  : Long_Float;
      T_Perp      : Long_Float;
   end record;

   type LU_Array is array (Positive range <>, Positive range <>) of LU_Record;

   --  Brewster_Angle returns nominal Brewster's angle (in radians)
   --  for the selected arm
   --  function Brewster_Angle (Arm : Polarizer_Arm) return Long_Float;

   --  Evaluate_Ray computes single-ray transmittance for a given local
   --  incidence angle Theta_I (radians) and plane-of-incidence rotation
   --  Psi (radians) relative to the polarizer's transmission axis.
   function Evaluate_Ray (Arm : Polarizer_Arm;
      Theta_I : Long_Float; Psi : Long_Float := 0.0)
       return Ray_Transmittance;

   --  Helper: Converts cone polar angle Alpha and azimuth Phi (relative to
   --  optical axis) into local plate incidence angle Theta_I and
   --  plane rotation Psi.
   procedure Cone_To_Plate_Angles (
      --  Polarizer tilt relative to optical axis (usually Brewster_Angle)
      Tilt_Angle : Long_Float;
      --  Ray polar angle from optical axis (0 .. 30 deg in rad)
      Alpha      : Long_Float;
      --  Ray azimuth around optical axis (0 .. 2*Pi)
      Phi        : Long_Float;
      --  Rotation of local plane of incidence)
      Theta_I, Psi        : out Long_Float);
   procedure Generate_LUT;
   function Get_LU_Table return LU_Array;
   procedure Load_LU_Table (Arm : Polarizer_Arm);

end Freedman_Polarizer_Model;
