#
#  StockBroker EDA / ETL - Auxiliary functions
#
createDF <- function(fn, code = 'Unicode', nrows, ...) {
    # creates a dataframe from sqlserver exported table
    
    datapath <- paste(DATA_ORIGIN, fn, sep = '/')    
    
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

saveFile <- function(df){
    # saves table in csv format
    
    fn <- paste0(deparse(substitute(df)), '.csv')
    datapath <- paste(DATA_DIR, fn, sep = '/')    
    cat('    Saving ', fn, '\n')
    
    write.table(x = df, 
                file = datapath, 
                quote = F,
                dec = ',',
                sep = ';', 
                row.names = F,
                col.names = T,
                eol = '\n')    
}

convertDate <- function(x, cols, format = '%Y-%m-%d'){
    # converts dataframe's cols dates to 'Ymd' format
    
    if (is.character(cols)){
        dates <- which(names(x) %in% cols)        
    } else {        
        dates <- cols
    }
    
    for (i in 1:length(dates)){
        x[, dates[i]] <- as.Date(x[, dates[i]], format = format)    
    }    
    x[, dates]
}

plot_TopN <- function(x, N, tit){
    
    # function used to make barplots of Rankings during testing
    topN <-x[order(-x$Monto, x$PersApellido),][1:N,]
    
    par(mai = c(1,2,1,1))
    bp <- barplot(height = topN$Monto[order(topN$Monto, -xtfrm(topN$PersApellido))], 
                  names.arg = topN$PersApellido[order(topN$Monto, -xtfrm(topN$PersApellido))], 
                  cex.names = 0.5, 
                  horiz = T, 
                  main = NULL,
                  las = 1)
    title(main = tit, 
          cex.main = 1.25, cex.sub = 1)
    mtext(paste(paste0('Top ', N, '   '), 
                paste(FromDate, ToDate, sep = ' -- '), sep = ' '), 
          cex = 0.8)
    text(0, bp, prettyNum(topN$Monto[order(topN$Monto, -xtfrm(topN$PersApellido))],
                          big.mark = ',', decimal.mark = '.'),
         cex = 0.8, pos = 4)    
}
