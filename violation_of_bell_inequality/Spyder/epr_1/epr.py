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
print()

data_00=pd.read_csv("OEM_00.csv")
data_01=pd.read_csv("OEM_01.csv")
data_10=pd.read_csv("OEM_10.csv")
data_11=pd.read_csv("OEM_11.csv")
print("data_00.info")
data_00.info()
print()
print ("Count 00 AB: ",data_00["AB"].count())
data_00["A Det"].hist()
print()
print ("data_00:")
print (data_00.describe())
print()
print ("data_01:")
print (data_01.describe())
print()
print ("data_10:")
print (data_10.describe())
print()
print ("data_11:")
print (data_11.describe())
print ("data AB mean:")
print (data_00["AB"].mean())
print (data_01["AB"].mean())
print (data_10["AB"].mean())
print (data_11["AB"].mean())
print ("data A+B mean:")
print (data_00["A+B"].mean())
print (data_01["A+B"].mean())
print (data_10["A+B"].mean())
print (data_11["A+B"].mean())
print ("data AB std dev:")
print (data_00["AB"].std())
print (data_01["AB"].std())
print (data_10["AB"].std())
print (data_11["AB"].std())
# %%
Det_Vals = data_00[["A Det","AB"]]
Det_Vals.plot(kind='line', title='Multiple Lines Plot')

plt.show()

# %%
# do_process.process_data(data, closest_indices)
