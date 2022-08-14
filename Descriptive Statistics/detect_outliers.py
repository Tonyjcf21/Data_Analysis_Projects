import pandas as pd
import numpy as np
import random

sample = [1, 2, 3, 5, 8, 9, 12, 300, 420, 8, 4, 2, 9]

def mean_and_std(sample):
    #create variables for mean and std from a sample
    sample = np.array(sample)
    sample_mean = sample.mean()
    sample_std = sample.std() #from documentation I saw that this is over the population. That is, 1/N.
    
    return sample_mean, sample_std
    
#DETECT OUTLIERS
def validation(sample, cutoff):
    #get mean and std from the previous function and return the new mean
    #with precision of 2 decimal points
    first_results = mean_and_std(sample)
    mean_before, std_before = first_results[0], first_results[1]

    while True:
        for number in sample:
            if number > mean_before+cutoff*std_before or number < mean_before-cutoff*std_before:
                sample.remove(number)

        sample = np.array(sample)
        mean_after = sample.mean()
        std_after = sample.std()
        new_mean = round(sample.mean(),2)
        if mean_after == mean_before and std_after == std_before:
            break
        else:
            mean_before = mean_after
            std_before = std_after
            sample = sample.tolist()
    print(sample)
    return new_mean
    
mean_and_std(sample)
validation(sample,2)
