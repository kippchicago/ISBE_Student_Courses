# This script produces the full ISBE Midyear Report for all Middle Schools

library(ProjectTemplate)
load.project()

source(here::here("munge", "01-A.R"))

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
         ) %>%
  
  # Select all required columns in the correct order.
  select(
    cps_school_id, 
    isbe_student_id, 
    cps_student_id, 
    student_last_name, 
    student_first_name, 
    student_birth_date, 
    home_rcdts, 
    serving_school, 
    school_year, 
    term, 
    isbe_state_course_code, 
    local_course_id, 
    local_course_title, 
    student_course_start_date, 
    section_number, 
    course_level, 
    course_credit, 
    articulated_credit, 
    dual_credit, 
    course_setting, 
    student_course_end_date, 
    student_course_final_letter_grade, 
    competency_based_education,
    teacher_iein, 
    teacher_last_name, 
    teacher_first_name, 
    teacher_birth_date, 
    teacher_serving, 
    employer_rcdts, 
    teacher_course_start_date, 
    teacher_course_end_date, 
    reason_for_exit, 
  )

