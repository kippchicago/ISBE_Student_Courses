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
    termid,
  ) %>%
  collect()

# Course Names
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
  get_powerschool("users") %>%
  select(
    users_dcid = dcid,
    teacher_first_name = first_name,
    teacher_last_name = last_name,
    teachernumber,
    email_addr
  ) %>%
  collect()

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
  select(
    ps_stud_id = studentid,
    schoolid,
    entrydate,
    exitdate,
    yearid
  ) %>%
  collect()

schoolstaff <-
  get_powerschool("schoolstaff") %>%
  select(
    users_dcid,
    id,
  ) %>%
  collect()
