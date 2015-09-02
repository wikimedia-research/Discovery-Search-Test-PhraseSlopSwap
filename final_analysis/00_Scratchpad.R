logs <- list()
for ( log in dir("Test2_ProcessedLogData/") ) {
  load(file.path("Test2_ProcessedLogData", log))
  logs[[log]] <- data
  rm(data)
}; rm(log)
range(sapply(logs, with, expr = 100*sum(device == "Spider")/length(device)))
# between 0.2% and 2.5% of obs are known automata
# filter the automata out:
logs <- lapply(logs, dplyr::filter, device != "Spider")
# check to make sure changes have been applied:
range(sapply(logs, with, expr = 100*sum(device == "Spider")/length(device)))
# 0, yay!
# okay, let's clean up the names to make it easier for displaying data by date:
names(logs) <- sub("second_ab_test_log-([0-9]{4})([0-9]{2})([0-9]{2})\\.RData", "\\1-\\2-\\3", names(logs))
log_dates <- lubridate::ymd(names(logs))

# Remove nonsensical queries:
logs %<>% lapply(dplyr::filter, !(project %in% c("be_x_old wiki", "donation site", "testwikidata")))

## Let's save these changes:
save(list = c("logs", "log_dates"), file = "Test2_ProcessedLogData/all_logs.RData")
## Okay, let's go ahead...


