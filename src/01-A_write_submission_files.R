# Writes submission ready files to the "output/final_reports" folder.
library(ProjectTemplate)
load.project()

# Run Munging Files -------------------------------------------------------

source(here::here("munge", "01-A_student_teacher_identifying_info.R"))
source(here::here("munge", "01-B_student_course_info.R"))
source(here::here("munge", "01-C_student_teacher_enrollment_info.R"))
source(here::here("munge", "02-A_produce_primary_submission_file.R"))
source(here::here("munge", "02-B_produce_middle_school_submission_file.R"))
source(here::here("munge", "03-A_produce_reports_brokenup_by_official_schools.R"))

# Write Files to output folder ----------------------------------------------

isbe_report_all_schools %>%
  select(`CPS Student ID`) %>%
  get_dupes() %>%
  View()

write_csv(isbe_midyear_report_400146, here::here("output", 
                                                 "final_reports", 
                                                 "400146_CourseAssignment2020_01.csv"))

write_csv(isbe_midyear_report_400044, here::here("output", 
                                                 "final_reports", 
                                                 "40044_CourseAssignment2020_01.csv"))

write_csv(isbe_midyear_report_400163, here::here("output", 
                                                 "final_reports", 
                                                 "400163_CourseAssignment2020_01.csv"))

write_csv(isbe_midyear_report_400180, here::here("output", 
                                                 "final_reports", 
                                                 "400180_CourseAssignment2020_01.csv"))
