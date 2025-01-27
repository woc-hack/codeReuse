# Replication Package for the Paper "Beyond Dependencies: The Role of Copy-Based Reuse in Open Source Software Development"

This package contains the scripts and information required to replicate our findings.

The data source we used in our study is World of Code (WoC) infrastructure. This resource is available for anyone who is interested in doing research in OSS and you may visit https://worldofcode.org/ to get access to it.

We provide the scripts that work on WoC servers and will reproduce the same results.

Specifically:  

## scripts: scripts that run on WoC to curate the data  

1. **reuse.sh**  
    The scripts to create all the blob copy instances (RQ1-a and RQ1-b).

2. **blobs.sh**   
    The scripts used to analyze the blob sample (RQ1-c).

3. **projects.sh**  
    The scripts used to analyze the project sample (RQ1-d).

4. **survey.sh** & **survey.ipynb**  
    The scripts used to sample survey participants (RQ2).

## analysis: notebooks for statistical analysis 

1. **blob.ipynb**  
    Blob-level analysis (RQ1-c).

2. **project.ipynb**  
    Project-level analysis (RQ1-d).

3. **python_plots.ipynb**  
    The code to create the plots used in the paper.

## survey: the survey questionnaire  

1. **survey0.pdf**  
    Questionnaire used in the preliminary round.

2. **survey1.pdf**  
    Questionnaire used in round 1.

3. **survey2.pdf**  
    Questionnaire used in round 2.
