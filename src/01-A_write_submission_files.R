# this file writes submission ready files to the "output/final_reports" folder. 

library(ProjectTemplate)
load.project()

source(here::here("munge", "01-A_produce_all_teacher_student_info.R"))
source(here::here("munge", "02-A_produce_primary_submission_file.R"))
source(here::here("munge", "03-A_produce_middle_school_submission_file.R"))
source(here::here("munge", "04-A_produce_reports_brokenup_by_official_schools.R"))

# Write Files to output folder ----------------------------------------------

write_csv(isbe_midyear_report_400146, here::here("output", "final_reports", "400146_CourseAssignment2020_01.csv"))

write_csv(isbe_midyear_report_400044, here::here("output", "final_reports", "40044_CourseAssignment2020_01.csv"))

write_csv(isbe_midyear_report_400163, here::here("output", "final_reports", "400163_CourseAssignment2020_01.csv"))

write_csv(isbe_midyear_report_400180, here::here("output", "final_reports", "400180_CourseAssignment2020_01.csv"))