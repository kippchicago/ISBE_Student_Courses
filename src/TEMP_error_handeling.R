# Error Handling Scripts

source(here::here("lib", "helpers.R"))

drive_download("400146_CourseAssignment2020_01", 
               path = here::here("output", "errors", "400146_CourseAssignment2020_01.csv"), 
                                 overwrite = TRUE)

report_400146_w_errors <-
  read_csv(here::here("output", "errors", "400146_CourseAssignment2020_01.csv"))

test <- locate_distinct_errors(report_400146_w_errors)


errors_400146 <-
  report_400146_w_errors %>%
  select(`Error Details`) %>%
  distinct() %>%
  separate(`Error Details`,
           into = c("E1", "E2", "E3", "E4", "E5", "E6", "E7", "E8", "E9", "E10",
                    "E11", "E12", "E13", "E14", "E15", "E16", "E17", "E18", "E19", "E20",
                    "E21", "E22", "E23", "E24", "E25", "E26", "E27", "E28", "E29", "E30"),
           sep = ";") %>%
  remove_empty(which = c("cols"))

final_errors_400146 <- data.frame(errors=character())

for (col in colnames(errors_400146)) {
   temp_df <- errors_400146 %>% select("errors" = col)
   temp_df <- temp_df
   final_errors_400146 <-
     bind_rows(final_errors_400146,
             temp_df) %>%
     distinct() %>%
     drop_na()
}

write_csv(final_errors_400146, 
          here::here("output", "errors", "distinct_errors", "final_errors_400146.csv"))
  

