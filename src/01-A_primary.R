# This script produces the full ISBE Midyear Report for all Primary Schools
# NOTE: all primary students will appear in both students_course_primary_coure
# and students_course_primary_excellence

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

# NOTE: Will need to be modified for teachers that
# arrived mid year
teacher_course_start_date = ymd("2019-08-19")
teacher_course_end_date = ymd("2020-06-19")

# More info: https://www.isbe.net/Documents/position-codes.pdf
eis_position_code = "200"

# 1.00 means 100% full time commitment to the course
teacher_commitment = "1.00"

# 01 = Course Ended
reason_for_exit = "01"


# Student Courses ISBE State Codes --------------------------------------------------

# Subjects
# state course IDs
# local course IDs (made up because not enrolled in Powerschool)

# NOTE: Multiple core courses per student
students_course_primary_core <- 
  students_local_course_id_title_section_number %>%
  
  filter(grepl("k|1|2|3", local_course_title),
         !grepl("Science", local_course_title)) %>%
  mutate(school = str_extract(local_course_id, "kop|kbp|kap|kacp"),
         grade_level = str_replace(local_course_id, "kop|kbp|kap|kacp", "") %>%       
           str_extract("^.")) %>%
  select(student_id, 
         teacherid, 
         school, 
         grade_level,
         local_course_title,
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
  
  filter(grepl("k|1|2|3", local_course_title),
         !grepl("Science", local_course_title)) %>%
  
  mutate(school = str_extract(local_course_id, "kop|kbp|kap|kacp"),
         grade_level = str_replace(local_course_id, "kop|kbp|kap|kacp", "") %>%      
           str_extract("^.")) %>%
  
  select(student_id, 
         teacherid, 
         school, 
         grade_level, 
         local_course_title,
         section_number,) %>%
  
  left_join(local_number_isbe_state_course_ids, 
            by = c("grade_level", "school")) %>% 
  
  filter(!is.na(first_last_teacher)) %>%
  
  # NOTE: teacherid cannot be used to join for excellence courses
  # for these courses the teacherid is incorrect. Teachers
  # will need to be joined by first and last name
  select(-teacherid)
  
# Full ISBE Report Primary Core -------------------------------------

isbe_report_primary_core_midyear_2020_full <- 
  students_course_primary_core %>%
  left_join(teacher_personal_info, 
            by = "teacherid") %>%
  select(-c(cps_school_id)) %>%
  left_join(students_current_demographics, 
            by = "student_id") %>%
  left_join(student_enrollment_info, 
            by = "student_id") %>%
  
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
         teacher_course_start_date = teacher_course_start_date,
         teacher_course_end_date = teacher_course_end_date,
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
    student_course_start_date = dateenrolled, 
    section_number, 
    course_level, 
    course_credit, 
    articulated_credit, 
    dual_credit, 
    course_setting, 
    student_course_end_date = dateleft, 
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

# Full ISBE Report Primary Excellence -------------------------------------


  