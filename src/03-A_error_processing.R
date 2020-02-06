# Error Correcting - Process for Fixing Errors ----------------------------

external_codes$cps_id %>%
  unique() %>%
  purrr::map_df(~ write_table_by_school(.x, combined_submission))

googledrive::drive_download("Copy of 400044_CourseAssignment2019_01.xls")

# cps_verify_ascend <- read.xlsx("data/Copy of 400044_CourseAssignment2019_01.xls.xlsx") %>%
#   as_tibble() %>%
#   clean_names()

cps_verify_ascend <- 
  read.xlsx("data/400044_CPS_verification_2019-07-16.xlsx") %>%
  as_tibble() %>%
  clean_names()
cps_verify_bloom <- read.xlsx("data/400163_CPS_verification_2019-07-15.xlsx") %>%
  as_tibble() %>%
  clean_names()

cps_verify_academy <- read.xlsx("data/400146_CPS_verification_2019-07-15.xlsx") %>%
  as_tibble() %>%
  clean_names()

cps_verify_one <- read.xlsx("data/400180_CPS_verification_2019-07-15.xlsx") %>%
  as_tibble() %>%
  clean_names()

cps_verify_all <- cps_verify_ascend %>%
  bind_rows(
    cps_verify_academy %>%
      mutate(teacher_iein_illinois_educator_identification_number = as.character(teacher_iein_illinois_educator_identification_number)),
    cps_verify_bloom,
    cps_verify_one
  ) %>%
  filter(!cps_school_id == 400001)

cps_verify_ascend %>% glimpse()

cps_verify_ascend %>%
  select(error_details) %>%
  unique()

cps_verify_all %>%
  select(error_details) %>%
  unique() %>%
  View()

# dup_ids_ascend <- cps_verify_ascend %>%
#   filter(grepl("Duplicates", error_details)) %>%
#   select(cps_student_id) %>%
#   unique()

# combined_submission %>%
#   filter(cps_school_id == 400044) %>%
#   unique() %>%
#   filter(cps_student_id %in% dup_ids_ascend$cps_student_id) %>%
#   select(student_last_name,
#          student_first_name,
#          local_course_id,
#          teacher_last_name,
#          teacher_first_name) %>%
#   View()

# clears all duplicates:
# deduped_ascend <- combined_submission %>%
#   filter(cps_school_id == 400044) %>%
#   unique()

# roles_errors <- "EIS Position Codes/Role of Professional must be one of the following: 200, 201, 202, 203, 204, 207, 208, 250, 251, 310, 601, 602, 603, 604, 604, 606, 607, 608, 609, 610, 611, 699"
iein_error <- "Please provide a valid all numeric IEIN"
enroll_error <- "CPS Student ID must be enrolled in SY19 in order for the record to be accepted"
isbe_error <- "No ISBE Student ID found from ASPEN"

id_stud_w_errors <- cps_verify_all %>%
  filter(
    !grepl("No Errors Found", error_details),
    !error_details == iein_error
  )


birthdate_errors <- id_stud_w_errors %>%
  filter(grepl("Birth Date", error_details)) %>%
  select(
    cps_student_id,
    birth_date,
    student_first_name,
    student_last_name
  ) %>%
  unique() %>%
  left_join(students %>%
              select(
                student_number,
                schoolid
              ),
            by = c("cps_student_id" = "student_number")
  )


firstname_errors <- id_stud_w_errors %>%
  filter(
    grepl("First Name", error_details),
    !grepl("Last Name", error_details)
  ) %>%
  select(
    cps_student_id,
    cps_school_id,
    birth_date,
    student_first_name,
    student_last_name,
    error_details
  ) %>%
  unique() %>%
  mutate(
    new_first_name = str_extract(error_details, "'\\w.+'"),
    new_first_name = gsub("'", "", new_first_name),
    new_first_name = gsub(";.+", "", new_first_name)
  ) %>%
  select(-error_details) %>%
  unique()


lastname_errors <- id_stud_w_errors %>%
  filter(grepl("Last Name", error_details)) %>%
  select(
    cps_student_id,
    cps_school_id,
    birth_date,
    student_first_name,
    student_last_name,
    error_details
  ) %>%
  unique() %>%
  mutate(
    error_details_2 = str_extract(error_details, ";.+"),
    new_last_name_1 = str_extract(error_details, "'\\w.+'"),
    new_last_name_2 = str_extract(error_details_2, "'\\w.+'"),
    new_last_name = new_last_name_1,
    new_last_name = if_else(!is.na(new_last_name_2),
                            new_last_name_2,
                            new_last_name
    ),
    new_last_name = gsub("'", "", new_last_name)
  ) %>%
  select(-c(error_details:new_last_name_2)) %>%
  unique()

course_dates <- id_stud_w_errors %>%
  filter(grepl("Course (Start|End)", error_details)) %>% # View()
  select(
    cps_student_id,
    birth_date,
    student_first_name,
    student_last_name,
    student_course_start_date,
    student_course_end_date
  ) %>%
  unique() %>%
  left_join(students %>%
              select(
                student_number,
                schoolid
              ),
            by = c("cps_student_id" = "student_number")
  )

cps_enroll <- cps_verify_all %>%
  filter(
    grepl(enroll_error, error_details),
    !grepl("Nadie", student_last_name)
  ) %>%
  select(
    cps_student_id,
    student_last_name,
    student_first_name
  ) %>%
  unique() %>%
  left_join(students %>%
              select(
                student_number,
                schoolid
              ),
            by = c("cps_student_id" = "student_number")
  )

isbe_num_error <- cps_verify_all %>%
  filter(
    grepl(isbe_error, error_details),
    !grepl("Nadie", student_last_name)
  ) %>%
  select(
    cps_student_id,
    isbe_student_id,
    student_last_name,
    student_first_name
  ) %>%
  unique() %>%
  left_join(students %>%
              select(
                student_number,
                schoolid
              ),
            by = c("cps_student_id" = "student_number")
  )



write_error_xlsx(78102)
write_error_xlsx(7810)
write_error_xlsx(400146)
write_error_xlsx(400163)
write_error_xlsx(4001632)
write_error_xlsx(400180)
write_error_xlsx(4001802)

rev_submission <- combined_submission %>%
  unique() %>%
  left_join(firstname_errors %>%
              select(
                cps_student_id,
                new_first_name
              ) %>%
              unique(),
            by = "cps_student_id"
  ) %>%
  left_join(lastname_errors %>%
              select(
                cps_student_id,
                new_last_name
              ) %>%
              unique(),
            by = "cps_student_id"
  ) %>%
  mutate(
    student_first_name = if_else(!is.na(new_first_name),
                                 new_first_name,
                                 student_first_name
    ),
    student_last_name = if_else(!is.na(new_last_name),
                                new_last_name,
                                student_last_name
    )
  ) %>%
  select(
    -new_last_name,
    -new_first_name
  )


googledrive::drive_download("18-19 KAMS CPS EOY data collection ERRORS_2019-07-15", overwrite = TRUE)

kams_corrections <- read.xlsx("18-19 KAMS CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 2)

kams_edits <- kams_corrections %>%
  as_tibble() %>%
  janitor::clean_names() %>%
  mutate(
    aspen_start_date = as_date(aspen_start_date),
    aspen_start_date = aspen_start_date - years(70),
    aspen_start_date = aspen_start_date - days(1),
    aspen_start_date = if_else(grepl("2016", aspen_start_date),
                               aspen_start_date - days(1),
                               aspen_start_date
    ),
    aspen_end_date = as_date(aspen_end_date),
    aspen_end_date = aspen_end_date - years(70),
    aspen_end_date = aspen_end_date - days(1),
    aspen_start_date = if_else(aspen_start_date < ymd("2018-08-20"),
                               ymd("2018-08-20"),
                               aspen_start_date
    )
  ) %>%
  select(
    cps_student_id,
    aspen_start_date,
    aspen_end_date
  ) %>%
  mutate(
    aspen_start_date = format(as_date(aspen_start_date), "%m/%d/%Y"),
    aspen_end_date = format(as_date(aspen_end_date), "%m/%d/%Y")
  )

googledrive::drive_download("18-19 KBP CPS EOY data collection ERRORS_2019-07-15", overwrite = TRUE)
googledrive::drive_download("18-19 KBCP CPS EOY data collection ERRORS_2019-07-15", overwrite = TRUE)

kbp_edits_dob <- read.xlsx("18-19 KBP CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 1)
kbcp_edits_dob <- read.xlsx("18-19 KBCP CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 1)
kbp_edits_courses <- read.xlsx("18-19 KBP CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 2)
kbcp_edits_courses <- read.xlsx("18-19 KBCP CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 2)
kbp_edits_id <- read.xlsx("18-19 KBP CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 3)




bloom_edits_dob <- kbp_edits_dob %>%
  bind_rows(kbcp_edits_dob) %>%
  clean_names() %>%
  mutate(
    aspen_dob = as.Date(aspen_dob, origin = "1899-12-30"),
    aspen_dob = format(as_date(aspen_dob), "%m/%d/%Y")
  ) %>%
  select(cps_student_id,
         new_birth_date = aspen_dob
  )

bloom_edits_courses <- kbp_edits_courses %>%
  bind_rows(kbcp_edits_courses) %>%
  as_tibble() %>%
  clean_names() %>%
  mutate(
    aspen_start_date = as.Date(aspen_start_date, origin = "1899-12-30"),
    aspen_start_date = format(as_date(aspen_start_date), "%m/%d/%Y"),
    aspen_end_date = as.Date(aspen_end_date, origin = "1899-12-30"),
    aspen_end_date = format(as_date(aspen_end_date), "%m/%d/%Y")
  ) %>%
  select(cps_student_id,
         new_start_date = aspen_start_date,
         new_end_date = aspen_end_date
  )

bloom_edits_id <- kbp_edits_id %>%
  select(cps_student_id,
         new_student_id = ASPEN_STUDENT_NUMBER
  )

rev_submission_1 <- rev_submission %>%
  left_join(kams_edits,
            by = "cps_student_id"
  ) %>%
  mutate(
    student_course_start = if_else(!is.na(aspen_start_date),
                                   aspen_start_date,
                                   student_course_start
    ),
    student_course_end = if_else(!is.na(aspen_end_date),
                                 aspen_end_date,
                                 student_course_end
    )
  ) %>%
  select(
    -aspen_end_date,
    -aspen_start_date
  )

rev_submission_2 <- rev_submission_1 %>%
  left_join(bloom_edits_dob,
            by = "cps_student_id"
  ) %>%
  mutate(dob = if_else(!is.na(new_birth_date),
                       new_birth_date,
                       dob
  )) %>%
  select(-new_birth_date) %>%
  left_join(bloom_edits_courses,
            by = "cps_student_id"
  ) %>%
  mutate(
    student_course_start = if_else(!is.na(new_start_date),
                                   new_start_date,
                                   student_course_start
    ),
    student_course_end = if_else(!is.na(new_end_date),
                                 new_end_date,
                                 student_course_end
    )
  ) %>%
  select(
    -new_start_date,
    -new_end_date
  ) %>%
  left_join(bloom_edits_id,
            by = "cps_student_id"
  ) %>%
  mutate(cps_student_id = if_else(!is.na(new_student_id),
                                  new_student_id,
                                  cps_student_id
  )) %>%
  select(-new_student_id)


googledrive::drive_download("18-19 KAC CPS EOY data collection ERRORS_2019-07-15", overwrite = TRUE)

kac_edits_dob <- read.xlsx("18-19 KAC CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 1)
kac_edits_courses <- read.xlsx("18-19 KAC CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 2)

kac_dob <- kac_edits_dob %>%
  as_tibble() %>%
  clean_names() %>%
  mutate(
    aspen_dob = as.Date(aspen_dob, origin = "1899-12-30"),
    aspen_dob = format(as_date(aspen_dob), "%m/%d/%Y")
  ) %>%
  select(cps_student_id,
         new_dob = aspen_dob
  )

kac_courses <- kac_edits_courses %>%
  as_tibble() %>%
  clean_names() %>%
  mutate(
    aspen_start_date = as.Date(aspen_start_date, origin = "1899-12-30"),
    aspen_start_date = format(as_date(aspen_start_date), "%m/%d/%Y"),
    aspen_end_date = as.double(aspen_end_date),
    aspen_end_date = as.Date(aspen_end_date, origin = "1899-12-30"),
    aspen_end_date = format(as_date(aspen_end_date), "%m/%d/%Y")
  ) %>%
  select(cps_student_id,
         new_start_date = aspen_start_date,
         new_end_date = aspen_end_date
  )

rev_submission_3 <- rev_submission_2 %>%
  left_join(kac_dob,
            by = "cps_student_id"
  ) %>%
  mutate(dob = if_else(!is.na(new_dob),
                       new_dob,
                       dob
  )) %>%
  select(-new_dob) %>%
  left_join(kac_courses,
            by = "cps_student_id"
  ) %>%
  mutate(
    student_course_start = if_else(!is.na(new_start_date),
                                   new_start_date,
                                   student_course_start
    ),
    student_course_end = if_else(!is.na(new_end_date),
                                 new_end_date,
                                 student_course_end
    )
  ) %>%
  select(
    -new_start_date,
    -new_end_date
  )

write_table_by_school(400146, rev_submission_3)

googledrive::drive_download("18-19 KOP CPS EOY data collection ERRORS_2019-07-15", overwrite = TRUE)
googledrive::drive_download("18-19 KOA CPS EOY data collection ERRORS_2019-07-15", overwrite = TRUE)

kop_edits_dob <- read.xlsx("18-19 KOP CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 1)
koa_edits_dob <- read.xlsx("18-19 KOA CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 1)
kop_edits_courses <- read.xlsx("18-19 KOP CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 2)
koa_edits_courses <- read.xlsx("18-19 KOA CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 2)
kop_edits_isbe_id <- read.xlsx("18-19 KOP CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 4)


one_edits_dob <- kop_edits_dob %>%
  bind_rows(koa_edits_dob) %>%
  clean_names() %>%
  mutate(
    aspen_dob = as.Date(aspen_dob, origin = "1899-12-30"),
    aspen_dob = format(as_date(aspen_dob), "%m/%d/%Y")
  ) %>%
  select(cps_student_id,
         new_birth_date = aspen_dob
  )

one_edits_courses <- kop_edits_courses %>%
  bind_rows(koa_edits_courses) %>%
  as_tibble() %>%
  clean_names() %>%
  mutate(
    aspen_start_date = as.Date(aspen_start_date, origin = "1899-12-30"),
    aspen_start_date = format(as_date(aspen_start_date), "%m/%d/%Y"),
    aspen_end_date = as.Date(aspen_end_date, origin = "1899-12-30"),
    aspen_end_date = format(as_date(aspen_end_date), "%m/%d/%Y")
  ) %>%
  select(cps_student_id,
         new_start_date = aspen_start_date,
         new_end_date = aspen_end_date
  )

one_edits_isbe_id <- kop_edits_isbe_id %>%
  select(cps_student_id,
         new_isbe_id = ASPEN_STATE_STUDENT_NUMBER
  )


rev_submission_4 <- rev_submission_3 %>%
  left_join(one_edits_dob,
            by = "cps_student_id"
  ) %>%
  mutate(dob = if_else(!is.na(new_birth_date),
                       new_birth_date,
                       dob
  )) %>%
  select(-new_birth_date) %>%
  left_join(one_edits_courses,
            by = "cps_student_id"
  ) %>%
  mutate(
    student_course_start = if_else(!is.na(new_start_date),
                                   new_start_date,
                                   student_course_start
    ),
    student_course_end = if_else(!is.na(new_end_date),
                                 new_end_date,
                                 student_course_end
    )
  ) %>%
  select(
    -new_start_date,
    -new_end_date
  ) %>%
  left_join(one_edits_isbe_id,
            by = "cps_student_id"
  ) %>%
  mutate(isbe_student_id = if_else(!is.na(new_isbe_id),
                                   as.character(new_isbe_id),
                                   isbe_student_id
  )) %>%
  select(-new_isbe_id)

write_table_by_school(400180, rev_submission_4)

googledrive::drive_download("18-19 KAP CPS EOY data collection ERRORS_2019-07-15", overwrite = TRUE)


kap_edits_dob <- read.xlsx("18-19 KAP CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 1)
kap_edits_courses <- read.xlsx("18-19 KAP CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 2)
kap_edits_id <- read.xlsx("18-19 KAP CPS EOY data collection ERRORS_2019-07-15.xlsx", sheet = 3)

kap_dob <- kap_edits_dob %>%
  clean_names() %>%
  mutate(
    aspen_dob = as.Date(aspen_dob, origin = "1899-12-30"),
    aspen_dob = format(as_date(aspen_dob), "%m/%d/%Y")
  ) %>%
  filter(!is.na(aspen_dob)) %>%
  select(cps_student_id,
         new_birth_date = aspen_dob
  )

kap_courses <- kap_edits_courses %>%
  as_tibble() %>%
  clean_names() %>%
  mutate(
    aspen_start_date = as.Date(aspen_start_date, origin = "1899-12-30"),
    aspen_start_date = format(as_date(aspen_start_date), "%m/%d/%Y"),
    aspen_end_date = as.Date(aspen_end_date, origin = "1899-12-30"),
    aspen_end_date = if_else(aspen_end_date > ymd("2019-06-14"),
                             ymd("2019-06-14"),
                             aspen_end_date
    ),
    aspen_end_date = format(as_date(aspen_end_date), "%m/%d/%Y")
  ) %>%
  select(cps_student_id,
         new_start_date = aspen_start_date,
         new_end_date = aspen_end_date
  )

kap_student_id <- kap_edits_id %>%
  select(cps_student_id,
         new_student_id = ASPEN_STUDENT_NUMBER
  )

rev_submission_5 <- rev_submission_4 %>%
  left_join(kap_dob,
            by = "cps_student_id"
  ) %>%
  mutate(dob = if_else(!is.na(new_birth_date),
                       new_birth_date,
                       dob
  )) %>%
  select(-new_birth_date) %>%
  left_join(kap_courses,
            by = "cps_student_id"
  ) %>%
  mutate(
    student_course_start = if_else(!is.na(new_start_date),
                                   new_start_date,
                                   student_course_start
    ),
    student_course_end = if_else(!is.na(new_end_date),
                                 new_end_date,
                                 student_course_end
    )
  ) %>%
  select(
    -new_start_date,
    -new_end_date
  ) %>%
  left_join(kap_student_id,
            by = "cps_student_id"
  ) %>%
  mutate(cps_student_id = if_else(!is.na(new_student_id),
                                  new_student_id,
                                  cps_student_id
  )) %>%
  select(-new_student_id)


write_table_by_school(400044, rev_submission_5)

suspensions <- read.xlsx("data/KIPP Chicago - Suspensions (FINAL - for ISBE submission).xlsx") %>%
  janitor::clean_names() %>%
  as_tibble()

reformat_suspensions <- suspensions %>%
  left_join(rev_submission_4 %>%
              select(
                cps_student_id,
                dob,
                student_first_name,
                student_last_name
              ) %>%
              unique(),
            by = "cps_student_id"
  ) %>%
  mutate(
    incident_type_code = 18,
    disciplinary_action = if_else(grepl("In-School Suspension", disciplinary_action),
                                  3,
                                  4
    ),
    student_first_name = if_else(is.na(student_first_name),
                                 legal_first_name,
                                 student_first_name
    ),
    student_last_name = if_else(is.na(student_last_name),
                                legal_last_name,
                                student_last_name
    ),
    birth_date = as.Date(birth_date, origin = "1899-12-30"),
    birth_date = format(as_date(birth_date), "%m/%d/%Y"),
    incident_date = as.Date(incident_date, origin = "1899-12-30"),
    incident_date = format(as_date(incident_date), "%m/%d/%Y"),
    dob = if_else(is.na(dob),
                  birth_date,
                  dob
    )
  ) %>%
  select(
    cps_school_id = school_id,
    isbe_student_id,
    cps_student_id,
    student_last_name,
    student_first_name,
    dob,
    home_school_rcdts_code,
    serving_school_program_rcdts_code,
    school_year,
    incident_date,
    incident_case_id,
    incident_number,
    disability_type,
    incident_type_code,
    disciplinary_action,
    disciplinary_duration
  )

reformat_suspensions %>%
  filter(cps_school_id == 400044) %>%
  unique() %>%
  write.xlsx(file = "reports/400044 ISBE Disciplinary Submission_2019_07_17.xlsx")


reformat_suspensions %>%
  filter(cps_school_id == 400146) %>%
  write.xlsx(file = "reports/400146 ISBE Disciplinary Submission_2019_07_17.xlsx")


reformat_suspensions %>%
  filter(cps_school_id == 400163) %>%
  write.xlsx(file = "reports/400163 ISBE Disciplinary Submission_2019_07_17.xlsx")

reformat_suspensions %>%
  filter(cps_school_id == 400180) %>%
  write.xlsx(file = "reports/400180 ISBE Disciplinary Submission_2019_07_17.xlsx")
