# Scripts EEG with FieldTrip

## Description
This repository features a suite of scripts and functions designed for the comprehensive preprocessing, analysis, and visualization of electroencephalography (EEG) data. Built as a powerful tool for researchers, it handles everything from data preparation to advanced time-frequency statistics.

## Key Modules and Functionality
The code is structured into dedicated modules that cover the entire EEG processing pipeline, ensuring modularity and efficient workflow management.
The scripts work correctly with Fieldtrip version fieldtrip-20190224 in a MATLAB v2024b version. 

### 1. Preprocessing and Study Setup
**Main Preprocessing Script (Preprocessing_pipeline)**: Executes the essential pipeline for cleaning raw EEG data.

**General Study Features Script (General_Config)**: Extracts and documents fundamental study metrics (e.g., epoch duration, participant count, channel information), providing instant data overview.

### 2. Advanced Analysis & Statistics
The core of the project focuses on extracting temporal and spectral features, along with robust statistical evaluation.

**Time-Frequency (T-F) Analysis (TimeFreq_analyses):** Computes and analyzes the distribution of spectral power across time for various frequency bands and conditions sets in advance.

**Cluster-Based Permutation Testing (CBPT) (CBPT_TF_BT_subj):** Dedicated scripts apply CBPT to T-F data, identifying statistically significant regions in the time-frequency space while correcting for multiple comparisons for between group comparisons.

**Band Power Extraction:** Precisely calculates and extracts specific frequency band power metrics within defined electrode clusters and time windows.

### 3. Visualization
Grand Averages & Topoplots (Plots_TF, Plot_CBPT): Scripts to generate plots; Grand Average, individual participants waveforms and results from CBPT, including topoplots, to clearly visualize group-level findings and statistically significant differences.

## Disclaimer 
These scripts are provided "as is." Though great care was taken to ensure accuracy and functionality, there is no promise they are entirely error-free or perfectly suited for every scenario. Therefore, the onus is on the user to carefully examine and confirm all data and code aspects. I encourage to double-check every phase of preprocessing, statistical modeling, and final interpretation—to ensure validity. Any issue or suggestion for improvement can be report to the author. 


## Acknowledgement
This project is a derivative work by Raquel Lezama (raquellezama42@gmail.com) based on material from the EEG_introductory_workshop by Juan Linde-Domingo and Rodika Sokoliuk (March, 2025)
