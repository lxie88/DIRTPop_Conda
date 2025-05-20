#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Root Architecture Similarity Analysis Tool

This script calculates and visualizes the similarity/distance between different root architecture types
across genotypes. It is particularly useful for:
- Comparing root architecture patterns between different genotypes
- Identifying similar or distinct root architecture types
- Quantifying the degree of similarity using various distance metrics

The script takes input data containing root architecture measurements and generates:
1. A distance matrix showing pairwise similarities between different root types
2. A hierarchical clustering visualization (heatmap) of the relationships
3. A CSV file containing the distance matrix for further analysis

Available distance metrics:
- frechet: Fréchet distance (measures similarity between curves)
- pcm: Partial Curve Mapping
- area: Area between curves
- cl: Curve Length Measure
- dtw: Dynamic Time Warping
- mae: Mean Absolute Error
- mse: Mean Squared Error

Usage:
    python alignDistance.py -i input_file.csv -o output_plot.png -d distance_metric

Input file format:
    CSV file with columns:
    - Category: Identifier for each root type
    - Columns 1-9: Root architecture measurements at different depths

Created on Mon May 25 20:43:10 2020
@author: Limeng (Momo) Xie
"""
import numpy as np
import similaritymeasures
import matplotlib.pyplot as plt
import pandas as pd
import sys
import warnings
from typing import Tuple, Optional, Iterable
import argparse

# pass the bash arguments
parser = argparse.ArgumentParser(description="Distance calculation")
parser.add_argument('-i','--input', type = str, metavar='', required=True, help='The mean value of each cluster')
parser.add_argument('-o','--output', type = str, metavar='', required=True, help = "Distance matrix png")
parser.add_argument('-d','--distance', type = str, metavar='', required=True, help = "What distance you want to calculate: frechet, pcm, area, cl, dtw, mae, mse")

args = parser.parse_args()
data = pd.read_csv(args.input)

# create function to get the distance based on the user input
def get_distance(x, y, measure):
    if measure == "frechet":
        return similaritymeasures.frechet_dist(x, y)
    elif measure == "pcm":
        return similaritymeasures.pcm(x, y)
    elif measure == "area":
        return similaritymeasures.area_between_two_curves(x, y)
    elif measure == "cl":
        return similaritymeasures.curve_length_measure(x, y)
    elif measure == "dtw":
        dtw, _ = similaritymeasures.dtw(x, y)
        return dtw
    elif measure == "mae":
        return similaritymeasures.mae(x, y)
    elif measure == "mse":
        return similaritymeasures.mse(x, y)
    else:
        raise ValueError(f"Invalid distance measure: {measure}")

# Create the distance matrix
column = data['Category'].array
index = column
Dist_matrix = pd.DataFrame(data, index=index, columns=column)

# calculate the selected distance and fill into distance matrix
for n in range(data.shape[0]):
    for m in range(data.shape[0]):
        line1 = data.iloc[n:(n+1),1:10].to_numpy().reshape(9,)
        line2 = data.iloc[m:(m+1),1:10].to_numpy().reshape(9,)
        x=np.arange(0.1,1,step=0.1)
        line1_array = np.zeros((9,2))
        line1_array[:,0] = x
        line1_array[:,1] = line1
        line2_array = np.zeros((9,2))
        line2_array[:,0] = x
        line2_array[:,1] = line2
        distance = get_distance(line1_array, line2_array, args.distance)
        Dist_matrix.iloc[n,m] = distance

import seaborn as sns; sns.set(color_codes=True)
import scipy.spatial as sp, scipy.cluster.hierarchy as hc
sns.set(style="ticks", context="talk",font_scale=0.5)
#linkage = hc.linkage(sp.distance.squareform(Dist_matrix), method="ward")
linkage = hc.linkage((Dist_matrix), method="ward")
s = sns.clustermap(Dist_matrix,row_linkage=linkage,col_linkage=linkage,tree_kws=dict(linewidths=5, colors=("black")),cmap='terrain')
#s.savefig(args.output)
#Dist_matrix.to_csv(f"{args.distance}_distancematrix.csv")
# Creating a clustermap
#s = sns.clustermap(Dist_matrix, row_linkage=linkage, col_linkage=linkage,
#                   tree_kws=dict(linewidths=5, colors=("black")),
#                   cmap='terrain',
#                   figsize=(10, 10),  # Adjust figure size
#                   annot=True,  # Annotate each cell with the numeric value
#                   fmt=".1f",  # Formatting string for annotations
#                   annot_kws={"size": 8},  # Size of annotation text
#                   cbar_kws={"label": "Distance", "orientation": "vertical"},
#                   )

# Adjust label sizes
s.ax_heatmap.set_xticklabels(s.ax_heatmap.get_xmajorticklabels(), fontsize=15)
s.ax_heatmap.set_yticklabels(s.ax_heatmap.get_ymajorticklabels(), fontsize=15)
s.cax.set_ylabel('Distance', rotation=-90, va="bottom", fontsize=12)
s.cax.set_yticklabels(s.cax.get_ymajorticklabels(), fontsize=12)

# Save plot to file
s.savefig(args.output)
Dist_matrix.to_csv(f"{args.distance}_distancematrix.csv")