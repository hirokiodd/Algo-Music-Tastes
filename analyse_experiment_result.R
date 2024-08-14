#===============================================================================
# analyse_experiment_result.R
# Purpose: Analyse the results of the experiment
# Author: Hiroki Oda
#===============================================================================

# Load the results of the experiment
experiment <- read.csv("../data/experiment/result_experiment.csv")

# Summary statistics of the experiment for each account type including number of cumlative counts and mean, median, standard deviation, min, max, 25th percentile, 75th percentile of variety, average_atypicality and populariry
experiment_summary <- experiment %>%
  group_by(account_type) %>%
  summarise(num_cumulative_counts = n(), mean_variety = mean(variety), median_variety = median(variety), sd_variety = sd(variety), min_variety = min(variety), max_variety = max(variety), q25_variety = quantile(variety, 0.25), q75_variety = quantile(variety, 0.75), mean_atypicality = mean(average_atypicality), median_atypicality = median(average_atypicality), sd_atypicality = sd(average_atypicality), min_atypicality = min(average_atypicality), max_atypicality = max(average_atypicality), q25_atypicality = quantile(average_atypicality, 0.25), q75_atypicality = quantile(average_atypicality, 0.75), mean_popularity = mean(popularity), median_popularity = median(popularity), sd_popularity = sd(popularity), min_popularity = min(popularity), max_popularity = max(popularity), q25_popularity = quantile(popularity, 0.25), q75_popularity = quantile(popularity, 0.75))

# Output the results
experiment_summary

# Plot variety over time (cumulative count) using a line plot
# Use 6 panels to show the variety of each account type with same y-axis range
# Set the range of y-axis from 0 to 15
# Change the order of the panels as 'mono-purist', 'mono-mixer', 'poly-purist', 'poly-mixer', 'control' and 'control2'
ggplot(experiment, aes(x = cumulative_count, y = variety, color = account_type)) +
  geom_line() +
  facet_wrap(~account_type, scales = "free_y") +
  ylim(0, 15) +
  xlab("Cumulative count") +
  ylab("Variety")

# Plot atypicality over time (cumulative count) using a line plot
# Use 6 panels to show the atypicality of each account type with same y-axis range
# Set the range of y-axis from 0 to 25
# Change the order of the panels as 'mono-purist', 'mono-mixer', 'poly-purist', 'poly-mixer', 'control' and 'control2'
ggplot(experiment, aes(x = cumulative_count, y = average_atypicality, color = account_type)) +
  geom_line() +
  facet_wrap(~account_type, scales = "free_y") +
  ylim(0, 20) +
  xlab("Cumulative count") +
  ylab("Average atypicality")

# Plot popularity over time (cumulative count) using a line plot'
# Use 6 panels to show the popularity of each account type with same y-axis range
# Set the range of y-axis from 0 to 100
# Change the order of the panels as 'mono-purist', 'mono-mixer', 'poly-purist', 'poly-mixer', 'control' and 'control2'
ggplot(experiment, aes(x = cumulative_count, y = popularity, color = account_type)) +
  geom_line() +
  facet_wrap(~account_type, scales = "free_y") +
  ylim(0, 100) +
  xlab("Cumulative count") +
  ylab("Popularity")

# Convert to long format if necessary
data_long <- experiment %>%
  gather(key = "variable", value = "value", variety, average_atypicality) %>%
  arrange(account_type, cumulative_count)

# Conducting repeated measures ANOVA for 'variety'
aov_variety <- aov(value ~ cumulative_count + Error(account_type/cumulative_count), 
                   data = subset(data_long, variable == "variety"))

summary(aov_variety)

# Conducting repeated measures ANOVA for 'average_atypicality'
aov_atypicality <- aov(value ~ cumulative_count + Error(account_type/cumulative_count), 
                       data = subset(data_long, variable == "average_atypicality"))

summary(aov_atypicality)

# One-way ANOVA for 'variety'
aov_variety_one_way <- aov(variety ~ account_type, data = experiment)
summary(aov_variety_one_way)

# One-way ANOVA for 'average_atypicality'
aov_atypicality_one_way <- aov(average_atypicality ~ account_type, data = experiment)
summary(aov_atypicality_one_way)

# Post-hoc test for 'variety'
posthoc_variety <- TukeyHSD(aov_variety_one_way)
posthoc_variety

# Post-hoc test for 'average_atypicality'
posthoc_atypicality <- TukeyHSD(aov_atypicality_one_way)
posthoc_atypicality
