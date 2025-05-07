#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon May  5 12:03:07 2025

@author: Roger
"""
import pandas as pd

def get_closest_indices(df, col1, col2):
    """
    Finds the indices of the closest values in col2 for each value in col1.
    Args:
        df (pd.DataFrame): The DataFrame containing the columns.
        col1 (str): The name of the first column.
        col2 (str): The name of the second column.

    Returns:
        pd.Series: A Series containing the indices of the closest values in col2 for each value in col1.
    """
    indices = []
    for val in df[col1]:
      closest_index = (df[col2] - val).abs().idxmin()
      indices.append(closest_index)
    return pd.Series(indices, index=df.index)
