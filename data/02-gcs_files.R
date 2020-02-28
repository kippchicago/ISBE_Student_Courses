# Pulls flat files from Google Cloud Storage bucket.
# Location: raw_data_storage/ ISBE_Student_Courses/

gcs_global_bucket("raw_data_storage")

# ISBE State Course Code & Local Course ID --------------------------------

gcs_get_object("ISBE_Student_Courses/19-20_files/course_local_number_state_ids.csv",
               saveToDisk = "data/flatfiles/course_local_number_state_ids.csv",
               overwrite = TRUE)

local_number_isbe_state_course_ids <-
  read_csv(here::here("data", "flatfiles", "course_local_number_state_ids.csv")) %>%
  janitor::clean_names()
# created by hand. Primary based on report card fields and hard coded Excellence teachers


# ISBE Teacher Info -------------------------------------------------------

gcs_get_object("ISBE_Student_Courses/19-20_files/zenefits_teacher_data_isbe_midyear_reporting.csv",
               saveToDisk = "data/flatfiles/zenefits_teacher_data_isbe_midyear_reporting.csv",
               overwrite = TRUE)

zenefits_teacher_info <-
  read_csv(here::here("data", "flatfiles", "zenefits_teacher_data_isbe_midyear_reporting.csv")) %>%
  janitor::clean_names()


# 19/20 IEIN Teacher Data (Collected from talent team) --------------------

gcs_get_object("ISBE_Student_Courses/19-20_files/19_20_IEIN_numbers.csv",
               saveToDisk = "data/flatfiles/19_20_IEIN_numbers.csv",
               overwrite = TRUE)

teacher_iein_licensure_report <-
  read_csv(here::here("data", "flatfiles", "19_20_IEIN_numbers.csv")) %>%
  janitor::clean_names() %>%
  rename("teacher_iein" = "iein") %>%
  mutate(email = trimws(email, which = c("both")),
         last_name = trimws(last_name, which = c("both")),
         first_name = trimws(first_name, which = c("both"))) %>%
  mutate(teacherid = as.character(teacherid),
         birthday = mdy(birthday)
         ) %>%
  mutate(birthday = format(as.Date(birthday), "%m/%d/%Y")) %>%
  # NOTE: This line trims all white space from character columns. This
  # is imperitive later when we want to join datasets on teacherid column
  mutate_if(is.character, str_trim)


# KIPP Staff who started after the start of school (2019/08/19) -----------

# Data gathered from HR
gcs_get_object("ISBE_Student_Courses/19-20_files/kipp_staff_member_start_after_20190819.csv",
               saveToDisk = "data/flatfiles/kipp_staff_member_start_after_20190819.csv",
               overwrite = TRUE)

kipp_staff_member_start_after_20190819 <-
  read_csv(here::here("data", "flatfiles", "kipp_staff_member_start_after_20190819.csv")) %>%
  janitor::clean_names()

# ASPEN Student Info (Current & Former Students 19-20) --------------------

# Ascend 400044
gcs_get_object("ISBE_Student_Courses/19-20_files/aspen_student_data/400044_ascend_current_students_aspen.csv",
               saveToDisk = "data/flatfiles/400044_ascend_current_students_aspen.csv",
               overwrite = TRUE)

ascend_400044_current_students_aspen <-
  read_csv(here::here("data", "flatfiles", "400044_ascend_current_students_aspen.csv")) %>%
  janitor::clean_names() %>%
  rename(current_school_name = school_name) %>%
  mutate(school_assigned_to = "400044") %>%
  # mutate_if(is.character, str_trim) %>%
  mutate(last_name = str_to_lower(last_name), 
         first_name = str_to_lower(first_name))

gcs_get_object("ISBE_Student_Courses/19-20_files/aspen_student_data/400044_ascend_former_students_aspen.csv",
               saveToDisk = "data/flatfiles/400044_ascend_former_students_aspen.csv",
               overwrite = TRUE)

ascend_400044_former_students_aspen <-
  read_csv(here::here("data", "flatfiles", "400044_ascend_former_students_aspen.csv")) %>%
  janitor::clean_names() %>%
  rename(current_school_name = school_name) %>%
  mutate(school_assigned_to = "400044") %>%
  mutate_if(is.character, str_trim) %>%
  mutate(last_name = str_to_lower(last_name), 
         first_name = str_to_lower(first_name))

# academy 400146
gcs_get_object("ISBE_Student_Courses/19-20_files/aspen_student_data/400146_academy_current_students_aspen.csv",
               saveToDisk = "data/flatfiles/400146_academy_current_students_aspen.csv",
               overwrite = TRUE)

academy_400146_current_students_aspen <-
  read_csv(here::here("data", "flatfiles", "400146_academy_current_students_aspen.csv")) %>%
  janitor::clean_names()  %>%
  rename(current_school_name = school_name) %>%
  mutate(school_assigned_to = "400146") %>%
  mutate_if(is.character, str_trim) %>%
  mutate(last_name = str_to_lower(last_name), 
         first_name = str_to_lower(first_name))

gcs_get_object("ISBE_Student_Courses/19-20_files/aspen_student_data/400146_academy_former_students_aspen.csv",
               saveToDisk = "data/flatfiles/400146_academy_former_students_aspen.csv",
               overwrite = TRUE)

academy_400146_former_students_aspen <-
  read_csv(here::here("data", "flatfiles", "400146_academy_former_students_aspen.csv")) %>%
  janitor::clean_names() %>%
  rename(current_school_name = school_name) %>%
  mutate(school_assigned_to = "400146") %>%
  mutate_if(is.character, str_trim) %>%
  mutate(last_name = str_to_lower(last_name), 
         first_name = str_to_lower(first_name))

# bloom 400163
gcs_get_object("ISBE_Student_Courses/19-20_files/aspen_student_data/400163_bloom_current_students_aspen.csv",
               saveToDisk = "data/flatfiles/400163_bloom_current_students_aspen.csv",
               overwrite = TRUE) 

bloom_400163_current_students_aspen <-
  read_csv(here::here("data", "flatfiles", "400163_bloom_current_students_aspen.csv")) %>%
  janitor::clean_names() %>%
  rename(current_school_name = school_name) %>%
  mutate(school_assigned_to = "400163") %>%
  mutate_if(is.character, str_trim) %>%
  mutate(last_name = str_to_lower(last_name), 
         first_name = str_to_lower(first_name))

gcs_get_object("ISBE_Student_Courses/19-20_files/aspen_student_data/400163_bloom_former_students_aspen.csv",
               saveToDisk = "data/flatfiles/400163_bloom_former_students_aspen.csv",
               overwrite = TRUE)

bloom_400163_former_students_aspen <-
  read_csv(here::here("data", "flatfiles", "400163_bloom_former_students_aspen.csv")) %>%
  janitor::clean_names() %>%
  rename(current_school_name = school_name) %>%
  mutate(school_assigned_to = "400163") %>%
  mutate_if(is.character, str_trim) %>%
  mutate(last_name = str_to_lower(last_name), 
         first_name = str_to_lower(first_name))

# one 400180
gcs_get_object("ISBE_Student_Courses/19-20_files/aspen_student_data/400180_one_current_students_aspen.csv",
               saveToDisk = "data/flatfiles/400180_one_current_students_aspen.csv",
               overwrite = TRUE)

one_400180_current_students_aspen <-
  read_csv(here::here("data", "flatfiles", "400180_one_current_students_aspen.csv")) %>%
  janitor::clean_names() %>%
  rename(current_school_name = school_name) %>%
  mutate(school_assigned_to = "400180") %>%
  mutate_if(is.character, str_trim) %>%
  mutate(last_name = str_to_lower(last_name), 
         first_name = str_to_lower(first_name))

gcs_get_object("ISBE_Student_Courses/19-20_files/aspen_student_data/400180_one_former_students_aspen.csv",
               saveToDisk = "data/flatfiles/400180_one_former_students_aspen.csv",
               overwrite = TRUE)

one_400180_former_students_aspen <-
  read_csv(here::here("data", "flatfiles", "400180_one_former_students_aspen.csv")) %>%
  janitor::clean_names() %>%
  rename(current_school_name = school_name) %>%
  mutate(school_assigned_to = "400180") %>%
  mutate_if(is.character, str_trim) %>%
  mutate(last_name = str_to_lower(last_name), 
         first_name = str_to_lower(first_name))

students_aspen_info_current_former <-
  bind_rows(ascend_400044_current_students_aspen, 
            ascend_400044_former_students_aspen, 
            academy_400146_current_students_aspen, 
            academy_400146_former_students_aspen, 
            bloom_400163_current_students_aspen, 
            bloom_400163_former_students_aspen, 
            one_400180_current_students_aspen, 
            one_400180_former_students_aspen
            ) %>%
  mutate(dob = mdy(dob)) %>%
  distinct() %>%
  group_by(student_id) %>%
  mutate(number_of_rows_student_id_appears_in = n(), 
         student_id_duplicated = case_when(number_of_rows_student_id_appears_in > 1 ~ 1, 
                                           TRUE ~ 0)
         ) %>%
  ungroup(student_id)


# Corrected CPS IDs -------------------------------------------------------

gcs_get_object("ISBE_Student_Courses/19-20_files/cps_id_corrections.csv",
               saveToDisk = "data/flatfiles/cps_id_corrections.csv",
               overwrite = TRUE)

cps_id_corrections <-
  read_csv(here::here("data", "flatfiles", "cps_id_corrections.csv")) %>%
  janitor::clean_names() %>%
  mutate(cps_student_id = as.character(cps_student_id), 
         kipp_incorrect_cpsid = as.character(kipp_incorrect_cpsid))


# CPS Enrollment Data ASPEN -----------------------------------------------

# Ascend 400044

gcs_get_object("ISBE_Student_Courses/19-20_files/aspen_student_data/enrollment_ascend_aspen_400044.csv",
               saveToDisk = "data/flatfiles/enrollment_ascend_aspen_400044.csv",
               overwrite = TRUE)

enrollment_ascend_aspen_400044 <-
  read_csv(here::here("data", "flatfiles", "enrollment_ascend_aspen_400044.csv")) %>%
  janitor::clean_names() %>%
  rename(date = x1, 
         type = x3, 
         student_name = x4,
         yog = x7,
         school_name = x8,
         code = x9,
         reason = x11) %>%
  mutate(date = na_if(date, "Date")) %>%
  drop_na(date) %>%
  select(-c(charter, x5, x6, yog, x10, reason, code)) %>%
  separate(col = student_name, 
           into = c("last_name", "first_name"), 
           sep = ",") %>%
  filter(school_name == "KIPP - ASCEND") %>%
  mutate(date = mdy(date), 
         cps_school_id = "400044") %>%
  mutate_if(is.character, str_trim) %>%
  mutate(last_name = str_to_lower(last_name), 
         first_name = str_to_lower(first_name))
  
# Academy 400146

gcs_get_object("ISBE_Student_Courses/19-20_files/aspen_student_data/enrollment_academy_aspen_400146.csv",
               saveToDisk = "data/flatfiles/enrollment_academy_aspen_400146.csv",
               overwrite = TRUE)

enrollment_academy_aspen_400146 <-
  read_csv(here::here("data", "flatfiles", "enrollment_academy_aspen_400146.csv")) %>%
  janitor::clean_names() %>%
  rename(date = x1, 
         type = x3, 
         student_name = x4,
         yog = x7,
         school_name = x8,
         code = x9,
         reason = x11) %>%
  mutate(date = na_if(date, "Date")) %>%
  drop_na(date) %>%
  select(-c(charter, x5, x6, yog, x10, reason, code)) %>%
  separate(col = student_name,
           into = c("last_name", "first_name"),
           sep = ",") %>%
  filter(school_name == "KIPP - ACADEMY") %>%
  mutate(date = mdy(date)) %>%
  mutate_if(is.character, str_trim) %>%
  mutate(last_name = str_to_lower(last_name), 
         first_name = str_to_lower(first_name))

# bloom 400163

gcs_get_object("ISBE_Student_Courses/19-20_files/aspen_student_data/enrollment_bloom_aspen_400163.csv",
               saveToDisk = "data/flatfiles/enrollment_bloom_aspen_400163.csv",
               overwrite = TRUE)

enrollment_bloom_aspen_400163 <-
  read_csv(here::here("data", "flatfiles", "enrollment_bloom_aspen_400163.csv")) %>%
  janitor::clean_names() %>%
  rename(date = x1, 
         type = x3, 
         student_name = x4,
         yog = x7,
         school_name = x8,
         code = x9,
         reason = x11) %>%
  mutate(date = na_if(date, "Date")) %>%
  drop_na(date) %>%
  select(-c(charter, x5, x6, yog, x10, reason, code)) %>%
  separate(col = student_name,
           into = c("last_name", "first_name"),
           sep = ",") %>%
  filter(school_name == "KIPP - BLOOM") %>%
  mutate(date = mdy(date)) %>%
  mutate_if(is.character, str_trim) %>%
  mutate(last_name = str_to_lower(last_name), 
         first_name = str_to_lower(first_name))

# ONE 400180

gcs_get_object("ISBE_Student_Courses/19-20_files/aspen_student_data/enrollment_one_aspen_400180.csv",
               saveToDisk = "data/flatfiles/enrollment_one_aspen_400180.csv",
               overwrite = TRUE)

enrollment_one_aspen_400180 <-
  read_csv(here::here("data", "flatfiles", "enrollment_one_aspen_400180.csv")) %>%
  janitor::clean_names() %>%
  rename(date = x1, 
         type = x3, 
         student_name = x4,
         yog = x7,
         school_name = x8,
         code = x9,
         reason = x11) %>%
  mutate(date = na_if(date, "Date")) %>%
  drop_na(date) %>%
  select(-c(charter, x5, x6, yog, x10, reason, code)) %>%
  separate(col = student_name,
           into = c("last_name", "first_name"),
           sep = ",") %>%
  filter(school_name == "KIPP - ONE") %>%
  mutate(date = mdy(date)) %>%
  mutate_if(is.character, str_trim) %>%
  mutate(last_name = str_to_lower(last_name), 
         first_name = str_to_lower(first_name))


# CPS Name Corrections ------------------------------------------------------

gcs_get_object("ISBE_Student_Courses/19-20_files/cps_name_replacement_aspen.csv",
               saveToDisk = "data/flatfiles/cps_name_replacement_aspen.csv",
               overwrite = TRUE)

cps_name_replacement_list <-
  read_csv(here::here("data", "flatfiles", "cps_name_replacement_aspen.csv")) %>%
  janitor::clean_names() %>%
  rename(ASPEN_name = error_details) %>%
  select(cps_student_id, 
         ASPEN_name) %>%
  mutate(name_location = if_else(grepl("First", ASPEN_name) ,"First", "Last")) %>%
  mutate(replacement_name = str_extract(ASPEN_name, "(?<=Name to match ').*")) %>%
  mutate(replacement_name = str_sub(replacement_name, 1, -2), 
         cps_student_id = as.character(cps_student_id)) %>%
  select(-c(ASPEN_name))

