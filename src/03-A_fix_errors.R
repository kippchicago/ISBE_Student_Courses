library(ProjectTemplate)
load.project()

source(here::here("lib", "helpers.R"))

name_replacements_full <- 
  bind_rows(incorrect_names_400044, 
            incorrect_names_400146, 
            incorrect_names_400163, 
            incorrect_names_400180) %>%
  select(CPS.Student.ID, 
         ASPEN_name) %>%
  mutate(name_location = if_else(grepl("First", ASPEN_name) ,"First", "Last")) %>%
  mutate(replacement_name = str_extract(ASPEN_name, "(?<=Name to match ').*")) %>%
  mutate(replacement_name = str_sub(replacement_name, 1, -2)) %>%
  select(-c(ASPEN_name))

dob_replacement_full <- 
  bind_rows(incorrect_dob_400044, 
            incorrect_dob_400146, 
            incorrect_dob_400163, 
            incorrect_dob_400180) %>%
  select(-c(school, grade_level, correct_dob))

replace_with_aspen_name(isbe_midyear_report_400044, 
                        name_replacement_df = name_replacement_full)


# Update School Reports w. Name & dob -------------------------------------


isbe_midyear_report_400044_name_dob_update <- 
  isbe_midyear_report_400044 %>%
  left_join(name_replacements_full, 
            by = c("CPS Student ID" = "CPS.Student.ID")) %>%
  mutate(`Student First Name` = case_when(name_location == "First" ~ replacement_name,
                                        TRUE ~ `Student First Name`)) %>%
  mutate(`Student Last Name` = case_when(name_location == "Last" ~ replacement_name, 
                                         TRUE ~ `Student Last Name`)) %>%
  mutate(`Birth Date` = mdy(`Birth Date`)) %>%
  left_join(dob_replacement_full, 
            by = c("CPS Student ID" = "CPS.Student.ID")) %>%
  mutate(`Birth Date` = if_else(!is.na(aspen_dob), 
                                        aspen_dob, 
                                        `Birth Date`)) %>%
  distinct()

isbe_midyear_report_400146_name_dob_update <- 
  isbe_midyear_report_400146 %>%
  left_join(name_replacements_full, 
            by = c("CPS Student ID" = "CPS.Student.ID")) %>%
  mutate(`Student First Name` = case_when(name_location == "First" ~ replacement_name,
                                          TRUE ~ `Student First Name`)) %>%
  mutate(`Student Last Name` = case_when(name_location == "Last" ~ replacement_name, 
                                         TRUE ~ `Student Last Name`)) %>%
  mutate(`Birth Date` = mdy(`Birth Date`)) %>%
  left_join(dob_replacement_full, 
            by = c("CPS Student ID" = "CPS.Student.ID")) %>%
  mutate(`Birth Date` = if_else(!is.na(aspen_dob), 
                                aspen_dob, 
                                `Birth Date`)) %>%
  distinct()

isbe_midyear_report_400163_name_dob_update <- 
  isbe_midyear_report_400163 %>%
  left_join(name_replacements_full, 
            by = c("CPS Student ID" = "CPS.Student.ID")) %>%
  mutate(`Student First Name` = case_when(name_location == "First" ~ replacement_name,
                                          TRUE ~ `Student First Name`)) %>%
  mutate(`Student Last Name` = case_when(name_location == "Last" ~ replacement_name, 
                                         TRUE ~ `Student Last Name`)) %>%
  mutate(`Birth Date` = mdy(`Birth Date`)) %>%
  left_join(dob_replacement_full, 
            by = c("CPS Student ID" = "CPS.Student.ID")) %>%
  mutate(`Birth Date` = if_else(!is.na(aspen_dob), 
                                aspen_dob, 
                                `Birth Date`)) %>%
  distinct()

isbe_midyear_report_400180_name_dob_update <- 
  isbe_midyear_report_400180 %>%
  left_join(name_replacements_full, 
            by = c("CPS Student ID" = "CPS.Student.ID")) %>%
  mutate(`Student First Name` = case_when(name_location == "First" ~ replacement_name,
                                          TRUE ~ `Student First Name`)) %>%
  mutate(`Student Last Name` = case_when(name_location == "Last" ~ replacement_name, 
                                         TRUE ~ `Student Last Name`)) %>%
  mutate(`Birth Date` = mdy(`Birth Date`)) %>%
  left_join(dob_replacement_full, 
            by = c("CPS Student ID" = "CPS.Student.ID")) %>%
  mutate(`Birth Date` = if_else(!is.na(aspen_dob), 
                                aspen_dob, 
                                `Birth Date`)) %>%
  distinct()


# Write Updated Files -----------------------------------------------------

write_csv(isbe_midyear_report_400146_name_dob_update, here::here("output", "final_reports", "400146_CourseAssignment2020_01.csv"))

write_csv(isbe_midyear_report_400044_name_dob_update, here::here("output", "final_reports", "40044_CourseAssignment2020_01.csv"))

write_csv(isbe_midyear_report_400163_name_dob_update, here::here("output", "final_reports", "400163_CourseAssignment2020_01.csv"))

write_csv(isbe_midyear_report_400180_name_dob_update, here::here("output", "final_reports", "400180_CourseAssignment2020_01.csv"))


isbe_midyear_report_400044 %>%
  group_by(`CPS Student ID`) %>%
  count() %>%
  View()
