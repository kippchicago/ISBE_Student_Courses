library('ProjectTemplate')
load.project()


# Students Table ----------------------------------------------------------

# Student Course Start Date
# Student Last Name
# Student First Name
# Birth Date
# "ISBE Student ID"

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
    enroll_status
  )

# cc Table ----------------------------------------------------------------
# Section Number
# Local Course ID

local_course_id_section_number <- 
  cc %>%
  filter(dateenrolled >= first_day_of_school) %>%
  select(
    student_id, 
    schoolid, 
    local_course_id = course_number, 
    section_number, 
    teacherid
  )

