library('ProjectTemplate')
load.project()

# for (dataset in project.info$data)
# {
#   message(paste('Showing top 5 rows of', dataset))
#   print(head(get(dataset)))
# }

# MIDDLE S. ANALYTICS -------------------------------------------------

# Note: Contains new (2019) alg and prealg isbe codes
# for middle school
isbe_local_course_codes <- 
  isbe_report_2017 %>%
  select(
    isbe_state_course_code,
    local_course_id
  ) %>%
  unique() %>%
  mutate(
    local_course_id = if_else(grepl("kccp", local_course_id),
                              gsub("kccp", "kac", local_course_id),
                              local_course_id
    ),
    local_course_id = if_else(grepl("kaps", local_course_id),
                              gsub("kaps", "kap", local_course_id),
                              local_course_id
    ),
    subject = sub("^\\D*(\\d|k)", "", local_course_id),
    grade_level = str_extract(local_course_id, "\\d"),
    grade_level = if_else(is.na(grade_level), "K", grade_level)
  ) %>%
  add_row(isbe_state_course_code = "52051A000", 
          local_course_id = "kbcp7prealg", 
          subject = "prealg", 
          grade_level = "7") %>%
  add_row(isbe_state_course_code = "52051A000", 
          local_course_id = "koa7prealg", 
          subject = "prealg", 
          grade_level = "7") %>%
  add_row(isbe_state_course_code = "52052A000", 
          local_course_id = "kbcp8alg", 
          subject = "alg", 
          grade_level = "8") %>%
  add_row(isbe_state_course_code = "52052A000", 
          local_course_id = "koa8alg", 
          subject = "alg", 
          grade_level = "8")

unique_codes <- 
  isbe_local_course_codes %>%
  select(
    isbe_state_course_code,
    subject,
    grade_level
  ) %>%
  unique()

# additional missing codes
addl_missing_codes <- 
  courses_4_8 %>%
  filter(is.na(isbe_state_course_code))

## Manually look up missing codes
codes_for_NAs <- tibble(
  local_course_id = addl_missing_codes$local_course_id,
  subject = addl_missing_codes$subject,
  grade_level = addl_missing_codes$grade_level,
  isbe_state_course_code = c(
    "52996A000",
    "53234A000",
    "54436A000",
    "55036A000",
    "55185A000",
    "55185A000",
    "58037A000",
    "53234A000",
    "58038A000",
    "54436A000",
    "55184A000",
    "58034A000", 
    NA, 
    NA
  )
)

# new state course codes (i.e. not in Michael's previous EOY submission)
missing_st_code <- 
  course_enroll %>%
  ungroup() %>%
  select(course_number) %>%
  filter(!grepl("att", course_number)) %>%
  unique() %>%
  anti_join(
    isbe_local_course_codes,
    by = c("course_number" = "local_course_id")
  ) %>%
  filter(!grepl("ell|behav|hw|cread|swela|swmath", course_number))

# added state codes
courses_4_8 <- 
  missing_st_code %>%
  filter(
    !grepl("kop|kbp", course_number),
    !grepl("kap[1-3|k]", course_number),
    # !grepl("kap[1-3|k]sci", course_number),
    !grepl("kapsped", course_number),
    # !grepl("kbcp58", course_number)
  ) %>%
  mutate(
    subject = sub("^\\D*\\d", "", course_number),
    grade_level = str_extract(course_number, "\\d")
    # subject = if_else(grepl("hum", subject), "ss", subject),
    # subject = if_else(grepl("lit", subject), "ela", subject)
  ) %>%
  left_join(unique_codes,
            by = c(
              "subject",
              "grade_level"
            )
  ) %>%
  rename(local_course_id = course_number)

st_courses_rev <- 
  isbe_local_course_codes %>%
  bind_rows(courses_4_8 %>%
              filter(!is.na(isbe_state_course_code))) %>%
  mutate(
    isbe_state_course_code = if_else(isbe_state_course_code == "05154A000",
                                     "55184A000",
                                     isbe_state_course_code
    ),
    isbe_state_course_code = if_else(isbe_state_course_code == "08001A000",
                                     "58034A000",
                                     isbe_state_course_code
    ),
    isbe_state_course_code = if_else(grepl("litcen", local_course_id),
                                     "51068A000",
                                     isbe_state_course_code
    )
  ) 


st_courses_rev_2 <- 
  st_courses_rev %>%
  bind_rows(codes_for_NAs) %>%
  unique()


# Final Grades -------------------

rc_course_names <- 
  grade_df_list_middle %>%
  map_df(get_middle_grade_courses)

rc_pct <- 
  grade_df_list_middle %>%
  map_df(get_y1_avgs)

# final letter grades

# get_final_grades <- . %>%
#   select(site_id,
#          student_id,
#          contains("y1_avg")) %>%
#   tidyr::gather(rc_field, letter_grade, -site_id:-student_id) %>%
#   filter(grepl("q4", rc_field)) %>%
#   mutate(subject = gsub("(^.+_cr_)(.+)(_final.+)", "\\2", rc_field),
#          course_school = toupper(stringr::str_extract(rc_field, "kap|kac|kccp|kbcp|kams|koa")),
#          course_school = if_else(course_school %in% "kccp", "kac", course_school)) %>%
#   left_join(external_codes %>%
#               select(schoolid,
#                      abbr),
#             by = c("site_id" = "schoolid")) %>%
#   mutate(keep = course_school == abbr) %>%
#   filter(keep)
#
# rc_letter_grades <- grade_df_list %>%
#   map_df(get_final_grades)


## combine grades and percent

# grades <- rc_letter_grades %>%
#   select(-c(rc_field,
#             keep,
#             course_school,
#             abbr)) %>%
#   inner_join(rc_pct %>%
#               select(-c(rc_field,
#                         keep,
#                         course_school,
#                         abbr)),
#             by = c("site_id",
#                    "student_id",
#                    "subject")) %>%
#   mutate(subject = if_else(subject %in% "ss", "social_studies", subject)) %>%
#   left_join(rc_course_names %>%
#               select(-c(rc_field,
#                         course_school,
#                         abbr,
#                         keep)),
#             by = c("site_id",
#                    "student_id",
#                    "subject")) %>%
#   filter(!is.na(percent))

grades <- 
  rc_pct %>%
  select(-c(
    course_school,
    site_id
  )) %>%
  left_join(rc_course_names %>%
              select(-c(
                course_school,
                site_id
              )),
            by = c(
              "abbr",
              "student_id",
              "subject"
            )
  ) %>%
  unique() %>%
  filter(!is.na(course_name))

# missing_course_names <- grades %>%
#   filter(is.na(course_name)) %>%
#   left_join(external_codes %>%
#               select(schoolid,
#                      abbr),
#             by = c("site_id" = "schoolid")) %>%
#   mutate(course_name0 = if_else(subject %in% "pe" &
#                                  abbr %in% "KAMS",
#                                "5th Physical Education",
#                                course_name),
#          course_name1 = if_else(subject %in% "art",
#                                 "4th Art",
#                                 course_name0),
#          course_name2 = if_else(subject %in% "dance",
#                                 "4th Dance",
#                                 course_name1),
#          course_name3 = if_else(subject %in% "explorations",
#                                 "4th Explorations",
#                                 course_name2),
#          course_name4 = if_else(subject %in% "musical_theater",
#                                 "4th Musical Theater",
#                                 course_name3),
#          course_name5 = if_else(subject %in% "pe" &
#                                   abbr %in% "KAP",
#                                 "4th Physical Education",
#                                 course_name4),
#          course_name = course_name5) %>% #filter(is.na(course_name)) %>% View()
#   select(-c(course_name0:course_name5))


# middle_grades_all <- grades %>%
#   filter(!is.na(course_name)) %>%
#   bind_rows(missing_course_names %>%
#               select(-abbr)) %>%
#   mutate(percent = gsub("%", "", percent),
#          percent = as.numeric(percent))

# combine isbe grade codes with middle school grades

# final_grades <- middle_grades_all %>%
#   left_join(isbe_grade_codes,
#             by = "letter_grade")


final_grades <- 
  grades %>%
  left_join(isbe_grade_codes,
            by = c("grade" = "letter_grade")
  )

all_students_1 <- students %>%
  filter(entrydate >= ymd("2018-08-01")) %>%
  mutate(dob = format(as_date(dob), "%m/%d/%Y"))

all_students_2 <- students %>%
  filter(
    entrydate >= ymd("2018-08-01"),
    !entrydate == exitdate
  ) # maybe remove same day exitdate

# Combine Data ------------------------------------------------------------

course_df <- 
  course_enroll %>%
  rename(ps_stud_id = student_id) %>%
  left_join(courses,
            by = "course_number"
  ) %>%
  mutate(
    course_name = if_else(str_detect(course_name, "\\dth Math") &
                            !grepl("Mathematics|Centers", course_name),
                          str_replace(course_name, "Math", "Mathematics"),
                          course_name
    ),
    course_name = if_else(grepl("ELA", course_name) &
                            !grepl("KAP", course_name),
                          str_replace(course_name, "ELA", "English Language Arts"),
                          course_name
    ),
    course_name = if_else(grepl("Literacy Center", course_name) & !grepl("Centers", course_name),
                          str_replace(course_name, "Center", "Centers"),
                          course_name
    )
  )

fin_grade_course_att <- 
  final_grades %>%
  mutate(
    course_name = if_else(grepl("7th Pre-Algebra", course_name),
                          "7th Mathematics",
                          course_name
    ),
    course_name = if_else(grepl("8th Algebra", course_name),
                          "8th Mathematics",
                          course_name
    )
  ) %>%
  left_join(all_students_1 %>%
              rename(ps_stud_id = student_id),
            by = c(
              "student_id" = "student_number",
              "schoolid"
            )
  ) %>%
  left_join(course_df,
            by = c(
              "ps_stud_id",
              "course_name",
              "schoolid"
            )
  ) %>%
  left_join(full_attendance,
            by = c("schoolid",
                   "student_id" = "student_number"
            )
  ) %>%
  left_join(st_courses_rev_2 %>%
              select(
                course_number = local_course_id,
                isbe_state_course_code
              ),
            by = "course_number"
  )

## missing section information for 4th PE
# grades_course_att %>%
#   filter(is.na(section_number))
#
# pe_g4_missing_sect <- grades_course_att %>%
#   filter(course_name %in% "4th Writing") %>%
#   select(student_id,
#          section_number_keep = section_number)
#
#
# pe_complete_section <- grades_course_att %>%
#   filter(is.na(section_number)) %>%
#   left_join(pe_g4_missing_sect,
#             by = "student_id") %>%
#   select(-section_number) %>%
#   rename(section_number = section_number_keep)
#
# fin_grade_course_att <- grades_course_att %>%
#   filter(!is.na(section_number)) %>%
#   bind_rows(pe_complete_section)

## add in teacher information
teacher_ids <- 
  fin_grade_course_att %>%
  select(teacherid) %>%
  unique()

# pe_4th <- tibble(teacherid = 4486)
#
# teacher_ids <- teacherids %>%
#   bind_rows(pe_4th)

teacher_info <- 
  schoolstaff %>%
  filter(teacherid %in% teacher_ids$teacherid) %>%
  select(-status) %>%
  unique() %>%
  left_join(users,
            by = "users_dcid"
  ) %>%
  left_join(iein_dob %>%
              select(
                users_dcid,
                schoolid,
                iein,
                dob
              ),
            by = c(
              "users_dcid",
              "schoolid"
            )
  ) %>%
  left_join(missing_iein_dob %>%
              select(
                miss_iein = iein,
                miss_dob = dob,
                e_mail
              ),
            by = c("email_addr" = "e_mail")
  ) %>%
  mutate(
    iein = if_else(is.na(iein), miss_iein, iein),
    dob = if_else(is.na(dob), miss_dob, dob),
    teacher_first_name = if_else(grepl("Lizzy", teacher_first_name),
                                 "Megan",
                                 teacher_first_name
    ),
    teacher_last_name = if_else(grepl("Morris", teacher_last_name),
                                "Martin",
                                teacher_last_name
    )
  ) %>%
  left_join(teach_absent,
            by = c(
              "teacher_first_name" = "first",
              "teacher_last_name" = "last"
            )
  ) %>%
  mutate(
    days_taken = if_else(is.na(days_taken), 0, days_taken),
    total_days = 176,
    actual_att = total_days - days_taken,
    teacher_course_start_date = as_date("2018-08-20"),
    teacher_course_end_date = as_date("2019-06-14"),
    exit_reason = "01",
    teacher_course_end_date = format(as_date(teacher_course_end_date), "%m/%d/%Y")
  )

# total_days = if_else(teacherid %in% 2939, 40, 176),
# actual_att = total_days - days_taken_off,
# teacher_course_start_date = as_date("2017-08-21"),
# teacher_course_end_date = as_date("2018-06-15"),
# teacher_course_end_date = if_else(teacherid == 4491, #J. Weiner
#                                   as_date("2018-03-23"),
#                                   teacher_course_end_date),
# teacher_course_start_date = if_else(teacherid == 4580, #T. Okulaja
#                                   as_date("2017-10-23"),
#                                   teacher_course_start_date),
# teacher_course_start_date = if_else(teacherid == 2939, #E. Delaney
#                                     as_date("2018-04-03"),
#                                     teacher_course_start_date),
# exit_reason = if_else(teacher_course_end_date < as_date("2018-06-15"),
#                       "01",
#                       "02"),
# teacher_course_end_date = format(as_date(teacher_course_end_date), "%m/%d/%Y")) #%>% View()


## will need to find attendance info for these dates
## then join with teacher/course/grade data,
### combine with full data
### finally adjust attendance data for the observations already in the full dataset

# student_list <- final_grades %>%
#   left_join(all_students_1 %>%
#               rename(ps_stud_id = student_id),
#             by = c("student_id" = "student_number")) %>%
#   left_join(course_df,
#             by = c("ps_stud_id",
#                    "course_name")) %>% #filter(!schoolid.x==site_id)
#   select(ps_stud_id) %>%
#   unique()

student_list <- 
  fin_grade_course_att %>%
  select(ps_stud_id) %>%
  unique()

return_mid_year <- 
  reenrollment %>%
  filter(
    student_id %in% student_list$ps_stud_id,
    exitdate >= ymd("2018-08-20")
  ) %>%
  mutate(exit_entry = difftime(exitdate, entrydate, units = "days")) %>%
  filter(exit_entry > 7)


# Final Spreadsheet - 4-8 middle school -----------------------------------

final_ibse_rep_4_8 <- 
  fin_grade_course_att %>%
  # mutate(teacherid = if_else(course_name %in% '4th Physical Education', 4486, as.double(teacherid)),
  #        state_course_code = if_else(course_name %in% '4th Physical Education', "58034A000", state_course_code)) %>%
  left_join(teacher_info %>%
              rename(teacher_dob = dob),
            by = c(
              "teacherid",
              "schoolid"
            )
  ) %>%
  left_join(external_codes,
            by = "schoolid"
  ) %>%
  rename(home_rcdts = rcdts_code) %>%
  mutate(
    serving_school = home_rcdts,
    school_year = 2019,
    term = "Y1", # if_else(course_name %in% "5th Math Centers", "Q4", "Y1"),
    course_level = "02",
    course_credit = 1.00,
    articulated_cred = "02",
    dual_credit = "02",
    course_setting = "01",
    total_att_days = 176, # if_else(course_name %in% "5th Math Centers", 40, 176),
    max_num_grade = 100,
    teacher_serving_loc = home_rcdts,
    employer_rcdts = home_rcdts,
    role_of_professional = 200,
    teacher_commitment = 1.00,
    teacher_total_att = total_att_days,
    reason_for_exit = "01"
  ) %>% # if_else(teacherid == 4491, "02", "01")) %>%  #glimpse()
  select(
    cps_school_id = cps_id,
    isbe_student_id = state_studentnumber,
    cps_student_id = student_id,
    student_last_name = last_name,
    student_first_name = first_name,
    dob,
    home_rcdts,
    serving_school,
    school_year,
    term,
    isbe_course_code = isbe_state_course_code,
    local_course_id = course_number,
    local_course_title = course_name,
    student_course_start = entrydate,
    section_number,
    course_level,
    course_credit,
    articulated_cred,
    dual_credit,
    course_setting,
    actual_att_days_stud = present,
    total_days_stud = enrolled,
    course_num_grade = percent,
    max_num_grade,
    student_course_end = exitdate,
    stud_course_letter_grade = isbe_code,
    teacher_iein = iein,
    local_teacher_id = teacherid,
    teacher_last_name,
    teacher_first_name,
    teacher_dob,
    teacher_serving_loc,
    employer_rcdts,
    teacher_course_start_date,
    role_of_professional,
    teacher_commitment,
    actual_att,
    total_att_days,
    teacher_course_end_date,
    reason_for_exit
  ) %>%
  mutate( # student_course_start = format(student_course_start, "%m/%d/%Y"),
    # student_course_end = format(student_course_end, "%m/%d/%Y"),
    student_first_name = gsub("'|\\.", " ", student_first_name),
    student_last_name = gsub("'|\\.", " ", student_last_name),
    teacher_first_name = gsub("'|\\.", " ", teacher_first_name),
    teacher_last_name = gsub("'|\\.", " ", teacher_last_name)
  )


# Write Final ISBE Report 4-8 -------------------------------------------------------------

# write.xlsx(final_ibse_rep_4_8, here("reports/isbe_4_8_180625.xlsx"))
# todays_date <- today()
# 
# file_name_4_8 <- sprintf("reports/isbe_4_8_%s.xlsx", todays_date)
# 
# write.xlsx(final_ibse_rep_4_8, here::here(file_name_4_8))
