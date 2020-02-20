# Error Handling Scripts

errors_400146_20200219 <- 
  read.xlsx(here::here("output", "errors", "400146_CourseAssignment2020_01.xlsx"))

errors_400146_20200219 %>%
  select(Error.Details) %>%
  View()