
with Ada.Calendar; use Ada.Calendar;
with Ada.Exceptions; use Ada.Exceptions;
with Ada.Numerics.Elementary_Functions;
with Ada.Numerics; use Ada.Numerics;
with Ada.Text_IO; use Ada.Text_IO;

with Maths;     use Maths;
--  with Printing; use Printing;
with Utilities; use Utilities;

package body Detection is

   function Set_Polarizer (Settings : Settings_Vector) return Float;

   function Detect_Particle
     (Particle : Particle_Data; Setting : Float) return Result_Data
   is
      use Ada.Numerics.Elementary_Functions;
      Routine : constant String := "Detection.Detect_Particle";
      Spin_2  : constant Float := 2.0 * Particle.Spin;
      C       : Float;
      Outcome : Integer := 0;
   begin
      C :=
        Float ((-1) ** Natural (Spin_2)) *
          Cos (Spin_2 * (Setting - Particle.Pol));

      if Particle.Prob < abs (C) then
         if C > 0.0 then
            Outcome := 1;
         elsif C < 0.0 then
            Outcome := -1;
         end if;
      end if;

      return (Setting, Outcome);

   exception
      when Error : others =>
         Put_Line (Routine & "Exception information:  " &
                     Exception_Information (Error));
         raise;

   end Detect_Particle;

   function Get_Particles (File_Name : String) return Station_Type is
      Name    : Unbounded_String := To_Unbounded_String ("Unknown");
      Station : Station_Type;
   begin
      if File_Name = "data/source_A.bin" then
         Name := To_Unbounded_String ("A");
      elsif File_Name = "data/source_B.bin" then
         Name := To_Unbounded_String ("B");
      else
         Put_Line ("Get_Particles unknown file name: '" & File_Name & "'");
      end if;

      Station.Name := Name;
      Station.Particles := Load_Particles (File_Name);

      return Station;

   end Get_Particles;

   function Load_Results
     (Particles : Particle_Vector; Settings  : Settings_Vector)
      return Result_Vector is
      use Particle_Data_Package;
      --  Routine_Name    : constant String := "Detection.Load_Results ";
      Curs            : Cursor := Particles.First;
      Setting         : Float;
      Item            : Particle_Data;
      Particle_Pair   : Particle_Record;
      Pairs           : Pairs_Vector;
      Results         : Result_Vector;
   begin
      while Has_Element (Curs) loop
         Setting := Set_Polarizer (Settings);
         Item := Element (Curs);
         Particle_Pair := (Item, Setting);
         Pairs.Append (Particle_Pair);
         Next (Curs);
      end loop;

      declare
         use Pairs_Vector_Package;
         Curs_2   : Pairs_Vector_Package.Cursor := Pairs.First;
         Item     : Particle_Record;
         Result   : Result_Data;
      begin
         while Has_Element (Curs_2) loop
            Item := Element (Curs_2);
            Result := Detect_Particle (Item.Particle, Item.Setting);
            Result_Vector_Package.Append (Results, Result);
            Next (Curs_2);
         end loop;
      end;

      return Results;

   end Load_Results;

   procedure Run_Detection (File_Name : String; Settings : Settings_Vector;
                            Out_File  : out Unbounded_String) is
      use Particle_Data_Package;
      Routine_Name   : constant String  := "Detection.Run_Detection ";
      Num_Particles  : constant Natural := File_Length (File_Name);
      Station        : Station_Type      := Get_Particles (File_Name);
      Results        : Result_Vector;
      Start_Time     : Time;
      End_Time       : Time;
   begin
      if Num_Particles > 0 then
         Put_Line (Routine_Name & "Detecting particles for arm " &
                     To_String (Station.Name));
         Start_Time := Clock;
         Results := Load_Results (Station.Particles, Settings);
         --  Results ncontains the detection results
         End_Time := Clock;

         Put_Line
           (Integer'Image (Integer (Station.Particles.Length)) &
              " particles detected in " &
              Float'Image (Float (End_Time - Start_Time)) & " seconds.");

         Station.Results := Results;
         Out_File := To_Unbounded_String ("data/") & Station.Name &
           To_Unbounded_String (".bin");
         Save (To_String (Out_File), Station);
         Put_Line ("Data saved to: " & To_String (Out_File));
      else
         Put_Line (Routine_Name & "empty file: " & File_Name);
      end if;

      Put_Line ("Detection processing complete.");

   exception
      when Error : others =>
         Put_Line (Routine_Name & "Exception information:  " &
                     Exception_Information (Error));
         raise;

   end Run_Detection;

   function Set_Polarizer (Settings : Settings_Vector) return Float is
      use Settings_Vector_Package;
      Size   : constant Natural := Natural (Length (Settings));
      Index  : constant Positive := Random_Index (Size);
      Result : Float := 0.0;
   begin
      if Settings = Empty_Vector then
         Put_Line
           ("Detection.Set_Polarizer called with empty Settings vector");
      else
         Result := Settings (Index);
      end if;

      return Result;

   exception
      when Error : others =>
         Put_Line ("Size, Index, Result:  " & Integer'Image (Size) & "  " &
                    Integer'Image (Index) & "  " & Float'Image (Result));
         Put_Line ("Detection.Set_Polarizer Exception information:  " &
                     Exception_Information (Error));
         raise;

   end Set_Polarizer;

end Detection;
