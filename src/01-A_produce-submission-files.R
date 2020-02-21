# Produces the 4 files that are ready for submission 

library(ProjectTemplate)
load.project()

source(here::here("munge", "01-A.R"))
source(here::here("munge", "02-A_primary.R"))
source(here::here("munge", "03-A_middle.R"))

# Individual Primary School Reports ---------------------------------------

isbe_midyear_report_kap <- 
  isbe_report_primary_midyear_2020_full %>%
  filter(grepl("kap", `Local Course ID`))

isbe_midyear_report_kbp <- 
  isbe_report_primary_midyear_2020_full %>%
  filter(grepl("kbp", `Local Course ID`))

isbe_midyear_report_kacp <- 
  isbe_report_primary_midyear_2020_full %>%
  filter(grepl("kacp", `Local Course ID`))

isbe_midyear_report_kop <- 
  isbe_report_primary_midyear_2020_full %>%
  filter(grepl("kop", `Local Course ID`))

# Individual Middle School Reports ----------------------------------------

isbe_midyear_report_kams <- 
  isbe_report_middle_midyear_2020_full %>%
  filter(grepl("kams", `Local Course ID`))

isbe_midyear_report_kbcp <- 
  isbe_report_middle_midyear_2020_full %>%
  filter(grepl("kbcp", `Local Course ID`))

isbe_midyear_report_kac <- 
  isbe_report_middle_midyear_2020_full %>%
  filter(grepl("kac", `Local Course ID`))

isbe_midyear_report_koa <- 
  isbe_report_middle_midyear_2020_full %>%
  filter(grepl("koa", `Local Course ID`))

# Final Combined Reports (4 Schools) -------------------------------------

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
