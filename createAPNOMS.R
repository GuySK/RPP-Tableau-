
#
# StockBroker ETL - Anonymus Names for PERSONAS
#

library(stringr)

xtrAPNOM <- function(fn){
    loc <- readLines(con = fn)
    loc_nomaps <- loc[grep('DNI', loc)]
    l_nomaps <- loc_nomaps[!is.na(str_locate(loc_nomaps, ',')[,2])]
    l_nomaps <- sub(pattern = ',.+', replacement = '', x = l_nomaps)
    l_nomaps <- str_extract(string = l_nomaps, pattern = '[a-zA-Z ]+')
    l_nomaps
}

fn = '../StockBrokerData/PadronDefinitivoMunicipioCachi.csv'
cachi_ApNoms <- xtrAPNOM(fn) 
fn = '../StockBrokerData/PadronDefinitivoMunicipioCafayate.csv'
cafayate_ApNoms <- xtrAPNOM(fn)
fn = '../StockBrokerData/PadronDefinitivoMunicipioLaMerced.csv'
LaMerced_ApNoms <- xtrAPNOM(fn)
ApNoms <- c(cachi_ApNoms, cafayate_ApNoms, LaMerced_ApNoms)

if (FALSE) {
    comit <- unique(PERSONAS$ComiCodigo)
    comit_apnoms <- sample(ApNoms, length(comit), replace = F)
    comit_names <- data.frame(ComiCodigo = comit, Name = comit_apnoms, stringsAsFactors = F)
    PERSONAS_NEW <- merge(PERSONAS, comit_names, by = 'ComiCodigo')
    PERSONAS$PersApellido <- PERSONAS_NEW$Name
    rm(PERSONAS_NEW)    
}

PERSONAS$PersApellido <- sample(ApNoms, length(PERSONAS$PersApellido), replace = F)
PERSONAS$PersPorPar[is.na(PERSONAS$PersPorPar)] <- 0
# PERSONAS <- PERSONAS[, c(1, 3, 5, 46)]

