setwd("/home/mahmoud/projects/codeReuse")
library(ggplot2)
library(dplyr)

#loading data
stat <- read.csv("./data/annoteStats/stat", header = TRUE, sep = ";")
stat <- stat[-c(7,8),]
row.names(stat) <- c("nmc","nblob","nsa","ncore","ncmt","na","nmcb","nblobb","nsb","ncoreb","ncmtb","nab")

#histogram
for (i in 1:nrow(stat)) {
  file <- paste("./data/annoteStats/", stat[i,1], ".hist", sep = "")
  data <- read.csv(file = file, header = FALSE, sep = ";")
  val <- data[,1]
  freq <- data[,2]
  dat <- data.frame(x = val, y = freq)
  p <- ggplot(dat) + geom_bar(mapping = aes(x = x, y = y), stat = "identity")
  path <- paste("./analysis/plots/", row.names(stat)[i], ".hist", sep="")
  tiff(path)
  print(p)
  dev.off()
}

#box plot
for (i in 1:nrow(stat)) {
  p <- data.frame(x = 1, 
                  y0 = stat[i,5],
                  y25 = stat[i,6], 
                  y50 = stat[i,7], 
                  y75 = stat[i,8], 
                  y100 = ((stat[i,8]-stat[i,6])*1.5)+stat[i,8]
                  ) %>%
    ggplot(df, mapping= aes(x)) +
      geom_boxplot(aes(ymin = y0, 
                       lower = y25,
                       middle = y50,
                       upper = y75,
                       ymax = y100),
                       stat = "identity")
  path <- paste("./analysis/plots/", row.names(stat)[i], ".box", sep="")
  tiff(path)
  print(p)
  dev.off()
}
