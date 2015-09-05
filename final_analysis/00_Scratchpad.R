logs <- list()
for ( log in dir("Test2_ProcessedLogData/", pattern = "second_ab_test_log.*") ) {
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
for ( i in 1:length(logs) ) {
  logs[[i]]$project %<>% as.character %>% factor
}; rm(i)

# Sub-sample down to ~4k obs
set.seed(20150903)
logs_small <- logs %>% lapply(function(x) {
  x %>% dplyr::group_by(group) %>%
    dplyr::sample_n(size = 2000, replace = FALSE) %>%
    dplyr::ungroup()
})
for ( i in 1:length(log_dates) ) {
  logs_small[[i]]$date <- log_dates[i]
}; rm(i)
logs_small_combined <- Reduce(dplyr::bind_rows, logs_small)
logs_small_combined$wiki %<>% factor
logs_small_combined$language %<>% factor
logs_small_combined$project %<>% factor
logs_small_combined$country %<>% factor
logs_small_combined$device %<>% factor
logs_small_combined$browser %<>% factor
logs_small_combined$browser2 %<>% factor
logs_small_combined$os %<>% factor
logs_small_combined$date2 <- logs_small_combined$date %>% as.character %>% factor

## Let's save these changes:
save(list = c("logs", "log_dates"),
     file = "Test2_ProcessedLogData/all_logs.RData")
save(list = c("logs_small", "logs_small_combined", "log_dates"),
     file = "Test2_ProcessedLogData/all_logs_subsample.RData")
## Okay, let's go ahead...

temp <- logs_small[[3]] %>% with({
  g2 <- group[group %in% c('a', 'c')] %>% as.character %>% factor(levels = c('a', 'c'))
  o2 <- outcome[group %in% c('a', 'c')] %>% as.character %>% factor(levels = c('0', '1+'))
  table(g2, o2)
})

prop.table(temp, margin = 1)
wmf:::oddsRatio(p_treatment = 0.5395, p_control = 0.8205)
1/mosaic::oddsRatio(temp, verbose = TRUE)
