
with Random_Pair; use Random_Pair;
with Station; use Station;
with Types; use Types;

procedure Simulate is
   Photon_A : Vector_3D;
   Photon_B : Vector_3D;
begin
   Generate_Source_Data (Photon_A, Photon_B);
   Process_Photon (Photon_A);
   Process_Photon (Photon_B);

end Simulate;
