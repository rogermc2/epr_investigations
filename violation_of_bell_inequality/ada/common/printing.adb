
with Interfaces;

with Ada.Text_IO; use Ada.Text_IO;

with Maths;
with Utils;

package body Printing is

   procedure Print_Byte_Array (Name  : String; Data : Byte_Array;
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
      if Start >= Data'First and then Last <= Data'Last then
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
           ("Print_Byte_Array called with invalid start or finish index:");
      end if;
      New_Line;

   end Print_Byte_Array;

   --  ------------------------------------------------------------------

   --  procedure Print_Hex_Byte_Array (Name  : String; Data : Byte_Array;
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
   --        Put ("Print_Hex_Byte_Array called with invalid start or");
   --        Put_Line (" finish index.");
   --     end if;
   --     New_Line;
   --
   --  end Print_Hex_Byte_Array;

   --  ------------------------------------------------------------------------

   procedure Print_Integer_List
     (Name  : String; Data : Integer_List;
      Start : Positive := 1; Finish : Natural := 0) is
      use Integer_List_Package;
      Last      : Natural;
      Item      : Integer;
      Num_Ones  : Natural := 0;
      Num_Minus : Natural := 0;
      Count     : Integer := 1;
   begin
      if Finish > 0 then
         Last := Finish;
      else
         Last := Natural (Length (Data));
      end if;

      Put_Line (Name & ": ");
      if Start >= Data.First_Index and then Finish <= Data.Last_index then
         for Index in Start .. Last loop
            Item := Data (Index);
            if Item = 1 then
               Num_Ones := Num_Ones + 1;
            elsif Item = -1 then
               Num_Minus := Num_Minus + 1;
            else
               Put_Line
                 ("Print_Integer_List invalid data: " & Integer'Image (Item));
            end if;
            Put (Integer'Image (Item) & "  ");
            Count := Count + 1;
            if Count > 10 then
               New_Line;
               Count := 1;
            end if;
         end loop;
      else
         Put_Line
           ("Print_Integer_List called with invalid start or finish index.");
      end if;
      New_Line;
      Put_Line ("Number of 1s, -1s: " &
                  Integer'Image (Num_Ones) & ", " & Integer'Image (Num_Minus));
      New_Line;

   end Print_Integer_List;

   --  ------------------------------------------------------------------------

    procedure Print_Double_Integer_Vector
       (Name  : String; Data : Double_Integer_Vector;
        Start : Positive := 1; Finish : Natural := 0) is
      use Double_Integer_Package;
      Last      : Natural;
      Item      : Double_Integer;
      Count     : Integer := 1;
   begin
      if Finish > 0 and then Finish <= Natural (Data.Last_index) then
         Last := Finish;
      else
         Last := Natural (Data.Last_index);
      end if;

      Put_Line (Name & ": ");
      if Start >= Data.First_Index and then Last <= Data.Last_index then
         for Index in Start .. Last loop
            Item := Data (Index);
            Put (Double_Integer'Image (Item) & ",  " );
            Count := Count + 1;
            if Count > 10 then
               New_Line;
               Count := 1;
            end if;
         end loop;
      else
         Put_Line
           ("Print_Double_Integer_Vector called with invalid" &
            " start or finish index.");
         Put_Line ("Start: " & Integer'Image (Start) & ",  Finish: " &
                   Integer'Image (Finish));
         Put_Line ("Data.First_Index: " & Integer'Image (Data.First_Index) &
                   ",  Data.Last_index: " & Integer'Image (Data.Last_index));
      end if;
      New_Line;

   end Print_Double_Integer_Vector;

   --  ------------------------------------------------------------------------
    procedure Print_Match_List (Name  : String; Data : Match_List;
                              Start : Positive := 1; Finish : Natural := 0) is
      use Match_Package;
      Last      : Natural;
      Item      : Index_Record;
      Count     : Integer := 1;
   begin
      if Finish > 0 and then Finish <= Natural (Data.Last_index) then
         Last := Finish;
      else
         Last := Natural (Data.Last_index);
      end if;

      Put_Line (Name & ": ");
      if Start >= Data.First_Index and then Last <= Data.Last_index then
         for Index in Start .. Last loop
            Item := Data (Index);
            Put (Integer'Image (Item.A_Index) & "  " &
               Integer'Image (Item.B_Index) & "; ");
            Count := Count + 1;
            if Count > 10 then
               New_Line;
               Count := 1;
            end if;
         end loop;
      else
         Put_Line
           ("Print_Match_List called with invalid start or finish index.");
         Put_Line ("Start: " & Integer'Image (Start) & ",  Finish: " &
                   Integer'Image (Finish));
         Put_Line ("Data.First_Index: " & Integer'Image (Data.First_Index) &
                   ",  Data.Last_index: " & Integer'Image (Data.Last_index));
      end if;
      New_Line;

   end Print_Match_List;

   --  ------------------------------------------------------------------------

   procedure Print_Statistics
     (Message : String; Mean_A, Mean_B, Mean_AB : Float;
      Detections : Sample_Data_List; Det_A, Det_B : Detect_Type) is
      use Maths;
      use Utils;
   begin
      Put_Line (Message & ": ");

      Put (" Sample_Mean A: " & Float'Image (Mean_A));
      Put_Line ("   Sample SD A: " & Float'Image (Sample_Std_Deviation
                (Get_Integer_List (Detections, Det_A), Mean_A)));
      Put (" Sample_Mean B: " & Float'Image (Mean_B));
      Put_Line ("   Sample SD B: " & Float'Image (Sample_Std_Deviation
                (Get_Integer_List (Detections, Det_B), Mean_B)));
      Put (" Sample_Mean AB: " & Float'Image (Mean_AB));
      Put_Line ("   Sample SD AB: " & Float'Image (Sample_Std_Deviation
                (Get_Integer_List (Detections, Det_B), Mean_AB)));

   end Print_Statistics;

   --  ------------------------------------------------------------------------

   procedure Print_String1_Array
     (Name  : String; Data : String1_Array;
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

   --  -----------------------------------------------------------------------

   procedure Print_String20_Array
     (Name  : String; Data : String20_Array;
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
         Put ("Print_String20_Array called with invalid start or");
         Put_Line (" finish index.");
      end if;
      New_Line;

   end Print_String20_Array;

   --  -----------------------------------------------------------------------

   procedure Print_String3_Array
     (Name  : String; Data : String3_Array;
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
           ("Print_String3_Array called with invalid start or finish index.");
      end if;
      New_Line;

   end Print_String3_Array;

   --  ------------------------------------------------------------------------

   procedure Print_String23_Array
     (Name  : String; Data : String23_Array;
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
           ("Print_String23_Array error: invalid start or finish index.");
      end if;
      New_Line;

   end Print_String23_Array;

   --  ------------------------------------------------------------------------

   procedure Print_String33_Array
     (Name  : String; Data : String33_Array;
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
           ("Print_String33_Array error: invalid start or finish index.");
      end if;
      New_Line;

   end Print_String33_Array;

   --  ------------------------------------------------------------------------

   procedure Print_String53_Array
     (Name  : String; Data : String53_Array;
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
           ("Print_String53_Array error: invalid start or finish index.");
      end if;
      New_Line;

   end Print_String53_Array;

   --  ------------------------------------------------------------------------

 procedure Print_String8_Array
     (Name  : String; Data : String8_Array;
      Start : Positive := 1; Finish : Natural := 0) is
      Last  : Positive := Data'Last;
   begin
      if Finish /= 0  and then Finish < Last then
         Last := Finish;
      end if;

      Put_Line (Name & ": ");
      if Start >= Data'First and then Last <= Data'Last then
         for Index in Start .. Last loop
            Put_Line (Integer'Image (Index) & ": " & Data (Index));
         end loop;
      else
         Put_Line
           ("Print_String8_Array error: invalid start or finish index.");
         Put_Line
           ("Start, Data'First: " & Integer'Image (Start) & ", " &
              Integer'Image (Data'First));
         Put_Line
           ("Finish, Data'Last: " & Integer'Image (Finish) & ", " &
              Integer'Image (Data'Last));
      end if;
      New_Line;

   end Print_String8_Array;

   --  ------------------------------------------------------------------------

   --  procedure Print_UB_String_Array
   --   (Name  : String; Data : UB_String_Array;
   --  Start : Positive := 1; Finish : Natural := 0) is
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
   --           Put ("Index " & Integer'Image (Index) & "  " &
   --           To_String (Data (Index)) & "  ");
   --           Count := Count + 1;
   --           if Count > 10 then
   --              New_Line;
   --              Count := 1;
   --           end if;
   --        end loop;
   --     else
   --        Put_Line
   --          ("Print_String1_Array error: invalid start or finish index.");
   --     end if;
   --     New_Line;

   --  end Print_UB_String_Array;

   --  ------------------------------------------------------------------------

end Printing;
