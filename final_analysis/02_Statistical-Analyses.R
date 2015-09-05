# load("Test2_ProcessedLogData/all_logs_subsample.RData")
stats.dir <- "statistics"

smart_stats <- function(log_data, groups) {
  # log_data is a list of data frames
  temp <- lapply(log_data, function(log.data) {
    if ( length(groups) == 2 ) {
      group2 <- log.data$group[log.data$group %in% groups] %>%
        as.character %>% factor(levels = rev(groups))
      outcome2 <- log.data$outcome[log.data$group %in% groups] %>%
        as.character %>% factor(levels = c("1+", "0"))
      x <- table(group2, outcome2)
      y <- chisq.test(x)
      x_prop <- prop.table(x, margin = 1)
      # or <- wmf:::oddsRatio(p_treatment = x_prop['b', '1+'], p_control = x_prop['a', '1+'])
      orrr <- mosaic::oddsRatio(x)
      z <- unname(c(y$statistic, y$p.value, sqrt(y$statistic/length(group2)),
                    1/attr(orrr, 'OR'), 1/attr(orrr, 'upper.OR'), 1/attr(orrr, 'lower.OR')))
      names(z) <- c("Chi-square Statistic", "p-value", "Cohen's w", "Odds Ratio", "Lower", "Upper")
    } else {
      x <- table(log.data$group, log.data$outcome)
      y <- chisq.test(x)
      z <- unname(c(y$statistic, y$p.value, sqrt(y$statistic/sum(x))))
      names(z) <- c("Chi-square Statistic", "p-value", "Cohen's w")
    }
    return(z)
  }) %>% do.call(rbind, .) %>% as.data.frame
  if ( length(groups) == 2 ) {
    temp$summary <- "Meh"
    temp$summary[temp$`Odds Ratio` < 1 & temp$Lower < 1 & temp$Upper < 1] <- "Significantly less likely"
    temp$summary[temp$`Odds Ratio` > 1 & temp$Lower > 1 & temp$Upper > 1] <- "Significantly more likely"
  }
  return(temp)
}

stats_AvsBvsC <- smart_stats(logs_small, letters[1:3])
stats_AvsB <- smart_stats(logs_small, c("a", "b"))
stats_AvsC <- smart_stats(logs_small, c("a", "c"))
stats_BvsC <- smart_stats(logs_small, c("b", "c"))

save(list = c("stats_AvsBvsC", "stats_AvsB", "stats_AvsC", "stats_BvsC", "log_dates"),
     file = file.path(stats.dir, "group_outcome_comparisons.RData"))

# format_results <- function(results) {
#   results %>%
#     cbind(Date = as.character(log_dates, format = "%A %m/%d")) %>%
#     dplyr::select(-`Chi-square Statistic`) %>%
#     dplyr::rename(`More or less likely than controls?` = summary) %>%
#     dplyr::mutate(`Odds Ratio 95% CI` = sprintf("(%.3f, %.3f)" ,Lower, Upper),
#                   `p-value` = ifelse(`p-value` < 0.001, "< 0.001", round(`p-value`, 3))) %>%
#     dplyr::select(-c(Lower, Upper)) %>%
#     dplyr::select(c(`Date`, `p-value`, `Cohen's w`, `Odds Ratio`,
#                     `More or less likely than controls?`))
# }

# lapply(logs_small, with, expr = mosaic::oddsRatio(table(group, outcome)))

# mosaicplot(outcome ~ group, data = logs_small[[i]], col = 2:4, main = names(logs_small)[i], shade = TRUE)

stats_AvsBvsC %>%
  cbind(Date = as.character(log_dates, format = "%A %m/%d")) %>%
  dplyr::select(-`Chi-square Statistic`) %>%
  dplyr::select(c(`Date`, `p-value`, `Cohen's w`)) %>%
  dplyr::mutate(`p-value` = ifelse(`p-value` < 0.001, "< 0.001", round(`p-value`, 3))) %>%
  knitr::kable(digits = 3)

stats_AvsB %>%
  cbind(Date = as.character(log_dates, format = "%A %m/%d")) %>%
  dplyr::select(-`Chi-square Statistic`) %>%
  dplyr::rename(`More or less likely than controls?` = summary) %>%
  dplyr::mutate(`Odds Ratio 95% CI` = sprintf("(%.3f, %.3f)" ,Lower, Upper),
                `p-value` = ifelse(`p-value` < 0.001, "< 0.001", round(`p-value`, 3))) %>%
  dplyr::select(-c(Lower, Upper)) %>%
  dplyr::select(c(`Date`, `p-value`, `Cohen's w`, `Odds Ratio`, `Odds Ratio 95% CI`,
                  `More or less likely than controls?`)) %>%
  knitr::kable(digits = 2)

stats_AvsC %>%
  cbind(Date = as.character(log_dates, format = "%A %m/%d")) %>%
  dplyr::select(-`Chi-square Statistic`) %>%
  dplyr::rename(`More or less likely than controls?` = summary) %>%
  dplyr::mutate(`Odds Ratio 95% CI` = sprintf("(%.3f, %.3f)" ,Lower, Upper),
                `p-value` = ifelse(`p-value` < 0.001, "< 0.001", round(`p-value`, 3))) %>%
  dplyr::select(-c(Lower, Upper)) %>%
  dplyr::select(c(`Date`, `p-value`, `Cohen's w`, `Odds Ratio`, `Odds Ratio 95% CI`,
                  `More or less likely than controls?`)) %>%
  knitr::kable(digits = 2)

stats_BvsC %>%
  cbind(Date = as.character(log_dates, format = "%A %m/%d")) %>%
  dplyr::select(-`Chi-square Statistic`) %>%
  dplyr::rename(`Slop 2 more or less likely than Slop 1?` = summary) %>%
  dplyr::mutate(`Odds Ratio 95% CI` = sprintf("(%.3f, %.3f)" ,Lower, Upper),
                `p-value` = ifelse(`p-value` < 0.001, "< 0.001", round(`p-value`, 3))) %>%
  dplyr::select(-c(Lower, Upper)) %>%
  dplyr::select(c(`Date`, `p-value`, `Cohen's w`, `Odds Ratio`, `Odds Ratio 95% CI`,
                  `Slop 2 more or less likely than Slop 1?`)) %>%
  knitr::kable(digits = 2)