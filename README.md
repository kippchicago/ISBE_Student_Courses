# ISBE Midyear Reporting Scripts

#### -- Project Status: [Active]

## Project Intro/Objective
In Illinois, at the at the end of every semester, each school is required to submit a set of data to the Office of I&I for transmission to the Illinois State Board of Education (ISBE). The state then uses this data to produce the annual State School Report Cards. The purpose of this project is to collect student and teacher data from KIPP Chicago's different data systems and put them in a format that conforms to ISBE's reporting requirements. **Note**: no data is included in this repository.

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
1. Instructions for how to use this Repo are in the [`documentation`](#) folder. 
1. Data scripts are being kept in the [`data`](https://github.com/kippchicago/isbe_midyear_reporting/tree/master/data) folder.
1. Data processing/transformation scripts are being kept in the [`src`](https://github.com/kippchicago/isbe_midyear_reporting/tree/master/munge) folder. 
1. Scripts that produce Middle School and Primary School reports are being kept in the [`munge`](https://github.com/kippchicago/isbe_midyear_reporting/tree/master/src) folder. 
1. Error file processing scripts are being kept in the [`src`](https://github.com/kippchicago/isbe_midyear_reporting/tree/master/src) folder.
1. Helper scripts are being kept in the [`lib`](https://github.com/kippchicago/isbe_midyear_reporting/tree/master/lib) folder. 
1. Data Documentation scripts (data dictionaries) are being kept in the [`documentation`](https://github.com/kippchicago/isbe_midyear_reporting/tree/master/documentation) folder.
1. Deliverables would be located in the [`output`](https://github.com/kippchicago/isbe_midyear_reporting/tree/master/output) folder. **Note**: Deliverables are not included in this repo.
