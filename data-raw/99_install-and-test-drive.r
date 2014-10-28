install.packages(pkgs = "~/teaching//gapminder",
                 lib = "~/resources/R/libraryDev",
                 repos = NULL,
                 type = "source")

library(gapminder, lib.loc = "~/resources/R/libraryDev")
head(gapminder)
tail(gapminder)
str(gapminder)

if (require("dplyr")) {
  gapminder
  gapminder %>%
    filter(year == 2007) %>%
    group_by(continent) %>%
    summarise(lifeExp = median(lifeExp))
}

## README.md
library(devtools)
install_github("jennybc/gapminder")

library(gapminder)

aggregate(lifeExp ~ continent, gapminder, median)

library(dplyr)
gapminder %>%
  filter(year == 2007) %>%
  group_by(continent) %>%
  summarise(lifeExp = median(lifeExp))

library(ggplot2)
ggplot(gapminder, aes(x = continent, y = lifeExp)) +
  geom_boxplot(outlier.colour = "hotpink") +
  geom_jitter(position = position_jitter(width = 0.1, height = 0), alpha = 1/4)
#ggsave("../test-drive-stripplot.png")

ggplot(subset(gapminder, continent != "Oceania"),
       aes(x = year, y = lifeExp, group = country, color = country)) +
  geom_line(lwd = 1, show_guide = FALSE) + facet_wrap(~ continent) +
  scale_color_manual(values = country_colors) +
  theme_bw() + theme(strip.text = element_text(size = rel(1.1)))
#ggsave("../test-drive-spaghettiplot.png")
