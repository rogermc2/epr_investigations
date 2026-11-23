
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Ada.Numerics.Real_Arrays; use Ada.Numerics.Real_Arrays;
with Ada.Text_IO; use Ada.Text_IO;

with Maths; use Maths;

procedure Freedman is
   a      : constant Real_Vector := (0.0, 0.5, 0.0);
   b      : constant Real_Vector := (0.5, 0.5, 0.0);
   lambda : constant Real_Vector := (0.5, -0.3, 0.6);
   Result : constant Float := AB (a, b, lambda);
begin
   Put_Line ("Hello!");
   Put (Result);
   
end Freedman;
