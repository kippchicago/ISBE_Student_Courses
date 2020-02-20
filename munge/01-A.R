# Pull and munge data for both primary and middle school

# Parameters --------------------------------------------------------------

FIRST_DAY_OF_SCHOOL <- ymd("2019-08-19")
TEACHER_COURSE_END_DATE = ymd("2020-06-19")

# Student Personal Information ----------------------------------------------------------

# Note: this section produces the following columns required for ISBE Reporting
# Student Last Name
# Student First Name
# Birth Date
# CPS Student ID
# ISBE Student ID
# Serving School

students_current_demographics <- 
  students %>% 
  filter(entrydate >= FIRST_DAY_OF_SCHOOL) %>% 
  
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
    student_id,
  ) %>%
  mutate(student_birth_date = format(as.Date(student_birth_date),'%m/%d/%Y')
         ) %>%
  left_join(
    cps_school_rcdts_ids, 
    by = "schoolid"
  ) %>%
  rename("home_rcdts" = "rcdts_code")

# Student Course Information ----------------------------------------------------------------

# Note: this section produces the following columns required for ISBE Reporting
# Section Number
# Local Course ID
# Local Course Title

students_local_course_id_title_section_number <- 
  cc %>%
  filter(dateenrolled >= FIRST_DAY_OF_SCHOOL) %>%
  select(
    student_id, 
    schoolid, 
    course_number, 
    section_number, 
    teacherid, 
    dateenrolled,
    dateleft,
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
                    "email_addr" = "work_email"
                    )
            ) %>%
  select(
    teacherid,
    teacher_first_name,
    teacher_last_name,
    date_of_birth,
    schoolid,
    email_addr,
    initial_employment_start_date,
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
  select(-c(first_name, last_name, email)) %>%
  left_join(teacher_cc_users_zenefits_compiled,
            by = "teacherid"
            ) %>%
  mutate(teacher_serving = rcdts_code, 
         employer_rcdts = rcdts_code) %>%
  rename("teacher_birth_date" = "date_of_birth") %>%
  mutate_if(is.character, str_trim)


# Teacher Enrollment Information ------------------------------------------------------

# Teacher Course Start Date
# Teacher Course End Date

teacher_enrollment <- 
  teacher_personal_info %>%
  left_join(kipp_staff_member_start_after_20190819, 
            by = c("teacher_last_name" = "last_name", 
                   "teacher_first_name" = "first_name")
            ) %>%
  mutate(current_employment_start_date = as.character(current_employment_start_date)) %>%
  mutate(teacher_course_start_date = if_else(is.na(current_employment_start_date), 
                                             "2019-08-19", 
                                             current_employment_start_date), 
         teacher_course_end_date = TEACHER_COURSE_END_DATE) %>%
  
  # change date format
  mutate(teacher_course_start_date = format(as.Date(teacher_course_start_date),'%m/%d/%Y')
         ) %>%
  mutate(teacher_course_end_date = format(as.Date(teacher_course_end_date),'%m/%d/%Y')
         ) %>%

  select(teacherid, 
         teacher_course_start_date, 
         teacher_course_end_date,) %>%
  distinct()

# Student Enrollment Information ------------------------------------------

# Note: this section produces the following columns required for ISBE Reporting
# Student Course End Date
# Student Course Start Date

student_enrollment_info <- 
  cc %>%
  filter(dateenrolled >= FIRST_DAY_OF_SCHOOL) %>%
  select(
    student_id, 
    student_course_start_date = dateenrolled, 
    student_course_end_date = dateleft, 
    schoolid
  ) %>% 
  distinct() %>%
  mutate(student_course_start_date = format(as.Date(student_course_start_date),'%m/%d/%Y')
         ) %>%
  mutate(student_course_end_date = format(as.Date(student_course_end_date),'%m/%d/%Y') 
         ) %>%
  
  # Keeps latest student enrollment date
  # source: https://stackoverflow.com/questions/21704207/r-subset-unique-observation-keeping-last-entry
  group_by(student_id) %>%
  filter(row_number(desc(student_course_start_date)) == 1)