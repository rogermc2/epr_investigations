
with Interfaces;

with Ada.Text_IO; use Ada.Text_IO;

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

   --  procedure Print_Hex_Byte_Array (Name  : String; Data : Types.Byte_Array;
   --     Start : Positive := 1; Finish : Natural := 0) is
   --     Last  : Positive;
   --     Count : Integer := 1;
   --  begin
   --     if Finish > 0 then
   --        Last := Finish;
   --     else
   --        Last := Data'Length;
   --     end if;
   --
   --     Put_Line (Name & ": ");
   --     if Start >= Data'First and then Finish <= Data'Last then
   --        for Index in Start .. Last loop
   --           Put (Utils.Hex (Data (Index)) & "  ");
   --           Count := Count + 1;
   --           if Count > 10 then
   --              New_Line;
   --              Count := 1;
   --           end if;
   --        end loop;
   --     else
   --        Put_Line
   --          ("Print_Hex_Byte_Array called with invalid start or finish index.");
   --     end if;
   --     New_Line;
   --
   --  end Print_Hex_Byte_Array;

   --  ------------------------------------------------------------------------

   procedure Print_String1_Array (Name  : String; Data : Types.String1_Array;
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
            Put (Data (Index) & "  ");
            Count := Count + 1;
            if Count > 10 then
               New_Line;
               Count := 1;
            end if;
         end loop;
      else
         Put_Line
           ("Print_String1_Array called with invalid start or finish index.");
      end if;
      New_Line;

   end Print_String1_Array;

   --  ------------------------------------------------------------------------

   procedure Print_String20_Array (Name  : String; Data : Types.String20_Array;
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
            Put (Data (Index) & "  ");
            Count := Count + 1;
            if Count > 10 then
               New_Line;
               Count := 1;
            end if;
         end loop;
      else
         Put_Line
           ("Print_String20_Array called with invalid start or finish index.");
      end if;
      New_Line;

   end Print_String20_Array;

   --  ------------------------------------------------------------------------

   procedure Print_String4_Array (Name  : String; Data : Types.String4_Array;
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
            Put (Data (Index) & "  ");
            Count := Count + 1;
            if Count > 10 then
               New_Line;
               Count := 1;
            end if;
         end loop;
      else
         Put_Line
           ("Print_String4_Array called with invalid start or finish index.");
      end if;
      New_Line;

   end Print_String4_Array;

   --  ------------------------------------------------------------------------

   procedure Print_String33_Array (Name  : String; Data : Types.String33_Array;
                                 Start : Positive := 1; Finish : Natural := 0) is
      Last  : Positive;
   begin
      if Finish > 0 then
         Last := Finish;
      else
         Last := Data'Length;
      end if;

      Put_Line (Name & ": ");
      if Start >= Data'First and then Finish <= Data'Last then
         for Index in Start .. Last loop
            Put_Line (Integer'Image (Index) & ": " & Data (Index));
         end loop;
      else
         Put_Line
           ("Print_String33_Array called with invalid start or finish index.");
      end if;
      New_Line;

   end Print_String33_Array;

   --  ------------------------------------------------------------------------

   procedure Print_String47_Array (Name  : String; Data : Types.String47_Array;
                                 Start : Positive := 1; Finish : Natural := 0) is
      Last  : Positive;
   begin
      if Finish > 0 then
         Last := Finish;
      else
         Last := Data'Length;
      end if;

      Put_Line (Name & ": ");
      if Start >= Data'First and then Finish <= Data'Last then
         for Index in Start .. Last loop
            Put_Line (Integer'Image (Index) & ": " & Data (Index));
         end loop;
      else
         Put_Line
           ("Print_String47_Array called with invalid start or finish index.");
      end if;
      New_Line;

   end Print_String47_Array;

   --  ------------------------------------------------------------------------

   --  procedure Print_UB_String_Array (Name  : String; Data : Types.UB_String_Array;
   --                                   Start : Positive := 1; Finish : Natural := 0) is
   --     use Interfaces;
   --     Last  : Positive;
   --     Count : Integer := 1;
   --  begin
   --     if Finish > 0 then
   --        Last := Finish;
   --     else
   --        Last := Data'Length;
   --     end if;
   --
   --     Put_Line (Name & ": ");
   --     if Start >= Data'First and then Finish <= Data'Last then
   --        for Index in Start .. Last loop
   --           Put ("Index " & Integer'Image (Index) & "  " & To_String (Data (Index)) & "  ");
   --           Count := Count + 1;
   --           if Count > 10 then
   --              New_Line;
   --              Count := 1;
   --           end if;
   --        end loop;
   --     else
   --        Put_Line
   --          ("Print_String1_Array called with invalid start or finish index.");
   --     end if;
   --     New_Line;

   --  end Print_UB_String_Array;

   --  ------------------------------------------------------------------------

end Printing;
