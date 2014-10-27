install.packages(pkgs = "~/teaching//gapminder",
                 lib = "~/resources/R/libraryDev",
                 repos = NULL,
                 type = "source")

library(gapminder)
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
ggsave("../test-drive-stripplot.png")
