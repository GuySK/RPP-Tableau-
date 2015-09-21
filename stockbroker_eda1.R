
#
# Stock Broker files - EDA 1
#


setwd("C:/Users/AAB330/Google Drive 2/Business Cases/Rosental/BI/StockBroker_code")
DATA_DIR = '../StockBrokerData'

createDF <- function(fn, code = 'Unicode', nrows, ...) {
    # creates a dataframe from sqlserver exported table
    datapath <- paste(DATA_DIR, fn, sep = '/')    
    if (missing(nrows)) 
        nrows <- length(readLines(datapath)) - 4    
    df <- read.table(file = datapath,
                     nrows = nrows,
                     header = T, 
                     sep = ';',
                     stringsAsFactors = F,
                     encoding = code, 
                     ...)
    df
}


files <- dir(DATA_DIR)
notabs <- grep(pattern = '^TIP', files)
notabs <-  c(notabs, grep(pattern = '^TP', files))
notabs <- c(notabs, c(6, 8, 9, 11, 12, 14, 16, 18, 
                      19, 20, 21, 24, 25, 26, 37, 
                      40, 42, 43, 51, 57, 58))
files <- files[-notabs]

for (i in 24:length(files)){
    dfname <- sub('\\.rpt', '', files[i])
    cat('Reading... ', dfname, '\n')
    assign(dfname, createDF(files[i]))
}

### Errores
# comitentes (??)
# oper (importación boletos)
# perfilcomitentes (omitir)
# tido (omitir)

lineInError <- tryCatch(read.table('../StockBrokerData/OPER.rpt'), 
                 error = errHandler, 
                 finally = print('Aborted.'))

msg =  "line 1234 did not have 9883 elements"

library(stringr)
errHandler <- function(e){
    # catches record format errors
    pat <- '^(line [0-9]+ did not have [0-9]+ elements)'
    if (grep(pat, e$message))
        return(as.integer(str_match(e$message, 
                                    pattern = '[0-9]+')))
    return(0)
}

pat2 <- '^(line )([0-9]+)( did not have [0-9]+ elements)'

lineInError <- tryCatch(read.table('../StockBrokerData/OPER.rpt', header = T, sep = ';'), 
                        error = errHandler, 
                        finally = print('Aborted.'))

createDF <- function(fn, code = 'Unicode', nrows, ...) {
    # creates a dataframe from sqlserver exported table
    datapath <- paste(DATA_DIR, fn, sep = '/')    
    if (missing(nrows)) 
        nrows <- length(readLines(datapath)) - 4    
    df <-  tryCatch(read.table(file = datapath,
                               nrows = nrows,
                               header = T, 
                               sep = ';',
                               stringsAsFactors = F,
                               encoding = code, ...),
                    error = errHandler,
                    finally = print('Data Frame creation aborted.')
    )
    df
}

oper <- readLines('../StockBrokerData/OPER.rpt')
library(stringr)
oper_feats <- str_count(oper, ';')
recs_in_err <- oper_feats !=  oper_feats[1]
sum(recs_in_err)
which(recs_in_err)

# This one works because fill = TRUE by default in read.csv
OPER <- read.csv('../StockBrokerData/OPER.rpt', sep = ';', stringsAsFactors = F)

# the above is the same as what we were trying but with fill = T
createDF <- function(fn, code = 'Unicode', nrows, ...) {
    # creates a dataframe from sqlserver exported table
    datapath <- paste(DATA_DIR, fn, sep = '/')    
    if (missing(nrows)) 
        nrows <- length(readLines(datapath)) - 4    
    df <- read.table(file = datapath,
                     nrows = nrows,
                     header = T, 
                     sep = ';',
                     stringsAsFactors = F,
                     encoding = code,
                     fill = T,
                     ...)
    df
}

files <- dir(DATA_DIR)
notabs <- grep(pattern = '^TIP', files)
notabs <-  c(notabs, grep(pattern = '^TP', files))
files <- files[-notabs]

for (i in 1:length(files)){
    dfname <- sub('\\.rpt', '', files[i])
    cat('Reading... ', dfname, '\n')
    assign(dfname, createDF(files[i]))
}

