# This script produces the full ISBE Midyear Report for all Middle Schools

# Parameters --------------------------------------------------------------
# Note: The below numbers are the same for everyone

school_year = "2020"
term = "Y1"

# 02 = general 
course_level = "02"

course_credit = "1"
articulated_credit = "02"
dual_credit = "02"
course_setting = "01"
competency_based_education = "02"

# More info: https://www.isbe.net/Documents/position-codes.pdf
eis_position_code = "200"

# 1.00 means 100% full time commitment to the course
teacher_commitment = "1.00"

# 01 = Course Ended
reason_for_exit = "01"

# Student Courses ISBE State Codes --------------------------------------------------

# State course IDs come from flat file and is joined with existing local course 
# IDs from Powerschool enrollment Multiple courses per student

# ISBE State Course IDs
students_course_middle <- 
  students_local_course_id_title_section_number %>%

  group_by(student_id, local_course_id) %>%
  filter(row_number(desc(dateenrolled)) == 1) %>%
  
  left_join(local_number_isbe_state_course_ids %>% 
              select(-local_course_title), 
            by = "local_course_id") %>%
  select(-c(first_last_teacher, school)) %>%
  mutate(teacherid = as.character(teacherid)) %>%
  distinct() %>%
  filter(schoolid == "7810" |
           schoolid == "400163" |
           schoolid == "400146" | 
           schoolid == "400180")

# Full ISBE Report Middle School -------------------------------------

isbe_report_middle_midyear_2020_full <- 
  students_course_middle %>%
  left_join(teacher_personal_info, 
            by = "teacherid") %>%
  select(-c(schoolid.x, schoolid.y, cps_school_id)) %>%
  left_join(students_current_demographics, 
            by = "student_id") %>%
  left_join(student_enrollment_info, 
            by = "student_id") %>%
  left_join(teacher_enrollment, 
            by = "teacherid") %>%
  ungroup() %>%
  
  # Add additional required columns that are the same for everyone
  mutate(serving_school = home_rcdts, 
         school_year = school_year, 
         term = term, 
         course_level = course_level, 
         course_credit = course_credit, 
         articulated_credit = articulated_credit,
         dual_credit = dual_credit, 
         course_setting = course_setting, 
         student_course_final_letter_grade = NA, 
         competency_based_education = competency_based_education,
         eis_position_code = eis_position_code,
         teacher_commitment = teacher_commitment, 
         reason_for_exit = reason_for_exit, 
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
  )

