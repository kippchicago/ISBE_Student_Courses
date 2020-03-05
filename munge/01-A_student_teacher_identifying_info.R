# Produce student and teacher identifying information

# Parameters --------------------------------------------------------------

FIRST_DAY_OF_SCHOOL <- ymd("2019-08-19")
LAST_DAY_OF_SCHOOL <- ymd("2020-06-20")

# Student Identifying Information ----------------------------------------------------------

# Note: student_identifying_info produces the following columns required for ISBE Reporting
# Student Last Name
# Student First Name
# Birth Date
# CPS Student ID
# ISBE Student ID
# Serving School

student_identifying_info <-
  students_aspen_info_current_former %>%

  # Note: Because some CPS Student IDs are different in ASPEN and Power School
  # we maintain a full list of CPS Student IDs in Power Schools (for data joining purposes)
  # and CPS Student IDs in ASPEN (for reporting purposes)
  left_join(cps_id_corrections,
    by = c("Student ID" = "cps_student_id")
  ) %>%

  # kipp_incorrect_cpsid from cps_id_corrections df
  mutate(cps_student_id_kipp = case_when(
    is.na(kipp_incorrect_cpsid) ~ `Student ID`,
    TRUE ~ kipp_incorrect_cpsid
  )) %>%
  select(-kipp_incorrect_cpsid) %>%

  # Drop all students who do not appear in powerschool.
  filter(cps_student_id_kipp != "no ps") %>%
  
  # Final report needs to contain student name, cps id and dob from aspen. Because
  # there is conflicting info between aspen and powerschool we will use the aspen 
  # information for reporting purposes
  rename(
    student_last_name_aspen = LastName,
    student_first_name_aspen = FirstName,
    student_birth_date_aspen = DOB,
    isbe_student_id_aspen = SASID,
    schoolid_aspen = school_assigned_to,
    cps_student_id_aspen = `Student ID`,
  ) %>%
  left_join(
    cps_school_rcdts_ids %>%
      select(cps_school_id, rcdts_code) %>%
      distinct(),
    by = c("schoolid_aspen" = "cps_school_id")
  ) %>%
  
  # Note: Powerschool Student ID is required to join this dataframe with cc
  left_join(students %>% 
              select(
                ps_student_id = student_id,
                student_number,
                grade_level
                ), 
            by = c("cps_student_id_kipp" = "student_number")
            )

# Note: a full list of students who we are responsible for reporting to ASPEN (according to ASPEN)
student_full_list_aspen <-
  student_identifying_info %>%
  select(
    "cps_student_id_aspen",
    "cps_student_id_kipp",
    "ps_student_id",
    "grade_level",
    "isbe_student_id_aspen",
    "schoolid_aspen",
    "student_last_name_aspen",
    "student_first_name_aspen"
  ) %>%
  
  mutate_if(is.character, str_trim) %>%
  mutate(
    student_first_name_aspen = str_to_lower(student_first_name_aspen),
    student_last_name_aspen = str_to_lower(student_last_name_aspen)
  )

# Teacher Identifying Information  -------------------------------------------------------------

# Note: this section produces the following columns required for ISBE Reporting
# Teacher IEIN (Illinois Educator Identification Number)
# Teacher Last Name
# Teacher First Name
# Teacher Birth Date
# Teacher Serving
# Employer RCDTS

teacher_identifying_info_partial <-
  cc %>%
  left_join(schoolstaff,
    by = c("teacherid" = "id")
  ) %>%

  # Join users to obtain teacher names and email addresses
  left_join(users,
    by = "users_dcid"
  ) %>%
  select(
    teacherid,
    teacher_first_name,
    teacher_last_name,
    email_addr,
    schoolid,
  ) %>%

  # Filter down to single row per teacher
  distinct() %>%
  left_join(zenefits_teacher_info,
    by = c(
      "teacher_first_name" = "First Name",
      "teacher_last_name" = "Last Name",
      "email_addr" = "Work Email"
    )
  ) %>%
  select(
    teacherid,
    teacher_first_name,
    teacher_last_name,
    schoolid,
    email_addr,
    `Initial Employment Start Date`,
  ) %>%

  # NOTE: This line trims all white space from character columns. This
  # is imperitive later when we want to join datasets on teacherid column
  mutate_if(is.character, str_trim)


teacher_identifying_info_complete <-
  teacher_iein_licensure_report %>%
  left_join(teacher_identifying_info_partial,
    by = "teacherid"
  ) %>%
  select(-c(
    Name, preffered_name, suffix, email_addr,
    teacher_first_name, teacher_last_name,
    `Initial Employment Start Date`,`Work Team`, 
    schoolid)
    ) %>%
  rename(
    "teacher_birth_date" = "birthday",
    "teacher_last_name" = "last_name",
    "teacher_first_name" = "first_name",
  ) %>%
  mutate_if(is.character, str_trim)
