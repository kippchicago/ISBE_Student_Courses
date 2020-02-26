#### Tables that have been created by hand. ####

# CPS School ID & Home RCDTS
cps_school_rcdts_ids <- 
  tribble(
    ~abbr, ~cps_school_id, ~rcdts_code,
    "KAP", 400044, "15016299025282C",
    "KAMS", 400044, "15016299025282C",
    "KAC", 400146, "15016299025101C",
    "KACP", 400146, "15016299025101C",
    "KBP", 400163, "15016299025103C",
    "KBCP", 400163, "15016299025103C",
    "KOP", 400180, "15016299025245C",
    "KOA", 400180, "15016299025245C"
  )

# Primary School Course Names
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
