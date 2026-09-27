
package body Station is

   procedure Apply_Pockell (Photon : Vector_3D; Angle : Boolean) is
   begin
      null;
   end Apply_Pockell;

   procedure Process_Photon (Photon : Vector_3D) is
      Angle : constant Boolean := False;
   begin
      Apply_Pockell (Photon, Angle);
   end Process_Photon;

end Station;