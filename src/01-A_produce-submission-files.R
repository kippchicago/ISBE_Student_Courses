# Produces the 4 files that are ready for submission 

library(ProjectTemplate)
load.project()

source(here::here("munge", "01-A.R"))
source(here::here("munge", "02-A_primary.R"))
source(here::here("munge", "03-A_middle.R"))

# Combine Middle and Primary Reports --------------------------------------

isbe_report_all_schools <- 
  bind_rows(isbe_report_middle_midyear_2020_full, 
            isbe_report_primary_midyear_2020_full) %>%
  drop_na(`Student First Name`)

# Filter Report for all 4 Schools -----------------------------------------

isbe_midyear_report_400044 <- 
  isbe_report_all_schools %>%
  filter(`CPS School ID` == 400044)

isbe_midyear_report_400146 <- 
  isbe_report_all_schools %>%
  filter(`CPS School ID` == 400146)

isbe_midyear_report_400163 <- 
  isbe_report_all_schools %>%
  filter(`CPS School ID` == 400163)

isbe_midyear_report_400180 <- 
  isbe_report_all_schools %>%
  filter(`CPS School ID` == 400180)

# Current Students Without ISBE IDs

# isbe_report_all_schools %>%
#   filter(is.na(`ISBE Student ID`)) %>%
#   select(`CPS School ID`, 
#          `CPS Student ID`, 
#          `Student Last Name`, 
#          `Student First Name`, 
#          `Birth Date`) %>%
#   distinct() %>%
#   View()

# # Student Roster by School -----------------------------------------
# 
# ps_school_student_roster_400044 <- students_current_demographics %>%
#   select(cps_school_id, cps_student_id) %>%
#   distinct() %>%
#   filter(cps_school_id == 400044)
# 
# ps_school_student_roster_400146 <- students_current_demographics %>%
#   select(cps_school_id, cps_student_id) %>%
#   distinct() %>%
#   filter(cps_school_id == 400146)
# 
# ps_school_student_roster_400163 <- students_current_demographics %>%
#   select(cps_school_id, cps_student_id) %>%
#   distinct() %>%
#   filter(cps_school_id == 400163)
# 
# ps_school_student_roster_400180 <- students_current_demographics %>%
#   select(cps_school_id, cps_student_id) %>%
#   distinct() %>%
#   filter(cps_school_id == 400180)
# 
# 
# # Rostered to the school but not in the report ------------------------------------
# 
# missing_students_400044 <- 
#   ps_school_student_roster_400044 %>%
#   anti_join(isbe_midyear_report_400044, 
#             by = c("cps_student_id" = "CPS Student ID"))
# 
# missing_students_400146 <- 
#   ps_school_student_roster_400146 %>%
#   anti_join(isbe_midyear_report_400146, 
#             by = c("cps_student_id" = "CPS Student ID"))
# 
# missing_students_400163 <- 
#   ps_school_student_roster_400163 %>%
#   anti_join(isbe_midyear_report_400163, 
#             by = c("cps_student_id" = "CPS Student ID"))
# 
# missing_students_400180 <- 
#   ps_school_student_roster_400180 %>%
#   anti_join(isbe_midyear_report_400180, 
#             by = c("cps_student_id" = "CPS Student ID"))
