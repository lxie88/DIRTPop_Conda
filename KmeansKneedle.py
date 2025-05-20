#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jun 15 14:21:04 2020
@author: Limeng Xie

This script is used to get the raw spectrum from DS curves.
"""

# Import required libraries
from sklearn.cluster import KMeans
import pandas as pd
from kneed import KneeLocator
import numpy as np

# Function to import DIRT format data, and return only the DS value for 10%-90% depth
def inputdata_ds(file):
    data = pd.read_csv(file,index_col=False)
    dswithtag = data[['IMAGE_NAME','DS10','DS20','DS30','DS40','DS50','DS60','DS70','DS80','DS90']]
    ds = dswithtag.iloc[:,1:10]
    return ds

# Function to import DIRT format data, and return the DS value for 10%-90% depth with Image Name
def inputdata_dswithtag(file):
    data = pd.read_csv(file,index_col=False)
    dswithtag = data[['IMAGE_NAME','DS10','DS20','DS30','DS40','DS50','DS60','DS70','DS80','DS90']]
    return dswithtag

# Function to determine the optimal number of clusters (K) for clustering using Elbow method
def kneepoint_onetime(K,ds):
    withinVar=[]
    for k in range(1, K+1):
        kmeansplusplus= KMeans(algorithm='auto',init= 'k-means++', max_iter=10, n_clusters=k,
                     random_state=None)
        model=kmeansplusplus.fit(ds)
        inerita=model.inertia_
        withinVar.append(inerita)
    x=[j for j in range(1,K+1)] # K number
    kn=KneeLocator(x, withinVar, S=1, curve='convex', direction='decreasing',interp_method='polynomial')
    kneepoint=kn.knee
    return kneepoint
    
# Function to get the most frequent knee point
def chooseCluster_num(n_trial_kneedle,ncluster_test,ds):
    kneepointlist = []
    for i in range (0,n_trial_kneedle):
        result = kneepoint_onetime(ncluster_test,ds)
        kneepointlist.append(result)
    cluster_num= int(max(kneepointlist,key=kneepointlist.count))
    return cluster_num
    
# Function to run n trials of kmeans++ clustering and choose the best trial based on the inertia score
def kmeansplusplus(n_trial, n_trial_kneedle, ncluster_test, ds, dswithtag):
    # Store the results
    tmp=[]
    # Determine the optimal number of clusters using the elbow method
    cluster_num = chooseCluster_num(n_trial_kneedle, ncluster_test, ds)
    # Print the optimal number of clusters
    print("Elbow method indicates number of clusters is:", cluster_num)
    # Run K-Means++ algorithm n_trial times
    for j in range (0, n_trial):
        # Initialize and fit KMeans++ model
        kmeansplusplus = KMeans(algorithm='auto',init= 'k-means++', max_iter=30, n_clusters=cluster_num,  random_state=None)
        model = kmeansplusplus.fit(ds)
        # Get labels of each point
        cluster_label = model.labels_.tolist()
        # Compute the total intra-cluster variance (inertia)
        inertia = model.inertia_
        inertia = np.asarray(inertia).tolist() # change float type to numpy array
        # Store the labels and corresponding inertia
        tmp.append((cluster_label, inertia))
    # Create a DataFrame to store each run's labels and inertia
    cols = ['label','inertia']
    result = pd.DataFrame(tmp, columns=cols)
    # Sort the trials by the ascending order of inertia
    result_sorted = result.sort_values(by=['inertia'], ascending=True)
    # Select the best labeling that has the smallest inertia
    best_label = result_sorted.iloc[0,0]
    # Add the best labels to the DataFrame
    dswithtag['cluster_label'] = best_label
    return dswithtag

