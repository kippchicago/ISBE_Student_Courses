### ISBE Mid-Year Data Collection 
## Last Update: February 2020 ##

# Load Libraries ----------------------------------------------------------
# move into config folder
library(googledrive)
library(googlesheets)
library(here)
library(janitor)
library(lubridate)
library(openxlsx)
library(purrr)
library(silounloadr)
library(stringi)
library(stringr)
library(tidyverse)

# Load Functions ----------------------------------------------------------
# going into lib into helpers.R

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

# Load Database Files ---------------------------------------------------------------
# this will be in template data folder and will pull this. 

students <- 
  get_powerschool("students") %>%
  select(
    student_id = id,
    student_number,
    state_studentnumber,
    schoolid,
    last_name,
    first_name,
    dob,
    entrydate,
    exitdate,
    enroll_status,
    enrollmentcode
  ) %>%
  collect()

# course/section information
cc <- 
  get_powerschool("cc") %>%
  select(
    cc_id = id,
    schoolid,
    course_number,
    dateenrolled,
    dateleft,
    section_number,
    student_id = studentid,
    teacherid,
    termid
  ) %>%
  collect()

# course name
courses <- 
  get_powerschool("courses") %>%
  select(
    course_number,
    course_name
  ) %>%
  collect()

# re-enrollments table
reenrollment <- 
  get_powerschool("reenrollments") %>% 
  select(
    student_id = studentid,
    enrollmentcode,
    entrydate,
    exitdate,
    schoolid
  ) %>%
  collect()

# school staff IDs to match with user information
schoolstaff <- 
  get_powerschool("schoolstaff") %>%
  select(
    teacherid = id,
    users_dcid,
    schoolid,
    status
  ) %>%
  collect()

# users info: full name, internal KIPP Chicago ID
users <- 
  get_powerschool("users") %>% # glimpse()
  select(
    users_dcid = dcid,
    teacher_first_name = first_name,
    teacher_last_name = last_name,
    teachernumber,
    email_addr
  ) %>%
  collect()

attendance <- 
  get_powerschool("attendance") %>%
  # filter(att_date >= lubridate::ymd("2017-08-21")) %>%
  # filter(att_date >= lubridate::ymd("2018-01-16")) %>%
  filter(att_date >= lubridate::ymd("2019-08-20")) %>% # hard coded, fix
  collect() %>%
  # janitor::clean_names() %>%
  filter(att_mode_code == "ATT_ModeDaily")

attendance_code <- 
  get_powerschool("attendance_code") %>%
  collect() %>%
  # janitor::clean_names() %>%
  mutate(att_code = if_else(att_code == "true", "T", att_code))

membership <- 
  get_powerschool("ps_membership_reg") %>%
  filter(yearid >= ps_sy_termid) %>%
  select(studentid,
         schoolid,
         date = calendardate,
         enrolled = studentmembership,
         grade_level,
         attendance = ATT_CalcCntPresentAbsent
  ) %>%
  collect()

ps_enrollment <- 
  get_powerschool("ps_enrollment_all") %>%
  filter(yearid == 28) %>%
  select(
    ps_stud_id = studentid,
    schoolid,
    entrydate,
    exitdate
  ) %>%
  collect()

# Load Flat Files ---------------------------------------------------------
# go in GCS bucket. script will go in data folder
teach_absent <- 
  read.xlsx(here::here("data", "190628_Days_Absent.xlsx")) %>%
  janitor::clean_names() %>%
  as_tibble()

iein_dob <- 
  read.xlsx(here::here("data", "IEINs & DOBs (18-19) rev.xlsx"), 
            detectDates = TRUE) %>% 
  as.tibble() %>%
  janitor::clean_names() %>%
  rename(
    users_dcid = ps_id,
    teacher_first_name = first,
    teacher_last_name = last
  ) %>%
  left_join(users %>%
              select(
                users_dcid,
                email_addr
              ) %>%
              mutate(
                email_addr = gsub(" ", "", email_addr),
                email_addr = if_else(grepl("dfrasure", email_addr),
                                     "dfrasure@kippchicago.org",
                                     email_addr
                )
              ),
            by = c("e_mail" = "email_addr")
  ) %>% # filter(schoolid != 0) %>% View()
  left_join(schoolstaff,
            by = c("users_dcid.y" = "users_dcid")
  ) %>%
  # filter(status == 1) %>%
  select(-users_dcid.x) %>%
  rename(users_dcid = users_dcid.y) %>%
  mutate(dob = format(as_date(dob), "%m/%d/%Y"))

missing_iein_dob <- 
  read.xlsx(here::here("data", "IEINs & DOBs.xlsx"), detectDates = TRUE) %>%
  as.tibble() %>%
  janitor::clean_names() %>%
  rename(
    users_dcid = ps_id,
    teacher_first_name = first,
    teacher_last_name = last
  ) %>%
  mutate(dob = format(as_date(dob), "%m/%d/%Y"))

# old submission from 2017. this doesn't have all the right courses so she pulls
# another ISBE Report on top of it. 
isbe_report_2017 <- 
  read.xlsx(here::here("EOY Data Collection_KIPP_Chicago_180627.xlsx")) %>%
  as_tibble() %>%
  janitor::clean_names()

# Grades (from report card)
file_list_middle <- 
  dir(path = here::here("data", "Middle school 4-8/"), 
      pattern = "SY18_19", full.names = TRUE)

grade_df_list_middle <- 
  file_list_middle %>%
  map(read_csv) %>%
  map(clean_names)

## pull grades for primary
file_list_primary <- 
  dir(path = here::here("data", "Primary school K-3/"), 
      pattern = "SY18_19", full.names = TRUE)

grade_df_list_prim <- 
  file_list_primary %>%
  map(read_csv) %>%
  map(clean_names)

# Manual Inserted Tables --------------------------------------------------
# load into data folder. 

## Manually look up missing codes
codes_for_NAs <- tibble(
  local_course_id = addl_missing_codes$local_course_id,
  subject = addl_missing_codes$subject,
  grade_level = addl_missing_codes$grade_level,
  isbe_state_course_code = c(
    "52996A000",
    "53234A000",
    "54436A000",
    "55036A000",
    "55185A000",
    "55185A000",
    "58037A000",
    "53234A000",
    "58038A000",
    "54436A000",
    "55184A000",
    "58034A000", 
    NA, 
    NA
  )
)

grade_percent_scale <- 
  tibble(
  grade = c(
    rep("A+", 3),
    rep("A", 4),
    rep("A-", 4),
    rep("B+", 3),
    rep("B", 4),
    rep("B-", 3),
    rep("C+", 3),
    rep("C", 4),
    rep("C-", 3),
    rep("F", 70)
  ),
  percent = c(
    seq(98, 100, 1),
    seq(94, 97, 1),
    seq(90, 93, 1),
    seq(87, 89, 1),
    seq(83, 86, 1),
    seq(80, 82, 1),
    seq(77, 79, 1),
    seq(73, 76, 1),
    seq(70, 72, 1),
    seq(0, 69, 1)
  )
) %>%
  arrange(desc(percent))

## create ISBE table of letter grade codes
isbe_grade_codes <- 
  tribble(
  ~letter_grade, ~isbe_code,
  "A+", "01",
  "A", "02",
  "A-", "03",
  "B+", "04",
  "B", "05",
  "B-", "06",
  "C+", "07",
  "C", "08",
  "C-", "09",
  "F", "13"
)

## tribble of isbe grade codes, KC primary grades, corresponding %
primary_grade_codes <- 
  tribble(
    ~kc_grades, ~kc_percent, ~isbe_codes,
    "EXCEEDS", 95, 27,
    "MEETS", 87, 28,
    "APPROACHING", 70, 29,
    "NOT YET", 59, 30
  )

# course names
course_names_primary <- 
  paste("art",
        "dance",
        "reading",
        "math",
        "musical theater",
        "physical education",
        "explorations",
        "writing",
        "visual arts",
        "science",
        "math centers",
        "performing arts",
        "music",
        "ela",
        sep = "|"
  )

# creating tibble with CPS codes and RCDT codes
external_codes <- 
  tribble(
    ~schoolid, ~abbr, ~cps_id, ~rcdts_code,
    78102, "KAP", 400044, "15016299025282C",
    7810, "KAMS", 400044, "15016299025282C",
    400146, "KAC", 400146, "15016299025101C",
    4001462, "KACP", 4001462, "15016299025101C",
    4001632, "KBP", 400163, "15016299025103C",
    400163, "KBCP", 400163, "15016299025103C",
    4001802, "KOP", 400180, "15016299025245C",
    400180, "KOA", 400180, "15016299025245C"
  )

# MUNGING FILE  ----------------------------------------------------

# NOTE: Filters to Current Course enrollment
# FOR ALL SCHOOLS
course_enroll <- 
  cc %>%
  filter(termid %in% c(2900, -2900)) %>% # remove hardcoding
  group_by(
    student_id,
    course_number
  ) %>%
  filter(dateleft == max(dateleft))

# Note: Filters down to student_id, schoolid, abbr for all past and present students
# FOR ALL SCHOOLS
student_schools <-
  students %>%
  select(
    schoolid,
    student_number
  ) %>%
  left_join(external_codes %>%
    select(
      schoolid,
      abbr
    ),
  by = "schoolid"
  )

# Note: Contains new (2019) alg and prealg isbe codes
isbe_local_course_codes <- 
  isbe_report_2017 %>%
  select(
    isbe_state_course_code,
    local_course_id
  ) %>%
  unique() %>%
  mutate(
    local_course_id = if_else(grepl("kccp", local_course_id),
                              gsub("kccp", "kac", local_course_id),
                              local_course_id
    ),
    local_course_id = if_else(grepl("kaps", local_course_id),
                              gsub("kaps", "kap", local_course_id),
                              local_course_id
    ),
    subject = sub("^\\D*(\\d|k)", "", local_course_id),
    grade_level = str_extract(local_course_id, "\\d"),
    grade_level = if_else(is.na(grade_level), "K", grade_level)
  ) %>%
  add_row(isbe_state_course_code = "52051A000", 
          local_course_id = "kbcp7prealg", 
          subject = "prealg", 
          grade_level = "7") %>%
  add_row(isbe_state_course_code = "52051A000", 
          local_course_id = "koa7prealg", 
          subject = "prealg", 
          grade_level = "7") %>%
  add_row(isbe_state_course_code = "52052A000", 
          local_course_id = "kbcp8alg", 
          subject = "alg", 
          grade_level = "8") %>%
  add_row(isbe_state_course_code = "52052A000", 
          local_course_id = "koa8alg", 
          subject = "alg", 
          grade_level = "8")

# PRIMARY NEEDS -----------------------------------------------------------
course_df <- 
  course_enroll %>%
  rename(ps_stud_id = student_id) %>%
  left_join(courses,
            by = "course_number"
  ) %>%
  mutate(
    course_name = if_else(str_detect(course_name, "\\dth Math") &
                            !grepl("Mathematics|Centers", course_name),
                          str_replace(course_name, "Math", "Mathematics"),
                          course_name
    ),
    course_name = if_else(grepl("ELA", course_name) &
                            !grepl("KAP", course_name),
                          str_replace(course_name, "ELA", "English Language Arts"),
                          course_name
    ),
    course_name = if_else(grepl("Literacy Center", course_name) & !grepl("Centers", course_name),
                          str_replace(course_name, "Center", "Centers"),
                          course_name
    )
  )

# PRIMARY NEEDS -----------------------------------------------------------
# new state course codes (i.e. not in Michael's previous EOY submission)
missing_st_code <- 
  course_enroll %>%
  ungroup() %>%
  select(course_number) %>%
  filter(!grepl("att", course_number)) %>%
  unique() %>%
  anti_join(
    isbe_local_course_codes,
    by = c("course_number" = "local_course_id")
  ) %>%
  filter(!grepl("ell|behav|hw|cread|swela|swmath", course_number))

# Attendance --------------------------------------------------------------

# sy<-silounloadr::calc_academic_year(today(), format = 'firstyear')
sy <- silounloadr::calc_academic_year(ymd("2020-06-07"), format = "firstyear") # hard coded, fix

ps_sy_termid <- 
  silounloadr::calc_ps_termid(sy) %>%
  str_extract("\\d{2}") %>%
  as.integer()

attendance_complete <- 
  attendance %>%
  right_join(attendance_code %>%
               select(
                 attendance_codeid = id,
                 att_code
               ),
             by = "attendance_codeid"
  )

member_att <- 
  membership %>%
  left_join(attendance_complete %>%
              select(
                studentid,
                att_date,
                att_code
                # presence_status_cd
              ),
            by = c("studentid",
                   "date" = "att_date"
            )
  )

attend_student <- 
  member_att %>%
  # mutate(date = lubridate::ymd_hms(date)) %>%
  filter(date >= lubridate::ymd("2019-08-20")) %>% # hard coded, fix
  mutate(
    enrolled0 = 1,
    enrolled = if_else(att_code == "D" & !is.na(att_code), 0, enrolled0),
    present0 = ifelse(is.na(att_code), 1, 0),
    present1 = ifelse(att_code %in% c("A", "S"), 0, present0),
    present2 = ifelse(att_code == "H", 0.5, present1),
    present3 = ifelse(att_code %in% c("T", "E"), 1, present2),
    present = ifelse(is.na(present2), 1, present3),
    absent = (1 - present) * enrolled,
    tardy = ifelse(att_code %in% "T", 1, 0)
  ) %>%
  left_join(students %>%
              select(
                student_id,
                student_number,
                first_name,
                last_name
              ),
            # home_room),
            by = c("studentid" = "student_id")
  ) %>%
  # inner_join(schools, by=c("schoolid")) %>%
  select(
    studentid,
    student_number,
    first_name,
    last_name,
    grade_level,
    schoolid,
    # schoolname,
    # schoolabbreviation,
    # home_room,
    date,
    att_code,
    enrolled,
    present,
    absent,
    tardy
  )

# agg attendance 
attend_school_grade_student <- 
  attend_student %>%
  dplyr::filter(date <= lubridate::ymd("2020-06-07")) %>% # CHANGE DATE    # hard coded, fix
  group_by(schoolid, grade_level, student_number, first_name, last_name) %>%
  summarize(
    enrolled = sum(enrolled),
    present = sum(present),
    absent = sum(absent),
    tardy = sum(tardy)
  ) %>%
  arrange(
    schoolid,
    grade_level
  )

full_attendance <- 
  attend_school_grade_student %>%
  ungroup() %>%
  select(
    schoolid,
    student_number,
    enrolled,
    present
  )

# MIDDLE S. ANALYTICS -------------------------------------------------

unique_codes <- 
  isbe_local_course_codes %>%
  select(
    isbe_state_course_code,
    subject,
    grade_level
  ) %>%
  unique()


# added state codes
courses_4_8 <- 
  missing_st_code %>%
  filter(
    !grepl("kop|kbp", course_number),
    !grepl("kap[1-3|k]", course_number),
    # !grepl("kap[1-3|k]sci", course_number),
    !grepl("kapsped", course_number),
    # !grepl("kbcp58", course_number)
  ) %>%
  mutate(
    subject = sub("^\\D*\\d", "", course_number),
    grade_level = str_extract(course_number, "\\d")
    # subject = if_else(grepl("hum", subject), "ss", subject),
    # subject = if_else(grepl("lit", subject), "ela", subject)
  ) %>%
  left_join(unique_codes,
    by = c(
      "subject",
      "grade_level"
    )
  ) %>%
  rename(local_course_id = course_number)


# PRIMARY NEEDS -----------------------------------------------------------
st_courses_rev <- 
  isbe_local_course_codes %>%
  bind_rows(courses_4_8 %>%
    filter(!is.na(isbe_state_course_code))) %>%
  mutate(
    isbe_state_course_code = if_else(isbe_state_course_code == "05154A000",
      "55184A000",
      isbe_state_course_code
    ),
    isbe_state_course_code = if_else(isbe_state_course_code == "08001A000",
      "58034A000",
      isbe_state_course_code
    ),
    isbe_state_course_code = if_else(grepl("litcen", local_course_id),
      "51068A000",
      isbe_state_course_code
    )
  ) 

# additional missing codes
addl_missing_codes <- 
  courses_4_8 %>%
  filter(is.na(isbe_state_course_code))


# PRIMARY NEEDS -----------------------------------------------------------
st_courses_rev_2 <- 
  st_courses_rev %>%
  bind_rows(codes_for_NAs) %>%
  unique()


# Final Grades -------------------

rc_course_names <- 
  grade_df_list_middle %>%
  map_df(get_middle_grade_courses)

rc_pct <- 
  grade_df_list_middle %>%
  map_df(get_y1_avgs)

# final letter grades

# get_final_grades <- . %>%
#   select(site_id,
#          student_id,
#          contains("y1_avg")) %>%
#   tidyr::gather(rc_field, letter_grade, -site_id:-student_id) %>%
#   filter(grepl("q4", rc_field)) %>%
#   mutate(subject = gsub("(^.+_cr_)(.+)(_final.+)", "\\2", rc_field),
#          course_school = toupper(stringr::str_extract(rc_field, "kap|kac|kccp|kbcp|kams|koa")),
#          course_school = if_else(course_school %in% "kccp", "kac", course_school)) %>%
#   left_join(external_codes %>%
#               select(schoolid,
#                      abbr),
#             by = c("site_id" = "schoolid")) %>%
#   mutate(keep = course_school == abbr) %>%
#   filter(keep)
#
# rc_letter_grades <- grade_df_list %>%
#   map_df(get_final_grades)


## combine grades and percent

# grades <- rc_letter_grades %>%
#   select(-c(rc_field,
#             keep,
#             course_school,
#             abbr)) %>%
#   inner_join(rc_pct %>%
#               select(-c(rc_field,
#                         keep,
#                         course_school,
#                         abbr)),
#             by = c("site_id",
#                    "student_id",
#                    "subject")) %>%
#   mutate(subject = if_else(subject %in% "ss", "social_studies", subject)) %>%
#   left_join(rc_course_names %>%
#               select(-c(rc_field,
#                         course_school,
#                         abbr,
#                         keep)),
#             by = c("site_id",
#                    "student_id",
#                    "subject")) %>%
#   filter(!is.na(percent))

grades <- 
  rc_pct %>%
  select(-c(
    course_school,
    site_id
  )) %>%
  left_join(rc_course_names %>%
    select(-c(
      course_school,
      site_id
    )),
  by = c(
    "abbr",
    "student_id",
    "subject"
  )
  ) %>%
  unique() %>%
  filter(!is.na(course_name))

# missing_course_names <- grades %>%
#   filter(is.na(course_name)) %>%
#   left_join(external_codes %>%
#               select(schoolid,
#                      abbr),
#             by = c("site_id" = "schoolid")) %>%
#   mutate(course_name0 = if_else(subject %in% "pe" &
#                                  abbr %in% "KAMS",
#                                "5th Physical Education",
#                                course_name),
#          course_name1 = if_else(subject %in% "art",
#                                 "4th Art",
#                                 course_name0),
#          course_name2 = if_else(subject %in% "dance",
#                                 "4th Dance",
#                                 course_name1),
#          course_name3 = if_else(subject %in% "explorations",
#                                 "4th Explorations",
#                                 course_name2),
#          course_name4 = if_else(subject %in% "musical_theater",
#                                 "4th Musical Theater",
#                                 course_name3),
#          course_name5 = if_else(subject %in% "pe" &
#                                   abbr %in% "KAP",
#                                 "4th Physical Education",
#                                 course_name4),
#          course_name = course_name5) %>% #filter(is.na(course_name)) %>% View()
#   select(-c(course_name0:course_name5))


# middle_grades_all <- grades %>%
#   filter(!is.na(course_name)) %>%
#   bind_rows(missing_course_names %>%
#               select(-abbr)) %>%
#   mutate(percent = gsub("%", "", percent),
#          percent = as.numeric(percent))

# combine isbe grade codes with middle school grades

# final_grades <- middle_grades_all %>%
#   left_join(isbe_grade_codes,
#             by = "letter_grade")


final_grades <- 
  grades %>%
  left_join(isbe_grade_codes,
    by = c("grade" = "letter_grade")
  )

all_students_1 <- students %>%
  filter(entrydate >= ymd("2018-08-01")) %>%
  mutate(dob = format(as_date(dob), "%m/%d/%Y"))

all_students_2 <- students %>%
  filter(
    entrydate >= ymd("2018-08-01"),
    !entrydate == exitdate
  ) # maybe remove same day exitdate

# Combine Data ------------------------------------------------------------

fin_grade_course_att <- 
  final_grades %>%
  mutate(
    course_name = if_else(grepl("7th Pre-Algebra", course_name),
      "7th Mathematics",
      course_name
    ),
    course_name = if_else(grepl("8th Algebra", course_name),
      "8th Mathematics",
      course_name
    )
  ) %>%
  left_join(all_students_1 %>%
    rename(ps_stud_id = student_id),
  by = c(
    "student_id" = "student_number",
    "schoolid"
  )
  ) %>%
  left_join(course_df,
    by = c(
      "ps_stud_id",
      "course_name",
      "schoolid"
    )
  ) %>%
  left_join(full_attendance,
    by = c("schoolid",
      "student_id" = "student_number"
    )
  ) %>%
  left_join(st_courses_rev_2 %>%
    select(
      course_number = local_course_id,
      isbe_state_course_code
    ),
  by = "course_number"
  )

## missing section information for 4th PE
# grades_course_att %>%
#   filter(is.na(section_number))
#
# pe_g4_missing_sect <- grades_course_att %>%
#   filter(course_name %in% "4th Writing") %>%
#   select(student_id,
#          section_number_keep = section_number)
#
#
# pe_complete_section <- grades_course_att %>%
#   filter(is.na(section_number)) %>%
#   left_join(pe_g4_missing_sect,
#             by = "student_id") %>%
#   select(-section_number) %>%
#   rename(section_number = section_number_keep)
#
# fin_grade_course_att <- grades_course_att %>%
#   filter(!is.na(section_number)) %>%
#   bind_rows(pe_complete_section)

## add in teacher information
teacher_ids <- 
  fin_grade_course_att %>%
  select(teacherid) %>%
  unique()

# pe_4th <- tibble(teacherid = 4486)
#
# teacher_ids <- teacherids %>%
#   bind_rows(pe_4th)

teacher_info <- 
  schoolstaff %>%
  filter(teacherid %in% teacher_ids$teacherid) %>%
  select(-status) %>%
  unique() %>%
  left_join(users,
    by = "users_dcid"
  ) %>%
  left_join(iein_dob %>%
    select(
      users_dcid,
      schoolid,
      iein,
      dob
    ),
  by = c(
    "users_dcid",
    "schoolid"
  )
  ) %>%
  left_join(missing_iein_dob %>%
    select(
      miss_iein = iein,
      miss_dob = dob,
      e_mail
    ),
  by = c("email_addr" = "e_mail")
  ) %>%
  mutate(
    iein = if_else(is.na(iein), miss_iein, iein),
    dob = if_else(is.na(dob), miss_dob, dob),
    teacher_first_name = if_else(grepl("Lizzy", teacher_first_name),
      "Megan",
      teacher_first_name
    ),
    teacher_last_name = if_else(grepl("Morris", teacher_last_name),
      "Martin",
      teacher_last_name
    )
  ) %>%
  left_join(teach_absent,
    by = c(
      "teacher_first_name" = "first",
      "teacher_last_name" = "last"
    )
  ) %>%
  mutate(
    days_taken = if_else(is.na(days_taken), 0, days_taken),
    total_days = 176,
    actual_att = total_days - days_taken,
    teacher_course_start_date = as_date("2018-08-20"),
    teacher_course_end_date = as_date("2019-06-14"),
    exit_reason = "01",
    teacher_course_end_date = format(as_date(teacher_course_end_date), "%m/%d/%Y")
  )

# total_days = if_else(teacherid %in% 2939, 40, 176),
# actual_att = total_days - days_taken_off,
# teacher_course_start_date = as_date("2017-08-21"),
# teacher_course_end_date = as_date("2018-06-15"),
# teacher_course_end_date = if_else(teacherid == 4491, #J. Weiner
#                                   as_date("2018-03-23"),
#                                   teacher_course_end_date),
# teacher_course_start_date = if_else(teacherid == 4580, #T. Okulaja
#                                   as_date("2017-10-23"),
#                                   teacher_course_start_date),
# teacher_course_start_date = if_else(teacherid == 2939, #E. Delaney
#                                     as_date("2018-04-03"),
#                                     teacher_course_start_date),
# exit_reason = if_else(teacher_course_end_date < as_date("2018-06-15"),
#                       "01",
#                       "02"),
# teacher_course_end_date = format(as_date(teacher_course_end_date), "%m/%d/%Y")) #%>% View()


## will need to find attendance info for these dates
## then join with teacher/course/grade data,
### combine with full data
### finally adjust attendance data for the observations already in the full dataset

# student_list <- final_grades %>%
#   left_join(all_students_1 %>%
#               rename(ps_stud_id = student_id),
#             by = c("student_id" = "student_number")) %>%
#   left_join(course_df,
#             by = c("ps_stud_id",
#                    "course_name")) %>% #filter(!schoolid.x==site_id)
#   select(ps_stud_id) %>%
#   unique()

student_list <- 
  fin_grade_course_att %>%
  select(ps_stud_id) %>%
  unique()

return_mid_year <- 
  reenrollment %>%
  filter(
    student_id %in% student_list$ps_stud_id,
    exitdate >= ymd("2018-08-20")
  ) %>%
  mutate(exit_entry = difftime(exitdate, entrydate, units = "days")) %>%
  filter(exit_entry > 7)


# Final Spreadsheet - 4-8 middle school -----------------------------------

final_ibse_rep_4_8 <- 
  fin_grade_course_att %>%
  # mutate(teacherid = if_else(course_name %in% '4th Physical Education', 4486, as.double(teacherid)),
  #        state_course_code = if_else(course_name %in% '4th Physical Education', "58034A000", state_course_code)) %>%
  left_join(teacher_info %>%
    rename(teacher_dob = dob),
  by = c(
    "teacherid",
    "schoolid"
  )
  ) %>%
  left_join(external_codes,
    by = "schoolid"
  ) %>%
  rename(home_rcdts = rcdts_code) %>%
  mutate(
    serving_school = home_rcdts,
    school_year = 2019,
    term = "Y1", # if_else(course_name %in% "5th Math Centers", "Q4", "Y1"),
    course_level = "02",
    course_credit = 1.00,
    articulated_cred = "02",
    dual_credit = "02",
    course_setting = "01",
    total_att_days = 176, # if_else(course_name %in% "5th Math Centers", 40, 176),
    max_num_grade = 100,
    teacher_serving_loc = home_rcdts,
    employer_rcdts = home_rcdts,
    role_of_professional = 200,
    teacher_commitment = 1.00,
    teacher_total_att = total_att_days,
    reason_for_exit = "01"
  ) %>% # if_else(teacherid == 4491, "02", "01")) %>%  #glimpse()
  select(
    cps_school_id = cps_id,
    isbe_student_id = state_studentnumber,
    cps_student_id = student_id,
    student_last_name = last_name,
    student_first_name = first_name,
    dob,
    home_rcdts,
    serving_school,
    school_year,
    term,
    isbe_course_code = isbe_state_course_code,
    local_course_id = course_number,
    local_course_title = course_name,
    student_course_start = entrydate,
    section_number,
    course_level,
    course_credit,
    articulated_cred,
    dual_credit,
    course_setting,
    actual_att_days_stud = present,
    total_days_stud = enrolled,
    course_num_grade = percent,
    max_num_grade,
    student_course_end = exitdate,
    stud_course_letter_grade = isbe_code,
    teacher_iein = iein,
    local_teacher_id = teacherid,
    teacher_last_name,
    teacher_first_name,
    teacher_dob,
    teacher_serving_loc,
    employer_rcdts,
    teacher_course_start_date,
    role_of_professional,
    teacher_commitment,
    actual_att,
    total_att_days,
    teacher_course_end_date,
    reason_for_exit
  ) %>%
  mutate( # student_course_start = format(student_course_start, "%m/%d/%Y"),
    # student_course_end = format(student_course_end, "%m/%d/%Y"),
    student_first_name = gsub("'|\\.", " ", student_first_name),
    student_last_name = gsub("'|\\.", " ", student_last_name),
    teacher_first_name = gsub("'|\\.", " ", teacher_first_name),
    teacher_last_name = gsub("'|\\.", " ", teacher_last_name)
  )


# Write Final ISBE Report 4-8 -------------------------------------------------------------

# write.xlsx(final_ibse_rep_4_8, here("reports/isbe_4_8_180625.xlsx"))
todays_date <- today()

file_name_4_8 <- sprintf("reports/isbe_4_8_%s.xlsx", todays_date)

write.xlsx(final_ibse_rep_4_8, here::here(file_name_4_8))


# PRIMARY ANALYTICS ------------------------------------------------------

primary_missing_codes <- 
  missing_st_code %>%
  anti_join(st_courses_rev_2,
            by = c("course_number" = "local_course_id")
  )
# filter(!grepl("kap[1-3|k][sci]", course_number),
#        !grepl("kbcp", course_number),
#        !grepl("kapsped", course_number))

primary_courses <- 
  isbe_report_2017 %>%
  select(
    isbe_state_course_code,
    local_course_id,
    local_course_title
  ) %>%
  mutate(
    grade_level = str_extract(local_course_id, "\\d"),
    grade_level = if_else(is.na(grade_level), 0, as.double(grade_level)),
    local_course_id = if_else(grepl("kaps", local_course_id),
                              gsub("kaps", "kap", local_course_id),
                              local_course_id
    ),
    local_course_title = if_else(grepl("4th Math", local_course_title) &
                                   !grepl("Centers", local_course_title),
                                 "4th Mathematics",
                                 local_course_title
    ) # ,
    # local_course_title = if_else(grepl("kap", local_course_id) &
    #                              grepl("Art", local_course_title) &
    #                              !grepl("Arts", local_course_title),
    #                              gsub("Art", "Visual Arts", local_course_title),
    #                              local_course_title)
  ) %>%
  filter(
    grade_level < 5,
    !grepl("kac", local_course_id)
  )

## Primary ISBE Course Codes

# primary_missing_codes <- missing_st_code %>%
#   filter(grepl("kop|kaps", course_number),
#          !grepl("4", course_number))

# 2015 primary courses and state course code (Michael S sent this info)
# student_course_2015 <- read.xlsx(here("data/Student Course Assignment 2015 - KIPP Chicago (EOY) - revised.xlsx")) %>%
#  janitor::clean_names()


# primary_st_course_codes <- student_course_2015 %>%
#   select(state_course_code,
#          local_course_id,
#          local_course_title) %>%
#   unique() %>%
#   filter(!grepl("([4-8])", local_course_id)) %>%
#   mutate(local_course_title = if_else(grepl("Math", local_course_title),
#                                       "Math",
#                                       local_course_title))

## primary teacher info
primary_course_info <- 
  course_df %>%
  filter(
    !grepl("([5-8])", course_number),
    !grepl("kac", course_number),
    !grepl("att|ell|swela|swmath", course_number)
    # !grepl("woo", course_number)
  ) %>%
  # filter(!grepl("Science|Power|Sped", course_name)) %>% #filter(ps_stud_id %in% 16934)
  group_by(ps_stud_id) %>%
  filter(dateleft == max(dateleft))

primary_teachers <- 
  primary_course_info %>% # filter(ps_stud_id %in% 16934)
  group_by(ps_stud_id) %>%
  filter(dateleft == max(dateleft)) %>%
  select(
    ps_stud_id,
    teacherid,
    course_number,
    course_name,
    section_number
  ) %>%
  unique() # %>% group_by(ps_stud_id) %>% summarize(N= n()) %>% filter(N > 1)

# primary_teachers %>% ungroup() %>% select(-ps_stud_id) %>% unique() %>%
#   left_join(schoolstaff,
#             by = "teacherid") %>%
#   left_join(users,
#             by = "users_dcid") %>%
#   left_join(iein_dob %>%
#               select(iein,
#                      dob,
#                      e_mail),
#             by = c("email_addr" = "e_mail")) %>%
#   left_join(missing_iein_dob %>%
#               select(miss_iein = iein,
#                      miss_dob = dob,
#                      e_mail),
#             by = c("email_addr" = "e_mail")) %>%
#   filter(is.na(iein), is.na(miss_iein))

homeroom_teacher <- 
  primary_teachers %>%
  left_join(schoolstaff,
    by = "teacherid"
  ) %>%
  left_join(users,
    by = "users_dcid"
  )

p_teachers_w_excel <- 
  primary_teachers %>%
  ungroup() %>%
  select(teacherid) %>%
  unique() %>%
  bind_rows(tibble(teacherid = c( # 3681,
    # KAP visual arts
    # 1689, # KAP Musical T.
    # 4941, #KAP PE,
    # 4487, # KAP Dance
    # 2484, #KAP explorations
    4521, # KOP visual arts
    5381, # KOP performance arts
    4954 # KBP music
  ))) %>%
  left_join(schoolstaff,
    by = "teacherid"
  ) %>%
  left_join(users,
    by = "users_dcid"
  )

primary_grades <- 
  grade_df_list_prim %>%
  map_df(get_primary_grades_courses)

k_3_teachers <- 
  primary_teachers %>%
  left_join(schoolstaff,
    by = c("teacherid")
  ) %>%
  left_join(users,
    by = c("users_dcid")
  ) %>%
  filter(
    !grepl("4", course_name),
    !grepl("Science", course_name)
  )

k_3_grades_teachid <- 
  primary_grades %>%
  filter(!grepl("4", course_name)) %>%
  left_join(students %>%
    select(student_number,
      ps_stud_id = student_id
    ),
  by = c("student_id" = "student_number")
  ) %>%
  left_join(k_3_teachers %>%
    select(
      ps_stud_id,
      teacherid
    ),
  by = c("ps_stud_id")
  )

k_3_excellance <- 
  k_3_grades_teachid %>%
  select(
    site_id,
    course_name
  ) %>%
  unique() %>%
  mutate(
    teacherid0 = if_else(site_id %in% 78102 &
      grepl("Art", course_name),
    3681,
    0
    ),
    teacherid1 = if_else(site_id %in% 78102 &
      grepl("Musical Theater", course_name),
    1689,
    teacherid0
    ),
    teacherid2 = if_else(site_id %in% 78102 &
      grepl("Physical Education", course_name),
    4941,
    teacherid1
    ),
    teacherid3 = if_else(site_id %in% 78102 &
      grepl("Dance", course_name),
    4487,
    teacherid2
    ),
    teacherid4 = if_else(site_id %in% 78102 &
      grepl("Explorations", course_name),
    2484,
    teacherid3
    ),
    teacherid5 = if_else(site_id %in% 4001802 &
      grepl("Visual Arts", course_name),
    4521,
    teacherid4
    ),
    teacherid6 = if_else(site_id %in% 4001802 &
      grepl("Performing Arts", course_name),
    5381,
    teacherid5
    ),
    teacherid7 = if_else(site_id %in% 4001802 &
      grepl("Performing Arts", course_name),
    5381,
    teacherid6
    ),
    teacherid = if_else(site_id %in% 4001632 &
      grepl("Music", course_name),
    4954,
    teacherid7
    )
  ) %>%
  filter(teacherid > 0) %>%
  select(-c(teacherid0:teacherid7))

k_3_grades_teacher <- 
  k_3_grades_teachid %>%
  left_join(k_3_excellance %>%
    rename(ex_teacherid = teacherid),
  by = c(
    "site_id",
    "course_name"
  )
  ) %>% # View()
  mutate(teacherid = if_else(!is.na(ex_teacherid),
    ex_teacherid,
    as.double(teacherid)
  )) %>% # View()
  select(-ex_teacherid) %>%
  left_join(p_teachers_w_excel,
    by = "teacherid"
  ) %>%
  filter(!grepl("Guided|Choice", course_name))

kap4_grades_teacher <- 
  primary_grades %>%
  filter(grepl("4", course_name)) %>%
  mutate(
    course_name = if_else(grepl("Art", course_name),
      "4th Visual Arts",
      course_name
    ),
    course_name = if_else(grepl("Ela", course_name),
      "4th English Language Arts",
      course_name
    ),
    course_name = if_else(grepl("Math", course_name),
      "4th Mathematics",
      course_name
    )
  ) %>%
  left_join(students %>%
    select(student_number,
      ps_stud_id = student_id
    ),
  by = c("student_id" = "student_number")
  ) %>%
  left_join(primary_teachers %>%
    filter(grepl("4", course_name)) %>%
    ungroup() %>%
    select(
      ps_stud_id,
      teacherid,
      course_name
    ),
  by = c(
    "ps_stud_id",
    "course_name"
  )
  ) %>%
  left_join(p_teachers_w_excel,
    by = "teacherid"
  )

# primary_grades_teachid <- primary_grades %>%
#   left_join(students %>%
#               select(student_number,
#                      ps_stud_id = student_id),
#             by = c("student_id" = "student_number")) %>%
#   left_join(primary_teachers %>%
#               select(ps_stud_id,
#                      teacherid) %>%
#               unique(),
#             by = c("ps_stud_id"))


# NOTE: Term ids will need to be changed
kap4_sections <- 
  cc %>%
  filter(
    termid == 2800,
    student_id %in% kap4_grades_teacher$ps_stud_id,
    grepl("att", course_number)
  ) %>%
  group_by(student_id) %>%
  filter(dateleft == max(dateleft)) %>%
  select(
    ps_stud_id = student_id,
    section_number
  )

p_grades_teacher <- 
  k_3_grades_teacher %>%
  mutate(section_number = "1") %>%
  bind_rows(kap4_grades_teacher %>%
    left_join(kap4_sections,
      by = "ps_stud_id"
    )) %>%
  left_join(ps_enrollment %>%
    group_by(
      schoolid,
      ps_stud_id
    ) %>%
    filter(exitdate == max(exitdate)),
  by = c(
    "ps_stud_id",
    "schoolid"
  )
  )

# primary_with_st_course_codes <-  p_grades_teacher %>%
#    select(course_name) %>%
#    unique() %>%
#    mutate(course_name0 = tolower(course_name)) %>%
#    left_join(primary_courses %>%
#                mutate(course_name0 = tolower(local_course_title)), #%>% View,
#              by = 'course_name0')


primary_with_st_course_codes <- 
  p_grades_teacher %>%
  filter(!grepl("Choice|Guided", course_name)) %>%
  mutate(school = str_extract(course_number, "kop|kap|kbp")) %>%
  left_join(primary_courses %>%
    mutate(school = str_extract(local_course_id, "kop|kap|kbp")) %>%
    select(
      isbe_state_course_code,
      local_course_title,
      school
    ) %>%
    unique(),
  by = c(
    "course_name" = "local_course_title",
    "school"
  )
  ) %>%
  unique()

na_st_codes <-
  primary_with_st_course_codes %>%
  filter(is.na(isbe_state_course_code)) %>%
  select(
    course_number,
    course_name
  ) %>%
  unique() %>%
  ungroup() %>%
  mutate(
    school = str_extract(course_number, "kap|kop|kbp"),
    st_course_code = c(
      "53233A000",
      "51130A000",
      "52030A000",
      "55130A000",
      "51040A000",
      "51130A000",
      "53231A000",
      "52032A000",
      "55072A000",
      "51042A000",
      "53232A000",
      "51132A000",
      "55184A000",
      "53234A000"
    )
  )

fin_codes <- 
  primary_with_st_course_codes %>%
  left_join(na_st_codes %>%
    select(
      course_name,
      school,
      st_course_code
    ),
  by = c("course_name", "school")
  ) %>%
  mutate(isbe_state_course_code = if_else(is.na(isbe_state_course_code),
    st_course_code,
    isbe_state_course_code
  )) %>% # View()
  select(-st_course_code)

final_isbe_k_4 <- 
  fin_codes %>%
  left_join(full_attendance,
    by = c(
      "student_id" = "student_number",
      "schoolid"
    )
  ) %>%
  select(schoolid,
    student_id,
    kc_percent,
    isbe_codes,
    course_number,
    course_name,
    ps_stud_id,
    teacherid,
    teacher_first_name,
    teacher_last_name,
    teachernumber,
    isbe_state_course_code,
    enrolled,
    present,
    dateenrolled = entrydate,
    dateleft = exitdate,
    email_addr,
    section_number
  ) %>%
  left_join(teach_absent,
    by = c(
      "teacher_first_name" = "first",
      "teacher_last_name" = "last"
    )
  ) %>%
  mutate(
    days_taken = if_else(is.na(days_taken),
      0,
      days_taken
    ),
    teacher_start_date = ymd("2018-08-20"),
    teacher_end_date = ymd("2019-06-14")
  ) %>%
  left_join(external_codes,
    by = "schoolid"
  ) %>%
  left_join(students %>%
    mutate(dob = format(as_date(dob), "%m/%d/%Y")) %>%
    select(
      student_id = student_number,
      dob,
      student_first_name = first_name,
      student_last_name = last_name,
      state_studentnumber
    ),
  by = "student_id"
  ) %>%
  left_join(iein_dob %>%
    select(
      teacher_dob = dob,
      iein,
      e_mail
    ) %>%
    unique(),
  by = c("email_addr" = "e_mail")
  ) %>% # glimpse()
  mutate(
    serving_school = rcdts_code,
    home_rcdts = rcdts_code,
    school_year = 2019,
    term = "Y1", # if_else(course_name %in% "5th Math Centers", "Q4", "Y1"),
    course_level = "02",
    course_credit = 1.00,
    articulated_cred = "02",
    dual_credit = "02",
    course_setting = "01",
    total_att_days = 176, # if_else(course_name %in% "5th Math Centers", 40, 176),
    max_num_grade = 100,
    teacher_serving_loc = home_rcdts,
    employer_rcdts = home_rcdts,
    role_of_professional = 200,
    teacher_commitment = 1.00,
    teacher_total_att = total_att_days,
    actual_att = teacher_total_att - days_taken,
    reason_for_exit = "01"
  ) %>%
  select(
    cps_school_id = cps_id,
    isbe_student_id = state_studentnumber,
    cps_student_id = student_id,
    student_last_name,
    student_first_name,
    dob,
    home_rcdts,
    serving_school,
    school_year,
    term,
    isbe_course_code = isbe_state_course_code,
    local_course_id = course_number,
    local_course_title = course_name,
    student_course_start = dateenrolled,
    section_number,
    course_level,
    course_credit,
    articulated_cred,
    dual_credit,
    course_setting,
    actual_att_days_stud = present,
    total_days_stud = enrolled,
    course_num_grade = kc_percent,
    max_num_grade,
    student_course_end = dateleft,
    stud_course_letter_grade = isbe_codes,
    teacher_iein = iein,
    local_teacher_id = teacherid,
    teacher_last_name,
    teacher_first_name,
    teacher_dob,
    teacher_serving_loc,
    employer_rcdts,
    teacher_course_start_date = teacher_start_date,
    role_of_professional,
    teacher_commitment,
    actual_att,
    total_att_days,
    teacher_course_end_date = teacher_end_date,
    reason_for_exit
  ) %>%
  mutate( # student_course_start = format(student_course_start, "%m/%d/%Y"),
    # student_course_end = format(student_course_end, "%m/%d/%Y"),
    student_first_name = gsub("'|\\.", " ", student_first_name),
    student_last_name = gsub("'|\\.", " ", student_last_name),
    teacher_first_name = gsub("'|\\.", " ", teacher_first_name),
    teacher_last_name = gsub("'|\\.", " ", teacher_last_name)
  )


# Write Final ISBE Report k-4  -----------------------------------------------------------

todays_date <- today()

file_name_k_4 <- sprintf("reports/isbe_k_4_%s.xlsx", todays_date)

write.xlsx(final_isbe_k_4, here::here(file_name_k_4))


# File Submissions -----------------------------------------------------

combined_submission <- 
  final_isbe_k_4 %>% # glimpse()
  mutate(
    course_num_grade = as.double(course_num_grade),
    teacher_course_end_date = format(as_date(teacher_course_end_date), "%m/%d/%Y")
  ) %>%
  bind_rows(final_ibse_rep_4_8 %>% # glimpse()
    mutate(
      course_num_grade = as.double(course_num_grade),
      stud_course_letter_grade = as.double(stud_course_letter_grade)
    )) %>%
  mutate(isbe_course_code = if_else(isbe_course_code == "08001A000",
    "58034A000",
    isbe_course_code
  )) %>%
  mutate(
    student_course_start = format(as_date(student_course_start), "%m/%d/%Y"),
    student_course_end = format(as_date(student_course_end), "%m/%d/%Y"),
    teacher_course_start_date = format(as_date(teacher_course_start_date), "%m/%d/%Y"),
    student_course_end = if_else(student_course_end == "06/15/2019", "06/14/2019", student_course_end)
  )


write_table_by_school(400044, combined_submission)
write_table_by_school(400163, combined_submission)
write_table_by_school(400146, combined_submission)
write_table_by_school(400180, combined_submission)


# Error Correcting - Process for Fixing Errors ----------------------------

external_codes$cps_id %>%
  unique() %>%
  purrr::map_df(~ write_table_by_school(.x, combined_submission))

googledrive::drive_download("Copy of 400044_CourseAssignment2019_01.xls")

# cps_verify_ascend <- read.xlsx("data/Copy of 400044_CourseAssignment2019_01.xls.xlsx") %>%
#   as_tibble() %>%
#   clean_names()

cps_verify_ascend <- 
  read.xlsx("data/400044_CPS_verification_2019-07-16.xlsx") %>%
  as_tibble() %>%
  clean_names()
cps_verify_bloom <- read.xlsx("data/400163_CPS_verification_2019-07-15.xlsx") %>%
  as_tibble() %>%
  clean_names()

cps_verify_academy <- read.xlsx("data/400146_CPS_verification_2019-07-15.xlsx") %>%
  as_tibble() %>%
  clean_names()

cps_verify_one <- read.xlsx("data/400180_CPS_verification_2019-07-15.xlsx") %>%
  as_tibble() %>%
  clean_names()

cps_verify_all <- cps_verify_ascend %>%
  bind_rows(
    cps_verify_academy %>%
      mutate(teacher_iein_illinois_educator_identification_number = as.character(teacher_iein_illinois_educator_identification_number)),
    cps_verify_bloom,
    cps_verify_one
  ) %>%
  filter(!cps_school_id == 400001)

cps_verify_ascend %>% glimpse()

cps_verify_ascend %>%
  select(error_details) %>%
  unique()

cps_verify_all %>%
  select(error_details) %>%
  unique() %>%
  View()

# dup_ids_ascend <- cps_verify_ascend %>%
#   filter(grepl("Duplicates", error_details)) %>%
#   select(cps_student_id) %>%
#   unique()

# combined_submission %>%
#   filter(cps_school_id == 400044) %>%
#   unique() %>%
#   filter(cps_student_id %in% dup_ids_ascend$cps_student_id) %>%
#   select(student_last_name,
#          student_first_name,
#          local_course_id,
#          teacher_last_name,
#          teacher_first_name) %>%
#   View()

# clears all duplicates:
# deduped_ascend <- combined_submission %>%
#   filter(cps_school_id == 400044) %>%
#   unique()

# roles_errors <- "EIS Position Codes/Role of Professional must be one of the following: 200, 201, 202, 203, 204, 207, 208, 250, 251, 310, 601, 602, 603, 604, 604, 606, 607, 608, 609, 610, 611, 699"
iein_error <- "Please provide a valid all numeric IEIN"
enroll_error <- "CPS Student ID must be enrolled in SY19 in order for the record to be accepted"
isbe_error <- "No ISBE Student ID found from ASPEN"

id_stud_w_errors <- cps_verify_all %>%
  filter(
    !grepl("No Errors Found", error_details),
    !error_details == iein_error
  )


birthdate_errors <- id_stud_w_errors %>%
  filter(grepl("Birth Date", error_details)) %>%
  select(
    cps_student_id,
    birth_date,
    student_first_name,
    student_last_name
  ) %>%
  unique() %>%
  left_join(students %>%
    select(
      student_number,
      schoolid
    ),
  by = c("cps_student_id" = "student_number")
  )


firstname_errors <- id_stud_w_errors %>%
  filter(
    grepl("First Name", error_details),
    !grepl("Last Name", error_details)
  ) %>%
  select(
    cps_student_id,
    cps_school_id,
    birth_date,
    student_first_name,
    student_last_name,
    error_details
  ) %>%
  unique() %>%
  mutate(
    new_first_name = str_extract(error_details, "'\\w.+'"),
    new_first_name = gsub("'", "", new_first_name),
    new_first_name = gsub(";.+", "", new_first_name)
  ) %>%
  select(-error_details) %>%
  unique()


lastname_errors <- id_stud_w_errors %>%
  filter(grepl("Last Name", error_details)) %>%
  select(
    cps_student_id,
    cps_school_id,
    birth_date,
    student_first_name,
    student_last_name,
    error_details
  ) %>%
  unique() %>%
  mutate(
    error_details_2 = str_extract(error_details, ";.+"),
    new_last_name_1 = str_extract(error_details, "'\\w.+'"),
    new_last_name_2 = str_extract(error_details_2, "'\\w.+'"),
    new_last_name = new_last_name_1,
    new_last_name = if_else(!is.na(new_last_name_2),
      new_last_name_2,
      new_last_name
    ),
    new_last_name = gsub("'", "", new_last_name)
  ) %>%
  select(-c(error_details:new_last_name_2)) %>%
  unique()

course_dates <- id_stud_w_errors %>%
  filter(grepl("Course (Start|End)", error_details)) %>% # View()
  select(
    cps_student_id,
    birth_date,
    student_first_name,
    student_last_name,
    student_course_start_date,
    student_course_end_date
  ) %>%
  unique() %>%
  left_join(students %>%
    select(
      student_number,
      schoolid
    ),
  by = c("cps_student_id" = "student_number")
  )

cps_enroll <- cps_verify_all %>%
  filter(
    grepl(enroll_error, error_details),
    !grepl("Nadie", student_last_name)
  ) %>%
  select(
    cps_student_id,
    student_last_name,
    student_first_name
  ) %>%
  unique() %>%
  left_join(students %>%
    select(
      student_number,
      schoolid
    ),
  by = c("cps_student_id" = "student_number")
  )

isbe_num_error <- cps_verify_all %>%
  filter(
    grepl(isbe_error, error_details),
    !grepl("Nadie", student_last_name)
  ) %>%
  select(
    cps_student_id,
    isbe_student_id,
    student_last_name,
    student_first_name
  ) %>%
  unique() %>%
  left_join(students %>%
    select(
      student_number,
      schoolid
    ),
  by = c("cps_student_id" = "student_number")
  )



write_error_xlsx(78102)
write_error_xlsx(7810)
write_error_xlsx(400146)
write_error_xlsx(400163)
write_error_xlsx(4001632)
write_error_xlsx(400180)
write_error_xlsx(4001802)

rev_submission <- combined_submission %>%
  unique() %>%
  left_join(firstname_errors %>%
    select(
      cps_student_id,
      new_first_name
    ) %>%
    unique(),
  by = "cps_student_id"
  ) %>%
  left_join(lastname_errors %>%
    select(
      cps_student_id,
      new_last_name
    ) %>%
    unique(),
  by = "cps_student_id"
  ) %>%
  mutate(
    student_first_name = if_else(!is.na(new_first_name),
      new_first_name,
      student_first_name
    ),
    student_last_name = if_else(!is.na(new_last_name),
      new_last_name,
      student_last_name
    )
  ) %>%
  select(
    -new_last_name,
    -new_first_name
  )


googledrive::drive_download("18-19 KAMS CPS EOY data collection ERRORS_2019-07-15", overwrite = TRUE)

kams_corrections <- read.xlsx("18-19 KAMS CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 2)

kams_edits <- kams_corrections %>%
  as_tibble() %>%
  janitor::clean_names() %>%
  mutate(
    aspen_start_date = as_date(aspen_start_date),
    aspen_start_date = aspen_start_date - years(70),
    aspen_start_date = aspen_start_date - days(1),
    aspen_start_date = if_else(grepl("2016", aspen_start_date),
      aspen_start_date - days(1),
      aspen_start_date
    ),
    aspen_end_date = as_date(aspen_end_date),
    aspen_end_date = aspen_end_date - years(70),
    aspen_end_date = aspen_end_date - days(1),
    aspen_start_date = if_else(aspen_start_date < ymd("2018-08-20"),
      ymd("2018-08-20"),
      aspen_start_date
    )
  ) %>%
  select(
    cps_student_id,
    aspen_start_date,
    aspen_end_date
  ) %>%
  mutate(
    aspen_start_date = format(as_date(aspen_start_date), "%m/%d/%Y"),
    aspen_end_date = format(as_date(aspen_end_date), "%m/%d/%Y")
  )

googledrive::drive_download("18-19 KBP CPS EOY data collection ERRORS_2019-07-15", overwrite = TRUE)
googledrive::drive_download("18-19 KBCP CPS EOY data collection ERRORS_2019-07-15", overwrite = TRUE)

kbp_edits_dob <- read.xlsx("18-19 KBP CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 1)
kbcp_edits_dob <- read.xlsx("18-19 KBCP CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 1)
kbp_edits_courses <- read.xlsx("18-19 KBP CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 2)
kbcp_edits_courses <- read.xlsx("18-19 KBCP CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 2)
kbp_edits_id <- read.xlsx("18-19 KBP CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 3)




bloom_edits_dob <- kbp_edits_dob %>%
  bind_rows(kbcp_edits_dob) %>%
  clean_names() %>%
  mutate(
    aspen_dob = as.Date(aspen_dob, origin = "1899-12-30"),
    aspen_dob = format(as_date(aspen_dob), "%m/%d/%Y")
  ) %>%
  select(cps_student_id,
    new_birth_date = aspen_dob
  )

bloom_edits_courses <- kbp_edits_courses %>%
  bind_rows(kbcp_edits_courses) %>%
  as_tibble() %>%
  clean_names() %>%
  mutate(
    aspen_start_date = as.Date(aspen_start_date, origin = "1899-12-30"),
    aspen_start_date = format(as_date(aspen_start_date), "%m/%d/%Y"),
    aspen_end_date = as.Date(aspen_end_date, origin = "1899-12-30"),
    aspen_end_date = format(as_date(aspen_end_date), "%m/%d/%Y")
  ) %>%
  select(cps_student_id,
    new_start_date = aspen_start_date,
    new_end_date = aspen_end_date
  )

bloom_edits_id <- kbp_edits_id %>%
  select(cps_student_id,
    new_student_id = ASPEN_STUDENT_NUMBER
  )

rev_submission_1 <- rev_submission %>%
  left_join(kams_edits,
    by = "cps_student_id"
  ) %>%
  mutate(
    student_course_start = if_else(!is.na(aspen_start_date),
      aspen_start_date,
      student_course_start
    ),
    student_course_end = if_else(!is.na(aspen_end_date),
      aspen_end_date,
      student_course_end
    )
  ) %>%
  select(
    -aspen_end_date,
    -aspen_start_date
  )

rev_submission_2 <- rev_submission_1 %>%
  left_join(bloom_edits_dob,
    by = "cps_student_id"
  ) %>%
  mutate(dob = if_else(!is.na(new_birth_date),
    new_birth_date,
    dob
  )) %>%
  select(-new_birth_date) %>%
  left_join(bloom_edits_courses,
    by = "cps_student_id"
  ) %>%
  mutate(
    student_course_start = if_else(!is.na(new_start_date),
      new_start_date,
      student_course_start
    ),
    student_course_end = if_else(!is.na(new_end_date),
      new_end_date,
      student_course_end
    )
  ) %>%
  select(
    -new_start_date,
    -new_end_date
  ) %>%
  left_join(bloom_edits_id,
    by = "cps_student_id"
  ) %>%
  mutate(cps_student_id = if_else(!is.na(new_student_id),
    new_student_id,
    cps_student_id
  )) %>%
  select(-new_student_id)


googledrive::drive_download("18-19 KAC CPS EOY data collection ERRORS_2019-07-15", overwrite = TRUE)

kac_edits_dob <- read.xlsx("18-19 KAC CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 1)
kac_edits_courses <- read.xlsx("18-19 KAC CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 2)

kac_dob <- kac_edits_dob %>%
  as_tibble() %>%
  clean_names() %>%
  mutate(
    aspen_dob = as.Date(aspen_dob, origin = "1899-12-30"),
    aspen_dob = format(as_date(aspen_dob), "%m/%d/%Y")
  ) %>%
  select(cps_student_id,
    new_dob = aspen_dob
  )

kac_courses <- kac_edits_courses %>%
  as_tibble() %>%
  clean_names() %>%
  mutate(
    aspen_start_date = as.Date(aspen_start_date, origin = "1899-12-30"),
    aspen_start_date = format(as_date(aspen_start_date), "%m/%d/%Y"),
    aspen_end_date = as.double(aspen_end_date),
    aspen_end_date = as.Date(aspen_end_date, origin = "1899-12-30"),
    aspen_end_date = format(as_date(aspen_end_date), "%m/%d/%Y")
  ) %>%
  select(cps_student_id,
    new_start_date = aspen_start_date,
    new_end_date = aspen_end_date
  )

rev_submission_3 <- rev_submission_2 %>%
  left_join(kac_dob,
    by = "cps_student_id"
  ) %>%
  mutate(dob = if_else(!is.na(new_dob),
    new_dob,
    dob
  )) %>%
  select(-new_dob) %>%
  left_join(kac_courses,
    by = "cps_student_id"
  ) %>%
  mutate(
    student_course_start = if_else(!is.na(new_start_date),
      new_start_date,
      student_course_start
    ),
    student_course_end = if_else(!is.na(new_end_date),
      new_end_date,
      student_course_end
    )
  ) %>%
  select(
    -new_start_date,
    -new_end_date
  )

write_table_by_school(400146, rev_submission_3)

googledrive::drive_download("18-19 KOP CPS EOY data collection ERRORS_2019-07-15", overwrite = TRUE)
googledrive::drive_download("18-19 KOA CPS EOY data collection ERRORS_2019-07-15", overwrite = TRUE)

kop_edits_dob <- read.xlsx("18-19 KOP CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 1)
koa_edits_dob <- read.xlsx("18-19 KOA CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 1)
kop_edits_courses <- read.xlsx("18-19 KOP CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 2)
koa_edits_courses <- read.xlsx("18-19 KOA CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 2)
kop_edits_isbe_id <- read.xlsx("18-19 KOP CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 4)


one_edits_dob <- kop_edits_dob %>%
  bind_rows(koa_edits_dob) %>%
  clean_names() %>%
  mutate(
    aspen_dob = as.Date(aspen_dob, origin = "1899-12-30"),
    aspen_dob = format(as_date(aspen_dob), "%m/%d/%Y")
  ) %>%
  select(cps_student_id,
    new_birth_date = aspen_dob
  )

one_edits_courses <- kop_edits_courses %>%
  bind_rows(koa_edits_courses) %>%
  as_tibble() %>%
  clean_names() %>%
  mutate(
    aspen_start_date = as.Date(aspen_start_date, origin = "1899-12-30"),
    aspen_start_date = format(as_date(aspen_start_date), "%m/%d/%Y"),
    aspen_end_date = as.Date(aspen_end_date, origin = "1899-12-30"),
    aspen_end_date = format(as_date(aspen_end_date), "%m/%d/%Y")
  ) %>%
  select(cps_student_id,
    new_start_date = aspen_start_date,
    new_end_date = aspen_end_date
  )

one_edits_isbe_id <- kop_edits_isbe_id %>%
  select(cps_student_id,
    new_isbe_id = ASPEN_STATE_STUDENT_NUMBER
  )


rev_submission_4 <- rev_submission_3 %>%
  left_join(one_edits_dob,
    by = "cps_student_id"
  ) %>%
  mutate(dob = if_else(!is.na(new_birth_date),
    new_birth_date,
    dob
  )) %>%
  select(-new_birth_date) %>%
  left_join(one_edits_courses,
    by = "cps_student_id"
  ) %>%
  mutate(
    student_course_start = if_else(!is.na(new_start_date),
      new_start_date,
      student_course_start
    ),
    student_course_end = if_else(!is.na(new_end_date),
      new_end_date,
      student_course_end
    )
  ) %>%
  select(
    -new_start_date,
    -new_end_date
  ) %>%
  left_join(one_edits_isbe_id,
    by = "cps_student_id"
  ) %>%
  mutate(isbe_student_id = if_else(!is.na(new_isbe_id),
    as.character(new_isbe_id),
    isbe_student_id
  )) %>%
  select(-new_isbe_id)

write_table_by_school(400180, rev_submission_4)

googledrive::drive_download("18-19 KAP CPS EOY data collection ERRORS_2019-07-15", overwrite = TRUE)


kap_edits_dob <- read.xlsx("18-19 KAP CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 1)
kap_edits_courses <- read.xlsx("18-19 KAP CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 2)
kap_edits_id <- read.xlsx("18-19 KAP CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 3)

kap_dob <- kap_edits_dob %>%
  clean_names() %>%
  mutate(
    aspen_dob = as.Date(aspen_dob, origin = "1899-12-30"),
    aspen_dob = format(as_date(aspen_dob), "%m/%d/%Y")
  ) %>%
  filter(!is.na(aspen_dob)) %>%
  select(cps_student_id,
    new_birth_date = aspen_dob
  )

kap_courses <- kap_edits_courses %>%
  as_tibble() %>%
  clean_names() %>%
  mutate(
    aspen_start_date = as.Date(aspen_start_date, origin = "1899-12-30"),
    aspen_start_date = format(as_date(aspen_start_date), "%m/%d/%Y"),
    aspen_end_date = as.Date(aspen_end_date, origin = "1899-12-30"),
    aspen_end_date = if_else(aspen_end_date > ymd("2019-06-14"),
      ymd("2019-06-14"),
      aspen_end_date
    ),
    aspen_end_date = format(as_date(aspen_end_date), "%m/%d/%Y")
  ) %>%
  select(cps_student_id,
    new_start_date = aspen_start_date,
    new_end_date = aspen_end_date
  )

kap_student_id <- kap_edits_id %>%
  select(cps_student_id,
    new_student_id = ASPEN_STUDENT_NUMBER
  )

rev_submission_5 <- rev_submission_4 %>%
  left_join(kap_dob,
    by = "cps_student_id"
  ) %>%
  mutate(dob = if_else(!is.na(new_birth_date),
    new_birth_date,
    dob
  )) %>%
  select(-new_birth_date) %>%
  left_join(kap_courses,
    by = "cps_student_id"
  ) %>%
  mutate(
    student_course_start = if_else(!is.na(new_start_date),
      new_start_date,
      student_course_start
    ),
    student_course_end = if_else(!is.na(new_end_date),
      new_end_date,
      student_course_end
    )
  ) %>%
  select(
    -new_start_date,
    -new_end_date
  ) %>%
  left_join(kap_student_id,
    by = "cps_student_id"
  ) %>%
  mutate(cps_student_id = if_else(!is.na(new_student_id),
    new_student_id,
    cps_student_id
  )) %>%
  select(-new_student_id)


write_table_by_school(400044, rev_submission_5)

suspensions <- read.xlsx("data/KIPP Chicago - Suspensions (FINAL - for ISBE submission).xlsx") %>%
  janitor::clean_names() %>%
  as_tibble()

reformat_suspensions <- suspensions %>%
  left_join(rev_submission_4 %>%
    select(
      cps_student_id,
      dob,
      student_first_name,
      student_last_name
    ) %>%
    unique(),
  by = "cps_student_id"
  ) %>%
  mutate(
    incident_type_code = 18,
    disciplinary_action = if_else(grepl("In-School Suspension", disciplinary_action),
      3,
      4
    ),
    student_first_name = if_else(is.na(student_first_name),
      legal_first_name,
      student_first_name
    ),
    student_last_name = if_else(is.na(student_last_name),
      legal_last_name,
      student_last_name
    ),
    birth_date = as.Date(birth_date, origin = "1899-12-30"),
    birth_date = format(as_date(birth_date), "%m/%d/%Y"),
    incident_date = as.Date(incident_date, origin = "1899-12-30"),
    incident_date = format(as_date(incident_date), "%m/%d/%Y"),
    dob = if_else(is.na(dob),
      birth_date,
      dob
    )
  ) %>%
  select(
    cps_school_id = school_id,
    isbe_student_id,
    cps_student_id,
    student_last_name,
    student_first_name,
    dob,
    home_school_rcdts_code,
    serving_school_program_rcdts_code,
    school_year,
    incident_date,
    incident_case_id,
    incident_number,
    disability_type,
    incident_type_code,
    disciplinary_action,
    disciplinary_duration
  )

reformat_suspensions %>%
  filter(cps_school_id == 400044) %>%
  unique() %>%
  write.xlsx(file = "reports/400044 ISBE Disciplinary Submission_2019_07_17.xlsx")


reformat_suspensions %>%
  filter(cps_school_id == 400146) %>%
  write.xlsx(file = "reports/400146 ISBE Disciplinary Submission_2019_07_17.xlsx")


reformat_suspensions %>%
  filter(cps_school_id == 400163) %>%
  write.xlsx(file = "reports/400163 ISBE Disciplinary Submission_2019_07_17.xlsx")

reformat_suspensions %>%
  filter(cps_school_id == 400180) %>%
  write.xlsx(file = "reports/400180 ISBE Disciplinary Submission_2019_07_17.xlsx")
