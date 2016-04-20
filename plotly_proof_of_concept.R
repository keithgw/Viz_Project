library(plotly)
library(ggplot2)

set.seed(100)
d <- diamonds[sample(nrow(diamonds), 1000),]

p <- ggplot(d, aes(x = carat, y = price)) +
    geom_point(aes(text = paste("Clarity:", clarity)), size = 4) +
    geom_smooth(aes(color = cut, fill = cut)) +
    facet_wrap(~cut)

p

(gg <- ggplotly(p))
