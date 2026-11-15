# ==============================================================================
# Tutorial 1 - Main Vignette (Importing and preprocessing data)
# ==============================================================================
# https://www.metaboanalyst.ca/resources/vignettes/Introductions.html

# Refresh environment and directory
rm(list = ls())
unlink("upload", recursive = TRUE)

# Working directory
setwd("/home/hhftang/Projects/MetaboAnalyzer-test/tutorial_1_main_vignette")

# 1. Notes
# ==============================================================================

# Importing data:
# ------------------------------------------------------------------------------
# - Use InitDataObjects to construct mSetObj object (e.g. mSet) that stores 
# user’s data for further processing and analysis
# - Must specify type of data and analysis

# Output:
# ------------------------------------------------------------------------------
# - MetaboAnalystR directly creates plots/tables/analysis outputs in current 
# working directory. 
# - Users are suggested to create a specific working directory every time they 
# perform any analysis, unless they want to overwrite existing results in 
# current directory. 
# - It is not necessary to call any plotting functions onto the created mSetObj.

# Data formats:
# ------------------------------------------------------------------------------
# .csv or .txt
# - concentration data, peak intensity tables, MS/NMR spectral bins
# - samples can be rows or columns
# - sample and feature names must be unique
# - class labels must immediately follow sample names
# - for two-factor and time-series, two class labels for two factors
# - for time-series data, one must be called "Time", and samples collected from
# the same subjects at diffeent time points should be consecutive
# - numeric or positive values only (+/- NA)

# File structure for statistical analysis
# ------------------------------------------------------------------------------
# NMR/MS peak list and GC/LC-MS spectral data:
# - folder containing data files from different groups under study 
# (one file per spectrum, one sub-folder for each group)
# - For paired comparison, users must upload a separate text file specifying 
# paired information.

# Raw LC-MS/MS spectral data:
# .mzML (recommended) /.mzXML/.mzData/.cdf
# - all vendor formats must be converted and centroided into .mzML files

# GC/LC-MS spectral data: 
# .NetCDF / .mzXML / .mzDATA 
# - Should be stored in two separate folders according to class labels

# Peak list files
# .csv
# - peak list files organized into separate folders named by class labels. 
# - first line of each is reserved for column label

# NMR peak list files 
# - two comma separated columns
# - 1st column: peak positions (ppm)
# - 2nd column: peak intensities (int)

# MS peak list files
# - either two-column (mass and intensities) or three-column format (mass, 
# retention time and intensities), but not mixture of both. 
# - 1st column: mass-charge ratio (mz)
# - 2nd column (opt.): retention time (rt)
# - 3rd column: intensities (int)

# 2. Data processing
# ==============================================================================

# Create object for data processing using InitDataObjects
# - R list structure
# - Contains information on type of data, data format, and paired or not paired
# - Also creates analSet and imgSet objects for downstream analyses
# - Also creates three libraries and databases
# - Also creates msg.vec for messsages produced during analysis
# - Must specify dataType: list, conc, specbin, pktable, nmrpeak, mspeak, msspec
# - Must specify analType: (type of analysis) stat, pathora, pathqea, msetora, 
# msetssp, msetpea, ts, cmpdmap, smpmap

# Read data file using Read.TextData
# - Must specify file path, data format and label type 

# Example dataset 1: Importing compound concentration dataset 
# ------------------------------------------------------------------------------
# “cachexia_concentrations.csv”
# - dataType: conc (compound concentration dataset)
# - analType: stat (statistical analysis)
# - Samples in rows, unpaired “rowu”, discrete (“disc”, vs. continuous)

# Note that mSet$dataSet$read.msg can be used to view the messages saved from 
# importing the dataset.

# Load MetaboAnalystR
library(MetaboAnalystR)

# Create objects for storing processed data
mSet <- InitDataObjects("conc", "stat", FALSE)
# Read in the data and fill in the dataSet list 
mSet <- Read.TextData(mSet,
                      "https://rest.xialab.ca/api/download/metaboanalyst/human_cachexia.csv", 
                      "rowu", "disc")

# To view messages from the data import and processing
print(mSet$msgSet$read.msg)
str(mSet)

# Removing sample variables
# ------------------------------------------------------------------------------
# - Reasons for removing samples: E.g. outliers, accidental duplicates

# Identifying outliers:
# - PlotNormSummary or PlotSampleNormSummary will give a box plot summary of 
# samples and features
# - PlotPCA2DScore will give you a 2D PCA score plot. outliers will be far away 
# from the main cluster. 
# - PlotHCTree and PlotHeatMap are two functions that perform hierarchical 
# clustering, providing you with a dendogram and a heatmap of the data, 
# respectively. 

# 3 functions to perform sample, feature, and group removal
# - Sample/feature/group removal must be performed following data processing and 
# filtering. 
# - If the data was normalized prior to removal, it is necessary to re-do the 
# normalization.

# E.g. using Compound Concentration dataset
# Remove a sample from the data set, in this case sample "PIF_178"
smpl.nm.vec <- c("PIF_178")# used to remove certain samples

# Remove a feature from the data set
feature.nm.vec <- c("2-Aminobutyrate")# used to remove certain feature, i.e. 2-Aminobutyrate

# Remove a group from the data set, in this case remove the "control" samples
grp.nm.vec <- c("control") # used to retain certain groups

mSet <- UpdateData(mSet)
str(mSet)

# Example dataset 2: importing peak intensity table
# ------------------------------------------------------------------------------
# Similar process
# - dataType: pktable 
# - analType: stat

mSet2 <- InitDataObjects("pktable", "stat", FALSE)
mSet2 <- Read.TextData(mSet2, 
                       "https://rest.xialab.ca/api/download/metaboanalyst/lcms_table.csv", 
                       "rowu", "disc")

print(mSet2[["msgSet"]][["read.msg"]])

# Example dataset 3: importing zipped peak list
# ------------------------------------------------------------------------------
# - dataType: mspeak
# - analType: stat

rm(list = ls())
unlink("upload", recursive = TRUE)

# Create an object for storing processed data
mSet <- InitDataObjects("mspeak", "stat", FALSE)

# Fetch an example data
# Zipped file of peak lists (“lcms_3col_peaks.zip”) from GitHub
download.file("https://rest.xialab.ca/api/download/metaboanalyst/lcms_3col_peaks.zip", 
              destfile = "lcms_3col_peaks.zip", 
              method = "wget")

# Unzips the uploaded zip file/s, removes it and saves it as "upload"
UnzipUploadedFile("lcms_3col_peaks.zip", "upload", F)

# Read peak lists/intensity files
mSet <- Read.PeakList(mSet, "upload")

# Read.PeakList 
# - Cretaes usable data matrix consistent with xcms matrix format
# - Must be formatted in 2 or 3 columns as mentioned above

print(mSet[["msgSet"]][["read.msg"]])

# Example dataset 4: importing and pre-processing nmr/ms peak lists
# ------------------------------------------------------------------------------
# - dataType: nmrpeak
# - analType: stat

rm(list = ls())
unlink("upload", recursive = TRUE)

# Initialize Objects
mSet <- InitDataObjects("nmrpeak", "stat", FALSE)

# Fetch data and unzipping
download.file("https://rest.xialab.ca/api/download/metaboanalyst/nmr_peaks.zip", 
              destfile = "nmr_peaks.zip", 
              method = "wget")
UnzipUploadedFile("nmr_peaks.zip", "upload")

# Read data in 
mSet <- Read.PeakList(mSet, "upload")
print(mSet[["msgSet"]][["read.msg"]])

# Perform grouping of peaks
mSet <- GroupPeakList(mSet, 0.025, 30.0)

# GroupPeakList 
# - Uses XCMS grouping algorithm to combine peaks across samples with similar 
# masses and retention times into groups. 
# - For NMR peaks, need to change ppm -> mz and add dummy rt
# - For 2-column MS, first need to add dummy rt 
# - For 3-column MS, data can be used directly
# - Arguments: 
#   - mSetObj: mSet Object
#   - mzwid: width of overlapping m/z slices for creating peak density chromatograms
# default: 0.25 m/z for ms; 0.03 ppm for nmr
#   - bw: bandwidth (sd or half width at half max) of gaussian smoothing kernel 
# to apply to peak density chromatogram
# default: 0.30 for LCMS; 5 for GCMS

# Form peak groups
mSet <- SetPeakList.GroupValues(mSet)

# SetPeakList.GroupValues 
# - cleans peak groups, summing multiple identical peaks within groups if they 
# originate from the same sample. 
print(mSet[["msgSet"]][["proc.msg"]])

# Data integerity check
# ------------------------------------------------------------------------------
# Data integrity check using SanityCheckData
# - ALWAYS necessary immediately after reading data, to ensure data is valid and 
# suitable for subsequent analyses (e.g. ReplaceMin, Normalization)
# - Evaluates accuracy of sample and class labels, and data structure, 
# - Deals with non-numeric values
# - Removes columns that are constant across all samples (variance = 0)
# - Replaces missing values with half of original minimal positive value in 
# dataset (default)
# - Ise mSet$dataSet$check.msg to view all collected messages that came from 
# running the sanity check

mSet <- SanityCheckData(mSet)

# Missing value imputation
# ------------------------------------------------------------------------------
# Missing values:
# - missing value imputation can be performed before or after normalization
# - Suggested default method for imputation is ReplaceMin: replaces all missing 
# or zero values in dataset with very small value (half smallest positive value 
# in original data)
# - Use mSet$dataSet$replace.msg to view value that replaced missing/zero values
# - NOTE: ReplaceMin is now replaced with PerformSanityClosure

# Replace missing/zero values with a minimum positive value
mSet <- PerformSanityClosure(mSet)

# Other imputation methods:
# 1) remove features with too many missing values, using RemoveMissingByPercent; 
# threshold is user
# - function also works directly upon dataSet object. 
# - E.g. removing any features with >50% missing values.
# 2) remove or replace remaining missing values, using ImputeMissingVar;
# - E.g. replacement based on min/mean/median value of each feature column
# - E.g. imputation using k-nearest neighbour (KNN), probabilistic PCA (PPCA), 
# Bayesian PCA (BPCA), or Singular Value Decomposition (SVD). 
# - E.g. exclude variables with missing values (“exclude”).

# STEP 1: Remove features containing a user-defined % cut-off of missing values
# mSet <- RemoveMissingByPercent(mSet, percent=0.5)
# mSet$msgSet$miss.filter.msg

# STEP 2: Remove variables with missing values
# mSet <- ImputeMissingVar(mSet, method="exclude")
# mSet$dataSet$containsBlank
# mSet$dataSet$missingCount

# Alternative with KNN
mSet <- ImputeMissingVar(mSet, method="knn_smp")

# Check if the sample size is too small, returns a 0 if the data passes the check
mSet <- IsSmallSmplSize(mSet)
mSet$dataSet$small.smpl.size

# IsSmallSmplSize(mSet) 
# - quick check evaluating if there are too many groups that contain a very 
# small number of replicates. 
# - Return 0 if data passes check
# - Return 1 if sample size too small

# Normalising data
# ------------------------------------------------------------------------------
# Row-wise normalization
# - 7 methods for reducing variation due to sampling
# - E.g. normalize data to reference feature (rowNorm = CompNorm), such as 
# internal standard within dataset, or to physiological constant (e.g. urine 
# creatine)
# - Normalization can be performed to reference sample or group of reference

# Column-wise normalization
# - 7 methods for centering, transforming, and scaling metabolomic data,
# cleaning it and reducing intra-group sample variation whilst focusing on 
# biologically relevant information.
# - Centering data: substract mean from variable, moving mean to 0;
# useful for adjusting for outliers and variation between high and low 
# concentration metabolites. 
# - Scaling data: each variable is divided by a chosen scaling factor, adjusting
# for fold differences in metabolite concentrations. 
# - Transformation: converts data to different scale, for instance to 
# logarithmic scale; aims to reduce heteroscedasticity and make unsymmetrical 
# data more symmetric. 

# Three examples in tutorial
# 1) Normalize data according to reference sample (Probabilistic Quotient 
# Normalization)
# “SamplePQN” is the mode of normalization
# “P037” is the reference sample.

# 2) Normalize data according to reference feature. 
# “CompNorm” is the mode of normalization
# “2.2882 is the reference feature.

# 3) Perform quantile normalization (“QuantileNorm”, replacing value of each 
# sample for each compound with quantile across all samples),
# log transformation (“LogNorm”), and mean-center scaling (“MeanCenter”).

# Viewing results:
# - PlotNormSummary: give feature-wise view of the data normalization
# - PlotSampleNormSummary: give sample-wise view of the normalization. 
# Both functions create before and after-normalization view of data, with 
# density plot and a box-plot.

### OPTION 1) Perform Probabilistic Quotient Normalization based upon a reference sample
# mSet <- PreparePrenormData(mSet)
# mSet <- Normalization(mSet, "SamplePQN", "NULL", "NULL", "P037")

### OPTION 2) Normalize by reference feature 
# mSet <- PreparePrenormData(mSet)
# mSet <- Normalization(mSet, "CompNorm", "NULL", "NULL", "2.2882")

### OPTION 3) Perform quantile normalization, log transformation, and mean-center scaling  
mSet <- PreparePrenormData(mSet)
mSet <- Normalization(mSet, "QuantileNorm", "LogNorm", "MeanCenter", ref=NULL)

# View feature normalization
mSet <- PlotNormSummary(mSet, "feature_norm", format="png", dpi=72, width=NA)

# View sample normalization
mSet <- PlotSampleNormSummary(mSet, "sample_norm", format="pdf", width=NA)

# Filtering data
# ------------------------------------------------------------------------------
# - Unsupervised method of feature selection
# - E.g. Removing variables with low variance across all samples
# - Particularly useful in untargeted metabolomics to remove uninformative noise

# 3 groups of uninformative data:
# 1) Small value variables: 
# - close to baseline/detection limit
# - Using mean/median filtering method can identify these
# 2) Near constant variables
# - variables with very low variance, as mentioned above. 
# - likely metabolites that have to do with housekeeping or homeostasis. 
# - Using standard deviation or more robust IQR will identify these
# 3) Variables with low repeatability
# - Repeatability refers to variation in repeat measurements of same sample at 
# different times. 
# - Measured using QC samples and calculated using RSD (RSD = SD/mean). 
# - Samples with high repeatability have low RSD, and vice-versa.
# - Features with a high RSD can be eliminated from dataset by specifying “rsd” 
# argument in FilterVariable function. 
# - For LC-MS data, the recommended cut-off is 20%
# - for GC-MS data, the recommended cut-off is 30%

# Guidelines:
# - Less than 250 variables: 5% will be filtered 
# - Between 250-500 variables: 10% will be filtered 
# - Between 500-1000 variables: 25% will be filtered 
# - Over 1000 variables: 40% will be filtered

# FilterVariable function
# - Arguments: filtering option (filter), whether or not the filtering is based 
# on quality-control (qcFilter) samples, and relative standard deviation (rsd). 
# - Option 1: uses median absolute deviation to filter variables, no QC-samples
# - Option 2: filtering method set to “none”, QC-Filter set to true, uses RSD 
# of 25 to filter samples. 

# Option 1: Filter variables based on the median absolute deviation, 
# percentage to filter out is 5 (%). No QS based filteration.
# mSet <- FilterVariable(mSet, "mad", 5, "F", 25, T)

# Option 2: Filter variables using Non-parametric relative standard deviation 
# (MAD/median) and a QC-based RDS threshold is 25. 
# mSet <- FilterVariable(mSet, "nrsd", 5, "T", 25, T)

# 3. Report generation with sweave
# ==============================================================================
# Following analysis, a comprehensive report can be generated which contains a 
# detailed description of each step performed in the R package, embedded with 
# graphical and tabular outputs. 
# To prepare the sweave report, please use the CreatePDFReport function. You 
# must ensure that you have the nexessary LaTeX libraries to generate the report 
# (i.e. texlive and texlive-fonts-extra). The object created must be named mSet, 
# and specify the user name in quotation marks.

# Create Biomarker Sweave report 
PreparePDFReport(mSet, "hhftang")

# To save all files created during your session
SaveTransformedData(mSet)
