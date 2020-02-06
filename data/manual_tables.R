#### Tables that have been created by hand. ####

# creating tibble with CPS codes and RCDT codes
external_codes <- 
  tribble(
    ~schoolid, ~abbr, ~cps_id, ~rcdts_code,
    78102, "KAP", 400044, "15016299025282C",
    7810, "KAMS", 400044, "15016299025282C",
    400146, "KAC", 400146, "15016299025101C",
    4001462, "KACP", 4001462, "15016299025101C",
    4001632, "KBP", 400163, "15016299025103C",
    400163, "KBCP", 400163, "15016299025103C",
    4001802, "KOP", 400180, "15016299025245C",
    400180, "KOA", 400180, "15016299025245C"
  )

## Manually look up missing codes
codes_for_NAs <- 
  tibble(
  local_course_id = addl_missing_codes$local_course_id,
  subject = addl_missing_codes$subject,
  grade_level = addl_missing_codes$grade_level,
  isbe_state_course_code = c(
    "52996A000",
    "53234A000",
    "54436A000",
    "55036A000",
    "55185A000",
    "55185A000",
    "58037A000",
    "53234A000",
    "58038A000",
    "54436A000",
    "55184A000",
    "58034A000", 
    NA, 
    NA
  )
)

grade_percent_scale <- 
  tibble(
    grade = c(
      rep("A+", 3),
      rep("A", 4),
      rep("A-", 4),
      rep("B+", 3),
      rep("B", 4),
      rep("B-", 3),
      rep("C+", 3),
      rep("C", 4),
      rep("C-", 3),
      rep("F", 70)
    ),
    percent = c(
      seq(98, 100, 1),
      seq(94, 97, 1),
      seq(90, 93, 1),
      seq(87, 89, 1),
      seq(83, 86, 1),
      seq(80, 82, 1),
      seq(77, 79, 1),
      seq(73, 76, 1),
      seq(70, 72, 1),
      seq(0, 69, 1)
    )
  ) %>%
  arrange(desc(percent))

## create ISBE table of letter grade codes
isbe_grade_codes <- 
  tribble(
    ~letter_grade, ~isbe_code,
    "A+", "01",
    "A", "02",
    "A-", "03",
    "B+", "04",
    "B", "05",
    "B-", "06",
    "C+", "07",
    "C", "08",
    "C-", "09",
    "F", "13"
  )

## tribble of isbe grade codes, KC primary grades, corresponding %
primary_grade_codes <- 
  tribble(
    ~kc_grades, ~kc_percent, ~isbe_codes,
    "EXCEEDS", 95, 27,
    "MEETS", 87, 28,
    "APPROACHING", 70, 29,
    "NOT YET", 59, 30
  )

# course names
course_names_primary <- 
  paste("art",
        "dance",
        "reading",
        "math",
        "musical theater",
        "physical education",
        "explorations",
        "writing",
        "visual arts",
        "science",
        "math centers",
        "performing arts",
        "music",
        "ela",
        sep = "|"
  )