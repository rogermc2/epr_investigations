
with Ada.Containers;
with Ada.Text_IO; use Ada.Text_IO;

package body Basic_Printing is

   procedure Print_String_List (Name  : String; UB : Types.Bounded_String_List;
                                Start : Positive := 1; Finish : Natural := 0) is
      Last  : Positive;
      Count : Integer := 1;
   begin
      if Finish > 0 then
         Last := Finish;
      else
         Last := Integer (UB.Length);
      end if;

      Put_Line (Name & ": ");
      if Start >= UB.First_Index and then Finish <= UB.Last_Index then
         for Index in Start .. Last loop
            Put (UB (Index) & "  ");
            Count := Count + 1;
            if Count > 10 then
               New_Line;
               Count := 1;
            end if;
         end loop;
      else
         Put_Line ("Print_String_List called with invalid start or finish index.");
      end if;
      New_Line;

   end Print_String_List;

   --  ------------------------------------------------------------------------

   procedure Print_Unbound_List (Name  : String; UB : Types.Unbounded_List;
                                 Start : Positive := 1; Finish : Natural := 0) is
      Last  : Positive;
      Count : Integer := 1;
   begin
      if Finish > 0 then
         Last := Finish;
      else
         Last := Integer (UB.Length);
      end if;

      Put_Line (Name & ": ");
      if Start >= UB.First_Index and then Finish <= UB.Last_Index then
         for Index in Start .. Last loop
            Put (To_String (UB (Index)) & "  ");
            Count := Count + 1;
            if Count > 10 then
               New_Line;
               Count := 1;
            end if;
         end loop;
      else
         Put_Line ("Print_Unbound_List called with invalid start or finish index.");
      end if;
      New_Line;

   end Print_Unbound_List;

   --  ------------------------------------------------------------------------

end Basic_Printing;
