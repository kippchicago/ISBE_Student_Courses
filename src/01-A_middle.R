library(ProjectTemplate)
load.project()

source(here::here("munge", "01-A.R"))


# Student Courses --------------------------------------------------

# add in state course id

students_course_middle <- students_local_course_id_title_section_number %>%
  left_join(local_number_isbe_state_course_ids, by = "local_course_id") %>%
  select(-c(first_last_teacher, school))