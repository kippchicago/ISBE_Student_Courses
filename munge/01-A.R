# preprocessing script.

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
