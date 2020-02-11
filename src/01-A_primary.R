library(ProjectTemplate)
load.project()

source(here::here("munge", "01-A.R"))


# Student Courses --------------------------------------------------

# add in state course id

students_course_primary <- students_local_course_id_title_section_number %>%
  filter(grepl("k|1|2|3", local_course_title)) %>%
  mutate(school = 
           school= "extract school"  #str_extract(school, "[1-3]|k"),
         grade_level = "extract number") %>%
  left_join(local_number_isbe_state_course_ids, by = c("subject", "grade_level", "school"))