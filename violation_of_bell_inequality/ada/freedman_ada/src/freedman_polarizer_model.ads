--  Freedman_Polarizer_Model exposes exact single-ray functions for arbitrary
--  incidence angles (theta {i}) and azimuthal tilt angles (φ).
--  When a ray enters a tilted pile-of-plates polarizer inside a finite
--  collection cone, two geometric effects occur simultaneously:
--  1. Effective Incidence Angle (theta {i}):
--     The ray strikes the plate normal at an angle shifted from
--     Brewster's angle (theta {B}).
--  2. Plane-of-Incidence Rotation (ψ):
--     Off-axis rays have a rotated plane of incidence relative to the
--     polarizer's nominal axis, mixing T{p} and T{s} into an effective
--     laboratory-frame transmittances T{parallel} and T{perp}.

with Maths; use Maths;

package Freedman_Polarizer_Model is

   type Pile_Of_Plates_Polarizer is record
      Angle_Deg : Float;
      Eps_Major : Float;   --  Parallel transmittance (e.g., 0.97)
      Eps_Minor : Float;   --  Perpendicular leakage (e.g., 0.038)
      Inserted  : Boolean; --  True = in path, False = folded out of path
      Matrix    : Jones_Matrix;
   end record;

   Alpha_Steps : constant Integer := 60; -- 0.5 deg steps (0.0 to 30.0 deg)
   Phi_Steps   : constant Integer := 72;  -- 5.0 deg steps (0.0 to 360.0 deg)

   type Polarizer_Arm is (Green_551nm, Violet_423nm);

   --  s-Polarization and p-Polarization:
   --  Linear polarization components perpendicular (s) or
   --  parallel (p) to the plane of incidence.
   --  type Ray_Transmittance is record
   --     --  Pure p-polarized transmittance in ray's local plane
   --     T_S_Local  : Long_Float := Long_Float (0.0);
   --     --  Pure s-polarized transmittance in ray's local plane
   --     T_P_Local : Long_Float := Long_Float (0.0);
   --     --  Effective transmittance aligned with polarizer axis
   --     T_Parallel   : Long_Float := Long_Float (0.0);
   --     --  Effective transmittance orthogonal to polarizer axis
   --     T_Perp       : Long_Float := Long_Float (0.0);
   --  end record;

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

   function Freedman_Theory_Ratio (Phi_Deg : Float) return Float;
   --  procedure Generate_LUT;
   --  function Get_LU_Table return LU_Array;
   --  procedure Load_LU_Table (Arm : Polarizer_Arm);
   function Simulate_Coincidence
     (Num_Pairs : Positive; Angle_1, Angle_2 : Float;
      Seed      : Integer := 1972) return Float;

end Freedman_Polarizer_Model;
