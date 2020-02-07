# Pulls flat files from GCS bucket. 
# Location: raw_data_storage/ ISBE_Student_Courses/

library(googleCloudStorageR)
library(tidyverse)
library(janitor)
gcs_global_bucket("raw_data_storage")

# pull middle school grades
all_grade_files <- gcs_list_objects()
middle_school_18_18_grade_files <- all_grade_files$name[6:36]

count = 1
for (file_name in middle_school_18_18_grade_files) {
  gcs_get_object(file_name,
                 saveToDisk = paste("data/flatfiles/Middle school 4-8/SY18_19_", count, ".csv", sep = ""), 
                 overwrite = TRUE)
  count = count + 1
}

# pull primary grades
primary_school_17_18_grade_files <- all_grade_files$name[37:51]

count = 1
for (file_name in primary_school_17_18_grade_files) {
  gcs_get_object(file_name,
                 saveToDisk = paste("data/flatfiles/Primary school K-3/SY17_18_", count, ".csv", sep = ""), 
                 overwrite = TRUE)
  count = count + 1
}

gcs_get_object("ISBE_Student_Courses/18-18_files/190628_Days_Absent.csv", 
               saveToDisk = "data/flatfiles/190628_Days_Absent.csv", 
               overwrite = TRUE)

gcs_get_object("ISBE_Student_Courses/18-18_files/IEINs & DOBs (18-19) rev.csv",
               saveToDisk = "data/flatfiles/IEINs & DOBs (18-19) rev.csv", 
               overwrite = TRUE)

gcs_get_object("ISBE_Student_Courses/18-18_files/IEINs & DOBs.csv",
               saveToDisk = "data/flatfiles/IEINs & DOBs.csv", 
               overwrite = TRUE)

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
  janitor::clean_names()

file_list_middle <- 
  dir(path = here::here("data", "flatfiles", "Middle school 4-8/"), 
      pattern = "SY18_19", full.names = TRUE)

grade_df_list_middle <- 
  file_list_middle %>%
  map(read_csv) %>%
  map(clean_names)

file_list_primary <- 
  dir(path = here::here("data", "flatfiles", "Primary school K-3/"), 
      pattern = "SY17_18", full.names = TRUE)

grade_df_list_prim <- 
  file_list_primary %>%
  map(read_csv) %>%
  map(clean_names)

