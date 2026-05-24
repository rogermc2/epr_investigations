
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;

package body Maths is

   function Sample_Error
     (Data : Sample_Data_List; Std_Deviation : Float) return Float is
   begin
      return Std_Deviation ** 2 /
        (Sqrt (Float (Sample_Data_Package.Length (Data))));

   end Sample_Error;

   function Sample_Std_Deviation
     (Data : Integer_List; Mean : Float) return Float is
      use Integer_List_Package;
      Count      : Natural := 0;
      Curs       : Cursor := Data.First;
      Dev_Sq     : Float;
      Sum_Dev_Sq : Float := 0.0;
      Var        : Float;

   begin
      while Has_Element (Curs) loop
         Count := Count + 1;
         Dev_Sq := (Float (Element (Curs)) - Mean) ** 2;
         Sum_Dev_Sq := Sum_Dev_Sq + Dev_Sq;
         Curs := Next (Curs);
      end loop;

      Var := Sum_Dev_Sq / Float (Count - 1);

      return Sqrt (Var);

   end Sample_Std_Deviation;

end Maths;
