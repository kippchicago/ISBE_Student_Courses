# Error Handling Scripts
library(ProjectTemplate)
load.project()

source(here::here("lib", "helpers.R"))

# Parameters --------------------------------------------------------------

ERROR_DATE <- ymd("2020-02-25")

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
incorrect_dob_400044 <- locate_distinct_dob_errors(full_error_report = report_400044_w_errors,
                                                   ps_students_table = students, 
                                                   school_ids = cps_school_rcdts_ids,
                                                   aspen_birthdays = all_student_birthdays_aspen
                                                   ) 
  

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

missing_cps_id_aspen_all_schools <- 
  bind_rows(incorrect_cps_id_400044, 
            incorrect_cps_id_400146, 
            incorrect_cps_id_400163, 
            incorrect_cps_id_400180
            ) %>%
  filter(is.na(aspen_cps_student_id))

conflicting_cps_id_aspen_all_schools <- 
  bind_rows(incorrect_cps_id_400044, 
            incorrect_cps_id_400146, 
            incorrect_cps_id_400163, 
            incorrect_cps_id_400180
  ) %>%
  filter(!is.na(aspen_cps_student_id))

missing_isbe_stateid_all <- 
  isbe_report_all_schools %>%
  filter(is.na(`ISBE Student ID`)) %>%
  select(`CPS Student ID`, 
         `ISBE Student ID`, 
         `Student Last Name`, 
         `Student First Name`, 
         `Birth Date`, 
         `CPS School ID`) %>%
  distinct()

write.csv(missing_isbe_stateid_all, 
          here::here("output", "errors", 
                     "distinct_errors", "students_missing_isbeid_all.csv"))

