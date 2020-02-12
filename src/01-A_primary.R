library(ProjectTemplate)
load.project()

source(here::here("munge", "01-A.R"))


# Student Courses --------------------------------------------------

# Subjects, state course IDs, and local course IDs (made up because not enrolled in Powerschool) come from a flat file
# Multiple core courses per student

students_course_primary_core <- 
  students_local_course_id_title_section_number %>%
  filter(grepl("k |1|2|3", local_course_title),
         !grepl("Science", local_course_title)) %>%
  mutate(school = str_extract(local_course_id, 
                              "kop|kbp|kap|kacp"),
         grade_level = str_replace(local_course_id, 
                                   "kop|kbp|kap|kacp", "") %>%       
           str_extract("^.")) %>%
  select(student_id, teacherid, school, grade_level) %>%
  left_join(local_number_isbe_state_course_ids, 
            by = c("grade_level", "school")) %>% 
  filter(is.na(first_last_teacher)) %>%
  select(-first_last_teacher)
  

# Subjects, state course IDs, local course IDs (made up because not enrolled in Powerschool) and teachers come from flat file
# Multiple excellence courses per student

students_course_primary_excellence <- 
  students_local_course_id_title_section_number %>%
  filter(grepl("k |1|2|3", local_course_title),
         !grepl("Science", local_course_title)) %>%
  mutate(school = str_extract(local_course_id, "kop|kbp|kap|kacp"),
         grade_level = str_replace(local_course_id, "kop|kbp|kap|kacp", "") %>%      
           str_extract("^.")) %>%
  select(student_id, teacherid, school, grade_level) %>%
  left_join(local_number_isbe_state_course_ids, 
            by = c("grade_level", "school")) %>% 
  filter(!is.na(first_last_teacher)) %>%
  select(-teacherid)
  
  
  
  
  