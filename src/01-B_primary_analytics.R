library('ProjectTemplate')
load.project()

for (dataset in project.info$data)
{
  message(paste('Showing top 5 rows of', dataset))
  print(head(get(dataset)))
}

# PRIMARY ANALYTICS ------------------------------------------------------

primary_missing_codes <- 
  missing_st_code %>%
  anti_join(st_courses_rev_2,
            by = c("course_number" = "local_course_id")
  )
# filter(!grepl("kap[1-3|k][sci]", course_number),
#        !grepl("kbcp", course_number),
#        !grepl("kapsped", course_number))

primary_courses <- 
  isbe_report_2017 %>%
  select(
    isbe_state_course_code,
    local_course_id,
    local_course_title
  ) %>%
  mutate(
    grade_level = str_extract(local_course_id, "\\d"),
    grade_level = if_else(is.na(grade_level), 0, as.double(grade_level)),
    local_course_id = if_else(grepl("kaps", local_course_id),
                              gsub("kaps", "kap", local_course_id),
                              local_course_id
    ),
    local_course_title = if_else(grepl("4th Math", local_course_title) &
                                   !grepl("Centers", local_course_title),
                                 "4th Mathematics",
                                 local_course_title
    ) # ,
    # local_course_title = if_else(grepl("kap", local_course_id) &
    #                              grepl("Art", local_course_title) &
    #                              !grepl("Arts", local_course_title),
    #                              gsub("Art", "Visual Arts", local_course_title),
    #                              local_course_title)
  ) %>%
  filter(
    grade_level < 5,
    !grepl("kac", local_course_id)
  )

## Primary ISBE Course Codes

# primary_missing_codes <- missing_st_code %>%
#   filter(grepl("kop|kaps", course_number),
#          !grepl("4", course_number))

# 2015 primary courses and state course code (Michael S sent this info)
# student_course_2015 <- read.xlsx(here("data/Student Course Assignment 2015 - KIPP Chicago (EOY) - revised.xlsx")) %>%
#  janitor::clean_names()


# primary_st_course_codes <- student_course_2015 %>%
#   select(state_course_code,
#          local_course_id,
#          local_course_title) %>%
#   unique() %>%
#   filter(!grepl("([4-8])", local_course_id)) %>%
#   mutate(local_course_title = if_else(grepl("Math", local_course_title),
#                                       "Math",
#                                       local_course_title))

## primary teacher info
primary_course_info <- 
  course_df %>%
  filter(
    !grepl("([5-8])", course_number),
    !grepl("kac", course_number),
    !grepl("att|ell|swela|swmath", course_number)
    # !grepl("woo", course_number)
  ) %>%
  # filter(!grepl("Science|Power|Sped", course_name)) %>% #filter(ps_stud_id %in% 16934)
  group_by(ps_stud_id) %>%
  filter(dateleft == max(dateleft))

primary_teachers <- 
  primary_course_info %>% # filter(ps_stud_id %in% 16934)
  group_by(ps_stud_id) %>%
  filter(dateleft == max(dateleft)) %>%
  select(
    ps_stud_id,
    teacherid,
    course_number,
    course_name,
    section_number
  ) %>%
  unique() # %>% group_by(ps_stud_id) %>% summarize(N= n()) %>% filter(N > 1)

# primary_teachers %>% ungroup() %>% select(-ps_stud_id) %>% unique() %>%
#   left_join(schoolstaff,
#             by = "teacherid") %>%
#   left_join(users,
#             by = "users_dcid") %>%
#   left_join(iein_dob %>%
#               select(iein,
#                      dob,
#                      e_mail),
#             by = c("email_addr" = "e_mail")) %>%
#   left_join(missing_iein_dob %>%
#               select(miss_iein = iein,
#                      miss_dob = dob,
#                      e_mail),
#             by = c("email_addr" = "e_mail")) %>%
#   filter(is.na(iein), is.na(miss_iein))

homeroom_teacher <- 
  primary_teachers %>%
  left_join(schoolstaff,
            by = "teacherid"
  ) %>%
  left_join(users,
            by = "users_dcid"
  )

p_teachers_w_excel <- 
  primary_teachers %>%
  ungroup() %>%
  select(teacherid) %>%
  unique() %>%
  bind_rows(tibble(teacherid = c( # 3681,
    # KAP visual arts
    # 1689, # KAP Musical T.
    # 4941, #KAP PE,
    # 4487, # KAP Dance
    # 2484, #KAP explorations
    4521, # KOP visual arts
    5381, # KOP performance arts
    4954 # KBP music
  ))) %>%
  left_join(schoolstaff,
            by = "teacherid"
  ) %>%
  left_join(users,
            by = "users_dcid"
  )

primary_grades <- 
  grade_df_list_prim %>%
  map_df(get_primary_grades_courses)

k_3_teachers <- 
  primary_teachers %>%
  left_join(schoolstaff,
            by = c("teacherid")
  ) %>%
  left_join(users,
            by = c("users_dcid")
  ) %>%
  filter(
    !grepl("4", course_name),
    !grepl("Science", course_name)
  )

k_3_grades_teachid <- 
  primary_grades %>%
  filter(!grepl("4", course_name)) %>%
  left_join(students %>%
              select(student_number,
                     ps_stud_id = student_id
              ),
            by = c("student_id" = "student_number")
  ) %>%
  left_join(k_3_teachers %>%
              select(
                ps_stud_id,
                teacherid
              ),
            by = c("ps_stud_id")
  )

k_3_excellance <- 
  k_3_grades_teachid %>%
  select(
    site_id,
    course_name
  ) %>%
  unique() %>%
  mutate(
    teacherid0 = if_else(site_id %in% 78102 &
                           grepl("Art", course_name),
                         3681,
                         0
    ),
    teacherid1 = if_else(site_id %in% 78102 &
                           grepl("Musical Theater", course_name),
                         1689,
                         teacherid0
    ),
    teacherid2 = if_else(site_id %in% 78102 &
                           grepl("Physical Education", course_name),
                         4941,
                         teacherid1
    ),
    teacherid3 = if_else(site_id %in% 78102 &
                           grepl("Dance", course_name),
                         4487,
                         teacherid2
    ),
    teacherid4 = if_else(site_id %in% 78102 &
                           grepl("Explorations", course_name),
                         2484,
                         teacherid3
    ),
    teacherid5 = if_else(site_id %in% 4001802 &
                           grepl("Visual Arts", course_name),
                         4521,
                         teacherid4
    ),
    teacherid6 = if_else(site_id %in% 4001802 &
                           grepl("Performing Arts", course_name),
                         5381,
                         teacherid5
    ),
    teacherid7 = if_else(site_id %in% 4001802 &
                           grepl("Performing Arts", course_name),
                         5381,
                         teacherid6
    ),
    teacherid = if_else(site_id %in% 4001632 &
                          grepl("Music", course_name),
                        4954,
                        teacherid7
    )
  ) %>%
  filter(teacherid > 0) %>%
  select(-c(teacherid0:teacherid7))

k_3_grades_teacher <- 
  k_3_grades_teachid %>%
  left_join(k_3_excellance %>%
              rename(ex_teacherid = teacherid),
            by = c(
              "site_id",
              "course_name"
            )
  ) %>% # View()
  mutate(teacherid = if_else(!is.na(ex_teacherid),
                             ex_teacherid,
                             as.double(teacherid)
  )) %>% # View()
  select(-ex_teacherid) %>%
  left_join(p_teachers_w_excel,
            by = "teacherid"
  ) %>%
  filter(!grepl("Guided|Choice", course_name))

kap4_grades_teacher <- 
  primary_grades %>%
  filter(grepl("4", course_name)) %>%
  mutate(
    course_name = if_else(grepl("Art", course_name),
                          "4th Visual Arts",
                          course_name
    ),
    course_name = if_else(grepl("Ela", course_name),
                          "4th English Language Arts",
                          course_name
    ),
    course_name = if_else(grepl("Math", course_name),
                          "4th Mathematics",
                          course_name
    )
  ) %>%
  left_join(students %>%
              select(student_number,
                     ps_stud_id = student_id
              ),
            by = c("student_id" = "student_number")
  ) %>%
  left_join(primary_teachers %>%
              filter(grepl("4", course_name)) %>%
              ungroup() %>%
              select(
                ps_stud_id,
                teacherid,
                course_name
              ),
            by = c(
              "ps_stud_id",
              "course_name"
            )
  ) %>%
  left_join(p_teachers_w_excel,
            by = "teacherid"
  )

# primary_grades_teachid <- primary_grades %>%
#   left_join(students %>%
#               select(student_number,
#                      ps_stud_id = student_id),
#             by = c("student_id" = "student_number")) %>%
#   left_join(primary_teachers %>%
#               select(ps_stud_id,
#                      teacherid) %>%
#               unique(),
#             by = c("ps_stud_id"))


# NOTE: Term ids will need to be changed
kap4_sections <- 
  cc %>%
  filter(
    termid == 2800,
    student_id %in% kap4_grades_teacher$ps_stud_id,
    grepl("att", course_number)
  ) %>%
  group_by(student_id) %>%
  filter(dateleft == max(dateleft)) %>%
  select(
    ps_stud_id = student_id,
    section_number
  )

p_grades_teacher <- 
  k_3_grades_teacher %>%
  mutate(section_number = "1") %>%
  bind_rows(kap4_grades_teacher %>%
              left_join(kap4_sections,
                        by = "ps_stud_id"
              )) %>%
  left_join(ps_enrollment %>%
              group_by(
                schoolid,
                ps_stud_id
              ) %>%
              filter(exitdate == max(exitdate)),
            by = c(
              "ps_stud_id",
              "schoolid"
            )
  )

# primary_with_st_course_codes <-  p_grades_teacher %>%
#    select(course_name) %>%
#    unique() %>%
#    mutate(course_name0 = tolower(course_name)) %>%
#    left_join(primary_courses %>%
#                mutate(course_name0 = tolower(local_course_title)), #%>% View,
#              by = 'course_name0')


primary_with_st_course_codes <- 
  p_grades_teacher %>%
  filter(!grepl("Choice|Guided", course_name)) %>%
  mutate(school = str_extract(course_number, "kop|kap|kbp")) %>%
  left_join(primary_courses %>%
              mutate(school = str_extract(local_course_id, "kop|kap|kbp")) %>%
              select(
                isbe_state_course_code,
                local_course_title,
                school
              ) %>%
              unique(),
            by = c(
              "course_name" = "local_course_title",
              "school"
            )
  ) %>%
  unique()

na_st_codes <-
  primary_with_st_course_codes %>%
  filter(is.na(isbe_state_course_code)) %>%
  select(
    course_number,
    course_name
  ) %>%
  unique() %>%
  ungroup() %>%
  mutate(
    school = str_extract(course_number, "kap|kop|kbp"),
    st_course_code = c(
      "53233A000",
      "51130A000",
      "52030A000",
      "55130A000",
      "51040A000",
      "51130A000",
      "53231A000",
      "52032A000",
      "55072A000",
      "51042A000",
      "53232A000",
      "51132A000",
      "55184A000",
      "53234A000", 
      NA, 
      NA, 
      NA, 
      NA, 
      NA, 
      NA, 
      NA, 
      NA, 
      NA, 
      NA
    )
  )

fin_codes <- 
  primary_with_st_course_codes %>%
  left_join(na_st_codes %>%
              select(
                course_name,
                school,
                st_course_code
              ),
            by = c("course_name", "school")
  ) %>%
  mutate(isbe_state_course_code = if_else(is.na(isbe_state_course_code),
                                          st_course_code,
                                          isbe_state_course_code
  )) %>% # View()
  select(-st_course_code)

final_isbe_k_4 <- 
  fin_codes %>%
  left_join(full_attendance,
            by = c(
              "student_id" = "student_number",
              "schoolid"
            )
  ) %>%
  select(schoolid,
         student_id,
         kc_percent,
         isbe_codes,
         course_number,
         course_name,
         ps_stud_id,
         teacherid,
         teacher_first_name,
         teacher_last_name,
         teachernumber,
         isbe_state_course_code,
         enrolled,
         present,
         dateenrolled = entrydate,
         dateleft = exitdate,
         email_addr,
         section_number
  ) %>%
  left_join(teach_absent,
            by = c(
              "teacher_first_name" = "first",
              "teacher_last_name" = "last"
            )
  ) %>%
  mutate(
    days_taken = if_else(is.na(days_taken),
                         0,
                         days_taken
    ),
    teacher_start_date = ymd("2018-08-20"),
    teacher_end_date = ymd("2019-06-14")
  ) %>%
  left_join(external_codes,
            by = "schoolid"
  ) %>%
  left_join(students %>%
              mutate(dob = format(as_date(dob), "%m/%d/%Y")) %>%
              select(
                student_id = student_number,
                dob,
                student_first_name = first_name,
                student_last_name = last_name,
                state_studentnumber
              ),
            by = "student_id"
  ) %>%
  left_join(iein_dob %>%
              select(
                teacher_dob = dob,
                iein,
                e_mail
              ) %>%
              unique(),
            by = c("email_addr" = "e_mail")
  ) %>% # glimpse()
  mutate(
    serving_school = rcdts_code,
    home_rcdts = rcdts_code,
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
    actual_att = teacher_total_att - days_taken,
    reason_for_exit = "01"
  ) %>%
  select(
    cps_school_id = cps_id,
    isbe_student_id = state_studentnumber,
    cps_student_id = student_id,
    student_last_name,
    student_first_name,
    dob,
    home_rcdts,
    serving_school,
    school_year,
    term,
    isbe_course_code = isbe_state_course_code,
    local_course_id = course_number,
    local_course_title = course_name,
    student_course_start = dateenrolled,
    section_number,
    course_level,
    course_credit,
    articulated_cred,
    dual_credit,
    course_setting,
    actual_att_days_stud = present,
    total_days_stud = enrolled,
    course_num_grade = kc_percent,
    max_num_grade,
    student_course_end = dateleft,
    stud_course_letter_grade = isbe_codes,
    teacher_iein = iein,
    local_teacher_id = teacherid,
    teacher_last_name,
    teacher_first_name,
    teacher_dob,
    teacher_serving_loc,
    employer_rcdts,
    teacher_course_start_date = teacher_start_date,
    role_of_professional,
    teacher_commitment,
    actual_att,
    total_att_days,
    teacher_course_end_date = teacher_end_date,
    reason_for_exit
  ) %>%
  mutate( # student_course_start = format(student_course_start, "%m/%d/%Y"),
    # student_course_end = format(student_course_end, "%m/%d/%Y"),
    student_first_name = gsub("'|\\.", " ", student_first_name),
    student_last_name = gsub("'|\\.", " ", student_last_name),
    teacher_first_name = gsub("'|\\.", " ", teacher_first_name),
    teacher_last_name = gsub("'|\\.", " ", teacher_last_name)
  )