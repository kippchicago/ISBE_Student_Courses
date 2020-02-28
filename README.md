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
1. Instructions for how to use this Repo are in [`documentation`](https://github.com/kippchicago/isbe_midyear_reporting/blob/master/documentation/PROJECT-USE-INSTRUCTIONS.md). 
1. Data scripts are being kept in [`data`](https://github.com/kippchicago/isbe_midyear_reporting/tree/master/data).
1. Data processing/transformation scripts are being kept in [`src`](https://github.com/kippchicago/isbe_midyear_reporting/tree/master/munge). 
1. Scripts that produce Middle School and Primary School reports are being kept in [`munge`](https://github.com/kippchicago/isbe_midyear_reporting/tree/master/src). 
1. Error file processing scripts are being kept in [`src`](https://github.com/kippchicago/isbe_midyear_reporting/tree/master/src).
1. Helper scripts are being kept in [`lib`](https://github.com/kippchicago/isbe_midyear_reporting/tree/master/lib). 
1. Data Documentation scripts (data dictionaries) are being kept in [`documentation`](https://github.com/kippchicago/isbe_midyear_reporting/tree/master/documentation).
1. Deliverables would be located in [`output`](https://github.com/kippchicago/isbe_midyear_reporting/tree/master/output). **Note**: Deliverables are not included in this repo.
