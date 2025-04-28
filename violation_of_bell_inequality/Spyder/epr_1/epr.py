import os
import pandas as pd

cwd = os.getcwd()
print ("cwd: ", cwd)
# os.chdir("/System/Volumes/Data/Education/Python/Python_For_Data_Analytics/Python_For_Data_Analytics")
# cwd = os.getcwd()
data=pd.read_csv("Long_Dist.csv")
data.info()