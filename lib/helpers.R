# This script contains all functions used throughout the project

locate_distinct_errors <- function(full_error_report) {
  errors_col_df <- 
    full_error_report %>%
    select("error_details" = contains("detail")) %>%
    distinct() %>%
    separate("error_details", 
             into = c("E1", "E2", "E3", "E4", "E5", "E6", "E7", "E8", "E9", "E10", 
                      "E11", "E12", "E13", "E14", "E15", "E16", "E17", "E18", "E19", "E20",
                      "E21", "E22", "E23", "E24", "E25", "E26", "E27", "E28", "E29", "E30"), 
             sep = ";") %>%
    remove_empty(which = c("cols"))
  
  final_errors <- data.frame(errors=character())
  
  for (col in colnames(errors_col_df)) {
    temp_df <- errors_col_df %>% select("errors" = col)
    temp_df <- temp_df
    final_errors <- 
      bind_rows(final_errors, 
                temp_df) %>%
      distinct() %>%
      drop_na()
  }
  return(final_errors)
}

locate_distinct_name_errors <- function(full_error_report, ps_students_table, school_ids)  {
  incorrect_name_df <- 
    full_error_report %>%
    group_by(CPS.Student.ID) %>%
    filter(row_number(desc(Student.Course.Start.Date)) == 1) %>%
    filter(grepl("does not match ASPEN", Error.Details)) %>% 
    select(CPS.Student.ID, Student.Last.Name, Student.First.Name, Error.Details) %>%
    separate("Error.Details", 
             into = c("E1", "E2", "E3", "E4", "E5", "E6", "E7", "E8", 
                      "E9", "E10", "E11", "E12", "E13", "E14", "E15", "E16"), 
             sep = ";") %>%
    pivot_longer(cols = c(E1, E2, E3, E4, E5, E6, E7, E8, E9, E10, E11), 
                 names_to = "errors") %>%
    filter(str_detect(value, "Name")) %>%
    select(CPS.Student.ID, Student.Last.Name, Student.First.Name, ASPEN_name = value) %>%
    ungroup(CPS.Student.ID) %>%
    mutate(CPS.Student.ID = as.character(CPS.Student.ID)) %>%
    left_join(ps_students_table, 
              by = c("CPS.Student.ID" = "student_number")) %>%
    left_join(school_ids, 
              by = "schoolid") %>%
    select(CPS.Student.ID, dob, school = abbr, grade_level, 
           Student.Last.Name, Student.First.Name, ASPEN_name) %>%
    mutate(correct_name = "")
  
  return(incorrect_name_df)
}

locate_distinct_dob_errors <- function(full_error_report, ps_students_table, school_ids, aspen_birthdays)  {
  incorrect_dob_df <- 
    full_error_report %>%
    group_by(CPS.Student.ID) %>%
    filter(row_number(desc(Student.Course.Start.Date)) == 1) %>%
    filter(grepl("Birth Date must match", Error.Details)) %>% 
    select(CPS.Student.ID, Student.Last.Name, Student.First.Name, Error.Details) %>%
    separate("Error.Details", 
             into = c("E1", "E2", "E3", "E4", "E5", "E6", "E7", "E8", 
                      "E9", "E10", "E11", "E12", "E13", "E14", "E15", "E16"), 
             sep = ";") %>%
    pivot_longer(cols = c(E1, E2, E3, E4, E5, E6, E7, E8, E9, E10, E11), 
                 names_to = "errors") %>%
    filter(str_detect(value, "Birth Date must match")) %>%
    select(CPS.Student.ID, Student.Last.Name, Student.First.Name, value) %>%
    ungroup(CPS.Student.ID) %>%
    mutate(CPS.Student.ID = as.character(CPS.Student.ID)) %>%
    left_join(ps_students_table, 
              by = c("CPS.Student.ID" = "student_number")) %>%
    left_join(school_ids, 
              by = "schoolid") %>%
    mutate(CPS.Student.ID = as.numeric(CPS.Student.ID)) %>%
    select(CPS.Student.ID, school = abbr, grade_level, Student.Last.Name, 
           Student.First.Name, powerschool_dob = dob) %>%
    mutate(correct_dob = "") %>%
    left_join(aspen_birthdays, 
              by = c("CPS.Student.ID" = "student_id")) %>%
    select(CPS.Student.ID, school, grade_level, Student.Last.Name, 
           Student.First.Name, powerschool_dob, aspen_dob = dob, correct_dob) %>%
    drop_na(aspen_dob)
  
  return(incorrect_dob_df)
}

locate_distinct_cps_id_errors <- function(full_error_report, ps_students_table, school_ids)  {
  incorrect_cps_id_df <- 
    full_error_report %>%
    group_by(CPS.Student.ID) %>%
    filter(row_number(desc(Student.Course.Start.Date)) == 1) %>%
    filter(grepl("CPS Student ID must be enrolled in SY20", Error.Details)) %>% 
    select(CPS.Student.ID, 
           ISBE.Student.ID,
           Student.Last.Name, 
           Student.First.Name, 
           Error.Details) %>%
    separate("Error.Details",
             into = c("E1", "E2", "E3", "E4", "E5", "E6", "E7", "E8",
                      "E9", "E10", "E11", "E12", "E13", "E14", "E15", "E16"),
             sep = ";") %>%
    pivot_longer(cols = c(E1, E2, E3, E4, E5, E6, E7, E8, E9, E10, E11),
                 names_to = "errors")  %>%
    filter(str_detect(value, "CPS Student ID must be enrolled in SY20")) %>%
    select(CPS.Student.ID, Student.Last.Name, Student.First.Name, ISBE.Student.ID) %>%
    ungroup(CPS.Student.ID) %>%
    mutate(CPS.Student.ID = as.integer(CPS.Student.ID)) %>%
    left_join(ps_students_table,
              by = c("CPS.Student.ID" = "student_number")) %>%
    left_join(school_ids,
              by = "schoolid") %>%
    select(cps_school_id, 
           rcdts_code, 
           Student.Last.Name,
           Student.First.Name, 
           powerschool_dob = dob,
           kipp_cps_student_id = CPS.Student.ID, 
           ISBE.Student.ID) %>%
    mutate(powerschool_dob = ymd(powerschool_dob)) %>%
    left_join(all_student_birthdays_aspen, 
              by = c("powerschool_dob" = "aspen_dob", 
                     "Student.Last.Name" = "last_name")) %>%
    select(-first_name) %>%
    rename(aspen_cps_student_id = student_id)
  
  return(incorrect_cps_id_df)
}

replace_with_aspen_first_name <- function(isbe_report_single_school, name_replacement_df) {
  isbe_report_update_name <- 
    isbe_report_single_school %>%
    left_join(name_replacement_df %>% 
                filter(name_location == "First"), 
              by = c("CPS Student ID" = "cps_student_id")) %>%
    mutate(`Student First Name` = case_when(name_location == "First" ~ replacement_name,
                                            TRUE ~ `Student First Name`)) %>%
    mutate(`Student Last Name` = case_when(name_location == "Last" ~ replacement_name, 
                                           TRUE ~ `Student Last Name`)) %>%
    select(-c("name_location", "replacement_name"))
  
  return(isbe_report_update_name)
}

replace_with_aspen_last_name <- function(isbe_report_single_school, name_replacement_df) {
  isbe_report_update_name <- 
    isbe_report_single_school %>%
    left_join(name_replacement_df %>% 
                filter(name_location == "Last"), 
              by = c("CPS Student ID" = "cps_student_id")) %>%
    mutate(`Student First Name` = case_when(name_location == "First" ~ replacement_name,
                                            TRUE ~ `Student First Name`)) %>%
    mutate(`Student Last Name` = case_when(name_location == "Last" ~ replacement_name, 
                                           TRUE ~ `Student Last Name`)) %>%
    select(-c("name_location", "replacement_name"))
  
  return(isbe_report_update_name)
}

replace_with_aspen_name <- function(isbe_report_single_school, name_replacement_df) {
  corrected_first_name <- replace_with_aspen_first_name(isbe_report_single_school, name_replacement_df)
  corrected_name_full <- replace_with_aspen_last_name(corrected_first_name, name_replacement_df)
  
  return(corrected_name_full)
}

replace_with_aspen_dob <- function(isbe_report_single_school, aspen_dob_df) {
  corrected_report <-
    isbe_report_single_school %>%
    left_join(aspen_dob_df, 
              by = c("CPS Student ID" = "CPS.Student.ID")) %>%
    mutate(`Birth Date` = mdy(`Birth Date`)) %>%
    mutate(`Birth Date` = case_when(!is.na(aspen_dob) ~ aspen_dob, 
                                    TRUE ~ `Birth Date`)) %>%
    select(-c("Student.Last.Name", "Student.First.Name", 
              "powerschool_dob", "aspen_dob"))
  
  return(corrected_report)
}
