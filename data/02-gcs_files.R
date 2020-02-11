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

# ISBE Teacher Info
gcs_get_object("ISBE_Student_Courses/19-20_files/teacher_info_isbe_report_19-20.csv", 
               saveToDisk = "data/flatfiles/teacher_info_isbe_report_19-20.csv", 
               overwrite = TRUE)

zenefits_teacher_info <- 
  read_csv(here::here("data", "flatfiles", "teacher_info_isbe_report_19-20.csv")) %>%
  janitor::clean_names()




