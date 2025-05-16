with Estimators;
with Samples;

procedure Statistics is

  type Data_Vector is array (Positive range <>) of Float;
  type Quantile_Table is array (Positive range <>) of Float;
   package Float_Estimators is new Estimators (Float, Data_Vector);
   package Float_Samples is new
     Samples (Float, Quantile_Table,  use_sub_histogram_index => False);

begin
   null;
end Statistics;
