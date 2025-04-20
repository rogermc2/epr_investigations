
with Interfaces;

with Ada.Text_IO; use Ada.Text_IO;

with Utils;

package body Printing is

   procedure Print_Byte_Array (Name  : String; Data : Types.Byte_Array;
                               Start : Positive := 1; Finish : Natural := 0) is
      use Interfaces;
      Last  : Positive;
      Count : Integer := 1;
   begin
      if Finish > 0 then
         Last := Finish;
      else
         Last := Data'Length;
      end if;

      Put_Line (Name & ": ");
      if Start >= Data'First and then Finish <= Data'Last then
         for Index in Start .. Last loop
            Put (Unsigned_8'Image (Data (Index)) & "  ");
            Count := Count + 1;
            if Count > 10 then
               New_Line;
               Count := 1;
            end if;
         end loop;
      else
         Put_Line
           ("Print_Byte_Array called with invalid start or finish index.");
      end if;
      New_Line;

   end Print_Byte_Array;

   --  ------------------------------------------------------------------------

   procedure Print_Hex_Byte_Array (Name  : String; Data : Types.Byte_Array;
      Start : Positive := 1; Finish : Natural := 0) is
      Last  : Positive;
      Count : Integer := 1;
   begin
      if Finish > 0 then
         Last := Finish;
      else
         Last := Data'Length;
      end if;

      Put_Line (Name & ": ");
      if Start >= Data'First and then Finish <= Data'Last then
         for Index in Start .. Last loop
            Put (Utils.Hex (Data (Index)) & "  ");
            Count := Count + 1;
            if Count > 10 then
               New_Line;
               Count := 1;
            end if;
         end loop;
      else
         Put_Line
           ("Print_Hex_Byte_Array called with invalid start or finish index.");
      end if;
      New_Line;

   end Print_Hex_Byte_Array;

   --  ------------------------------------------------------------------------

end Printing;
