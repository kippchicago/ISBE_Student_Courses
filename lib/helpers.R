# contains all functions used throughout project


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
    mutate(CPS.Student.ID = as.integer(CPS.Student.ID)) %>%
    left_join(ps_students_table, 
              by = c("CPS.Student.ID" = "student_number")) %>%
    left_join(school_ids, 
              by = "schoolid") %>%
    select(CPS.Student.ID, dob, school = abbr, grade_level, 
           Student.Last.Name, Student.First.Name, ASPEN_name) %>%
    mutate(correct_name = "")
  
  return(incorrect_name_df)
}

locate_distinct_dob_errors <- function(full_error_report, ps_students_table, school_ids)  {
  incorrect_name_df <- 
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
    select(CPS.Student.ID, Student.Last.Name, Student.First.Name, ASPEN_name = value) %>%
    ungroup(CPS.Student.ID) %>%
    mutate(CPS.Student.ID = as.integer(CPS.Student.ID)) %>%
    left_join(ps_students_table, 
              by = c("CPS.Student.ID" = "student_number")) %>%
    left_join(school_ids, 
              by = "schoolid") %>%
    select(CPS.Student.ID, dob, school = abbr, grade_level, 
           Student.Last.Name, Student.First.Name, ASPEN_name) %>%
    mutate(correct_name = "")
  
  return(incorrect_name_df)
}
