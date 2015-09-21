
#
# Stock Broker files - ETL 1
#

cat('>>> StockBroker ETL 1. \n')

# Params
CODE_DIR       = 'C:/Users/AAB330/Google Drive 2/Business Cases/Rosental/BI/StockBroker_code' 
DATA_DIR       = '../StockBrokerData'
DATA_ORIGIN    = '../StockBroker_rar'
READ_FILES     = TRUE
SAVE_FILES     = TRUE
SAVE_ROBJS     = TRUE
SAVED_WKSP     = 'env.RData'
REPL_NUM_NA    = FALSE
FORMAT_DATES   = TRUE
CREATE_APNOMS  = TRUE
NEW_PERSONAS   = FALSE
SAVE_WORKSPACE = FALSE
LOAD_WORKSPACE = FALSE
ALL_FILES      = FALSE
FILE_LIST      = list('OPER', 'PERSONAS', 'DIVRA',                       
                      'DIVRA4', 'CUENTACORRIENTE', 
                      'COMPMOV', 'OPERICO')

# Set up
cat('>>> Parameter Settings. \n')
cat('   CODE_DIR       = ', CODE_DIR, '\n')  
cat('   DATA_DIR       = ', DATA_DIR, '\n')
cat('   DATA_ORIGIN    = ', DATA_ORIGIN, '\n')
cat('   READ_FILES     = ', READ_FILES, '\n')
cat('   SAVE_FILES     = ', SAVE_FILES, '\n')
cat('   SAVE_ROBJS     = ', SAVE_ROBJS, '\n')
cat('   SAVED_WKSP     = ', SAVED_WKSP, '\n') 
cat('   REPL_NUM_NA    = ', REPL_NUM_NA, '\n')
cat('   FORMAT_DATES   = ', FORMAT_DATES, '\n')
cat('   CREATE_APNOMS  = ', CREATE_APNOMS, '\n')
cat('   NEW_PERSONAS   = ', NEW_PERSONAS, '\n')
cat('   SAVE_WORKSPACE = ', SAVE_WORKSPACE, '\n')
cat('   LOAD_WORKSPACE = ', LOAD_WORKSPACE, '\n')
cat('   ALL_FILES      = ', ALL_FILES, '\n')
cat('\n')

setwd(CODE_DIR)

# Auxiliary functions
source('EDA_ETL_AuxFuncts.R')

# Read original files
if(READ_FILES) {
    
    cat('>>> Reading files... \n')
    fns <- sort(dir(DATA_ORIGIN))
    fns <- fns[-grep('\\.rar', fns)]
    
    if (!ALL_FILES){
        fns <- sapply(FILE_LIST, function(x) paste0(x, '.rpt'))
        cat('    Warning. A subset of files will be read. \n')
    }
    
    for (i in 1:length(fns)){
        dfname <- sub('\\.rpt', '', fns[i])
        cat('    Reading ', dfname, '\n')
        assign(dfname, createDF(fns[i]))
    }    
}

if (REPL_NUM_NA) {
    
    # OPER - Replace NAs by 0 in all numerics
    
    # OPER$OperComiCMonto[is.na(OPER$OperComiCMonto)] <- 0
    Oper_class <- sapply(X = OPER, FUN = class)
    Oper_numeric <- names(Oper_class[Oper_classes == 'numeric'])
    na_matrix    <- is.na(OPER[,Oper_numeric])
    
    for (i in 1:ncol(na_matrix)){
        OPER[na_matrix[,i], dimnames(na_matrix)[[2]][i]] <- 0
    }    
}

if (FORMAT_DATES){

    # OPER - Convert date formats
    OPER$OperInformado <- as.Date(OPER$OperInformado, format = '%Y-%m-%d')
    OPER$OperFechaVto  <- as.Date(OPER$OperFechaVto, format = '%Y-%m-%d')
    OPER$OperFecCon    <- as.Date(OPER$OperFecCon, format = '%Y-%m-%d')
    OPER$OperFecAnul    <- as.Date(OPER$OperFecAnul, format = '%Y-%m-%d')
        
    # DIVRA4 and DIVRA - 
    DIVRA[, c(6,8)] <- convertDate(DIVRA, c(6,8))
    
    
    # CUENTACORRIENTE
    CUENTACORRIENTE[, c(2,6)] <- convertDate(CUENTACORRIENTE, c(2,6))
    
    # NC y ND - COMPMOV
    comp_mov_dates <- c(4, 7, 16)
    COMPMOV[, comp_mov_dates] <- convertDate(COMPMOV, comp_mov_dates)
    
    # OPERICO
    operico_dates <- c(1)
    OPERICO[, operico_dates] <- convertDate(OPERICO, operico_dates)
}

if (CREATE_APNOMS) {
    
    cat('>>> Creating Names for PERSONAS... \n')
    source('createAPNOMS.R', local = FALSE)    

}

if (NEW_PERSONAS) {
    PERSONAS <- PERSONAS[, c('ComiCodigo', 'PersApellido')]
    PERSONAS <- unique(PERSONAS)
    saveFile(PERSONAS)
}

if (SAVE_FILES){
    
    cat('>>> Saving Files... \n')
    saveFile(OPER)
    saveFile(PERSONAS)
    saveFile(DIVRA)
    saveFile(DIVRA4)
    saveFile(CUENTACORRIENTE)
    saveFile(COMPMOV)
    saveFile(OPERICO)
    
}

if (SAVE_ROBJS) {
    
    cat('>>> Saving R Objects... \n')
    save(list = unlist(FILE_LIST), 
         file = 'DataFiles.RData')
    
}

if (SAVE_WORKSPACE){
    # Save image if needed
    save.image(SAVED_WKSP)    
}

# Load all files from a saved workspace
if (LOAD_WORKSPACE) {

    # Load all data frames
    cat('>>> Loading Workspace... \n')
    load(SAVED_WKSP)
    
}

# End of run
cat('>>> End of Run. \n')