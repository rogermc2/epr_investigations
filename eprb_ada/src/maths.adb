
package body Maths is

      --  NaN representation
      --  function NaN return Float is
      --     use Ada.Numerics.Elementary_Functions;
      --     X : constant Float := 0.0 / 0.0;
      --  begin
      --     return X;
      --  exception
      --     when others => return 0.0 / 0.0;
      --  end NaN;

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
