locate_distinct_errors <- function(df_with_errors) {
  errors_col_df <- 
    df_with_errors %>%
    select(`Error Details`) %>%
    distinct() %>%
    separate(`Error Details`, 
             into = c("E1", "E2", "E3", "E4", "E5", "E6", "E7", "E8", "E9", "E10", 
                      "E11", "E12", "E13", "E14", "E15", "E16", "E17", "E18", "E19", "E20",
                      "E21", "E22", "E23", "E24", "E25", "E26", "E27", "E28", "E29", "E30"), 
             sep = ";") %>%
    remove_empty(which = c("cols"))
  
  final_errors <- data.frame(errors=character())
  
  for (col in colnames(errors_col_df)) {
    temp_df <- errors_col_df %>% select("errors" = col)
    temp_df <- temp_df
    final_errors <- 
      bind_rows(final_errors, 
                temp_df) %>%
      distinct() %>%
      drop_na()
  }
  return(final_errors)
}