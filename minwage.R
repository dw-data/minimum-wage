library(tidyverse)
#source("../Templates/chart_template.R")

#### Read dataset ###
#####################
d_all = read.csv("data_OECD_summary.csv", sep=";", dec=",", stringsAsFactors = F)
names(d_all)

#filter and simplify for analysis
d = d_all %>%
  #select relevant variables and simplify names
  select(country = Country,
         minwage_gross = minwage.2017.monthly,
         minwage_net = est.net.from.minwage.monthly,
         median_net = median.net.income.monthly,
         poverty = poverty.threshold.monthly) %>% 
  #sort by median income
  arrange(median_net) %>%
  #convert country to factor with levels according to median
  mutate(country = factor(country, levels = country))


### 097 Handlebar chart: Minimum wage vs median wage vs. poverty line ####
######################################################################

#Set colors
cols = c(dpov = dw_info[3], dmed = dw_info[1], minwage = dw_info[2])
## Make chart
ggplot(d, aes(y = country)) +
  #Line from median income to minimum wage
  geom_segment(aes(x=median_net, xend = minwage_net, y = country, yend = country), color = cols[2], size = 3) +
  #Point for median income
  geom_point(aes(x = median_net), size = 10, color = cols[2]) +
  #Line from poverty threshold to minimum wage
  geom_segment(aes(x=poverty, xend = minwage_net, y = country, yend = country), color = cols[1], size = 3) +
  #Point for poverty threshold
  geom_point(aes(x = poverty), size = 10, color = cols[1]) +
  #Point for minimum wage
  geom_point(aes(x = minwage_net), size = 10, color = cols[3]) +
  theme_dw()
ggsave("plots/original/minwage_median_handlebar_circles.svg", device = "svg", scale = 10, width= 50, height= 60, units="mm")


### 098 Strip plot: Percent distance from poverty threshold ####
############################################################

#Pick countries to highlight
highlight = c("United Kingdom", "Romania", "Portugal", "Spain","Germany", "Latvia")
#Make temporary dataset: Calculate distance from poverty, whether to highlight the country and convert country to character vector
tmp = d %>% mutate(dist_poverty= (minwage_net / poverty) - 1,
                   group = ifelse(country %in% highlight,"col","grey"),
                   country = as.character(country))
##Make chart
ggplot(tmp, aes(y = dist_poverty, x = 1)) +
  #line for poverty threshold
  geom_hline(yintercept = 0, color = dw_info[5], size = 1) +
  #grey strips
  geom_segment(aes(x=1, xend = 2, y = dist_poverty, yend = dist_poverty),
               color = dw_grey[12], size = 0.5) +
  #highlighted strips
  geom_segment(data = tmp %>% filter(group == "col"),
               aes(x=1, xend = 2, y = dist_poverty, yend = dist_poverty), color = dw_info[2], size = 2) +
  #annotate highlighted strips
  geom_text(aes(x = 2, y = dist_poverty, label = ifelse(group == "col",country,"")), size = 25, hjust = 0, nudge_x = 0.25) +
  #set limits and breaks for y axis
  scale_x_continuous(limits = c(0,3.5)) +
  scale_y_continuous(limits = c(-0.15,0.8), labels = scales::percent_format(accuracy = 1)) +
  theme_dw()
ggsave("plots/original/minwage_strip_relative_poverty.svg", device = "svg", scale = 10, width= 70, height= 80, units="mm")