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

zenefits_teacher_info <- 
  read_csv(here::here("data", "flatfiles", "zenefits_teacher_data_isbe_midyear_reporting.csv")) %>%
  janitor::clean_names()

# 19/20 IEIN Teacher Data (Collected from talent team)
gcs_get_object("ISBE_Student_Courses/19-20_files/19_20_IEIN_numbers.csv", 
               saveToDisk = "data/flatfiles/19_20_IEIN_numbers.csv", 
               overwrite = TRUE)

teacher_iein_licensure_report <- 
  read_csv(here::here("data", "flatfiles", "19_20_IEIN_numbers.csv")) %>%
  janitor::clean_names() %>%
  rename("teacher_iein" = "iein") %>%
  mutate(email = trimws(email, which = c("both")), 
         last_name = trimws(last_name, which = c("both")), 
         first_name = trimws(first_name, which = c("both"))) %>%
  mutate(teacherid = as.character(teacherid), 
         birthday = mdy(birthday)
         ) %>% 
  mutate(birthday = format(as.Date(birthday), "%m/%d/%Y")) %>%
  # NOTE: This line trims all white space from character columns. This 
  # is imperitive later when we want to join datasets on teacherid column
  mutate_if(is.character, str_trim)

# KIPP Staff who started after the start of school (2019/08/19)
# Data gathered from HR
gcs_get_object("ISBE_Student_Courses/19-20_files/kipp_staff_member_start_after_20190819.csv", 
               saveToDisk = "data/flatfiles/kipp_staff_member_start_after_20190819.csv", 
               overwrite = TRUE)

kipp_staff_member_start_after_20190819 <- 
  read_csv(here::here("data", "flatfiles", "kipp_staff_member_start_after_20190819.csv")) %>%
  janitor::clean_names()
