with Estimators;

procedure Statistics is

  type Data_vector is array (Positive range <>) of Float;
   package Float_Estimators is new Estimators (Float, Data_vector);

begin
   null;
end Statistics;
