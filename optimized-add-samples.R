#file <- read.csv("/home/oskar/01-workspace/00-temp/bigger-input-for-imputeserver/chr1-samples", header = F, sep = "\t")

args = commandArgs(trailingOnly=TRUE)
file <- read.csv(args[1], header = T, sep = "\t")

## Assign "file" to new variables

x <- as.list(1:10)
names(x) <- paste("a", 1:length(x), sep = "")
list2env(x , envir = .GlobalEnv)

for (i in 1:10){
  x[[i]] <- file
}

file <- do.call("cbind", x)
len <- length(file)

write.table(file, file = paste(args[1], "-bigger", sep = ""), 
            quote = F, row.names = F, col.names = c(paste0("sample-", 1:len)), sep = "\t")
