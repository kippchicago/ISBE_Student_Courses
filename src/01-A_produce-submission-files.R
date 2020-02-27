# Produces the 4 files that are ready for submission 

library(ProjectTemplate)
load.project()

source(here::here("munge", "01-A.R"))
source(here::here("munge", "02-A_primary.R"))
source(here::here("munge", "03-A_middle.R"))

# Combine Middle and Primary Reports --------------------------------------

# 3,112 total students
isbe_report_all_schools <- 
  bind_rows(isbe_report_middle_midyear_2020_full, 
            isbe_report_primary_midyear_2020_full) %>%
  filter(!is.na(`ISBE Student ID`))
  
# Filter Report for all 4 Schools -----------------------------------------

isbe_midyear_report_400044 <- 
  isbe_report_all_schools %>%
  filter(`CPS School ID` == 400044) %>%
  filter(grepl("kap|kams", `Local Course ID`)) %>%
  
  # If student, course and school are the same then sort
  # and choose first one
  group_by(`CPS Student ID`, `State Course Code`) %>%
  filter(row_number(desc(`Student Last Name`)) == 1) %>%
  ungroup()

isbe_midyear_report_400146 <- 
  isbe_report_all_schools %>%
  filter(`CPS School ID` == 400146) %>%
  filter(grepl("kac|kacp", `Local Course ID`)) %>%
  
  # If student, course and school are the same then sort
  # and choose first one
  group_by(`CPS Student ID`, `State Course Code`) %>%
  filter(row_number(desc(`Student Last Name`)) == 1) %>%
  ungroup()
  
isbe_midyear_report_400163 <- 
  isbe_report_all_schools %>%
  filter(`CPS School ID` == 400163) %>%
  filter(grepl("kbp|kbcp", `Local Course ID`)) %>%
  
  # If student, course and school are the same then sort
  # and choose first one
  group_by(`CPS Student ID`, `State Course Code`) %>%
  filter(row_number(desc(`Student Last Name`)) == 1) %>%
  ungroup()

isbe_midyear_report_400180 <- 
  isbe_report_all_schools %>%
  filter(`CPS School ID` == 400180) %>%
  filter(grepl("kop|koa", `Local Course ID`)) %>%
  
  # If student, course and school are the same then sort
  # and choose first one
  group_by(`CPS Student ID`, `State Course Code`) %>%
  filter(row_number(desc(`Student Last Name`)) == 1) %>%
  ungroup()
