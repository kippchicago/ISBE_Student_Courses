# Pulls flat files from GCS bucket. 
# Location: raw_data_storage/ ISBE_Student_Courses/

teach_absent <- 
  read.xlsx(here::here("data", "190628_Days_Absent.xlsx")) %>%
  janitor::clean_names() %>%
  as_tibble()

iein_dob <- 
  read.xlsx(here::here("data", "IEINs & DOBs (18-19) rev.xlsx"), 
            detectDates = TRUE) %>% 
  as.tibble() %>%
  janitor::clean_names() %>%
  rename(
    users_dcid = ps_id,
    teacher_first_name = first,
    teacher_last_name = last
  ) %>%
  left_join(users %>%
              select(
                users_dcid,
                email_addr
              ) %>%
              mutate(
                email_addr = gsub(" ", "", email_addr),
                email_addr = if_else(grepl("dfrasure", email_addr),
                                     "dfrasure@kippchicago.org",
                                     email_addr
                )
              ),
            by = c("e_mail" = "email_addr")
  ) %>% # filter(schoolid != 0) %>% View()
  left_join(schoolstaff,
            by = c("users_dcid.y" = "users_dcid")
  ) %>%
  # filter(status == 1) %>%
  select(-users_dcid.x) %>%
  rename(users_dcid = users_dcid.y) %>%
  mutate(dob = format(as_date(dob), "%m/%d/%Y"))

missing_iein_dob <- 
  read.xlsx(here::here("data", "IEINs & DOBs.xlsx"), detectDates = TRUE) %>%
  as.tibble() %>%
  janitor::clean_names() %>%
  rename(
    users_dcid = ps_id,
    teacher_first_name = first,
    teacher_last_name = last
  ) %>%
  mutate(dob = format(as_date(dob), "%m/%d/%Y"))

# old submission from 2017. this doesn't have all the right courses so she pulls
# another ISBE Report on top of it. 
isbe_report_2017 <- 
  read.xlsx(here::here("EOY Data Collection_KIPP_Chicago_180627.xlsx")) %>%
  as_tibble() %>%
  janitor::clean_names()

# Grades (from report card)
file_list_middle <- 
  dir(path = here::here("data", "Middle school 4-8/"), 
      pattern = "SY18_19", full.names = TRUE)

grade_df_list_middle <- 
  file_list_middle %>%
  map(read_csv) %>%
  map(clean_names)

## pull grades for primary
file_list_primary <- 
  dir(path = here::here("data", "Primary school K-3/"), 
      pattern = "SY18_19", full.names = TRUE)

grade_df_list_prim <- 
  file_list_primary %>%
  map(read_csv) %>%
  map(clean_names)