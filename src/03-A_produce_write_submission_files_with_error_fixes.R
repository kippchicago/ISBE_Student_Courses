# This file fixes errors for submission that cannot be corrected in original code

library(ProjectTemplate)
load.project()

source(here::here("munge", "01-A_produce_all_teacher_student_info.R"))
source(here::here("munge", "02-A_produce_primary_submission_file.R"))
source(here::here("munge", "03-A_produce_middle_school_submission_file.R"))
source(here::here("munge", "04-A_produce_reports_brokenup_by_official_schools.R"))

# Correct Dataframes from 01-A_Produce-submission-files.R -----------------

isbe_midyear_report_400044_corrected <- replace_with_aspen_name(
  isbe_report_single_school = isbe_midyear_report_400044, 
  name_replacement_df = cps_name_replacement_list
  )

isbe_midyear_report_400146_corrected <- replace_with_aspen_name(
  isbe_report_single_school = isbe_midyear_report_400146, 
  name_replacement_df = cps_name_replacement_list
)

isbe_midyear_report_400163_corrected <- replace_with_aspen_name(
  isbe_report_single_school = isbe_midyear_report_400163, 
  name_replacement_df = cps_name_replacement_list
)

isbe_midyear_report_400180_corrected <- replace_with_aspen_name(
  isbe_report_single_school = isbe_midyear_report_400180, 
  name_replacement_df = cps_name_replacement_list
) %>%
  distinct()


# Write Updated Files -----------------------------------------------------
write_csv(isbe_midyear_report_400044_corrected, 
          here::here("output",
                     "final_reports", 
                     paste("400044_CourseAssignment2020_01_corrected", today(), ".csv")))

write_csv(isbe_midyear_report_400146_corrected, 
          here::here("output", 
                     "final_reports", 
                     paste("400146_CourseAssignment2020_01_corrected", today(), ".csv")))

write_csv(isbe_midyear_report_400163_corrected, 
          here::here("output", 
                     "final_reports",
                     paste("400163_CourseAssignment2020_01_corrected", today(), ".csv")))

write_csv(isbe_midyear_report_400180_corrected, 
          here::here("output", 
                     "final_reports", 
                     paste("400180_CourseAssignment2020_01_corrected", today(), ".csv")))

