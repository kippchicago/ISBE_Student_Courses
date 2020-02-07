# preprocessing script.

# Enrolled Courses & Student/ School IDs ----------------------------------------------------

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
