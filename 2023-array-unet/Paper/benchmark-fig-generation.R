library(dplyr)
library(ggplot2)

# Terrible R code but gets the job done.

data.file <- "./Raw Performance Numbers.txt"
data <- as.matrix(read.csv(data.file, header = FALSE, sep = " "))

times <- c()
sources <- c()
for (i in (1:nrow(data))) {
    for (j in (2:ncol(data))) {
        sources <- c(sources, as.character(data[i, 1]))
        times <- c(times, data[i, j])
    }
}

df <- data.frame(time = as.numeric(times), source = sources)

orig_sources <- c("Dyalog", "Co-dfns(CPU)", "PyTorch(CPU)", "Co-dfns(GPU)", "PyTorch(SMP)", "PyTorch(GPU)")
colours <- c("#fc9732", "#b8cae6", "#e65c73", "#4772b3", "#a62137", "#4d000d")
df %>% group_by(source) %>%
    summarise(meant = mean(time), min = min(time), max = max(time)) %>%
    ggplot(aes(x = reorder(source, meant), y = meant, min = min, max = max, nudge = max - min)) +
    geom_col(aes(fill = source), show.legend = FALSE) +
    geom_pointrange(aes(ymin = min, ymax = max)) +
    geom_errorbar(aes(ymin = min, ymax = max), width = .3) +
    geom_text(aes(label = round(meant, 2)), nudge_y = 6, size = 8) +
    coord_flip() +
    theme_bw() +
    theme(text = element_text(size = 20)) +
    ggtitle("Execution time of a forward and backward pass in several computational models.") +
    xlab("Computation model") +
    ylab("Execution time (s)") +
    scale_fill_manual(values = colours, limits = orig_sources)
    # scale_y_continuous(trans = "log2", breaks = c(2, 4, 8, 16, 32, 64))
    # stat_summary(geom="text", fun.y = median, aes(label = sprintf("%2.2f", 2^..y..)), position=position_nudge(y=.2))
