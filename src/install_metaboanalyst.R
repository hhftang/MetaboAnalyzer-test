# ==============================================================================
# Sources
# ==============================================================================
# https://www.metaboanalyst.ca/docs/RTutorial.xhtml
# https://github.com/xia-lab/MetaboAnalystR

# ==============================================================================
# Install dependencies
# ==============================================================================
install.packages("pacman")
library(pacman)

pacman::p_load(impute, pcaMethods, globaltest, GlobalAncova, Rgraphviz, 
               preprocessCore, genefilter, sva, limma, KEGGgraph, 
               siggenes, BiocParallel, MSnbase, multtest, RBGL, edgeR, fgsea,
               httr, qs2)

# ==============================================================================
# Install MetaboAnalyst R
# ==============================================================================

# Step 1: Install devtools
install.packages("devtools")
library(devtools)

# Step 2: Install MetaboAnalystR
# Due to issues with Latex, some users may find that they are only able to 
# install MetaboAnalystR 4.0 without any documentation (i.e. vignettes).
# Refer instead to: 
# https://www.metaboanalyst.ca/resources/vignettes/Introductions.html
devtools::install_github("xia-lab/MetaboAnalystR",
                         build = TRUE,
                         build_vignettes = TRUE,
                         build_manual =T)

