import os
import pandas as pd
import matplotlib.pyplot as plt

# import do_process

cwd = os.getcwd()
print ("cwd: ", cwd)
# os.chdir("/System/Volumes/Data/Education/Python/Python_For_Data_Analytics/Python_For_Data_Analytics")
# cwd = os.getcwd()
# pd.set_option('display.precision', 12)
# pd.set_option("display.chop_threshold", 12)
# pd.options.display.float_format = '{:.12f}'.format

data_00=pd.read_csv("OEM_00.csv")
data_01=pd.read_csv("OEM_01.csv")
data_10=pd.read_csv("OEM_10.csv")
data_11=pd.read_csv("OEM_11.csv")
data_00.info()
# print (data["A Set"].describe())
# data["B Arrival Time"].describe()
# %%
# Arrival_Times = data[["A Arrival Time","B Arrival Time"]]
# Arrival_Times.plot(kind='line', title='Multiple Lines Plot')
# plt.show()

# %%
# do_process.process_data(data, closest_indices)
