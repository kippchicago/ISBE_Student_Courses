# this file writes submission ready files to the "output/final_reports" folder. 
# NOTE: run "src/01-A_produce-submission-files.R" first

library(ProjectTemplate)

# Write Files to output folder ----------------------------------------------

write_csv(isbe_midyear_report_400146, here::here("output", "final_reports", "400146_CourseAssignment2020_01.csv"))

write_csv(isbe_midyear_report_400044, here::here("output", "final_reports", "40044_CourseAssignment2020_01.csv"))

write_csv(isbe_midyear_report_400163, here::here("output", "final_reports", "400163_CourseAssignment2020_01.csv"))

write_csv(isbe_midyear_report_400180, here::here("output", "final_reports", "400180_CourseAssignment2020_01.csv"))