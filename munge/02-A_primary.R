# This script produces the full ISBE Midyear Report for all Primary Schools
# NOTE: all primary students will appear in both students_course_primary_coure
# and students_course_primary_excellence

# Parameters --------------------------------------------------------------
# Note: The below numbers are the same for everyone

SCHOOL_YEAR = "2020"
TERM = "Y1"

# 02 = general 
COURSE_LEVEL = "02"

COURSE_CREDIT = "1"
ARTICULATED_CREDIT = "02"
DUAL_CREDIT = "02"
COURSE_SETTING = "01"
COMPETENCY_BASED_EDUCATION = "02"

# More info: https://www.isbe.net/Documents/position-codes.pdf
EIS_POSITION_CODE = "200"

# 1.00 means 100% full time commitment to the course
TEACHER_COMMITMENT = "1.00"

# 01 = Course Ended
REASON_FOR_EXIT = "01"

# Student Courses ISBE State Codes --------------------------------------------------

# Subjects
# state course IDs
# local course IDs (made up because not enrolled in Powerschool)

# NOTE: Multiple core courses per student
students_course_primary_core <- 
  students_local_course_id_title_section_number %>%
  
  # group_by(student_id) %>%
  # filter(row_number(desc(dateenrolled)) == 1) %>%
  
  filter(grepl("k|1|2|3", local_course_id),
         !grepl("Science", local_course_title),
         !grepl("Homework", local_course_title)) %>%
  mutate(school = str_extract(local_course_id, "kacp|kop|kbp|kap|kacp"),
         grade_level = str_replace(local_course_id, "kacp|kop|kbp|kap|kacp", "") %>%       
           str_extract("^.")) %>%
  select(student_id, 
         teacherid, 
         school, 
         grade_level,
         section_number,) %>%
  left_join(local_number_isbe_state_course_ids, 
            by = c("grade_level", 
                   "school")) %>% 
  filter(is.na(first_last_teacher)) %>%
  select(-first_last_teacher) %>%
  mutate(teacherid = as.character(teacherid))


# NOTE: Multiple excellence courses per student
students_course_primary_excellence <- 
  students_local_course_id_title_section_number %>%
  
  group_by(student_id) %>%
  filter(row_number(desc(dateenrolled)) == 1) %>%
  
  filter(grepl("k|1|2|3", local_course_title),
         !grepl("Science", local_course_title)) %>%
  
  mutate(school = str_extract(local_course_id, "kop|kbp|kap|kacp"),
         grade_level = str_replace(local_course_id, "kop|kbp|kap|kacp", "") %>%      
           str_extract("^.")) %>%
  
  select(student_id, 
         teacherid, 
         school, 
         grade_level, 
         section_number,) %>%
  
  left_join(local_number_isbe_state_course_ids, 
            by = c("grade_level", "school")) %>% 
  
  filter(!is.na(first_last_teacher)) %>%
  
  # NOTE: teacherid cannot be used to join for excellence courses
  # for these courses the teacherid is incorrect. Teachers
  # will need to be joined by first and last name
  select(-teacherid) %>%
  separate(col = first_last_teacher,
           into = c("teacher_first_name", "teacher_last_name"),
           sep = " ") %>%
  mutate_if(is.character, str_trim)
  
# ISBE Report Primary Core -------------------------------------

isbe_report_primary_core_midyear <- 
  students_course_primary_core %>%
  left_join(teacher_personal_info, 
            by = "teacherid") %>%
  select(-c(schoolid)) %>%
  left_join(students_current_demographics, 
            by = "student_id") %>%
  select(-c(schoolid)) %>%
  left_join(student_enrollment_info, 
            by = "student_id") %>%
  left_join(teacher_enrollment, 
            by = "teacherid") %>%
  ungroup() %>%
  
  mutate(serving_school = home_rcdts, 
         school_year = SCHOOL_YEAR, 
         term = TERM, 
         course_level = COURSE_LEVEL, 
         course_credit = COURSE_CREDIT, 
         articulated_credit = ARTICULATED_CREDIT,
         dual_credit = DUAL_CREDIT, 
         course_setting = COURSE_SETTING, 
         student_course_final_letter_grade = NA, 
         competency_based_education = COMPETENCY_BASED_EDUCATION,
         eis_position_code = EIS_POSITION_CODE,
         teacher_commitment = TEACHER_COMMITMENT, 
         reason_for_exit = REASON_FOR_EXIT, 
         'Errors Detected?' = NA, 
         'Number of Errors in Record' = NA, 
         'Error Details' = NA, 
         'Other Notes' = NA, 
         'Actual Attendance Days' = NA, 
         'Total Attendance Days' = NA, 
         'Single Parent including Single Pregnant Woman' = NA, 
         'Displaced Homemaker' = NA, 
         'Course Numeric Grade (Term)' = NA, 
         'Maximum Numeric Grade (Term)' = NA,
         'Course Final Letter Grade ISBE Code' = NA, 
         'Language Course was Taught In' = NA, 
         'Outside Course School Year(Outside Course Assignment Only)' = NA, 
         'Outside Course Grade Level(Outside Course Assignment Only)' = NA, 
         'Outside Course Facility Type(Outside Course Assignment Only)' = NA, 
         'Outside Course Facility Name(Outside Course Assignment Only)' = NA,
         'IPEDS(College Course Assignment Only)' = NA,
         'Local Teacher ID' = NA,
         'Actual Attendance (Classes)' = NA, 
         'Total Attendance (Classes)' = NA, 
         
  ) %>%
  
  # Select all required columns in the correct order.
  select(
    'CPS School ID' = cps_school_id, 
    'ISBE Student ID' = isbe_student_id, 
    'CPS Student ID' = cps_student_id, 
    'Student Last Name' = student_last_name, 
    'Student First Name' = student_first_name, 
    'Birth Date' = student_birth_date, 
    'Home RCDTS' = home_rcdts, 
    'Serving School' = serving_school, 
    'School Year' = school_year, 
    'Term (Semester)' = term, 
    'State Course Code' = isbe_state_course_code, 
    'Local Course ID' = local_course_id, 
    'Local Course Title' = local_course_title, 
    'Student Course Start Date' = student_course_start_date, 
    'Section Number' = section_number, 
    'Course Level' = course_level, 
    'Course Credit' = course_credit, 
    'Articulated Credit' = articulated_credit, 
    'Dual Credit' = dual_credit, 
    'Course Setting' = course_setting, 
    'Actual Attendance Days', 
    'Total Attendance Days', 
    'Single Parent including Single Pregnant Woman', 
    'Displaced Homemaker', 
    'Course Numeric Grade (Term)', 
    'Maximum Numeric Grade (Term)',
    'Student Course End Date'= student_course_end_date, 
    'Course Final Letter Grade ISBE Code' = student_course_final_letter_grade, 
    'Language Course was Taught In', 
    'Competency Based Education' = competency_based_education,
    'Outside Course School Year(Outside Course Assignment Only)', 
    'Outside Course Grade Level(Outside Course Assignment Only)', 
    'Outside Course Facility Type(Outside Course Assignment Only)', 
    'Outside Course Facility Name(Outside Course Assignment Only)',
    'IPEDS(College Course Assignment Only)',
    'Teacher IEIN  (Illinois Educator Identification Number)' = teacher_iein, 
    'Local Teacher ID',
    'Teacher Last Name' = teacher_last_name, 
    'Teacher First Name' = teacher_first_name, 
    'Teacher Birth Date' = teacher_birth_date, 
    'Teacher Serving Location RCDTS Code' = teacher_serving, 
    'Employer RCDTS' = employer_rcdts, 
    'Teacher Course Start Date' = teacher_course_start_date, 
    'Role of Professional' = eis_position_code,
    'Teacher Commitment (1.00 means 100% full time commitment to the course)' = teacher_commitment, 
    'Actual Attendance (Classes)', 
    'Total Attendance (Classes)',
    'Teacher Course End Date' = teacher_course_end_date, 
    'Reason for Exit' = reason_for_exit, 
    'Errors Detected?', 
    'Number of Errors in Record', 
    'Error Details', 
    'Other Notes', 
    -student_id, 
  )

# ISBE Report Primary Excellence -------------------------------------

isbe_report_primary_excellence_midyear <- 
  students_course_primary_excellence %>%
  left_join(teacher_personal_info, 
            by = c("teacher_last_name", 
                   "teacher_first_name")) %>%
  # select(-c(cps_school_id)) %>%
  left_join(students_current_demographics, 
            by = "student_id") %>%
  left_join(student_enrollment_info, 
            by = "student_id") %>%
  left_join(teacher_enrollment, 
            by = "teacherid") %>%
  ungroup() %>%
  
  mutate(serving_school = home_rcdts, 
         school_year = SCHOOL_YEAR, 
         term = TERM, 
         course_level = COURSE_LEVEL, 
         course_credit = COURSE_CREDIT, 
         articulated_credit = ARTICULATED_CREDIT,
         dual_credit = DUAL_CREDIT, 
         course_setting = COURSE_SETTING, 
         student_course_final_letter_grade = NA, 
         competency_based_education = COMPETENCY_BASED_EDUCATION,
         eis_position_code = EIS_POSITION_CODE,
         teacher_commitment = TEACHER_COMMITMENT, 
         reason_for_exit = REASON_FOR_EXIT, 
         'Errors Detected?' = NA, 
         'Number of Errors in Record' = NA, 
         'Error Details' = NA, 
         'Other Notes' = NA, 
         'Actual Attendance Days' = NA, 
         'Total Attendance Days' = NA, 
         'Single Parent including Single Pregnant Woman' = NA, 
         'Displaced Homemaker' = NA, 
         'Course Numeric Grade (Term)' = NA, 
         'Maximum Numeric Grade (Term)' = NA,
         'Course Final Letter Grade ISBE Code' = NA, 
         'Language Course was Taught In' = NA, 
         'Outside Course School Year(Outside Course Assignment Only)' = NA, 
         'Outside Course Grade Level(Outside Course Assignment Only)' = NA, 
         'Outside Course Facility Type(Outside Course Assignment Only)' = NA, 
         'Outside Course Facility Name(Outside Course Assignment Only)' = NA,
         'IPEDS(College Course Assignment Only)' = NA,
         'Local Teacher ID' = NA,
         'Actual Attendance (Classes)' = NA, 
         'Total Attendance (Classes)' = NA, 
         
  ) %>%
  
  # Select all required columns in the correct order.
  select(
    'CPS School ID' = cps_school_id, 
    'ISBE Student ID' = isbe_student_id, 
    'CPS Student ID' = cps_student_id, 
    'Student Last Name' = student_last_name, 
    'Student First Name' = student_first_name, 
    'Birth Date' = student_birth_date, 
    'Home RCDTS' = home_rcdts, 
    'Serving School' = serving_school, 
    'School Year' = school_year, 
    'Term (Semester)' = term, 
    'State Course Code' = isbe_state_course_code, 
    'Local Course ID' = local_course_id, 
    'Local Course Title' = local_course_title, 
    'Student Course Start Date' = student_course_start_date, 
    'Section Number' = section_number, 
    'Course Level' = course_level, 
    'Course Credit' = course_credit, 
    'Articulated Credit' = articulated_credit, 
    'Dual Credit' = dual_credit, 
    'Course Setting' = course_setting, 
    'Actual Attendance Days', 
    'Total Attendance Days', 
    'Single Parent including Single Pregnant Woman', 
    'Displaced Homemaker', 
    'Course Numeric Grade (Term)', 
    'Maximum Numeric Grade (Term)',
    'Student Course End Date'= student_course_end_date, 
    'Course Final Letter Grade ISBE Code' = student_course_final_letter_grade, 
    'Language Course was Taught In', 
    'Competency Based Education' = competency_based_education,
    'Outside Course School Year(Outside Course Assignment Only)', 
    'Outside Course Grade Level(Outside Course Assignment Only)', 
    'Outside Course Facility Type(Outside Course Assignment Only)', 
    'Outside Course Facility Name(Outside Course Assignment Only)',
    'IPEDS(College Course Assignment Only)',
    'Teacher IEIN  (Illinois Educator Identification Number)' = teacher_iein, 
    'Local Teacher ID',
    'Teacher Last Name' = teacher_last_name, 
    'Teacher First Name' = teacher_first_name, 
    'Teacher Birth Date' = teacher_birth_date, 
    'Teacher Serving Location RCDTS Code' = teacher_serving, 
    'Employer RCDTS' = employer_rcdts, 
    'Teacher Course Start Date' = teacher_course_start_date, 
    'Role of Professional' = eis_position_code,
    'Teacher Commitment (1.00 means 100% full time commitment to the course)' = teacher_commitment, 
    'Actual Attendance (Classes)', 
    'Total Attendance (Classes)',
    'Teacher Course End Date' = teacher_course_end_date, 
    'Reason for Exit' = reason_for_exit, 
    'Errors Detected?', 
    'Number of Errors in Record', 
    'Error Details', 
    'Other Notes', 
    -student_id,
  )

# Full ISBE Report Primary ------------------------------------------------

isbe_report_primary_midyear_2020_full <- 
  bind_rows(isbe_report_primary_core_midyear, 
            isbe_report_primary_excellence_midyear)
