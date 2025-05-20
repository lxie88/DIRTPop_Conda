
## Prerequisites

- Make sure you have R installed on your system.
- Ensure you have the required R packages installed. You can install them using:
  ```R
  install.packages(c("reticulate", "roahd", "optparse", "tidyr", "ggplot2", "ggpubr"))
  ```
- You should have a conda environment named `DIRTPop` set up. If not, you can create it using:
  ```bash
  conda create -n DIRTPop
  conda activate DIRTPop
  ```

## Creating the Conda Environment (strongly suggest this to build the project environment)

To create the conda environment using the provided `dirtpop_environment.yml` file, follow these steps:

1. Open your terminal and navigate to the project directory.
2. Run the following command to create the environment:
   ```bash
   conda env create -f dirtpop_environment.yml
   ```
3. Activate the environment:
   ```bash
   conda activate DIRTPop
   ```

This will set up the environment with all the necessary packages and dependencies.

## Step 1: Run DirtPop.R

1. Open your terminal and navigate to the project directory.
2. Activate the conda environment:
   ```bash
   conda activate DIRTPop
   ```
3. Run the DirtPop.R script with your input file. For example:
   ```bash
   Rscript DirtPop.R -f DIRTtest.csv -o clustered_results.csv -n 10 -m 10 -k 25
   ```
   - `-f`: Input file (e.g., DIRTtest.csv)
   - `-o`: Output file name (e.g., clustered_results.csv)
   - `-n`: Number of kmeans++ trials (e.g., 10)
   - `-m`: Number of kneedle algorithm trials (e.g., 10)
   - `-k`: Maximum number of clusters to test (e.g., 15)

## Step 2: Plot the Results

1. After running DirtPop.R, you will have a file named `clustered_results.csv`.
2. To plot the results, run the DrawSpectrum.R script:
   ```bash
   Rscript DrawSpectrum.R clustered_results.csv clustered_plot jco 12 6
   ```
   - The first argument is the input file (clustered_results.csv).
   - The second argument is the base name for the output files (e.g., clustered_plot).
   - The third argument is the color palette (e.g., jco).
   - The fourth and fifth arguments are the width and height of the plot (e.g., 12 and 6).

3. This will generate:
   - `clustered_plot_spec.png`: The spectrum plot image.
   - `clustered_plot_clusterstat.csv`: The cluster statistics.

## Troubleshooting

- If you encounter any errors, ensure that your conda environment is activated and that all required packages are installed.
- Check the input file format to ensure it matches the expected structure.

## Using aligndistance.py

The `aligndistance.py` script is designed to compare the similarity of root architecture types across different genotypes. It allows users to choose the distance metric they want to use for the comparison.

### Purpose
- This script helps in analyzing the similarity between root architectures of different genotypes.
- It provides flexibility in selecting the distance metric for comparison.

### How to Use
1. Open your terminal and navigate to the project directory.
2. Run the script using the following command:
   ```bash
   python aligndistance.py
   ```
3. Follow the prompts to select the desired distance metric and input the necessary data.

Happy coding! 
