# Pulls flat files from GCS bucket. 
# Location: raw_data_storage/ ISBE_Student_Courses/

library(googleCloudStorageR)
library(tidyverse)
library(janitor)

gcs_global_bucket("raw_data_storage")

# ISBE State Course Code & Local Course ID
gcs_get_object("ISBE_Student_Courses/19-20_files/course_local_number_state_ids.csv", 
               saveToDisk = "data/flatfiles/course_local_number_state_ids.csv", 
               overwrite = TRUE)

local_number_isbe_state_course_ids <-
  read_csv(here::here("data", "flatfiles", "course_local_number_state_ids.csv")) %>%
  janitor::clean_names()
# created by hand. Primary based on report card fields and hard coded Excellence teachers

# ISBE Teacher Info
gcs_get_object("ISBE_Student_Courses/19-20_files/zenefits_teacher_data_isbe_midyear_reporting.csv", 
               saveToDisk = "data/flatfiles/zenefits_teacher_data_isbe_midyear_reporting.csv", 
               overwrite = TRUE)

<<<<<<< HEAD
# added course number state ID file
gcs_get_object("ISBE_Student_Courses/18-18_files/isbe_report_courses_2017.csv",
               saveToDisk = "data/flatfiles/isbe_report_courses_2017.csv", 
               overwrite = TRUE)


# Read in Files to Environment -----------------------------------------------------------

teach_absent <-
  read_csv(here::here("data", "flatfiles", "190628_Days_Absent.csv")) %>%
  janitor::clean_names() %>%
  as_tibble()

iein_dob <-
  read_csv(here::here("data", "flatfiles", "IEINs & DOBs (18-19) rev.csv")) %>%
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
  read_csv(here::here("data", "flatfiles", "IEINs & DOBs.csv")) %>%
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
  read_csv(here::here("data", "flatfiles", "isbe_report_courses_2017.csv")) %>%
  as_tibble() %>%
=======
zenefits_teacher_info <- 
  read_csv(here::here("data", "flatfiles", "zenefits_teacher_data_isbe_midyear_reporting.csv")) %>%
>>>>>>> V2
  janitor::clean_names()

# 19/20 IEIN Teacher Data (Collected from talent team)
gcs_get_object("ISBE_Student_Courses/19-20_files/19_20_IEIN_numbers.csv", 
               saveToDisk = "data/flatfiles/19_20_IEIN_numbers.csv", 
               overwrite = TRUE)

teacher_iein_licensure_report <- 
  read_csv(here::here("data", "flatfiles", "19_20_IEIN_numbers.csv")) %>%
  janitor::clean_names()

# KIPP Staff who started after the start of school (2019/08/19)
# Data gathered from HR
gcs_get_object("ISBE_Student_Courses/19-20_files/kipp_staff_member_start_after_20190819.csv", 
               saveToDisk = "data/flatfiles/kipp_staff_member_start_after_20190819.csv", 
               overwrite = TRUE)

kipp_staff_member_start_after_20190819 <- 
  read_csv(here::here("data", "flatfiles", "kipp_staff_member_start_after_20190819.csv")) %>%
  janitor::clean_names()

