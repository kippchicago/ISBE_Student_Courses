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
  
  # set column types
  mutate(student_id = as.character(student_id), 
         student_number = as.character(student_number), 
         state_studentnumber = as.character(state_studentnumber), 
         schoolid = as.character(schoolid), 
         dob = ymd(dob), 
         entrydate = ymd(entrydate), 
         exitdate = ymd(exitdate)
        )

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
    sectionid
  ) %>%
  collect() %>%
  
  # set column types
  mutate(cc_id = as.character(cc_id), 
         schoolid = as.character(schoolid), 
         course_number = as.character(course_number), 
         dateenrolled = ymd(dateenrolled), 
         dateleft = ymd(dateleft), 
         student_id = as.character(student_id), 
         teacherid = as.character(teacherid), 
         termid = as.character(termid))

# Course Names
courses <-
  get_powerschool("courses") %>%
  select(
    course_number,
    course_name
  ) %>%
  collect() %>%

  # set column types
  mutate(course_number = as.character(course_number), 
         course_name = as.character(course_name))

# school staff IDs to match with user information
schoolstaff <-
  get_powerschool("schoolstaff") %>%
  select(
    teacherid = id,
    users_dcid,
    schoolid,
    status
  ) %>%
  collect() %>%
  
  # set column type
  mutate(teacherid = as.character(teacherid), 
         users_dcid = as.character(users_dcid), 
         schoolid = as.character(schoolid), 
         status = as.character(status))

# users info: full name, internal KIPP Chicago ID
users <-
  get_powerschool("users") %>%
  select(
    users_dcid = dcid,
    teacher_first_name = first_name,
    teacher_last_name = last_name,
    teachernumber,
    email_addr, 
    homeschoolid,
  ) %>%
  collect() %>%
  
  # set column type
  mutate(users_dcid = as.character(users_dcid), 
         teachernumber = as.character(teachernumber))

schoolstaff <-
  get_powerschool("schoolstaff") %>%
  select(
    users_dcid,
    teacherid = id,
  ) %>%
  collect() %>%
  
  # set column type
  mutate(users_dcid = as.character(users_dcid))
