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
  students_aspen_info_current_former %>%
  mutate(student_id = as.character(student_id)) %>%
  left_join(cps_id_corrections, 
            by = c("student_id" = "cps_student_id")) %>%
  mutate(cps_student_id_kipp = case_when(is.na(kipp_incorrect_cpsid) ~ student_id, 
                                                         TRUE ~ kipp_incorrect_cpsid)) %>%
  select(-kipp_incorrect_cpsid) %>%
  
  # Drop students who do not appear in powerschool and so never enrolled with us. 
  filter(cps_student_id_kipp != "no ps") %>%
  rename(
    student_last_name_aspen = last_name,
    student_first_name_aspen = first_name,
    student_birth_date_aspen = dob,
    isbe_student_id_aspen = sasid,
    schoolid_aspen = school_assigned_to,
    cps_student_id_aspen = student_id, 
    enrollment_date_aspen = org_enr_date
  ) %>%
  
  mutate(student_birth_date_aspen = format(as.Date(student_birth_date_aspen),'%m/%d/%Y'),
         schoolid_aspen = as.double(schoolid_aspen)
  ) %>%
  left_join(
    cps_school_rcdts_ids %>% 
      select(cps_school_id, rcdts_code) %>% 
      distinct(), 
    by = c("schoolid_aspen" = "cps_school_id")
  ) %>%
  rename("home_rcdts" = "rcdts_code") %>%
  left_join(students %>% select(ps_student_id = student_id, 
                                student_number, 
                                grade_level), 
            by = c("cps_student_id_kipp" = "student_number")) %>%
  select(-home_rcdts)

current_studentid <-
  students_current_demographics %>%
  select("cps_student_id_aspen", 
         "cps_student_id_kipp", 
         "ps_student_id", 
         "grade_level",
         "isbe_student_id_aspen", 
         "schoolid_aspen", 
         "enrollment_date_aspen"
         )


# Student Course Information ----------------------------------------------------------------

# Note: this section produces the following columns required for ISBE Reporting
# Section Number
# Local Course ID
# Local Course Title

students_local_course_id_title_section_number <- 
  current_studentid %>%
  left_join(cc, 
            by = c("ps_student_id" = "student_id")) %>%
  
  # Note: student_id includes student ids that conflict with CPS student ID, 
  # in order to get student classes I need to use the IDs that kipp has, but
  # the report will include the cps_student_id_correct
  
  # Lose 229 students by filtering for dateenrolled > first day of school
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
  mutate(date_of_birth = format(as.Date(date_of_birth), "%m/%d/%Y")) %>%
  # Add RCDTS Code for Teacher Location 
  left_join(
    cps_school_rcdts_ids,
    by = "schoolid"
    ) %>%
  mutate(teacherid = as.character(teacherid)) %>%
  
  # NOTE: This line trims all white space from character columns. This 
  # is imperitive later when we want to join datasets on teacherid column
  mutate_if(is.character, str_trim)

teacher_personal_info <-
  teacher_iein_licensure_report %>%
  left_join(teacher_cc_users_zenefits_compiled,
            by = "teacherid"
            ) %>%
  select(-c(name, preffered_name, suffix, email_addr,
            teacher_first_name, teacher_last_name, 
            date_of_birth, initial_employment_start_date, 
            abbr, cps_school_id, work_team,)) %>%
  mutate(teacher_serving = rcdts_code, 
         employer_rcdts = rcdts_code) %>%
  rename("teacher_birth_date" = "birthday", 
         "teacher_last_name" = "last_name", 
         "teacher_first_name" = "first_name",) %>%
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
  current_studentid %>%
  left_join(cc, by = c("ps_student_id" = "student_id")) %>%
  filter(dateenrolled >= FIRST_DAY_OF_SCHOOL) %>%
  select(
    ps_student_id, 
    student_course_start_date = dateenrolled, 
    student_course_end_date = dateleft, 
    schoolid, 
    cps_student_id_aspen, 
    cps_student_id_kipp,
    enrollment_date_aspen
  ) %>% 
  mutate(student_course_start_date = ymd(student_course_start_date)
         ) %>%
  mutate(student_course_end_date = ymd(student_course_end_date)
         ) %>%
  mutate(enrollment_date_aspen = mdy(enrollment_date_aspen)) %>%
  mutate(student_course_start_date = case_when(enrollment_date_aspen > student_course_start_date ~ enrollment_date_aspen,
                                               TRUE ~ student_course_start_date
                                               )
  ) %>%
  
  # Keeps latest student enrollment date
  # source: https://stackoverflow.com/questions/21704207/r-subset-unique-observation-keeping-last-entry
  group_by(cps_student_id_aspen) %>%
  filter(row_number(desc(student_course_start_date)) == 1) %>%
  ungroup()
