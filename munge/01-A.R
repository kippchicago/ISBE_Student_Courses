# Pull and munge data for both primary and middle school

# Student Personal Information ----------------------------------------------------------

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
  )

# Student Course Information ----------------------------------------------------------------

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
# Teacher IEIN  (Illinois Educator Identification Number)

# Create list of all files in "staff_directory" folder
files_staff_directory <- dir(path = here::here("data", 
                                               "flatfiles", 
                                               "staff_directory"), 
                             pattern = "*.csv")

staff_directory_path <- here::here("data", "flatfiles", "staff_directory")

all_current_kipp_staff <- 
  files_staff_directory %>% 
  map(~ read_csv(file.path(staff_directory_path, .))) %>%
  reduce(rbind) 


teacher_info <- 
  cc %>%

  # finds current courses for this school year
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
                    "teacher_last_name" = "last_name")) %>%
  
  # Find currently "active" users in Zenefits (people still working for KIPP)
  filter(status_active_terminated == "Active" & 
           work_location != "Shared Services Center") %>%
  select(
    teacherid, 
    teacher_first_name, 
    teacher_last_name, 
    date_of_birth, 
    schoolid, 
    work_location, 
    work_email, 
    licensure_iein_number,
  ) %>%
  
  # Add RCDTS Code for Teacher Location 
  left_join(
    cps_school_rcdts_ids, 
    by = "schoolid"
    )


# Student Enrollment Information ------------------------------------------
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
  

