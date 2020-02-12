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
  janitor::clean_names()