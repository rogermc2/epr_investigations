--  Dependencies: GNAT (FSF) runtime only.
--  The two data files must be in the working directory
--  as in the Python original.

with Ada.Text_IO;
with Ada.Long_Float_Text_IO;
with Ada.Containers.Vectors;
with Ada.Numerics.Long_Elementary_Functions;
with Ada.Strings;
with Ada.Strings.Fixed;
with Ada.IO_Exceptions;

procedure Analysis is

   package TIO renames Ada.Text_IO;
   package LF_IO renames Ada.Long_Float_Text_IO;
   package LEF renames Ada.Numerics.Long_Elementary_Functions;

   subtype Int is Long_Long_Integer;

   --  One row of the combined arrays a_i, b_i, x_i, y_i, t_i (np.append in the original).
   type Trial is record
      A : Int;
      B : Int;
      X : Int;
      Y : Int;
      T : Int;
   end record;

   package Trial_Vectors is new Ada.Containers.Vectors
     (Index_Type => Natural, Element_Type => Trial);

   All_Trials : Trial_Vectors.Vector;

   --  Data columns 1..16 of the file (0-based indices 0..15 here,
   --  i.e. data[:,0] .. data[:,15]).
   type Field_Values is array (0 .. 15) of Int;
   type Corr_Matrix is array (0 .. 3, 0 .. 3) of Int;
   type Real_Vec is array (0 .. 3) of Long_Float;
   type Real_Array is array (Natural range <>) of Long_Float;
   type Real_Array_Access is access Real_Array;

   Data_Filepath_Old : constant String := "bell_open_data_2_old_detector.txt";
   Data_Filepath_New : constant String := "bell_open_data_2_new_detector.txt";
   Dashes : constant String (1 .. 40) := (others => '-');
   --  The new APD has a different calibrated detection-to-output delay.
   --  picoseconds after last sync-pulse
   Event_Ready_Window_Start_Channel0_Old : constant Int := 5426000;
   Event_Ready_Window_Start_Channel0_New : constant Int :=
      Event_Ready_Window_Start_Channel0_Old - 700;  -- picoseconds

   --  Analysis parameters
   -- picoseconds after last sync-pulse
   Event_Ready_Window_Start_Channel1 : constant Int := 5425100;
   --  picoseconds
   Event_Ready_Window_Length         : constant Int := 50000;
   Event_Ready_Window_Separation     : constant Int := 250000;
   Event_Ready_Second_Window_Length_Psi_Plus_Channel0  : constant Int := 4000;
   Event_Ready_Second_Window_Length_Psi_Plus_Channel1  : constant Int := 2500;
   --  nanoseconds after last sync-pulse
   Readout_Window_Start              : constant Int := 10620;
   -- nanoseconds
   Readout_Window_Length             : constant Int := 3700;
   -- number of attempts (sync-pulses)
   Check_For_Invalid_Marker_In_Past  : constant Int := 250;

   function Trim_Both (S : String) return String is
   begin
      return Ada.Strings.Fixed.Trim (S, Ada.Strings.Both);
   end Trim_Both;

   function Img (X : Int) return String is
   begin
      return Trim_Both (Int'Image (X));
   end Img;

   --  Equivalent of Python '{:.3f}' (Plus = False) and '{:+.3f}' (Plus = True).
   function Fmt (X : Long_Float; Aft : Natural; Plus : Boolean := False) return String is
      Buf : String (1 .. 100);
   begin
      LF_IO.Put (Buf, X, Aft => Aft, Exp => 0);
      declare
         T : constant String := Trim_Both (Buf);
      begin
         if Plus and then X >= 0.0 then
            return "+" & T;
         end if;
         return T;
      end;
   end Fmt;

   function Pad_Left (S : String; W : Natural) return String is
   begin
      if S'Length >= W then
         return S;
      else
         return (1 .. W - S'Length => ' ') & S;
      end if;
   end Pad_Left;

   --  Equivalent of numpy's printing of a 1-D int64 row, e.g. "[ 1 12  3  4]".
   function Img_Row (M : Corr_Matrix; Ii : Natural) return String is
      W : Natural := 0;
   begin
      for Jj in 0 .. 3 loop
         W := Natural'Max (W, Img (M (Ii, Jj))'Length);
      end loop;
      return "[" & Pad_Left (Img (M (Ii, 0)), W)
             & " " & Pad_Left (Img (M (Ii, 1)), W)
             & " " & Pad_Left (Img (M (Ii, 2)), W)
             & " " & Pad_Left (Img (M (Ii, 3)), W) & "]";
   end Img_Row;

   --  Splits a comma-separated line and stores fields 2..17 (file columns 1..16) in Values.
   --  The first field (datetime) is skipped, as it is not used in the analysis.
   procedure Parse_Line (Line : String; Values : out Field_Values) is
      Field_Index : Natural := 0;
      Start       : Integer := Line'First;
      Pos         : Integer;
   begin
      Values := (others => 0);
      loop
         Pos := Start;
         while Pos <= Line'Last and then Line (Pos) /= ',' loop
            Pos := Pos + 1;
         end loop;
         if Field_Index >= 1 and then Field_Index <= 16 then
            Values (Field_Index - 1) := Int'Value (Trim_Both (Line (Start .. Pos - 1)));
         end if;
         Field_Index := Field_Index + 1;
         exit when Pos > Line'Last;
         Start := Pos + 1;
      end loop;
      if Field_Index < 17 then
         raise Ada.IO_Exceptions.Data_Error with "expected at least 17 columns";
      end if;
   end Parse_Line;

   --  Reads one data file and appends the valid trials (np.append in the original loop).
   procedure Process_File (Path : String; Window_Start_Channel0 : Int) is
      File : TIO.File_Type;
      Buf  : String (1 .. 4096);
      Last : Natural;
      V    : Field_Values;
   begin
      TIO.Open (File, TIO.In_File, Path);
      while not TIO.End_Of_File (File) loop
         TIO.Get_Line (File, Buf, Last);
         declare
            Raw  : constant String := Buf (1 .. Last);
            Line : constant String :=
              (if Raw'Length > 0 and then Raw (Raw'Last) = ASCII.CR
               then Raw (Raw'First .. Raw'Last - 1)
               else Raw);
         begin
            --  np.loadtxt skips blank lines.
            if Trim_Both (Line)'Length > 0 then
               Parse_Line (Line, V);
               declare
                  Click1_Time    : constant Int := V (2);   -- window 1 detection time (ps)
                  Click1_Channel : constant Int := V (3);   -- window 1 detection channel
                  Click2_Time    : constant Int := V (4);   -- window 2 detection time (ps)
                  Click2_Channel : constant Int := V (5);   -- window 2 detection channel
                  Rnd_A          : constant Int := V (6);   -- random number at location A
                  Rnd_B          : constant Int := V (7);   -- random number at location B
                  Readout_A      : constant Int := V (10);  -- readout click time at A (ns), 0 if none
                  Readout_B      : constant Int := V (11);  -- readout click time at B (ns), 0 if none
                  Excite_A       : constant Int := V (12);  -- click after excitation at A, 0 if none
                  Excite_B       : constant Int := V (13);  -- click after excitation at B, 0 if none
                  Invalid_A      : constant Int := V (14);  -- sync-pulses since last invalid marker at A
                  Invalid_B      : constant Int := V (15);  -- sync-pulses since last invalid marker at B

                  --  Window 1 filters (See Supplementary Information, Section K)
                  W1C0 : constant Boolean :=
                    (Window_Start_Channel0 <= Click1_Time)
                    and (Click1_Time < (Window_Start_Channel0 + Event_Ready_Window_Length))
                    and (Click1_Channel = 0);
                  W1C1 : constant Boolean :=
                    (Event_Ready_Window_Start_Channel1 <= Click1_Time)
                    and (Click1_Time < (Event_Ready_Window_Start_Channel1 + Event_Ready_Window_Length))
                    and (Click1_Channel = 1);
                  W1   : constant Boolean := W1C0 or W1C1;

                  --  Window 2 psi-min filters
                  W2C0_Min : constant Boolean :=
                    ((Window_Start_Channel0 + Event_Ready_Window_Separation) <= Click2_Time)
                    and (Click2_Time < (Window_Start_Channel0 + Event_Ready_Window_Separation + Event_Ready_Window_Length))
                    and (Click2_Channel = 0);
                  W2C1_Min : constant Boolean :=
                    ((Event_Ready_Window_Start_Channel1 + Event_Ready_Window_Separation) <= Click2_Time)
                    and (Click2_Time < (Event_Ready_Window_Start_Channel1 + Event_Ready_Window_Separation + Event_Ready_Window_Length))
                    and (Click2_Channel = 1);

                  --  Window 2 psi-plus filters (short second window)
                  W2C0_Plus : constant Boolean :=
                    ((Window_Start_Channel0 + Event_Ready_Window_Separation) <= Click2_Time)
                    and (Click2_Time < (Window_Start_Channel0 + Event_Ready_Window_Separation + Event_Ready_Second_Window_Length_Psi_Plus_Channel0))
                    and (Click2_Channel = 0);
                  W2C1_Plus : constant Boolean :=
                    ((Event_Ready_Window_Start_Channel1 + Event_Ready_Window_Separation) <= Click2_Time)
                    and (Click2_Time < (Event_Ready_Window_Start_Channel1 + Event_Ready_Window_Separation + Event_Ready_Second_Window_Length_Psi_Plus_Channel1))
                    and (Click2_Channel = 1);

                  W2_Min  : constant Boolean := W2C0_Min or W2C1_Min;
                  W2_Plus : constant Boolean := W2C0_Plus or W2C1_Plus;

                  Psi_Min  : constant Boolean := Click1_Channel /= Click2_Channel;
                  Psi_Plus : constant Boolean := not Psi_Min;

                  Window_Filter : constant Boolean :=
                    (W1 and W2_Min and Psi_Min) or (W1 and W2_Plus and Psi_Plus);

                  No_Invalid_A_Filter : constant Boolean :=
                    (Invalid_A = 0) or (Invalid_A > Check_For_Invalid_Marker_In_Past);
                  No_Invalid_B_Filter : constant Boolean :=
                    (Invalid_B = 0) or (Invalid_B > Check_For_Invalid_Marker_In_Past);
                  No_Invalid_AB_Filter : constant Boolean :=
                    No_Invalid_A_Filter and No_Invalid_B_Filter;

                  No_Excitation_Click_AB_Filter : constant Boolean :=
                    (Excite_A = 0) and (Excite_B = 0);

                  Bell_Trial_Filter : constant Boolean :=
                    Window_Filter and No_Invalid_AB_Filter and No_Excitation_Click_AB_Filter;

                  --  Readout window checks (See Supplementary Information, Section K)
                  Detection_In_Readout_Window_A : constant Boolean :=
                    (Readout_A > Readout_Window_Start)
                    and (Readout_A <= Readout_Window_Start + Readout_Window_Length);
                  Detection_In_Readout_Window_B : constant Boolean :=
                    (Readout_B > Readout_Window_Start)
                    and (Readout_B <= Readout_Window_Start + Readout_Window_Length);

                  X_Val : constant Int := (if Detection_In_Readout_Window_A then 1 else -1);
                  Y_Val : constant Int := (if Detection_In_Readout_Window_B then 1 else -1);
                  T_Val : constant Int :=
                    (if Bell_Trial_Filter
                     then (if Psi_Plus then 1 else -1)
                     else 0);
               begin
                  All_Trials.Append ((A => Rnd_A, B => Rnd_B, X => X_Val, Y => Y_Val, T => T_Val));
               end;
            end if;
         end;
      end loop;
      TIO.Close (File);
   end Process_File;

   --  Returns P(X >= K) for X ~ Binomial(N, P), i.e. 1 - binom.cdf(K - 1, N, P).
   --  Computed as a sum of terms in log space to avoid underflow.
   function Binom_Sf (K : Int; N : Int; P : Long_Float) return Long_Float is
      Log_Fact : Real_Array_Access;
      Sum      : Long_Float := 0.0;
      Log_P    : Long_Float;
      Log_Q    : Long_Float;
   begin
      if K <= 0 then
         return 1.0;
      end if;
      if K > N then
         return 0.0;
      end if;
      Log_Fact := new Real_Array (0 .. Natural (N));
      Log_Fact (0) := 0.0;
      for I in 1 .. Natural (N) loop
         Log_Fact (I) := Log_Fact (I - 1) + LEF.Log (Long_Float (I));
      end loop;
      Log_P := LEF.Log (P);
      Log_Q := LEF.Log (1.0 - P);
      for I in Natural (K) .. Natural (N) loop
         Sum := Sum + LEF.Exp (Log_Fact (Natural (N))
                 - Log_Fact (I) - Log_Fact (Natural (N) - I)
                  + Long_Float (Natural (N - Int (I))) * Log_Q);
      end loop;
      return Sum;
   end Binom_Sf;

   S_Plus       : Long_Float := 0.0;
   S_Min        : Long_Float := 0.0;
   S_Err_Plus   : Long_Float := 0.0;
   S_Err_Min    : Long_Float := 0.0;
   N_Plus       : Int := 0;
   N_Min        : Int := 0;

begin

   --  Two datasets: before and after replacement of one APD at location C.
   Process_File (Data_Filepath_Old, Event_Ready_Window_Start_Channel0_Old);
   Process_File (Data_Filepath_New, Event_Ready_Window_Start_Channel0_New);

   --  Statistical analysis
   declare
      N   : Int := 0;   -- number of Bell trials
      K   : Int := 0;   -- sum of c_i
      Tau : constant Long_Float := 5.4e-6 * 2.0;
      Ksi : constant Long_Float := 3.0 / 4.0 + 3.0 * (Tau + Tau * Tau);
      P_Value : Long_Float;
   begin
      for Tr of All_Trials loop
         declare
            Abs_T : constant Int := abs (Tr.T);
            --  Python: (t+1)/2 is float; only matters when |t| = 1, where it is exactly 0 or 1.
            Expo  : constant Int := Tr.A * (Tr.B + (Tr.T + 1) / 2);
            Sgn   : constant Int := (if Expo mod 2 = 0 then 1 else -1);
         begin
            N := N + Abs_T;
            K := K + Abs_T * ((Sgn * Tr.X * Tr.Y + 1) / 2);
         end;
      end loop;

      P_Value := Binom_Sf (K, N, Ksi);

      TIO.Put_Line (Dashes);
      --  Python prints k as a numpy float64 (c_i involves /2), hence the ".0".
      TIO.Put_Line ("k/n: " & Img (K) & ".0/" & Img (N));
      TIO.Put_Line ("p-value : " & Fmt (P_Value, 3));

      for Psi_Idx in 1 .. 2 loop
         declare
            Psi : constant Int := (if Psi_Idx = 1 then 1 else -1);

            --  Inputs (a,b) and outputs (x,y) in the order used by the original.
            A_In  : constant array (0 .. 3) of Int := (0, 0, 1, 1);
            B_In  : constant array (0 .. 3) of Int := (0, 1, 0, 1);
            X_Out : constant array (0 .. 3) of Int := (1, 1, -1, -1);
            Y_Out : constant array (0 .. 3) of Int := (1, -1, 1, -1);

            Corr : Corr_Matrix := (others => (others => 0));
            E    : Real_Vec := (others => 0.0);
            Err  : Real_Vec := (others => 0.0);

            S_Val     : Long_Float;
            S_Err_Val : Long_Float;
            Total     : Int := 0;
         begin
            TIO.Put_Line (Dashes);
            TIO.Put_Line (if Psi = 1 then "psi_plus" else "psi_min");

            for Ii in 0 .. 3 loop
               for Jj in 0 .. 3 loop
                  for Tr of All_Trials loop
                     if Tr.T = Psi
                       and then Tr.A = A_In (Ii)
                       and then Tr.B = B_In (Ii)
                       and then Tr.X = X_Out (Jj)
                       and then Tr.Y = Y_Out (Jj)
                     then
                        Corr (Ii, Jj) := Corr (Ii, Jj) + 1;
                     end if;
                  end loop;
               end loop;

               --  <x.y>_(a,b), equation (1) of the main text
               declare
                  Row_Total : constant Long_Float :=
                    Long_Float (Corr (Ii, 0) + Corr (Ii, 1) + Corr (Ii, 2) + Corr (Ii, 3));
                  Numer     : constant Long_Float :=
                    Long_Float (Corr (Ii, 0) - Corr (Ii, 1) - Corr (Ii, 2) + Corr (Ii, 3));
               begin
                  if Row_Total = 0.0 then
                     --  Python would give nan here; see notes.
                     E (Ii)   := 0.0;
                     Err (Ii) := 0.0;
                  else
                     E (Ii)   := Numer / Row_Total;
                     Err (Ii) := LEF.Sqrt ((1.0 - E (Ii) * E (Ii)) / Row_Total);
                  end if;
               end;
            end loop;

            for Ii in 0 .. 3 loop
               for Jj in 0 .. 3 loop
                  Total := Total + Corr (Ii, Jj);
               end loop;
            end loop;

            --  CHSH S parameter
            S_Err_Val := LEF.Sqrt (Err (0) * Err (0) + Err (1) * Err (1)
                                   + Err (2) * Err (2) + Err (3) * Err (3));

            if Psi = 1 then
               S_Val := E (0) + E (1) - E (2) + E (3);
               S_Plus     := S_Val;
               S_Err_Plus := S_Err_Val;
               N_Plus     := Total;
            else
               S_Val := E (0) + E (1) + E (2) - E (3);
               S_Min      := S_Val;
               S_Err_Min  := S_Err_Val;
               N_Min      := Total;
            end if;

            TIO.Put_Line ("xy     ++,+-,-+,--");
            TIO.Put_Line ("ab 00 " & Img_Row (Corr, 0) & "   (0,    -3pi/4)");
            TIO.Put_Line ("ab 01 " & Img_Row (Corr, 1) & "   (0,    +3pi/4)");
            TIO.Put_Line ("ab 10 " & Img_Row (Corr, 2) & "   (pi/2, -3pi/4)");
            TIO.Put_Line ("ab 11 " & Img_Row (Corr, 3) & "   (pi/2, +3pi/4)");
            TIO.New_Line;

            TIO.Put_Line (" E (RND00  RND01  RND10  RND11 )");
            TIO.Put_Line ("   (" & Fmt (E (0), 3, True) & ", " & Fmt (E (1), 3, True)
                          & ", " & Fmt (E (2), 3, True) & ", " & Fmt (E (3), 3, True)
                          & ") measured");
            TIO.Put_Line ("+/-( " & Fmt (Err (0), 3) & ",  " & Fmt (Err (1), 3)
                          & ",  " & Fmt (Err (2), 3) & ",  " & Fmt (Err (3), 3) & " )");

            TIO.Put_Line ("CHSH S : " & Fmt (S_Val, 3) & " +- " & Fmt (S_Err_Val, 3));
         end;
      end loop;
   end;

   declare
      N_Tot        : constant Int := N_Min + N_Plus;
      S_Combined   : Long_Float;
      S_Err_Comb   : Long_Float;
   begin
      if N_Tot = 0 then
         --  Python would give nan here; see notes.
         S_Combined := 0.0;
         S_Err_Comb := 0.0;
      else
         declare
            Fp : constant Long_Float := Long_Float (N_Plus) / Long_Float (N_Tot);
            Fm : constant Long_Float := Long_Float (N_Min) / Long_Float (N_Tot);
         begin
            S_Combined := Fp * S_Plus + Fm * S_Min;
            S_Err_Comb := LEF.Sqrt (Fp * Fp * S_Err_Plus * S_Err_Plus
                                    + Fm * Fm * S_Err_Min * S_Err_Min);
         end;
      end if;

      TIO.Put_Line (Dashes);
      TIO.Put_Line ("psi_plus, psi_min combined");
      TIO.Put_Line ("CHSH S : " & Fmt (S_Combined, 3) & " +- " & Fmt (S_Err_Comb, 3));
   end;

end Analysis;
