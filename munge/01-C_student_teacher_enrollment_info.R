# Produce Enrollment Information for both teachers and students
# NOTE: WRITE DOCUMENTATION FOR EACH DATAFRAME
# Parameters --------------------------------------------------------------

FIRST_DAY_OF_SCHOOL <- ymd("2019-08-19")
LAST_DAY_OF_SCHOOL <- ymd("2020-06-20")

# Teacher Enrollment Information ------------------------------------------------------

# Teacher Course Start Date
# Teacher Course End Date

teacher_enrollment_info <-
  teacher_identifying_info %>%
  
  # Note: Requested list from HR of teachers who started after the 1st day of school
  left_join(kipp_staff_member_start_after_20190819,
            by = c(
              "teacher_last_name" = "Last Name",
              "teacher_first_name" = "First Name")
  ) %>%
  mutate(teacher_course_start_date = if_else(is.na(`Current Employment Start Date`), 
                                             FIRST_DAY_OF_SCHOOL, 
                                             `Current Employment Start Date`
  ), 
  teacher_course_end_date = LAST_DAY_OF_SCHOOL
  ) %>%
  
  select(
    teacherid,
    teacher_course_start_date,
    teacher_course_end_date,
  ) %>%
  distinct()

# Student Enrollment Information ------------------------------------------

# Note: this section produces the following columns required for ISBE Reporting
# Student Course Start Date
# Student Course End Date

# Note: We join the student_full_list_aspen df in order to add Student CPS ID
student_enrollment_info_aspen_400044 <-
  enrollment_ascend_aspen_400044 %>%
  left_join(student_full_list_aspen,
            by = c(
              "last_name" = "student_last_name_aspen",
              "first_name" = "student_first_name_aspen"
            )
  ) %>%
  drop_na(isbe_student_id_aspen)

student_enrollment_info_aspen_400146 <-
  enrollment_academy_aspen_400146 %>%
  left_join(student_full_list_aspen,
            by = c(
              "last_name" = "student_last_name_aspen",
              "first_name" = "student_first_name_aspen"
            )
  ) %>%
  drop_na(isbe_student_id_aspen)

student_enrollment_info_aspen_400163 <-
  enrollment_bloom_aspen_400163 %>%
  left_join(student_full_list_aspen,
            by = c(
              "last_name" = "student_last_name_aspen",
              "first_name" = "student_first_name_aspen"
            )
  ) %>%
  drop_na(isbe_student_id_aspen)

student_enrollment_info_aspen_400180 <-
  enrollment_one_aspen_400180 %>%
  left_join(student_full_list_aspen,
            by = c(
              "last_name" = "student_last_name_aspen",
              "first_name" = "student_first_name_aspen"
            )
  ) %>%
  drop_na(isbe_student_id_aspen)

student_enrollment_info_aspen_full <-
  bind_rows(
    student_enrollment_info_aspen_400044,
    student_enrollment_info_aspen_400146,
    student_enrollment_info_aspen_400163,
    student_enrollment_info_aspen_400180
  ) %>%
  select(
    student_enrollment_info_aspen = date,
    cps_student_id_aspen,
    type
  )

student_enrollment_info_aspen_entered <-
  student_enrollment_info_aspen_full %>%
  filter(type == "E") %>%
  rename(student_entry_date_aspen = student_enrollment_info_aspen) %>%
  select(-type) %>%
  distinct() %>%
  group_by(cps_student_id_aspen) %>%
  arrange(student_entry_date_aspen) %>%
  filter(row_number(student_entry_date_aspen) == 1) %>%
  ungroup()

student_enrollment_info_aspen_withdrew <-
  student_enrollment_info_aspen_full %>%
  filter(type == "W") %>%
  rename(student_withdraw_date_aspen = student_enrollment_info_aspen) %>%
  select(-type) %>%
  distinct() %>%
  group_by(cps_student_id_aspen) %>%
  filter(row_number(desc(student_withdraw_date_aspen)) == 1) %>%
  ungroup()

student_enrollment_info_aspen_wide <-
  student_enrollment_info_aspen_entered %>%
  full_join(student_enrollment_info_aspen_withdrew,
            by = "cps_student_id_aspen"
  ) %>%
  rename(
    student_course_start_date = student_entry_date_aspen,
    student_course_end_date = student_withdraw_date_aspen
  )

student_enrollment_info_ps_entered <-
  student_full_list_aspen %>%
  left_join(cc, by = c("ps_student_id" = "student_id")) %>%
  filter(dateenrolled >= FIRST_DAY_OF_SCHOOL) %>%
  select(
    student_course_start_date = dateenrolled,
    cps_student_id_aspen,
  ) %>%
  distinct() %>%
  group_by(cps_student_id_aspen) %>%
  arrange(student_course_start_date) %>%
  filter(row_number(student_course_start_date) == 1) %>%
  ungroup()

student_enrollment_info_ps_withdrew <-
  student_full_list_aspen %>%
  left_join(cc, by = c("ps_student_id" = "student_id")) %>%
  filter(dateenrolled >= FIRST_DAY_OF_SCHOOL) %>%
  select(
    student_course_end_date = dateleft,
    cps_student_id_aspen,
  ) %>%
  distinct() %>%
  group_by(cps_student_id_aspen) %>%
  filter(row_number(desc(student_course_end_date)) == 1) %>%
  ungroup()

student_enrollment_info_ps_wide <-
  student_enrollment_info_ps_entered %>%
  full_join(student_enrollment_info_ps_withdrew,
            by = "cps_student_id_aspen"
  )

student_enrollment_info_ps_no_match_in_aspen <-
  student_enrollment_info_ps_wide %>%
  anti_join(student_enrollment_info_aspen_wide,
            by = "cps_student_id_aspen"
  ) %>%
  mutate(
    student_course_start_date = ymd(student_course_start_date),
    student_course_end_date = ymd(student_course_end_date)
  )

student_enrollment_info <-
  bind_rows(
    student_enrollment_info_ps_no_match_in_aspen,
    student_enrollment_info_aspen_wide
  ) %>%
  mutate(
    student_course_end_date = replace_na(student_course_end_date, LAST_DAY_OF_SCHOOL),
    student_course_start_date = replace_na(student_course_start_date, FIRST_DAY_OF_SCHOOL),
    student_course_end_date = case_when(
      student_course_end_date < student_course_start_date ~ LAST_DAY_OF_SCHOOL,
      TRUE ~ student_course_end_date
    ),
    student_course_start_date = case_when(
      student_course_start_date < FIRST_DAY_OF_SCHOOL ~ FIRST_DAY_OF_SCHOOL,
      TRUE ~ student_course_start_date
    )
  )
