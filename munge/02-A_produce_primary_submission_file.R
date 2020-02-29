# This script produces the full ISBE Midyear Report for all Primary Schools
# NOTE: all primary students will appear in both students_course_primary_coure
# and students_course_primary_excellence

# Parameters --------------------------------------------------------------
# Note: The below numbers are the same for everyone

SCHOOL_YEAR <- "2020"
TERM <- "Y1"

# 02 = general
COURSE_LEVEL <- "02"

COURSE_CREDIT <- "1"
ARTICULATED_CREDIT <- "02"
DUAL_CREDIT <- "02"
COURSE_SETTING <- "01"
COMPETENCY_BASED_EDUCATION <- "02"

# More info: https://www.isbe.net/Documents/position-codes.pdf
EIS_POSITION_CODE <- "200"

# 1.00 means 100% full time commitment to the course
TEACHER_COMMITMENT <- "1.00"

# 01 = Course Ended
REASON_FOR_EXIT <- "01"

# Student Courses ISBE State Codes --------------------------------------------------

# Subjects
# state course IDs
# local course IDs (made up because not enrolled in Powerschool)

# NOTE: Multiple core courses per student
students_course_primary_core <-
  student_course_info %>%

  # Note: Filter out homework because not an actual course. Filter out science because
  # that is a special class specific to only one school
  filter(
    grade_level %in% c(0, 1, 2, 3),
    !grepl("Science", local_course_title),
    !grepl("Homework", local_course_title)
  ) %>%
  mutate(grade_level = as.character(grade_level)) %>%
  mutate(grade_level = str_replace(grade_level, "0", "k")) %>%
  mutate(school = str_extract(local_course_id, "kop|kbp|kap|kacp")) %>%
  select(
    cps_student_id_aspen,
    teacherid,
    school,
    grade_level,
    section_number
  ) %>%
  mutate(grade_level = as.character(grade_level)) %>%
  left_join(local_number_isbe_state_course_ids,
    by = c(
      "grade_level",
      "school"
    )
  ) %>%
  filter(is.na(first_last_teacher)) %>%
  select(-first_last_teacher) %>%
  mutate(teacherid = as.character(teacherid)) %>%
  distinct()


# NOTE: Multiple excellence courses per student
students_course_primary_excellence <-
  student_course_info %>%

  # Note: Filter out homework because not an actual course. Filter out science because
  # that is a special class specific to only one school
  filter(
    grepl("kop|kacp|kap|kbp|1|2|3", local_course_title),
    !grepl("Science", local_course_title)
  ) %>%
  mutate(
    school = str_extract(local_course_id, "kop|kbp|kap|kacp"),
    grade_level = str_replace(local_course_id, "kop|kbp|kap|kacp", "") %>%
      str_extract("^.")
  ) %>%
  filter(
    grade_level %in% c(0, 1, 2, 3),
    !grepl("Science", local_course_title),
    !grepl("Homework", local_course_title)
  ) %>%
  mutate(grade_level = as.character(grade_level)) %>%
  mutate(grade_level = str_replace(grade_level, "0", "k")) %>%
  mutate(school = str_extract(local_course_id, "kop|kbp|kap|kacp")) %>%
  select(
    cps_student_id_aspen,
    teacherid,
    school,
    grade_level,
    section_number
  ) %>%
  left_join(local_number_isbe_state_course_ids,
    by = c("grade_level", "school")
  ) %>%
  filter(!is.na(first_last_teacher)) %>%

  # NOTE: teacherid cannot be used to join for excellence courses
  # for these courses the teacherid is incorrect. Teachers
  # will need to be joined by first and last name
  select(-teacherid) %>%
  separate(
    col = first_last_teacher,
    into = c(
      "teacher_first_name",
      "teacher_last_name"
    ),
    sep = " "
  ) %>%
  mutate_if(is.character, str_trim)

students_course_primary_4th <-
  student_course_info %>%

  # Note: Filter out homework because not an actual course. Filter out science because
  # that is a special class specific to only one school
  filter(grade_level %in% c(4)) %>%
  left_join(local_number_isbe_state_course_ids %>%
    select(-local_course_title),
  by = "local_course_id"
  ) %>%
  select(-c(
    first_last_teacher,
    school,
    isbe_student_id_aspen,
    cps_student_id_kipp,
    schoolid_aspen
  )) %>%
  mutate(teacherid = as.character(teacherid)) %>%
  filter(
    local_course_title != "4th Behavior",
    local_course_title != "4th Homework",
    local_course_title != "4th Choice Reading",
    local_course_title != "4th Physical Education"
  ) %>%
  distinct()

# ISBE Report Primary Core -------------------------------------

isbe_report_primary_core_midyear <-
  students_course_primary_core %>%
  left_join(teacher_identifying_info_complete,
    by = "teacherid"
  ) %>%
  # select(-c(schoolid, )) %>%
  left_join(student_identifying_info,
    by = "cps_student_id_aspen"
  ) %>%
  left_join(student_enrollment_info,
    by = "cps_student_id_aspen"
  ) %>%
  left_join(teacher_enrollment_info,
    by = "teacherid"
  ) %>%
  select(-c("rcdts_code")) %>%
  left_join(cps_school_rcdts_ids,
    by = c("schoolid_aspen" = "cps_school_id")
  ) %>%
  rename(rcdts_code_aspen = rcdts_code) %>%
  ungroup() %>%

  # Add additional required columns that are the same for everyone
  mutate(
    serving_school = rcdts_code_aspen,
    school_year = SCHOOL_YEAR,
    term = TERM,
    course_level = COURSE_LEVEL,
    course_credit = COURSE_CREDIT,
    articulated_credit = ARTICULATED_CREDIT,
    dual_credit = DUAL_CREDIT,
    course_setting = COURSE_SETTING,
    student_course_final_letter_grade = "",
    competency_based_education = COMPETENCY_BASED_EDUCATION,
    eis_position_code = EIS_POSITION_CODE,
    teacher_commitment = TEACHER_COMMITMENT,
    reason_for_exit = REASON_FOR_EXIT,
    "Errors Detected?" = "",
    "Number of Errors in Record" = "",
    "Error Details" = "",
    "Other Notes" = "",
    "Actual Attendance Days" = "",
    "Total Attendance Days" = "",
    "Single Parent including Single Pregnant Woman" = "",
    "Displaced Homemaker" = "",
    "Course Numeric Grade (Term)" = "",
    "Maximum Numeric Grade (Term)" = "",
    "Course Final Letter Grade ISBE Code" = "",
    "Language Course was Taught In" = "",
    "Outside Course School Year(Outside Course Assignment Only)" = "",
    "Outside Course Grade Level(Outside Course Assignment Only)" = "",
    "Outside Course Facility Type(Outside Course Assignment Only)" = "",
    "Outside Course Facility Name(Outside Course Assignment Only)" = "",
    "IPEDS(College Course Assignment Only)" = "",
    "Local Teacher ID" = "",
    "Actual Attendance (Classes)" = "",
    "Total Attendance (Classes)" = "",
  ) %>%

  # Select all required columns in the correct order.
  select(
    "CPS School ID" = schoolid_aspen,
    "ISBE Student ID" = isbe_student_id_aspen,
    "CPS Student ID" = cps_student_id_aspen,
    "Student Last Name" = student_last_name_aspen,
    "Student First Name" = student_first_name_aspen,
    "Birth Date" = student_birth_date_aspen,
    "Home RCDTS" = rcdts_code_aspen,
    "Serving School" = serving_school,
    "School Year" = school_year,
    "Term (Semester)" = term,
    "State Course Code" = isbe_state_course_code,
    "Local Course ID" = local_course_id,
    "Local Course Title" = local_course_title,
    "Student Course Start Date" = student_course_start_date,
    "Section Number" = section_number,
    "Course Level" = course_level,
    "Course Credit" = course_credit,
    "Articulated Credit" = articulated_credit,
    "Dual Credit" = dual_credit,
    "Course Setting" = course_setting,
    "Actual Attendance Days",
    "Total Attendance Days",
    "Single Parent including Single Pregnant Woman",
    "Displaced Homemaker",
    "Course Numeric Grade (Term)",
    "Maximum Numeric Grade (Term)",
    "Student Course End Date" = student_course_end_date,
    "Course Final Letter Grade ISBE Code" = student_course_final_letter_grade,
    "Language Course was Taught In",
    "Competency Based Education" = competency_based_education,
    "Outside Course School Year(Outside Course Assignment Only)",
    "Outside Course Grade Level(Outside Course Assignment Only)",
    "Outside Course Facility Type(Outside Course Assignment Only)",
    "Outside Course Facility Name(Outside Course Assignment Only)",
    "IPEDS(College Course Assignment Only)",
    "Teacher IEIN  (Illinois Educator Identification Number)" = teacher_iein,
    "Local Teacher ID",
    "Teacher Last Name" = teacher_last_name,
    "Teacher First Name" = teacher_first_name,
    "Teacher Birth Date" = teacher_birth_date,
    "Teacher Serving Location RCDTS Code" = rcdts_code_aspen,
    "Employer RCDTS" = rcdts_code_aspen,
    "Teacher Course Start Date" = teacher_course_start_date,
    "Role of Professional" = eis_position_code,
    "Teacher Commitment (1.00 means 100% full time commitment to the course)" = teacher_commitment,
    "Actual Attendance (Classes)",
    "Total Attendance (Classes)",
    "Teacher Course End Date" = teacher_course_end_date,
    "Reason for Exit" = reason_for_exit,
    "Errors Detected?",
    "Number of Errors in Record",
    "Error Details",
    "Other Notes",
  ) %>%
  distinct()


# ISBE Report Primary Excellence -------------------------------------

isbe_report_primary_excellence_midyear <-
  students_course_primary_excellence %>%
  left_join(teacher_identifying_info_complete,
    by = c(
      "teacher_last_name",
      "teacher_first_name"
    )
  ) %>%
  left_join(student_identifying_info,
    by = "cps_student_id_aspen"
  ) %>%
  left_join(student_enrollment_info,
    by = "cps_student_id_aspen"
  ) %>%
  left_join(teacher_enrollment_info,
    by = "teacherid"
  ) %>%
  select(-c("rcdts_code")) %>%
  left_join(cps_school_rcdts_ids,
    by = c("schoolid_aspen" = "cps_school_id")
  ) %>%
  rename(rcdts_code_aspen = rcdts_code) %>%
  ungroup() %>%

  # Add additional required columns that are the same for everyone
  mutate(
    serving_school = rcdts_code_aspen,
    school_year = SCHOOL_YEAR,
    term = TERM,
    course_level = COURSE_LEVEL,
    course_credit = COURSE_CREDIT,
    articulated_credit = ARTICULATED_CREDIT,
    dual_credit = DUAL_CREDIT,
    course_setting = COURSE_SETTING,
    student_course_final_letter_grade = "",
    competency_based_education = COMPETENCY_BASED_EDUCATION,
    eis_position_code = EIS_POSITION_CODE,
    teacher_commitment = TEACHER_COMMITMENT,
    reason_for_exit = REASON_FOR_EXIT,
    "Errors Detected?" = "",
    "Number of Errors in Record" = "",
    "Error Details" = "",
    "Other Notes" = "",
    "Actual Attendance Days" = "",
    "Total Attendance Days" = "",
    "Single Parent including Single Pregnant Woman" = "",
    "Displaced Homemaker" = "",
    "Course Numeric Grade (Term)" = "",
    "Maximum Numeric Grade (Term)" = "",
    "Course Final Letter Grade ISBE Code" = "",
    "Language Course was Taught In" = "",
    "Outside Course School Year(Outside Course Assignment Only)" = "",
    "Outside Course Grade Level(Outside Course Assignment Only)" = "",
    "Outside Course Facility Type(Outside Course Assignment Only)" = "",
    "Outside Course Facility Name(Outside Course Assignment Only)" = "",
    "IPEDS(College Course Assignment Only)" = "",
    "Local Teacher ID" = "",
    "Actual Attendance (Classes)" = "",
    "Total Attendance (Classes)" = "",
  ) %>%

  # Select all required columns in the correct order.
  select(
    "CPS School ID" = schoolid_aspen,
    "ISBE Student ID" = isbe_student_id_aspen,
    "CPS Student ID" = cps_student_id_aspen,
    "Student Last Name" = student_last_name_aspen,
    "Student First Name" = student_first_name_aspen,
    "Birth Date" = student_birth_date_aspen,
    "Home RCDTS" = rcdts_code_aspen,
    "Serving School" = serving_school,
    "School Year" = school_year,
    "Term (Semester)" = term,
    "State Course Code" = isbe_state_course_code,
    "Local Course ID" = local_course_id,
    "Local Course Title" = local_course_title,
    "Student Course Start Date" = student_course_start_date,
    "Section Number" = section_number,
    "Course Level" = course_level,
    "Course Credit" = course_credit,
    "Articulated Credit" = articulated_credit,
    "Dual Credit" = dual_credit,
    "Course Setting" = course_setting,
    "Actual Attendance Days",
    "Total Attendance Days",
    "Single Parent including Single Pregnant Woman",
    "Displaced Homemaker",
    "Course Numeric Grade (Term)",
    "Maximum Numeric Grade (Term)",
    "Student Course End Date" = student_course_end_date,
    "Course Final Letter Grade ISBE Code" = student_course_final_letter_grade,
    "Language Course was Taught In",
    "Competency Based Education" = competency_based_education,
    "Outside Course School Year(Outside Course Assignment Only)",
    "Outside Course Grade Level(Outside Course Assignment Only)",
    "Outside Course Facility Type(Outside Course Assignment Only)",
    "Outside Course Facility Name(Outside Course Assignment Only)",
    "IPEDS(College Course Assignment Only)",
    "Teacher IEIN  (Illinois Educator Identification Number)" = teacher_iein,
    "Local Teacher ID",
    "Teacher Last Name" = teacher_last_name,
    "Teacher First Name" = teacher_first_name,
    "Teacher Birth Date" = teacher_birth_date,
    "Teacher Serving Location RCDTS Code" = rcdts_code_aspen,
    "Employer RCDTS" = rcdts_code_aspen,
    "Teacher Course Start Date" = teacher_course_start_date,
    "Role of Professional" = eis_position_code,
    "Teacher Commitment (1.00 means 100% full time commitment to the course)" = teacher_commitment,
    "Actual Attendance (Classes)",
    "Total Attendance (Classes)",
    "Teacher Course End Date" = teacher_course_end_date,
    "Reason for Exit" = reason_for_exit,
    "Errors Detected?",
    "Number of Errors in Record",
    "Error Details",
    "Other Notes",
  ) %>%
  distinct()

# ISBE Report Primary 4th Graders -------------------------------------------------------------

isbe_report_primary_4th_grade_midyear <-
  students_course_primary_4th %>%
  left_join(teacher_identifying_info_complete,
    by = "teacherid"
  ) %>%
  # select(-c(schoolid, )) %>%
  left_join(student_identifying_info,
    by = "cps_student_id_aspen"
  ) %>%
  left_join(student_enrollment_info,
    by = "cps_student_id_aspen"
  ) %>%
  left_join(teacher_enrollment_info,
    by = "teacherid"
  ) %>%
  select(-c("rcdts_code")) %>%
  left_join(cps_school_rcdts_ids,
    by = c("schoolid_aspen" = "cps_school_id")
  ) %>%
  rename(rcdts_code_aspen = rcdts_code) %>%
  ungroup() %>%

  # Add additional required columns that are the same for everyone
  mutate(
    serving_school = rcdts_code_aspen,
    school_year = SCHOOL_YEAR,
    term = TERM,
    course_level = COURSE_LEVEL,
    course_credit = COURSE_CREDIT,
    articulated_credit = ARTICULATED_CREDIT,
    dual_credit = DUAL_CREDIT,
    course_setting = COURSE_SETTING,
    student_course_final_letter_grade = "",
    competency_based_education = COMPETENCY_BASED_EDUCATION,
    eis_position_code = EIS_POSITION_CODE,
    teacher_commitment = TEACHER_COMMITMENT,
    reason_for_exit = REASON_FOR_EXIT,
    "Errors Detected?" = "",
    "Number of Errors in Record" = "",
    "Error Details" = "",
    "Other Notes" = "",
    "Actual Attendance Days" = "",
    "Total Attendance Days" = "",
    "Single Parent including Single Pregnant Woman" = "",
    "Displaced Homemaker" = "",
    "Course Numeric Grade (Term)" = "",
    "Maximum Numeric Grade (Term)" = "",
    "Course Final Letter Grade ISBE Code" = "",
    "Language Course was Taught In" = "",
    "Outside Course School Year(Outside Course Assignment Only)" = "",
    "Outside Course Grade Level(Outside Course Assignment Only)" = "",
    "Outside Course Facility Type(Outside Course Assignment Only)" = "",
    "Outside Course Facility Name(Outside Course Assignment Only)" = "",
    "IPEDS(College Course Assignment Only)" = "",
    "Local Teacher ID" = "",
    "Actual Attendance (Classes)" = "",
    "Total Attendance (Classes)" = "",
  ) %>%

  # Select all required columns in the correct order.
  select(
    "CPS School ID" = schoolid_aspen,
    "ISBE Student ID" = isbe_student_id_aspen,
    "CPS Student ID" = cps_student_id_aspen,
    "Student Last Name" = student_last_name_aspen,
    "Student First Name" = student_first_name_aspen,
    "Birth Date" = student_birth_date_aspen,
    "Home RCDTS" = rcdts_code_aspen,
    "Serving School" = serving_school,
    "School Year" = school_year,
    "Term (Semester)" = term,
    "State Course Code" = isbe_state_course_code,
    "Local Course ID" = local_course_id,
    "Local Course Title" = local_course_title,
    "Student Course Start Date" = student_course_start_date,
    "Section Number" = section_number,
    "Course Level" = course_level,
    "Course Credit" = course_credit,
    "Articulated Credit" = articulated_credit,
    "Dual Credit" = dual_credit,
    "Course Setting" = course_setting,
    "Actual Attendance Days",
    "Total Attendance Days",
    "Single Parent including Single Pregnant Woman",
    "Displaced Homemaker",
    "Course Numeric Grade (Term)",
    "Maximum Numeric Grade (Term)",
    "Student Course End Date" = student_course_end_date,
    "Course Final Letter Grade ISBE Code" = student_course_final_letter_grade,
    "Language Course was Taught In",
    "Competency Based Education" = competency_based_education,
    "Outside Course School Year(Outside Course Assignment Only)",
    "Outside Course Grade Level(Outside Course Assignment Only)",
    "Outside Course Facility Type(Outside Course Assignment Only)",
    "Outside Course Facility Name(Outside Course Assignment Only)",
    "IPEDS(College Course Assignment Only)",
    "Teacher IEIN  (Illinois Educator Identification Number)" = teacher_iein,
    "Local Teacher ID",
    "Teacher Last Name" = teacher_last_name,
    "Teacher First Name" = teacher_first_name,
    "Teacher Birth Date" = teacher_birth_date,
    "Teacher Serving Location RCDTS Code" = rcdts_code_aspen,
    "Employer RCDTS" = rcdts_code_aspen,
    "Teacher Course Start Date" = teacher_course_start_date,
    "Role of Professional" = eis_position_code,
    "Teacher Commitment (1.00 means 100% full time commitment to the course)" = teacher_commitment,
    "Actual Attendance (Classes)",
    "Total Attendance (Classes)",
    "Teacher Course End Date" = teacher_course_end_date,
    "Reason for Exit" = reason_for_exit,
    "Errors Detected?",
    "Number of Errors in Record",
    "Error Details",
    "Other Notes",
  ) %>%
  distinct()



# Full ISBE Report Primary ------------------------------------------------

isbe_report_primary_midyear_2020_full <-
  bind_rows(
    isbe_report_primary_core_midyear,
    isbe_report_primary_excellence_midyear,
    isbe_report_primary_4th_grade_midyear
  )
