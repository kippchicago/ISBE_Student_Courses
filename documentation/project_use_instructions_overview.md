# PROJECT USE INSTRUCTIONS

## Intro:
This document lays out a step-by-step guide for how to use this project.

## Project File Outline:

```
.
└── ISBE_Student_Courses
    |
    ├── README.md                   <- Description of project content and guide
    |                                  for users
    |
    ├── config                      <- Contains configuration files for project
    |                                  ProjectTemplate. List required libraries
    |                                  and scripts during `load.project()`.
    ├── data                        
    │   ├── 01-bq_files.R           <- Load files from Big Query Database
    │   ├── 02-gcs_files.R          <- Load files for Google Cloud Storage (GCS)
    │   ├── 03-manual_tables.R      <- Loads Manual Tables
    │   ├── flatfiles               <- Contains flatfiles downloaded from GCS
    │   └── README.md               <- Describes data folder
    |
    ├── documentation
    |   │── data_dictionary_bq      <- Data dictionary `data/01-bq_files.R`
    |   │── data_dictionary_gcs     <- Data dictionary `data/02-gcs_files.R`
    |   │── data_dictionary_manual  <- Data dictionary `data/03-manual_tables.R`
    |   └── data_schema             <- Details how some tables connect
    |
    ├── output
    │   ├── final_reports          <- Location for final output
    │   └── errors                  
    |       ├── original_files     <- Location for error report from CPS
    |       └── distinct_files     <- Location from distinct errors produced by
    |                                `02-A_produce_error_identification_files.R`
    |
    ├── src
    |   ├── 01-A_write_submission_files.R <- writes ISBE Reports to csv
    |   ├── 02-A_evaluate_cps_validation_period_errors <- Identify cps errors
    |   ├── 03-A_produce_write_submission_files_with_error_fixes.R <- fix errors
    |   ├── 02-B_write_error_identification_files.R <- writes error file to csv
    |   └── README.md
    |
    ├── munge
    |   ├── 01-A.R                  <- Script contains processes that clean
    |   |                                data across primary and middle school. Any
    |   |                                Data cleaning process that do not overlap
    |   |                                are in the separate primary and Middle
    |   |                                school files.
    |   ├── 02-A_primary.R          <- Specific primary munging
    |   ├── 03-A_middle.R           <- Specific middle school munging
    |   ├── 02-B_write_error_identification_files.R  <- write error files
    |   └── README.md
    |
    ├── lib                         
    |   └── helpers.R                <- All functions contained here.
    |
    ├── ISBE_Student_Courses.Rproject
    |
    └── .gitignore                   <- contains files that should not be
                                        uploaded to github.
```
## Step-by-Step Guide

### Initial Report Generation
1. Ensure that you have the `ProjectTemplate` package in R.
1. Ensure that you have All required R Packages (check the `config/global.dcf`
file for all required libraries).
1. Ensure that you have required permissions for KIPP Chicago Big Query and
Account.
1. Navigate to the `src` folder and run `01-A_produce-submission-files.R` file.
This will produce the report files in the required format for ISBE.
1. If you are ready to write the files to the output folder run the
`01-B_write-submission-files.R`

### Error Handling
1. After you receive your first error report from CPS navigate to the `src`
folder and run the `02-A_produce_error_identification_files.R` file. This file
will produce dataframes that show all unique errors per school file. This file
will also produce dataframes that list all unique name errors, date of birth
errors and cps id errors.
1. if you would like to write the files the `output/errors` folder then run the
`02-B_write_error_identification_files.R` script.
