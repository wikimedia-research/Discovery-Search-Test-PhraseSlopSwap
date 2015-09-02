library(magrittr)

# setwd("Data/Test2-Slop_Logs")
source('00_Data-Import.R')

## The log pre-processing pipeline: 
# gunzip -c /a/mw-log/archive/CirrusSearchUserTesting.log-<DATE>.gz |
#   awk '{sub(/.*CirrusSearchUserTesting DEBUG: /,""); print}' |
#     grep '"full_text"'| grep "phrase-slop" | gzip > second_ab_test_log-<DATE>.tsv.gz

log_dates <- as.character(as.Date("2015-08-21") + 0:11, format = "%Y%m%d")
for ( log_date in log_dates ) {
  filepath_in = paste0("second_ab_test_log-", log_date,".tsv.gz")
  filepath_out = paste0("second_ab_test_log-", log_date,".RData")
  print(system.time(try(process_logs(filepath_in, filepath_out)))['elapsed'])
}
