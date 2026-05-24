
package body Analysis_Types is

   function "<" (L, R : Setting_Map_Record) return Boolean is
   begin
      return (L.A + L.B) < (R.A + R.B);
   end "<";

   function "=" (L, R : Setting_Map_Record) return Boolean is
   begin
      return (L.A = R.B) and then (L.B = R.B);
   end "=";

   function ">" (L, R : Setting_Map_Record) return Boolean is
   begin
      return (L.A + L.B) > (R.A + R.B);
   end ">";

end Analysis_Types;
