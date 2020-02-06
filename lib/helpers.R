# Function
get_middle_grade_courses <- . %>%
  select(
    site_id,
    student_id,
    contains("course_name")
  ) %>%
  tidyr::gather(rc_field, course_name, -site_id:-student_id) %>%
  # NOTE: will q4 need to be changed? 
  filter(grepl("q4", rc_field)) %>%
  mutate(
    subject = gsub("(^.+course_name_)(.+)", "\\2", rc_field),
    course_school = toupper(stringr::str_extract(rc_field, "kap|kac|kbcp|kams|koa"))
  ) %>%
  left_join(external_codes %>%
              select(
                schoolid,
                abbr
              ),
            by = c("site_id" = "schoolid")
  ) %>%
  mutate(keep = course_school == abbr) %>%
  filter(keep)

# Function
# final percent
get_y1_avgs <- . %>%
  select(
    site_id,
    student_id,
    contains("q4")
  ) %>%
  tidyr::gather(rc_field, percent, -site_id:-student_id) %>%
  filter(
    grepl("percent", rc_field),
    grepl("y1_avg", rc_field)
  ) %>% # View()
  mutate(
    subject = gsub("(^.+avg_)(\\w.+)(_y1.+)", "\\2", rc_field),
    # subject = gsub("_", " ", subject0),
    course_school = toupper(stringr::str_extract(rc_field, "kac|kbcp|kams|koa"))
  ) %>%
  # select(-subject0) %>%
  left_join(student_schools,
            by = c("student_id" = "student_number")
  ) %>%
  filter(course_school == abbr) %>%
  mutate(
    percent = round(as.double(gsub("%", "", percent)), 0),
    percent = as.character(percent)
  ) %>%
  left_join(grade_percent_scale %>%
              mutate(percent = as.character(percent)),
            by = "percent"
  ) %>%
  select(-rc_field)

# Function
get_primary_grades_courses <- 
  . %>%
  select(
    site_id,
    student_id,
    contains("q4")
  ) %>% # need Q3 performing arts 1st, Q3 visual arts 2nd
  tidyr::gather(rc_field, grade, -site_id:-student_id) %>% # View()
  filter(
    !grepl("tardy|absent|spanish", rc_field),
    !is.na(grade)
  ) %>%
  mutate(rc_field = gsub("_", " ", rc_field)) %>%
  filter(grepl(course_names_primary, rc_field)) %>%
  mutate(
    subject0 = gsub("(^.+ primary )(\\w+.\\w+)(\\s\\w.+)", "\\2", rc_field),
    subject1 = if_else(grepl("kap|primary", subject0),
                       gsub(" kap| primary", "", subject0),
                       subject0
    ),
    subject2 = if_else(subject1 == "math", "math centers", subject1),
    subject3 = if_else(subject2 == "we act", "explorations", subject2),
    subject = if_else(subject2 == "math math", "math", subject3)
  ) %>%
  select(-c(subject0:subject3)) %>% # View()
  left_join(primary_grade_codes,
            by = c("grade" = "kc_grades")
  ) %>%
  mutate(school_grade = gsub("(^.+ rc )((kop|kap|kbp).+)( q.+)", "\\2", rc_field)) %>%
  tidyr::separate(school_grade, into = c("school", "grade"), sep = " ") %>%
  mutate(
    grade0 = gsub("st|nd|rd|th", "", grade),
    subject0 = gsub(" ", "", subject)
  ) %>%
  rowwise() %>%
  mutate(
    course_number = paste(school, grade0, subject0, sep = ""),
    course_name = paste(grade, subject),
    course_name = stringr::str_to_title(course_name)
  ) %>% # View()
  select(-c(
    rc_field,
    subject,
    school,
    grade,
    grade0,
    subject0
  ))

write_table_by_school <- function(cps_id, data) {
  write_data <- data %>%
    filter(cps_school_id %in% as.double(cps_id)) %>%
    unique()
  
  if (cps_id == 400044) {
    write_data <- write_data %>%
      filter(grepl("kap|kams", local_course_id))
  } else if (cps_id == 400146) {
    write_data <- write_data %>%
      filter(grepl("kac", local_course_id))
  } else if (cps_id == 400163) {
    write_data <- write_data %>%
      filter(grepl("kbcp|kbp", local_course_id))
  } else if (cps_id == 400180) {
    write_data <- write_data %>%
      filter(grepl("kop|koa|kao", local_course_id))
  }
  
  todays_date <- today()
  file_name <- sprintf("reports/%s_isbe_18_19_submission_%s.xlsx", cps_id, todays_date)
  write.xlsx(write_data, here::here(file_name))
}

write_error_xlsx <- function(school_id) {
  school_abbrv <- external_codes %>%
    filter(schoolid == school_id)
  
  birthdate_school <- birthdate_errors %>%
    filter(schoolid == school_id) %>%
    # select(-error_details_3) %>%
    mutate(ASPEN_dob = "")
  
  coursedate_school <- course_dates %>%
    filter(schoolid == school_id) %>%
    mutate(
      ASPEN_START_DATE = "",
      ASPEN_END_DATE = ""
    )
  
  cpsenroll_school <- cps_enroll %>%
    filter(schoolid == school_id) %>%
    mutate(ASPEN_STUDENT_NUMBER = "")
  
  isbe_school <- isbe_num_error %>%
    filter(schoolid == school_id) %>%
    mutate(ASPEN_STATE_STUDENT_NUMBER = "")
  
  
  new_wb <- createWorkbook()
  
  addWorksheet(new_wb, "Birthdate Errors")
  addWorksheet(new_wb, "Course Date Errors")
  addWorksheet(new_wb, "Student Number Errors")
  addWorksheet(new_wb, "State Student Number Errors")
  
  writeDataTable(new_wb, sheet = "Birthdate Errors", birthdate_school, tableStyle = "TableStyleLight1")
  writeDataTable(new_wb, sheet = "Course Date Errors", coursedate_school, tableStyle = "TableStyleLight1")
  writeDataTable(new_wb, sheet = "Student Number Errors", cpsenroll_school, tableStyle = "TableStyleLight1")
  writeDataTable(new_wb, sheet = "State Student Number Errors", isbe_school, tableStyle = "TableStyleLight1")
  
  setColWidths(new_wb, sheet = "Birthdate Errors", cols = c(1:ncol(birthdate_school)), widths = "auto")
  setColWidths(new_wb, sheet = "Course Date Errors", cols = c(1:ncol(coursedate_school)), widths = "auto")
  setColWidths(new_wb, sheet = "Student Number Errors", cols = c(1:ncol(cpsenroll_school)), widths = "auto")
  setColWidths(new_wb, sheet = "State Student Number Errors", cols = c(1:ncol(isbe_school)), widths = "auto")
  
  file_name <- sprintf("18-19 %s CPS EOY data collection ERRORS_%s.xlsx", school_abbrv$abbr, today()) # last_friday_date
  # save workbook
  saveWorkbook(new_wb, file_name, overwrite = TRUE)
}