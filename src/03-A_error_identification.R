# Error Handling Scripts
library(ProjectTemplate)
load.project()

source(here::here("lib", "helpers.R"))

# Download Error Files "output/errors/original_files" -----------------------------------------------------

drive_download("400044_CourseAssignment2020_01.xls", 
               path = here::here("output", "errors", "original_files", 
                                 "400044_CourseAssignment2020_01.xlsx"), 
               overwrite = TRUE)

drive_download("400146_CourseAssignment2020_01", 
               path = here::here("output", "errors", "original_files", 
                                 "400146_CourseAssignment2020_01.csv"), 
               overwrite = TRUE)

drive_download("400163_CourseAssignment2020_01.xls", 
               path = here::here("output", "errors", "original_files", 
                                 "400163_CourseAssignment2020_01.xlsx"), 
               overwrite = TRUE)

drive_download("400180_CourseAssignment2020_01", 
               path = here::here("output", "errors", "original_files", 
                                 "400180_CourseAssignment2020_01.csv"), 
               overwrite = TRUE)

# Read in full error files ------------------------------------------------

report_400044_w_errors <-
  read.xlsx(here::here("output", "errors", "original_files", "400044_CourseAssignment2020_01.xlsx"))

report_400146_w_errors <-
  read_csv(here::here("output", "errors", "original_files", "400146_CourseAssignment2020_01.csv"))

report_400163_w_errors <-
  read.xlsx(here::here("output", "errors", "original_files", "400163_CourseAssignment2020_01.xlsx"))

report_400180_w_errors <-
  read_csv(here::here("output", "errors", "original_files", "400180_CourseAssignment2020_01.csv"))


# Locate Unique Errors for each School ------------------------------------

final_errors_400044 <- locate_distinct_errors(report_400044_w_errors)
final_errors_400146 <- locate_distinct_errors(report_400146_w_errors)
final_errors_400163 <- locate_distinct_errors(report_400163_w_errors)
final_errors_400180 <- locate_distinct_errors(report_400180_w_errors)

# Write distinct Errors to Error Folder -----------------------------------
write_csv(final_errors_400044, 
          here::here("output", "errors", "distinct_errors", "final_errors_400044.csv"))

write_csv(final_errors_400146, 
          here::here("output", "errors", "distinct_errors", "final_errors_400146.csv"))

write_csv(final_errors_400163, 
          here::here("output", "errors", "distinct_errors", "final_errors_400163.csv"))

write_csv(final_errors_400180, 
          here::here("output", "errors", "distinct_errors", "final_errors_400180.csv"))

