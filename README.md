# ISBE Midyear Reporting Scripts

#### -- Project Status: [Active]

## Project Intro/Objective
In Illinois, at the at the end of every semester, each school is required to submit a set of data to the Office of I&I for transmission to the Illinois State Board of Education (ISBE). The state then uses this data to produce the annual State School Report Cards. The purpose of this project is to collect student and teacher data from KIPP Chicago's different data systems and put them in a format that conforms to ISBE's reporting requirements. **Note: Because of confidentiality considerations no data is included in this repository.**

### Technologies
* R
* ProjectTemplate
* Google Big Query
* Google Cloud Storage

### Data Systems
* PowerSchool
* Illuminate Education

## Project Description
This repo contains scripts that ingest data that is stored in KIPP Chicago's database and file storage systems and transforms the datasets into a report.

## Getting Started

1. Clone this repo (for help see this [tutorial](https://help.github.com/articles/cloning-a-repository/)).
1. Details on how to use this repository and how to prepare for the report are located in [`documentation/isbe_midyear_report_documentation.pdf`](https://github.com/kippchicago/isbe_midyear_reporting/blob/master/documentation/isbe_midyear_report_documentation.pdf).
1. Data scripts are being kept in [`data`](https://github.com/kippchicago/isbe_midyear_reporting/tree/master/data).
1. Data processing/transformation scripts are being kept in [`src`](https://github.com/kippchicago/isbe_midyear_reporting/tree/master/munge).
1. Scripts that produce Middle School and Primary School reports are being kept in [`munge`](https://github.com/kippchicago/isbe_midyear_reporting/tree/master/src).
1. Error file processing scripts are being kept in [`src`](https://github.com/kippchicago/isbe_midyear_reporting/tree/master/src).
1. Helper scripts are being kept in [`lib`](https://github.com/kippchicago/isbe_midyear_reporting/tree/master/lib).
1. Data Documentation scripts (data dictionaries) are being kept in [`documentation`](https://github.com/kippchicago/isbe_midyear_reporting/tree/master/documentation).
1. Deliverables would be located in [`output`](https://github.com/kippchicago/isbe_midyear_reporting/tree/master/output). **Note**: Deliverables are not included in this repo.


## Project File Outline:

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
