# PROJECT USE INSTRUCTIONS

## Intro:
This document lays out a step-by-step overview for how to use this repository.
For more detailed information check out the ISBE Midyear Report Process Documentation file located at the top level of this repo (Note: This file Contains
private information and is not available for people outside of the organization).

## Step-by-Step Guide

### Initial Report Generation
1. Ensure that you have the `ProjectTemplate` package installed in R.
1. Ensure that you have All required R Packages (check the `config/global.dcf`
file for all required libraries).
1. Ensure that you have required permissions for KIPP Chicago Google Cloud Platform
account (Big Query and Google Cloud Storage used for this project).
1. Navigate to the `src` folder and run `01-A_write_submission_files.R` file.
This will produce the report files in the required format for ISBE and write them
to the `output\final_reports` folder. Note: if you'd like to see the final Files
in R look at the `isbe_midyear_report_400146`, `isbe_midyear_report_400044`,
`isbe_midyear_report_400163`, and `isbe_midyear_report_400180` dataframes.

### Error Handling
1. After you receive your first error report from CPS navigate to the `src`
folder and run the `02-A_evaluate_cps_validation_period_errors.Rmd` file. This file
will produce dataframes that show all unique errors by school. This file
will also produce dataframes that list all unique name errors and date of birth
errors.
1. Use the `03-A_produce_write_submission_files_with_error_fixes.R` file to fix problems with the final reports that cannot be corrected in original code (use this
file cautiously).

### Project File Outline:
```
.
└── ISBE_Student_Courses
    |
    ├── README.md                   <- Description of project content.
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
    |   │── data_dictionary_bq      <- For `data/01-bq_files.R`
    |   │── data_dictionary_gcs     <- For `data/02-gcs_files.R`
    |   │── data_dictionary_manual  <- For `data/03-manual_tables.R`
    |   └── data_schema
    |
    ├── output
    │   ├── final_reports           <- Location for final output
    │   └── errors                  <- Location for error files
    |       ├── original_files
    |       └── distinct_files
    |                                
    |
    ├── munge
    |   ├── 01-A_student_teacher_identifying_info.R
    |   ├── 01-B_student_course_info.R
    |   ├── 01-C_student_teacher_enrollment_info.R
    |   ├── 02-A_produce_primary_submission_file.R
    |   ├── 02-B_produce_middle_school_submission_file.R
    |   ├── 03-A_produce_reports_brokenup_by_official_schools.R
    |   └── README.md
    |
    ├── src
    |   ├── 01-A_write_submission_files.R
    |   ├── 02-A_evaluate_cps_validation_period_errors.Rmd
    |   ├── 03-A_produce_write_submission_files_with_error_fixes.R
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
