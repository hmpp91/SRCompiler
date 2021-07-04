inputData <- function(x,name,datalist=input.Data) {
	df=datalist[[name]]
	minT <- min(df[,1],na.rm=T)
	maxT <- max(df[,1],na.rm=T)
	if (x < minT | x > maxT) {
		l <- lm(get(colnames(df)[2])~poly(get(colnames(df)[1]),3),data=df)
		do <- data.frame(x); colnames(do) <- colnames(df)[1]
		o <- predict(l,newdata=do)[[1]]	} else {
	t1 <- max(df[which(df[,1] <= x),1])
	t2 <- min(df[which(df[,1] >= x),1])
	if (t1 == t2) {
		o <- df[t1,2]}
	else {
		w1=1/abs(x-t1);w2=1/abs(x-t2)
	o <- ((df[which( df[,1] == t1),2]*w1)+(df[which( df[,1] == t2),2]*w2)) / (w1+w2) } }
  o }

# DATA FUNCTIONS
#----------------
HISTORY <- function(x, y) 
{ 
    if( y >= 1 )
    {
        return(x[y])
    }
    else
    {
        return(0)
    }
}
#----------------
PREVIOUS <- function(x, y=0)
{
    if (Time-1 <= 0 )
    {
        return(y)     
    }
    else
    { 
        return(x[Time-1])
    }
}
#----------------
INIT <- function(x)
{
    return (x[1])
}

# SIMULATION FUNCTIONS
TIME <- function(){ return(Time) }

# LOGICAL FUNCTIONS
IFELSE <- function(x,y,z) { ifelse(x,y,z) }

# STATISTICAL FUNCTIONS
#----------------
RANDOM <- function(x,y,z=1) { runif(z,x,y)}
#----------------
NORMAL <- function(x,y,z=1) { rnorm(z,x,y) }
#----------------
POISSON <- function(y=1,x)  { rpois(x,y) }
#----------------
LOGNORMAL <- function(x,y,z=1) { rlnorm(z,x,y) }
#----------------
EXPRAND <- function (x,y=1) { rexp(y,x) }

# MISCELLANEOUS FUNCTIONS
#----------------
COUNTER <- function(x,y) {
    if (Time == time[1]) COUNTER_TEMP <<- x
    if (!exists('COUNTER_TEMP')) COUNTER_TEMP <<- x
    else COUNTER_TEMP <<- COUNTER_TEMP  + 1
    if (COUNTER_TEMP == y) COUNTER_TEMP  <<- x
    return(COUNTER_TEMP)}
#----------------
TREND <- function(x,y,z=0) {
    if (!exists('AVERAGE_INPUT')) AVERAGE_INPUT <<- z
    CHANGE_IN_AVERAGE <- (x - AVERAGE_INPUT) / y
    AVERAGE_INPUT <<- AVERAGE_INPUT + (DT * CHANGE_IN_AVERAGE)
    TREND_IN_INPUT <- (x - AVERAGE_INPUT) / (AVERAGE_INPUT * y)
    if (Time == time[length(time)]) rm(AVERAGE_INPUT,envir=environment(TREND))
    TREND_IN_INPUT}

# MATHEMATICAL FUNCTIONS
#----------------
MOD <- function(x,y) {	x %% y }
#----------------
MAX <- function(x,y) { max(c(x,y)) }
#----------------
MIN <- function(x,y) { min(c(x,y)) }
#----------------
EXP <- function(x) { exp(x) }
#----------------
ABS <- function(x) { abs(x) }
#----------------
LN <- function(x) { log(x) }
#----------------
LOG10 <- function(x) { log10(x) }
#----------------
INT <- function(x) { as.integer(x) }
#----------------
PERCENT <- function(x) {x*100}
#----------------
PI <- function(x) { pi }
#----------------
ROOTN <- function(x,y) { x^(1/round(y)) }
#----------------
ROUND <- function(x) { round(x) }
#----------------
SQRT <- function(x) { sqrt(x) }

# TRIGONOMETRIC FUNCTIONS
#----------------
SINWAVE <- function(x,y) { x * sin(2 * pi * Time / y) }
#----------------
COSWAVE <- function(x,y) { x * cos(2 * pi * Time / y) }
#----------------
SIN <- function(x) { sin(x) }
#----------------
COS <- function(x) { cos(x) }
#----------------
TAN <- function(x) { tan(x) }
#----------------
ARCCOS <- function(x) { acos(x) }
#----------------
ARCSIN <- function(x) { asin(x) }
#----------------
ARCTAN <- function(x) { atan(x) }

