# Error Handling Scripts
library(ProjectTemplate)
load.project()

source(here::here("lib", "helpers.R"))

# Parameters --------------------------------------------------------------

ERROR_DATE <- ymd("2020-02-21")


# Download Files ----------------------------------------------------------

# Download Error Files "output/errors/original_files" 

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

# Add Aspen Birthday Information

all_student_birthdays_aspen <- 
  bind_rows(one_400180_student_dobs_aspen, 
            academy_400146_student_dobs_aspen, 
            ascend_400044_student_dobs_aspen, 
            bloom_400163_student_dobs_aspen) %>%
  rename(aspen_dob = dob)

# Read in full error files ------------------------------------------------

report_400044_w_errors <-
  read.xlsx(here::here("output", "errors", "original_files", 
                       paste("400044_CourseAssignment2020_01", 
                             ERROR_DATE, ".xlsx", sep = "_")))

report_400146_w_errors <-
  read.xlsx(here::here("output", "errors", "original_files", 
                       paste("400146_CourseAssignment2020_01", 
                             ERROR_DATE, ".xlsx", sep = "_")))

report_400163_w_errors <-
  read.xlsx(here::here("output", "errors", "original_files", 
                       paste("400163_CourseAssignment2020_01", 
                             ERROR_DATE, ".xlsx", sep = "_")))

report_400180_w_errors <-
  read.xlsx(here::here("output", "errors", "original_files", 
                       paste("400180_CourseAssignment2020_01", 
                             ERROR_DATE, ".xlsx", sep = "_")))


# Locate All Unique Errors for each School ------------------------------------

final_errors_400044 <- locate_distinct_errors(report_400044_w_errors)

final_errors_400146 <- locate_distinct_errors(report_400146_w_errors)

final_errors_400163 <- locate_distinct_errors(report_400163_w_errors)

final_errors_400180 <- locate_distinct_errors(report_400180_w_errors)

# Locate Name Errors For Each School ------------------------------------------------------

incorrect_names_400044 <- locate_distinct_name_errors(report_400044_w_errors, 
                                                      students, cps_school_rcdts_ids)
incorrect_names_400146 <- locate_distinct_name_errors(report_400146_w_errors, 
                                                      students, cps_school_rcdts_ids)
incorrect_names_400163 <- locate_distinct_name_errors(report_400163_w_errors, 
                                                      students, cps_school_rcdts_ids)
incorrect_names_400180 <- locate_distinct_name_errors(report_400180_w_errors, 
                                                      students, cps_school_rcdts_ids)

# Locate DOB Errors For Each School -------------------------------------------------------

# create seperate dob files
incorrect_dob_400044 <- locate_distinct_dob_errors(report_400044_w_errors, 
                                                      students, cps_school_rcdts_ids) %>%
  left_join(all_student_birthdays_aspen, 
            by = c("CPS.Student.ID" = "student_id")) %>%
  select(CPS.Student.ID, school, grade_level, Student.Last.Name, 
         Student.First.Name, powerschool_dob, aspen_dob, correct_dob) %>%
  drop_na(aspen_dob)
  

incorrect_dob_400146 <- locate_distinct_dob_errors(report_400146_w_errors, 
                                                      students, cps_school_rcdts_ids) %>%
  left_join(all_student_birthdays_aspen, 
            by = c("CPS.Student.ID" = "student_id")) %>%
  select(CPS.Student.ID, school, grade_level, Student.Last.Name, 
         Student.First.Name, powerschool_dob, aspen_dob, correct_dob) %>%
  drop_na(aspen_dob)

incorrect_dob_400163 <- locate_distinct_dob_errors(report_400163_w_errors, 
                                                      students, cps_school_rcdts_ids) %>%
  left_join(all_student_birthdays_aspen, 
            by = c("CPS.Student.ID" = "student_id")) %>%
  select(CPS.Student.ID, school, grade_level, Student.Last.Name, 
         Student.First.Name, powerschool_dob, aspen_dob, correct_dob) %>%
  drop_na(aspen_dob)

incorrect_dob_400180 <- locate_distinct_dob_errors(report_400180_w_errors, 
                                                      students, cps_school_rcdts_ids) %>%
  left_join(all_student_birthdays_aspen, 
            by = c("CPS.Student.ID" = "student_id")) %>%
  select(CPS.Student.ID, school, grade_level, Student.Last.Name, 
         Student.First.Name, powerschool_dob, aspen_dob, correct_dob) %>%
  drop_na(aspen_dob)


# Locate CPS ID Errors For Each School -------------------------------------------------------

incorrect_cps_id_400044 <- locate_distinct_cps_id_errors(report_400044_w_errors, 
                                                         students, cps_school_rcdts_ids)
incorrect_cps_id_400146 <- locate_distinct_cps_id_errors(report_400146_w_errors, 
                                                         students, cps_school_rcdts_ids)
incorrect_cps_id_400163 <- locate_distinct_cps_id_errors(report_400163_w_errors, 
                                                         students, cps_school_rcdts_ids)
incorrect_cps_id_400180 <- locate_distinct_cps_id_errors(report_400180_w_errors, 
                                                         students, cps_school_rcdts_ids)
incorrect_cps_id_all_schools <- 
  bind_rows(incorrect_cps_id_400044, 
            incorrect_cps_id_400146, 
            incorrect_cps_id_400163, 
            incorrect_cps_id_400180
            )
