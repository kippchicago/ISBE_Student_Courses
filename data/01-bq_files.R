# pulls datasets from Big Query Database
sy <- silounloadr::calc_academic_year(ymd("2020-06-07"), format = "firstyear")

ps_sy_termid <-
  silounloadr::calc_ps_termid(sy) %>%
  str_extract("\\d{2}") %>%
  as.integer()

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
    enrollmentcode,
    grade_level, 
    exitcode
  ) %>%
  collect() %>%
  mutate(student_id = as.character(student_id)) %>%
  mutate(student_number = as.character(student_number))

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
    termid,
  ) %>%
  collect() %>%
  mutate(student_id = as.character(student_id))

# Course Names
courses <-
  get_powerschool("courses") %>%
  select(
    course_number,
    course_name
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
  get_powerschool("users") %>%
  select(
    users_dcid = dcid,
    teacher_first_name = first_name,
    teacher_last_name = last_name,
    teachernumber,
    email_addr
  ) %>%
  collect()

schoolstaff <-
  get_powerschool("schoolstaff") %>%
  select(
    users_dcid,
    id,
  ) %>%
  collect()
