library('ProjectTemplate')
load.project()

# Student Personal Information ----------------------------------------------------------

# Student Course Start Date
# Student Last Name
# Student First Name
# Birth Date
# CPS Student ID
# ISBE Student ID
# Serving School

first_day_of_school <- ymd("2019-08-19")

students_current <- 
  students %>% 
  filter(entrydate >= first_day_of_school) %>% 
  
  # 0 = currently enrolled | 2 = transferred
  filter(enroll_status==0 | enroll_status==2) %>%
  
  # NOTE: if student_number is NA it means that the student already exists under a different student ID
  mutate(student_number = na_if(student_number, ""),
         state_studentnumber = na_if(state_studentnumber, "")) %>%
  drop_na(student_number) %>%
  select(
    student_course_start_date = entrydate,
    student_last_name = last_name,
    student_first_name = first_name,
    student_birth_date = dob,
    isbe_student_id = state_studentnumber,
    schoolid,
    cps_student_id = student_number, 
    enroll_status,
  )

# Student Course Information  ----------------------------------------------------------------

# Section Number
# Local Course ID
# Local Course Title

local_course_id_title_section_number <- 
  cc %>%
  filter(dateenrolled >= first_day_of_school) %>%
  select(
    student_id, 
    schoolid, 
    course_number, 
    section_number, 
    teacherid, 
  ) %>%
  
  # Join to add Local Course title
  left_join(courses, 
            by = "course_number") %>%
  rename(local_course_id = course_number, 
         local_course_title = course_name)

# Teacher Information  -------------------------------------------------------------

# Teacher Last Name
# Teacher First Name
# Teacher Birth Date
# Teacher Commitment (1.00 means 100% full time commitment to the course)
# Reason for Exit
# Teacher Course Start Date
# Teacher Course End Date
# Teacher IEIN  (Illinois Educator Identification Number)



  
