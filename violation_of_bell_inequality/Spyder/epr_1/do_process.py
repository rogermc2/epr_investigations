#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue May  6 11:53:24 2025

@author: Roger
"""

def all_pairs(A, B, match):
    u = 1e-06
    v = 5e-06
    delta = (u + v)/2
    w = abs(v - u)/2
    C = []
    print("A.head\n", A.head())
    print("B.head\n", B.head())
    print ("all_pairs match\n", match.head(10))
    print("w: ", w)
    for k, value in match.items():   
        a_index=k
        b_index=value
        if (k < 30):
            print("Match diff: ", (A.at[a_index,"A Arrival Time"] - B.at[b_index,"B Arrival Time"]).round(12))
        
        if (abs(B.at[b_index,"B Arrival Time"] - A.at[a_index,"A Arrival Time"]) <= w):
            C.append([A.at[a_index,"A Arrival Time"],B.at[b_index,"B Arrival Time"]])
    # head = C[0]
    print("C size: ", len(C))
    return C

def process_data (data, match):  
    A_Log = data[["A Arrival Time","A Set"," A Polarization"]]
    B_Log = data[["B Arrival Time"," B Set"," B Polarization"]]
    C_all = all_pairs(A_Log, B_Log, match)