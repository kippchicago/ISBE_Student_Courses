#### Tables that have been created by hand. ####

# CPS School ID & Home RCDTS
cps_school_rcdts_ids <- 
  tribble(
    ~schoolid, ~abbr, ~cps_school_id, ~rcdts_code,
    "78102", "KAP", "400044", "15016299025282C",
    "7810", "KAMS", "400044", "15016299025282C",
    "400146", "KAC", "400146", "15016299025101C",
    "4001462", "KACP", "400146", "15016299025101C",
    "4001632", "KBP", "400163", "15016299025103C",
    "400163", "KBCP", "400163", "15016299025103C",
    "4001802", "KOP", "400180", "15016299025245C",
    "400180", "KOA", "400180", "15016299025245C"
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
