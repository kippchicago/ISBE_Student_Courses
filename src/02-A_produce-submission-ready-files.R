library(ProjectTemplate)
load.project()

# Individual Primary School Reports ---------------------------------------

isbe_midyear_report_kap <- 
  isbe_report_primary_midyear_2020_full %>%
  filter(grepl("kap", local_course_id))

isbe_midyear_report_kbp <- 
  isbe_report_primary_midyear_2020_full %>%
  filter(grepl("kbp", local_course_id))

isbe_midyear_report_kacp <- 
  isbe_report_primary_midyear_2020_full %>%
  filter(grepl("kacp", local_course_id))

isbe_midyear_report_kop <- 
  isbe_report_primary_midyear_2020_full %>%
  filter(grepl("kop", local_course_id))


# Individual Middle School Reports ----------------------------------------

isbe_midyear_report_kams <- 
  isbe_report_middle_midyear_2020_full %>%
  filter(grepl("kams", local_course_id))

isbe_midyear_report_kbcp <- 
  isbe_report_middle_midyear_2020_full %>%
  filter(grepl("kbcp", local_course_id))

isbe_midyear_report_kac <- 
  isbe_report_middle_midyear_2020_full %>%
  filter(grepl("kac", local_course_id))

isbe_midyear_report_koa <- 
  isbe_report_middle_midyear_2020_full %>%
  filter(grepl("koa", local_course_id))


# Final Combined Reports (4 Schools)  -------------------------------------

isbe_midyear_report_ascend <- 
  bind_rows(isbe_midyear_report_kap, 
            isbe_midyear_report_kams)

isbe_midyear_report_bloom <- 
  bind_rows(isbe_midyear_report_kbcp, 
            isbe_midyear_report_kbp)

isbe_midyear_report_one <- 
  bind_rows(isbe_midyear_report_koa, 
            isbe_midyear_report_kop)

isbe_midyear_report_academy <- 
  bind_rows(isbe_midyear_report_kac, 
            isbe_midyear_report_kacp)


