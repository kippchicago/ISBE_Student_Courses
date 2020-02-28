library(ProjectTemplate)
load.project()

source(here::here("src", "02-A_error_checking.R"))


# Correct Dataframes from 01-A_Produce-submission-files.R -----------------

isbe_midyear_report_400044_corrected <- fix_name_dob_cps_errors(
  isbe_report_single_school = isbe_midyear_report_400044, 
  name_replacement_df = name_replacements_full, 
  conflicting_cps_id_df = conflicting_cps_id_aspen_all_schools, 
  aspen_dob_df = dob_replacement_full
  )

isbe_midyear_report_400146_corrected <- fix_name_dob_cps_errors(
  isbe_report_single_school = isbe_midyear_report_400146, 
  name_replacement_df = name_replacements_full, 
  conflicting_cps_id_df = conflicting_cps_id_aspen_all_schools, 
  aspen_dob_df = dob_replacement_full
)

isbe_midyear_report_400163_corrected <- fix_name_dob_cps_errors(
  isbe_report_single_school = isbe_midyear_report_400163, 
  name_replacement_df = name_replacements_full, 
  conflicting_cps_id_df = conflicting_cps_id_aspen_all_schools, 
  aspen_dob_df = dob_replacement_full
)

isbe_midyear_report_400180_corrected <- fix_name_dob_cps_errors(
  isbe_report_single_school = isbe_midyear_report_400180, 
  name_replacement_df = name_replacements_full, 
  conflicting_cps_id_df = conflicting_cps_id_aspen_all_schools, 
  aspen_dob_df = dob_replacement_full
)


# Write Updated Files -----------------------------------------------------
write_csv(isbe_midyear_report_400044_corrected, here::here("output", 
                                                           "final_reports", 
                                                           "400044_CourseAssignment2020_01_corrected.csv"))

write_csv(isbe_midyear_report_400146_corrected, here::here("output", 
                                                           "final_reports", 
                                                           "400146_CourseAssignment2020_01_corrected.csv"))

write_csv(isbe_midyear_report_400163_corrected, here::here("output", 
                                                           "final_reports", 
                                                           "400163_CourseAssignment2020_01_corrected.csv"))

write_csv(isbe_midyear_report_400180_corrected, here::here("output", 
                                                           "final_reports", 
                                                           "400180_CourseAssignment2020_01_corrected.csv"))

