# Produces course information for students

# Parameters --------------------------------------------------------------

FIRST_DAY_OF_SCHOOL <- ymd("2019-08-19")
LAST_DAY_OF_SCHOOL <- ymd("2020-06-20")
PS_TERMID <- silounloadr::calc_ps_termid(2019)

# Student Course Information ----------------------------------------------------------------

# Note: this section produces the following columns required for ISBE Reporting
# Section Number
# Local Course ID
# Local Course Title

student_course_info <-
  
  # Note: identify students we need course information for
  student_full_list_aspen %>%
  
  # Note: cc table contains required course information
  left_join(cc,
            by = c("ps_student_id" = "student_id")
  ) %>%
  
  # Note: student_id includes student ids that conflict with CPS student ID,
  # in order to get student classes I need to use the IDs that kipp has, but
  # the report will include the cps_student_id_correct
  
  # Note: filter for courses for this school year
  filter(dateenrolled >= FIRST_DAY_OF_SCHOOL) %>%
  select(
    cps_student_id_kipp,
    cps_student_id_aspen,
    schoolid,
    course_number,
    section_number,
    teacherid,
    dateenrolled,
    dateleft,
    grade_level,
    isbe_student_id_aspen,
    schoolid_aspen
  ) %>%
  
  # Note: Courses includes Local Course title information
  left_join(courses,
            by = "course_number"
  ) %>%
  rename(
    local_course_id = course_number,
    local_course_title = course_name
  ) %>%
  
  # remove Attendance (homeroom) and ELL sections (used for sorting but not an actual course)
  filter(!grepl("Attendance| ELL", local_course_title))


# Teacher Course Info -----------------------------------------------------

teacher_course_info <- 
  users %>%
  
  # joins users and teachers
  left_join(teachers, 
            by = "users_dcid") %>%
  
  # joins users/teachers and cc
  left_join(cc,
            by = "teacherid") %>% 
  filter(termid == PS_TERMID) %>%
  left_join(courses,
            by = "course_number")
