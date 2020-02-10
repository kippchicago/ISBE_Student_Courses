
# File Submissions -----------------------------------------------------

combined_submission <- 
  final_isbe_k_4 %>% # glimpse()
  mutate(
    course_num_grade = as.double(course_num_grade),
    teacher_course_end_date = format(as_date(teacher_course_end_date), "%m/%d/%Y")
  ) %>%
  bind_rows(final_ibse_rep_4_8 %>% # glimpse()
              mutate(
                course_num_grade = as.double(course_num_grade),
                stud_course_letter_grade = as.double(stud_course_letter_grade)
              )) %>%
  mutate(isbe_course_code = if_else(isbe_course_code == "08001A000",
                                    "58034A000",
                                    isbe_course_code
  )) %>%
  mutate(
    student_course_start = format(as_date(student_course_start), "%m/%d/%Y"),
    student_course_end = format(as_date(student_course_end), "%m/%d/%Y"),
    teacher_course_start_date = format(as_date(teacher_course_start_date), "%m/%d/%Y"),
    student_course_end = if_else(student_course_end == "06/15/2019", "06/14/2019", student_course_end)
  )


write_table_by_school(400044, combined_submission)
write_table_by_school(400163, combined_submission)
write_table_by_school(400146, combined_submission)
write_table_by_school(400180, combined_submission)