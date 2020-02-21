# this file writes error files to output/errors/distinct_errors folder. 
# NOTE: run "src/02-A_produce_error_identification_files.R" first


# Write All Errors --------------------------------------------------------

write_csv(final_errors_400044, 
          here::here("output", "errors", "distinct_errors", 
                     paste("final_errors_400044", today(), ".csv", sep="_")))

write_csv(final_errors_400146, 
          here::here("output", "errors", "distinct_errors", 
                     paste("final_errors_400146", today(), ".csv", sep="_")))

write_csv(final_errors_400163, 
          here::here("output", "errors", "distinct_errors", 
                     paste("final_errors_400163", today(), ".csv", sep="_")))

write_csv(final_errors_400180, 
          here::here("output", "errors", "distinct_errors", paste("final_errors_400180", today(), ".csv", sep="_")))


# Write Name Errors -------------------------------------------------------

write_csv(incorrect_names_400044, 
          here::here("output", "errors", "distinct_errors", 
                     paste("incorrect_names_400044", today(), ".csv", sep = "_")))

write_csv(incorrect_names_400146, 
          here::here("output", "errors", "distinct_errors",
                     paste("incorrect_names_400146", today(), ".csv", sep = "_")))
write_csv(incorrect_names_400163, 
          here::here("output", "errors", "distinct_errors",
                     paste("incorrect_names_400163", today(), ".csv", sep = "_")))

write_csv(incorrect_names_400180, 
          here::here("output", "errors", "distinct_errors",
                     paste("incorrect_names_400180", today(), ".csv", sep = "_")))
