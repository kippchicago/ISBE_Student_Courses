# Error Handling Scripts
library(ProjectTemplate)
load.project()

source(here::here("lib", "helpers.R"))

# Download Error Files "output/errors/original_files" -----------------------------------------------------

drive_download("400044_CourseAssignment2020_01.xls", 
               path = here::here("output", "errors", "original_files", 
                                 paste("400044_CourseAssignment2020_01", 
                                       today(), ".xlsx", sep = "_")), 
               overwrite = TRUE)

drive_download("400146_CourseAssignment2020_01.xls", 
               path = here::here("output", "errors", "original_files", 
                                 paste("400146_CourseAssignment2020_01", 
                                       today(), ".xlsx", sep = "_")), 
               overwrite = TRUE)

drive_download("400163_CourseAssignment2020_01.xls", 
               path = here::here("output", "errors", "original_files", 
                                 paste("400163_CourseAssignment2020_01", 
                                       today(), ".xlsx", sep = "_")), 
               overwrite = TRUE)

drive_download("400180_CourseAssignment2020_01.xls", 
               path = here::here("output", "errors", "original_files", 
                                 paste("400180_CourseAssignment2020_01", 
                                       today(), ".xlsx", sep = "_")), 
               overwrite = TRUE)

# Read in full error files ------------------------------------------------

report_400044_w_errors <-
  read.xlsx(here::here("output", "errors", "original_files", 
                       "400044_CourseAssignment2020_01.xlsx"))

report_400146_w_errors <-
  read.xlsx(here::here("output", "errors", "original_files", 
                       "400146_CourseAssignment2020_01.xlsx"))

report_400163_w_errors <-
  read.xlsx(here::here("output", "errors", "original_files", 
                       "400163_CourseAssignment2020_01.xlsx"))

report_400180_w_errors <-
  read.xlsx(here::here("output", "errors", "original_files", 
                       "400180_CourseAssignment2020_01.xlsx"))


# Locate Unique Errors for each School ------------------------------------

final_errors_400044 <- locate_distinct_errors(report_400044_w_errors)
final_errors_400146 <- locate_distinct_errors(report_400146_w_errors)
final_errors_400163 <- locate_distinct_errors(report_400163_w_errors)
final_errors_400180 <- locate_distinct_errors(report_400180_w_errors)

