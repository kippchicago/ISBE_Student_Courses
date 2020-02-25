library(ProjectTemplate)
load.project()

source(here::here("lib", "helpers.R"))

incorrect_names_full <- 
  bind_rows(incorrect_names_400044, 
            incorrect_names_400146, 
            incorrect_names_400163, 
            incorrect_names_400180) %>%
  select(CPS.Student.ID, 
         Student.Last.Name, 
         Student.First.Name, 
         ASPEN_name) %>%
  mutate(name_location = if_else(grepl("First", ASPEN_name) ,"First", "Last")) %>%
  mutate(replacement_name = )

isbe_midyear_report_400044_names_fixed <- 
  isbe_midyear_report_400044 %>%
  left_join()