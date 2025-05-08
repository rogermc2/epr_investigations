import os
import pandas as pd
import matplotlib.pyplot as plt

import utilities
import do_process

cwd = os.getcwd()
print ("cwd: ", cwd)
# os.chdir("/System/Volumes/Data/Education/Python/Python_For_Data_Analytics/Python_For_Data_Analytics")
# cwd = os.getcwd()
# pd.set_option('display.precision', 12)
# pd.set_option("display.chop_threshold", 12)
# pd.options.display.float_format = '{:.12f}'.format

data=pd.read_csv("Long_Dist.csv")
data['A Arrival Shifted'] = data['A Arrival Time'].shift(-5, fill_value=0)
data.info()
# %%
data["A Arrival Time"].describe()
# %%
data["B Arrival Time"].describe()
# %%
Arrival_Times = data[["A Arrival Time","B Arrival Time"]]
Arrival_Times.plot(kind='line', title='Multiple Lines Plot')
plt.show()
# %%
Arrival_Times.head(10)
data['Difference'] = data['B Arrival Time'] - data['A Arrival Time']
print('Differences\n', data.head())

Diff_Times = data[["Difference"]].round(12)
Diff_Times.plot(kind='line', title='Arrival Time Differences')
plt.show()
# %%
closest_indices = utilities.get_closest_indices(data, 'A Arrival Time', 'B Arrival Time')
print(closest_indices)
print("closest_indices\n", closest_indices.head(20))
print()
print ("A10-B5", (data.at[10, 'A Arrival Time'] - data.at[5, 'B Arrival Time']))
print ("A11-B5", (data.at[11, 'A Arrival Time'] - data.at[5, 'B Arrival Time']))
print ("A12-B5", (data.at[12, 'A Arrival Time'] - data.at[5, 'B Arrival Time']))
print ("A9996-B7552", (data.at[9996, 'A Arrival Time'] - data.at[7552, 'B Arrival Time']))
print ("A9997-B7552", (data.at[9997, 'A Arrival Time'] - data.at[7552, 'B Arrival Time']))
print ("A9998-B7552", (data.at[9998, 'A Arrival Time'] - data.at[7552, 'B Arrival Time']))
print ("A9997-B7552", (data.at[9997, 'A Arrival Time'] - data.at[7552, 'B Arrival Time']))
# %%
Arrival_Times.iloc[0:100].plot(kind='line', title='Multiple Lines Plot')
plt.show()
print ("Arrival_Times", Arrival_Times.head(10))

# %%
do_process.process_data(data, closest_indices)
