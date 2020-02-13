# this file writes submission ready files to the "output" folder. 
# NOTE: run "src/01-A_produce-submission-ready-files.R" first

library(ProjectTemplate)
load.project()


# Write Files to output folder ----------------------------------------------

write.xlsx(isbe_midyear_report_academy, here::here("output", "400146_CourseAssignment2020_01.xlsx"))

write.xlsx(isbe_midyear_report_ascend, here::here("output", "40044_CourseAssignment2020_01.xlsx"))

write.xlsx(isbe_midyear_report_bloom, here::here("output", "400163_CourseAssignment2020_01.xlsx"))

write.xlsx(isbe_midyear_report_one, here::here("output", "400180_CourseAssignment2020_01.xlsx"))
