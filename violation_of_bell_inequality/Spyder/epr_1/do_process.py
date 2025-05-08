#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue May  6 11:53:24 2025

@author: Roger
"""

def all_pairs(A, B, match):
    # u = 1e-06
    # v = 5e-06
    # delta = (u + v)/2
    # w = abs(v - u)/2
    w = 5e-09
    C = []
    print("all_pairs A.head\n", A.head())
    print("all_pairs B.head\n", B.head())
    print ("all_pairs match\n", match.head(10))

    print("w: ", w)
    for k, value in match.items():   
        a_index=k
        b_index=value
        if (abs(B.at[b_index,"B Arrival Time"] - A.at[a_index,"A Arrival Time"]) <= w):
            C.append([a_index,b_index])
    print("C size: ", len(C))
    for i in C[:10]:  
        print(i[0],i[1],A.at[i[0],"A Arrival Time"],B.at[i[1],"B Arrival Time"])
    # For individual values
    print("all_pairs ndividual A values",f"A[221]: {A.at[221, 'A Arrival Time']:.12f}")
    print("all_pairs ndividual B values",f"B[140]: {B.at[140, 'B Arrival Time']:.12f}")

    return C

def process_data (data, match):  
    A_Log = data[["A Arrival Time","A Set"," A Polarization"]]
    B_Log = data[["B Arrival Time"," B Set"," B Polarization"]]
    C_all = all_pairs(A_Log, B_Log, match)
    for i in range (6):
        print ("process_data.C_all", C_all[i])