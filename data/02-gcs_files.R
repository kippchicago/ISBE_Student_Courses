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

# May erase the staff directory -------------------------------------------

# 19-20 Staff Directory
# Source: https://docs.google.com/spreadsheets/d/1IUGg9sL_KbzlPMvrXm1czlorBgBwSRTtYXWKnmV3p94/edit?ts=5d119a5d#gid=0
# all_raw_data_storage_files <- gcs_list_objects()
# all_staff_directory_files <- all_raw_data_storage_files$name[58:65]
# 
# for (file_name in all_staff_directory_files) {
#   gcs_get_object(file_name,
#                  saveToDisk = paste("data/flatfiles/staff_directory/",
#                                     str_sub(file_name, 56, -1), sep = ""),
#                  overwrite = TRUE)
# }
# 
# staff_directory_KAC <- 
#   read_csv(here::here("data", "flatfiles", "staff_directory", 
#                       "19-20_KIPP_Chicago_Staff_Directory_KAC.csv")) %>%
#   janitor::clean_names()
# 
# staff_directory_KACP <- 
#   read_csv(here::here("data", "flatfiles", "staff_directory", 
#                       "19-20_KIPP_Chicago_Staff_Directory_KACP.csv")) %>%
#   janitor::clean_names()
# 
# staff_directory_KAMS <- 
#   read_csv(here::here("data", "flatfiles", "staff_directory", 
#                       "19-20_KIPP_Chicago_Staff_Directory_KAMS.csv")) %>%
#   janitor::clean_names()
# 
# staff_directory_KAP <- 
#   read_csv(here::here("data", "flatfiles", "staff_directory", 
#                       "19-20_KIPP_Chicago_Staff_Directory_KAP.csv")) %>%
#   janitor::clean_names()
# 
# staff_directory_KBCP <- 
#   read_csv(here::here("data", "flatfiles", "staff_directory", 
#                       "19-20_KIPP_Chicago_Staff_Directory-KBCP.csv")) %>%
#   janitor::clean_names()
# 
# staff_directory_KBP <- 
#   read_csv(here::here("data", "flatfiles", 
#                       "staff_directory", 
#                       "19-20_KIPP_Chicago_Staff_Directory-KBP.csv")) %>%
#   janitor::clean_names()
# 
# staff_directory_KOA <- 
#   read_csv(here::here("data", "flatfiles", 
#                       "staff_directory", 
#                       "19-20_KIPP_Chicago_Staff_Directory_KOA.csv")) %>%
#   janitor::clean_names()
# 
# staff_directory_KOP <- 
#   read_csv(here::here("data", "flatfiles", 
#                       "staff_directory", 
#                       "19-20_KIPP_Chicago_Staff_Directory-KOP.csv")) %>%
#   janitor::clean_names()

# # Create list of all files in "staff_directory" folder
# files_staff_directory <-
#   dir(path = here::here("data",
#                         "flatfiles",
#                         "staff_directory"),
#       pattern = "*.csv")
# 
# staff_directory_path <-
#   here::here("data", "flatfiles",
#              "staff_directory")
# 
# all_current_kipp_staff <-
#   files_staff_directory %>%
#   map(~ read_csv(file.path(staff_directory_path, .))) %>%
#   reduce(rbind)
# 
# all_current_teachers <-
#   all_current_kipp_staff %>%
#   select(
#     'Last Name',
#     'First Name',
#     'Position',
#     'E-mail'
#   )

