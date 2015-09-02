process_logs <- function(filepath_in, filepath_out) {

  test_data <- readr::read_tsv(filepath_in,
                               col_names = c("wiki", "group", "queries", "results", "source", "time_taken", "ip", "user_agent", "query_metadata"),
                               col_types = "ccciciccc")
  
  cat("Performing some initial processing steps...")
  test_data$source %<>% factor
  test_data$wiki %<>% factor
  test_data$group %<>% substr(13, 13) %>% factor # we just need to know 'a/b/c'
  test_data$queries <- NULL
  test_data$query_metadata <- NULL
  cat("done.\n")
  
  cat("Extracting data from 'wiki' column...")
  test_data$language <- sub("(.*)wik.*", "\\1", test_data$wiki)
  test_data$project <- sub(".*wik(.*)", "wik\\1", test_data$wiki)
  lang_should_be_proj <- test_data$language %in% c("commons", "wikidata", "foundation", "mediawiki", "incubator", "meta", "simple", "sources", "species", "testwikidata", "office", "outreach", "donate", "be_x_old", "beta")
  test_data$project[lang_should_be_proj] <- paste(test_data$language[lang_should_be_proj], test_data$project[lang_should_be_proj])
  test_data$project[test_data$project == "wiki"] <- "wikipedia"
  test_data$project %<>% sub("commons wiki", "commons", .)
  test_data$project %<>% sub("donate wiki", "donation site", .)
  test_data$project %<>% sub("incubator", "wikimedia incubator", .)
  test_data$project %<>% sub("mediawiki wiki", "mediawiki", .)
  test_data$project %<>% sub("species wiki", "wikispecies", .)
  test_data$project %<>% sub("sources wiki", "wikisource", .)
  test_data$project %<>% sub("simple wiki", "simple wikipedia", .)
  test_data$project %<>% sub("wikidata wiki", "wikidata", .)
  test_data$project %<>% sub("testwikidata wiki", "wikidata test", .)
  test_data$project %<>% factor
  test_data$language[lang_should_be_proj] <- NA
  test_data$language %<>% factor
  # rm(lang_should_be_proj)
  cat("done.\n")
  
  cat("Geolocating...")
  test_data$country <- factor(rgeolocate::maxmind(ips = test_data$ip, file = "/usr/local/share/GeoIP/GeoIP2-Country.mmdb", "country_name")$country_name)
  cat("done.\n")
  test_data$ip <- NULL
  
  library(uaparser) # uaparser::update_regexes()
  cat("Parsing user agents...")
  ua_data <- uaparser::parse_agents(test_data$user_agent)
  cat("done.\n")
  test_data$user_agent <- NULL
  
  data <- cbind(test_data, ua_data)
  
  cat("Performing final processing steps...")
  # This cleans up the merged data from the UA parsing step.
  data$outcome <- factor(data$results > 0, c(TRUE, FALSE), c("1+", "0"))
  data$group2 <- factor(data$group == "a", c(TRUE, FALSE), c("control", "treatment"))
  data$browser2 <- paste(data$browser, data$browser_major)
  data$browser[data$browser == "Other"] <- "Other (Unknown)"
  data$browser[data$browser == "CFNetwork"] <- "Apple CFNetwork framework"
  top10_browsers <- names(head(sort(table(data$browser), decreasing = TRUE), 10))
  data$browser[!(data$browser %in% top10_browsers)] <- "Other (Known)"
  data$device %<>% factor
  # data %<>% subset(data, device != "Spider")
  data$os %<>% factor
  data$browser %<>% factor
  # data %<>% subset(data, time_taken > 0)
  # reorder the columns in the data frame to make the important stuff show up first
  order_of_cols <- union(c("wiki", "group", "group2", "results", "outcome",
                           "source", "time_taken",
                           "language", "project", "country",
                           "device", "browser", "browser2"), colnames(data))
  data <- data[, order_of_cols]
  cat("done.")
  
  save(list = "data", file = filepath_out)
  
  cat(" Finished!\n")

}
