# Pull and munge data for both primary and middle school

# Student Personal Information ----------------------------------------------------------

# Note: this section produces the following columns required for ISBE Reporting
# Student Last Name
# Student First Name
# Birth Date
# CPS Student ID
# ISBE Student ID
# Serving School

first_day_of_school <- ymd("2019-08-19")

students_current_demographics <- 
  students %>% 
  filter(entrydate >= first_day_of_school) %>% 
  
  # 0 = currently enrolled | 2 = transferred
  filter(enroll_status==0 | enroll_status==2) %>%
  
  # NOTE: if student_number is NA it means that the student 
  # already exists under a different student ID
  mutate(student_number = na_if(student_number, ""),
         state_studentnumber = na_if(state_studentnumber, "")) %>%
  drop_na(student_number) %>%
  select(
    student_last_name = last_name,
    student_first_name = first_name,
    student_birth_date = dob,
    isbe_student_id = state_studentnumber,
    schoolid,
    cps_student_id = student_number, 
    enroll_status,
  ) %>%
  left_join(
    cps_school_rcdts_ids, 
    by = "schoolid"
  )

# Student Course Information ----------------------------------------------------------------

# Note: this section produces the following columns required for ISBE Reporting
# Section Number
# Local Course ID
# Local Course Title

students_local_course_id_title_section_number <- 
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
         local_course_title = course_name) %>%
  
  # remove Attendance (homeroom) and ELL (used for sorting but not an actual course) sections
  filter(!grepl("Attendance| ELL", local_course_title))


# Teacher Personal Information  -------------------------------------------------------------

# Note: this section produces the following columns required for ISBE Reporting
# Teacher IEIN (Illinois Educator Identification Number)
# Teacher Last Name
# Teacher First Name
# Teacher Birth Date
# Teacher Serving
# Employer RCDTS
# EIS Position Code
# Teacher Commitment
# Reason for Exit

teacher_cc_users_zenefits_compiled <- 
  cc %>%
  left_join(schoolstaff, 
            by = c("teacherid" = "id")) %>%
  
  # Join users to obtain teacher names and email addresses
  left_join(users,
            by = "users_dcid"
            ) %>%
  select (
    teacherid, 
    teacher_first_name, 
    teacher_last_name, 
    email_addr,
    schoolid, 
  ) %>%
  
  # Filter down to single row per teacher
  distinct() %>%
  left_join(zenefits_teacher_info, 
             by = c("teacher_first_name" = "first_name", 
                    "teacher_last_name" = "last_name", 
                    "email_addr" = "work_email")) %>%
  select(
    teacherid, 
    teacher_first_name, 
    teacher_last_name, 
    date_of_birth, 
    schoolid, 
    email_addr, 
  ) %>%
  
  # Add RCDTS Code for Teacher Location 
  left_join(
    cps_school_rcdts_ids, 
    by = "schoolid"
    ) %>%
  mutate(teacherid = as.character(teacherid)) %>%
  
  # NOTE: This line trims all white space from character columns. This 
  # is imperitive later when we want to join datasets on teacherid column
  mutate_if(is.character, str_trim)

teacher_iein <-
  teacher_iein_licensure_report %>%
  separate(col = name,
           into = c("last_name", "first_name"),
           sep = ",") %>%
  drop_na(last_name) %>%
  select(-work_team) %>%
  rename("teacher_iein" = "iein") %>%
  mutate(email = trimws(email, which = c("both"))) %>%
  mutate(teacherid = as.character(teacherid)) %>% 
  
  # NOTE: This line trims all white space from character columns. This 
  # is imperitive later when we want to join datasets on teacherid column
  mutate_if(is.character, str_trim)

teacher_personal_info <-
  teacher_iein %>%
  # select(-c(first_name, last_name, email)) %>%
  left_join(teacher_cc_users_zenefits_compiled,
            by = "teacherid"
            )

# Student Enrollment Information ------------------------------------------

# Note: this section produces the following columns required for ISBE Reporting
# Student Course End Date
# Student Course Start Date

student_enrollment_info <- 
  cc %>%
  filter(dateenrolled >= first_day_of_school) %>%
  select(
    student_id, 
    dateenrolled, 
    dateleft, 
    schoolid
  ) %>%
  distinct()



  