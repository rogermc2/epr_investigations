
package body Maths is

   function Sign (X : Interfaces.C.double) return Integer is
   begin
      if X > 0.0 then
         return 1;
      elsif X < 0.0 then
         return -1;
      else
         return 0;
      end if;

   end Sign;

end Maths;
