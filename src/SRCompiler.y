/*
    This file is part of SRCompiler.

    SRCompiler is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SRCompiler is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with SRCompiler.  If not, see <https://www.gnu.org/licenses/>.
*/

%token tkTimePar tkDT tkComa 
%token tkTime tkDiT tkStartTime tkStopTime
%token tkIf tkElse tkNot tkOr tkThen tkAnd
%token tkInit tkT
%token tkGraph 
%token tkCter tkTrend 
%token tkRandom tkNormal tkPoisson tkLognormal tkExprand 
%token tkEndval tkHistory tkPrevious
%token tkArccos tkArcsin tkArctan tkCos tkCoswave tkSin tkSinwave tkTan
%token tkMax tkMin tkExp tkAbs tkInt tkLn tkLog tkMod tkPer tkPi tkRtn tkRond tkSfDiv tkSqrt

%token id
%token opas opmul oprel opExp
%token numentero numreal pari pard
%token pyc coma dosp
%token lbra
%token rbra
%token asig
%token tkfloat tkint

%{


const int ERRYADECL=1,ERRNODECL=2,ERRTIPOS=3,ERRNOSIMPLE=4,ERRNOENTERO=5;

#include <sstream>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <iostream>
#include <map>
#include <fstream>
#include <algorithm>

using namespace std;

#include "comun.h"
#include "TablaSimbolos.h"

extern int ncol, nlin, findefichero;

extern int yylex();

extern char *yytext;
extern FILE *yyin;

int yyerror(char *s);

string operador, s1, s2, prefijo;

const std::string CSVFOLDER = "generatedCSV/";
const std::string REQDESOLVE { "if (require(deSolve) == F) {install.packages('deSolve', repos='http://cran.r-project.org');if (require(deSolve) == F) print ('Error: deSolve package is not installed on your machine')}" };
const std::string FUNCHEADER = "model<-function(t,Y,parameters,...) {";

int anidados = 0;

std::vector<std::string> CSVValues;

std::vector<std::string> YValues;
std::map<std::string, float> InitValues;
std::map<std::string, float> ParamValues;
std::map<std::string, std::string> DValues;
std::map<std::string, std::string> BValues;

TablaSimbolos *tsa = new TablaSimbolos(NULL);

%}

%%

X   : {
        $$.prefijo = ""; 
        YValues.clear(); 
        ParamValues.clear(); 
        DValues.clear();
        BValues.clear();
        InitValues.clear();
    } S {{ /* check after running the program that there isn't more tokens */
    cout << $2.cod << endl;
    int tk = yylex();
    if (tk != 0) yyerror(""); 
}} 
;

S   : A {};

A   : id { YValues.push_back($1.lexema); } pari tkT pard asig id pari tkT opas tkDT pard opas pari Op {
            char prefix = 'd';
            std::string varName { $1.lexema };
            varName = prefix + varName;
            DValues[varName] = $15.lexema; 
        } pard opmul tkDT A{};
    | tkInit id asig F A {
        InitValues[$2.lexema] = atof($4.lexema);
    };  
    | id asig Op { 
        if ($3.tipo == REAL || $3.tipo == ENTERO) {
            ParamValues[$1.lexema] = atof($3.lexema);
        } else {
            BValues[$1.lexema] = $3.lexema;
        }
    } A{};
        
    | {};


OpEndval   : tkEndval pari Op tkComa Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
            $$.lexema = strcat($$.lexema, $5.lexema);
            $$.lexema = strcat($$.lexema, $6.lexema);
        };

OpHistory  : tkHistory pari Op tkComa Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
            $$.lexema = strcat($$.lexema, $5.lexema);
            $$.lexema = strcat($$.lexema, $6.lexema);
        };  
           | tkHistory pari Op tkComa Op tkComa Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
            $$.lexema = strcat($$.lexema, $5.lexema);
            $$.lexema = strcat($$.lexema, $6.lexema);
            $$.lexema = strcat($$.lexema, $7.lexema);
            $$.lexema = strcat($$.lexema, $8.lexema);
        };

OpPrevious : tkPrevious pari Op tkComa Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
            $$.lexema = strcat($$.lexema, $5.lexema);
            $$.lexema = strcat($$.lexema, $6.lexema);
        };

// Logical Builtins 
OpIf       : tkIf Op oprel Op tkThen Op tkElse Op {
            $$.lexema = strcat($$.lexema,  "ELSE(");
            $$.lexema = strcat($$.lexema,  $2.lexema);
            $$.lexema = strcat($$.lexema,  $3.lexema);
            $$.lexema = strcat($$.lexema,  $4.lexema);
            $$.lexema = strcat($$.lexema, ",");
            $$.lexema = strcat($$.lexema, $6.lexema);
            $$.lexema = strcat($$.lexema, ",");
            $$.lexema = strcat($$.lexema, $8.lexema);
            $$.lexema = strcat($$.lexema, ")");
        };
            | tkIf oprel pari Op oprel Op pard tkThen Op tkElse Op {
            $$.lexema = strcat($$.lexema,  "ELSE(");
            $$.lexema = strcat($$.lexema,  $2.lexema);
            $$.lexema = strcat($$.lexema,  $3.lexema);
            $$.lexema = strcat($$.lexema,  $4.lexema);
            $$.lexema = strcat($$.lexema,  $5.lexema);
            $$.lexema = strcat($$.lexema,  $6.lexema);
            $$.lexema = strcat($$.lexema,  $7.lexema);
            $$.lexema = strcat($$.lexema, ",");
            $$.lexema = strcat($$.lexema, $9.lexema);
            $$.lexema = strcat($$.lexema, ",");
            $$.lexema = strcat($$.lexema, $11.lexema);
            $$.lexema = strcat($$.lexema, ")"); 
            };
            | tkIf pari Op oprel Op pard oprel pari Op oprel Op pard tkThen Op tkElse Op {
            $$.lexema = strcat($$.lexema,  "ELSE(");           
            $$.lexema = strcat($$.lexema,  $2.lexema);
            $$.lexema = strcat($$.lexema,  $3.lexema);
            $$.lexema = strcat($$.lexema,  $4.lexema);
            $$.lexema = strcat($$.lexema,  $5.lexema);
            $$.lexema = strcat($$.lexema,  $6.lexema);
            $$.lexema = strcat($$.lexema,  $7.lexema);
            $$.lexema = strcat($$.lexema,  $8.lexema);
            $$.lexema = strcat($$.lexema,  $9.lexema);
            $$.lexema = strcat($$.lexema,  $10.lexema);
            $$.lexema = strcat($$.lexema,  $11.lexema);
            $$.lexema = strcat($$.lexema,  $12.lexema);
            $$.lexema = strcat($$.lexema, ",");
            $$.lexema = strcat($$.lexema, $14.lexema);
            $$.lexema = strcat($$.lexema, ",");
            $$.lexema = strcat($$.lexema, $16.lexema);
            $$.lexema = strcat($$.lexema, ")");
            };

// Statistical Builtins 
OpRandom     : tkRandom pari Op tkComa Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
            $$.lexema = strcat($$.lexema, $5.lexema);
            $$.lexema = strcat($$.lexema, $6.lexema);
        }; 
             | tkRandom pari Op tkComa Op tkComa Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
            $$.lexema = strcat($$.lexema, $5.lexema);
            $$.lexema = strcat($$.lexema, $6.lexema);
            $$.lexema = strcat($$.lexema, $7.lexema);
            $$.lexema = strcat($$.lexema, $8.lexema);
        }; 

OpNormal     : tkNormal pari Op tkComa Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
            $$.lexema = strcat($$.lexema, $5.lexema);
            $$.lexema = strcat($$.lexema, $6.lexema);
        }; 
             | tkNormal pari Op tkComa Op tkComa Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
            $$.lexema = strcat($$.lexema, $5.lexema);
            $$.lexema = strcat($$.lexema, $6.lexema);
            $$.lexema = strcat($$.lexema, $7.lexema);
            $$.lexema = strcat($$.lexema, $8.lexema);
        }; 

OpPoisson    : tkPoisson pari Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
        }; 
             | tkPoisson pari Op tkComa Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
            $$.lexema = strcat($$.lexema, $5.lexema);
            $$.lexema = strcat($$.lexema, $6.lexema);
        }; 

OpLognormal  : tkLognormal pari Op tkComa Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
            $$.lexema = strcat($$.lexema, $5.lexema);
            $$.lexema = strcat($$.lexema, $6.lexema);
        }; 
             | tkLognormal pari Op tkComa Op tkComa Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
            $$.lexema = strcat($$.lexema, $5.lexema);
            $$.lexema = strcat($$.lexema, $6.lexema);
            $$.lexema = strcat($$.lexema, $7.lexema);
            $$.lexema = strcat($$.lexema, $8.lexema);
        }; 

OpExprand    : tkExprand pari Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
        }; 
             | tkExprand pari Op tkComa Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
            $$.lexema = strcat($$.lexema, $5.lexema);
            $$.lexema = strcat($$.lexema, $6.lexema);
        }; 

// Miscellaneous Builtins 
OpCter : tkCter pari Op tkComa Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
            $$.lexema = strcat($$.lexema, $5.lexema);
            $$.lexema = strcat($$.lexema, $6.lexema);
        };
OpTren    : tkTrend pari Op tkComa Op tkComa Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
            $$.lexema = strcat($$.lexema, $5.lexema);
            $$.lexema = strcat($$.lexema, $6.lexema);
            $$.lexema = strcat($$.lexema, $7.lexema);
            $$.lexema = strcat($$.lexema, $8.lexema);
        }; 

// Simulation Builtins 
OpTime  : tkTime {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, "(");
            $$.lexema = strcat($$.lexema, ")");
        }

// Mathematical Builtins 
OpMax   : tkMax pari Op tkComa Op pard { 
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
            $$.lexema = strcat($$.lexema, $5.lexema);
            $$.lexema = strcat($$.lexema, $6.lexema); 
        }; 
        | tkMax pari Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
        };

OpMin   : tkMin pari Op tkComa Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
            $$.lexema = strcat($$.lexema, $5.lexema);
            $$.lexema = strcat($$.lexema, $6.lexema);
        };

OpExp   : tkExp pari Op pard { 
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
        };

OpAbs   : tkAbs pari Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
        };

OpInt   : tkInt pari Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
        };

OpLn    : tkLn pari Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
        };

OpLog   : tkLog pari Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
        };

OpMod   : tkMod pari Op tkComa Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
            $$.lexema = strcat($$.lexema, $5.lexema);
            $$.lexema = strcat($$.lexema, $6.lexema);
        };

OpPer   : tkPer pari Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
        };

OpPi    : tkPi pari pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
        };

OpRtn   : tkRtn pari Op tkComa Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
            $$.lexema = strcat($$.lexema, $5.lexema);
            $$.lexema = strcat($$.lexema, $6.lexema);
        };

OpRond  : tkRond pari Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
        };

OpSfDiv : tkSfDiv pari Op tkComa Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
            $$.lexema = strcat($$.lexema, $5.lexema);
            $$.lexema = strcat($$.lexema, $6.lexema);
        };

OpSqrt  : tkSqrt pari Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
        };


// Trigonometric Builtins 
OpACos  : tkArccos pari Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
        };

OpASin  : tkArcsin pari Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
        };

OpATan  : tkArctan pari Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
        };

OpCos   : tkCos pari Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
        };

OpCW    : tkCoswave pari Op tkComa Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
            $$.lexema = strcat($$.lexema, $5.lexema);
            $$.lexema = strcat($$.lexema, $6.lexema);
        };

OpSin   : tkSin pari Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
        };

OpSW    : tkSinwave pari Op tkComa Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
            $$.lexema = strcat($$.lexema, $5.lexema);
            $$.lexema = strcat($$.lexema, $6.lexema);
        };

OpTan   : tkTan pari Op pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
        };

Op     : F opas Op { 
            std::stringstream ss;
            ss << $1.lexema << " " << $2.lexema << " " << $3.lexema;
            $$.lexema = strdup(ss.str().c_str()); };
       | OpMul{ $$.tipo = $1.tipo; };

OpMul  : F opmul Op {
            std::stringstream ss;
            ss << $1.lexema << " " << $2.lexema << " " << $3.lexema;
            $$.lexema = strdup(ss.str().c_str()); 
        };
       | OpExpo { 
            $$.tipo = $1.tipo; 
        };

OpExpo : F opExp Op {
            std::stringstream ss;
            ss << $1.lexema << " " << $2.lexema << " " << $3.lexema;
            $$.lexema = strdup(ss.str().c_str()); };
       | F{ $$.tipo = $1.tipo; };

F   : numentero { $$.tipo = ENTERO; };
    | numreal   { $$.tipo = REAL; };
    | opas F    { $$.lexema = $1.lexema; };
    | OpEndval  { $$.lexema = $1.lexema; };
    | OpHistory { $$.lexema = $1.lexema; };
    | OpPrevious{ $$.lexema = $1.lexema; };
    | OpRandom  { $$.lexema = $1.lexema; };
    | OpMax     { $$.lexema = $1.lexema; };
    | OpMin     { $$.lexema = $1.lexema; };
    | OpExp     { $$.lexema = $1.lexema; };
    | OpAbs     { $$.lexema = $1.lexema; };
    | OpInt     { $$.lexema = $1.lexema; };
    | OpLn      { $$.lexema = $1.lexema; };
    | OpLog     { $$.lexema = $1.lexema; };
    | OpMod     { $$.lexema = $1.lexema; };
    | OpPer     { $$.lexema = $1.lexema; };
    | OpPi      { $$.lexema = $1.lexema; };
    | OpRtn     { $$.lexema = $1.lexema; };
    | OpRond    { $$.lexema = $1.lexema; };
    | OpSfDiv   { $$.lexema = $1.lexema; };
    | OpSqrt    { $$.lexema = $1.lexema; };
    | OpACos    { $$.lexema = $1.lexema; };
    | OpASin    { $$.lexema = $1.lexema; };
    | OpATan    { $$.lexema = $1.lexema; };
    | OpCos     { $$.lexema = $1.lexema; };
    | OpCW      { $$.lexema = $1.lexema; };
    | OpSin     { $$.lexema = $1.lexema; };
    | OpSW      { $$.lexema = $1.lexema; };
    | OpTan     { $$.lexema = $1.lexema; };
    | OpCter    { $$.lexema = $1.lexema; };
    | OpIf      { $$.lexema = $1.lexema; };
    | OpTime    { $$.lexema = $1.lexema; };
    | id        { $$.lexema = $1.lexema; };
    | pari Op pard { 
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);};

%%

void errorSemantico(int nerror,char *lexema,int fila,int columna)
{
    fprintf(stderr,"Semantic error (%d,%d): in '%s', ",fila,columna,lexema);
    switch (nerror) {
      case ERRYADECL: fprintf(stderr,"already exist in this context\n");
         break;
      case ERRNODECL: fprintf(stderr,"not declared\n");
         break;
      case ERRTIPOS: fprintf(stderr,"incorrect type integer/real\n");
         break;
      case ERRNOSIMPLE: fprintf(stderr,"must be integer or real\n");
         break;
      case ERRNOENTERO: fprintf(stderr,"must be integer\n");
         break;
    }
    exit(-1);
}


/// ---------- Syntactical and Lexical ERRORS ----------------------
void msgError(int nerror,int nlin,int ncol,const char *s)
{
     switch (nerror) {
         case ERRLEXICO: fprintf(stderr,"Lexical error (%d,%d): incorrect '%s' character\n",nlin,ncol,s);
            break;
         case ERRSINT: fprintf(stderr,"Syntactic error (%d,%d): in '%s'\n",nlin,ncol,s);
            break;
         case ERREOF: fprintf(stderr,"Syntactic error: unexpected EOF\n");
            break;
         case ERRLEXEOF: fprintf(stderr,"Lexical error: unexpected EOF\n");
            break;
     }
        
     exit(1);
}

int yyerror(char *s)
{
    if (findefichero) 
    {
       msgError(ERREOF,-1,-1,"");
    }
    else
    {  
       msgError(ERRSINT,nlin,ncol-strlen(yytext),yytext);
    }
    return 0;
}

void parseFile(const std::string& fileName) {
    std::ifstream file { fileName };
    std::ofstream fileWithoutGraph { fileName + ".tmp" };
    std::string buffer;

    std::ofstream fileFunctions { fileName.substr( 0, fileName.length() - 4 ) + "_functions.R" };
    fileFunctions << "input.Data <- c()" << "\n";

    CSVValues.clear();

    while (getline(file, buffer)) {
        if (buffer.find("OR") != std::string::npos)
        {
            buffer.replace(buffer.find(" OR "), 4, " || ");
        }
        if (buffer.find("NOT") != std::string::npos)
        {
            buffer.replace(buffer.find(" NOT"), 4, " !");
        }
        if (buffer.find(" AND ") != std::string::npos)
        {
            buffer.replace(buffer.find(" AND "), 5, " && ");
        }

        if (buffer.find("GRAPH") == std::string::npos) {
            fileWithoutGraph << buffer <<"\n";
        }
        else {
            size_t position = buffer.find_first_of("="); 

            std::string varName = buffer.substr(0, position-1);

            std::ofstream fileGraph { fileName.substr( 0, fileName.length() - 4 ) + "_Data_" + varName + ".csv"};

            CSVValues.push_back(varName);

            getline(file, buffer);

            size_t firstPos = buffer.find_first_not_of("(");
            size_t commaPos = buffer.find_first_of(",");
            size_t lastPos  = buffer.find_first_of(")", commaPos + 1);

            fileGraph << "t," << varName << "\n";

            fileFunctions << "temp <- read.csv(" << "'" << fileName.substr( fileName.find_last_of("/")+1, fileName.find_last_of(".") - fileName.find_last_of("/")-1 ) + "_Data_" + varName + ".csv" << "')" << "\n";
            fileFunctions << "temp <- list(" + varName + " = temp)" << "\n";
            fileFunctions << "input.Data <- c(input.Data, temp)" << "\n"; 
            
            while (firstPos != std::string::npos && lastPos != std::string::npos ) {
                std::string firstColumn  = buffer.substr(firstPos, commaPos - firstPos);
                std::string secondColumn = buffer.substr(commaPos+1, lastPos - commaPos - 1);

                fileGraph << firstColumn << "," << secondColumn << "\n";

                buffer.erase(buffer.begin(), buffer.begin() + lastPos);

                firstPos = buffer.find_first_of("(") + 1;
                commaPos = buffer.find_first_of(",", firstPos);
                lastPos  = buffer.find_first_of(")", commaPos);

            }
             
            fileGraph.close();
        }
    }

    fileFunctions << "rm(temp)" << "\n" << "\n"; 
    std::ifstream file2 { "src/functions.R" };
    while (getline(file2, buffer)) {
            fileFunctions << buffer <<"\n";
    }

    fileFunctions.close();
    fileWithoutGraph.close();
    file.close();
}

void
writeOutputFile(const std::string& fileName) {
    std::ofstream writer { fileName.substr( 0, fileName.length() - 8 ) + ".R" };

    writer << REQDESOLVE << "\n";
    writer << FUNCHEADER << "\n";

    writer << "\n\tTime <<- t\n\n";

    for (const std::string& Yv : YValues) {
        writer << "\t" << Yv << " <- Y['" << Yv << "']\n";
    }

    writer << "\n";

    for (std::map<string, float>::iterator i = ParamValues.begin(); i != ParamValues.end(); ++i) {
        writer << "\t" << i->first << " <- parameters['" << i->first << "']\n";
    }

    writer << "\n";

    for (const std::string& CSV : CSVValues) {
        writer << "\t" << CSV << " <- inputData(t, '" << CSV << "')\n";
    }

    writer << "\n";

    for (std::map<string, std::string>::iterator i = BValues.begin(); i != BValues.end(); ++i) {
        writer << "\t" << i->first << " <- " << i->second << "\n";
    }

    writer << "\n";

    for (std::map<string, std::string>::iterator i = DValues.begin(); i != DValues.end(); ++i) {
        writer << "\t" << i->first << " <- " << i->second << "\n";
    }

    writer << "\n";

    writer << "\tlist(c(";

    for (std::map<string, std::string>::iterator i = DValues.begin(); i != DValues.end();) {
        writer << i->first;

        if (++i != DValues.end()) writer << ", ";
    }

    writer << "))\n";

    writer << "}\n";

    writer << "##########################################\n"; 
    writer << "##########################################\n";
    writer << "\n";

    writer << "parms <- c(";

    for (std::map<string, float>::iterator i = ParamValues.begin(); i != ParamValues.end();) {
        writer << i->first << " = " << i->second;

        if (++i != ParamValues.end()) writer << ", ";
    }

    writer <<")\n";

    writer << "Y <- c(";

    for (std::map<string, float>::iterator i = InitValues.begin(); i != InitValues.end();) {
        writer << i->first << " = " << i->second;

        if (++i != InitValues.end()) writer << ", ";
    }

    writer << ")\n\n";

    writer << "source('" + fileName.substr( fileName.find_last_of("/")+1, fileName.find_last_of(".") - fileName.find_last_of("/")-1 ) + "_functions.R" + "')\n";
    writer << "DT <- 0.25\n";
    writer << "time <- seq(0.001,100,DT)\n";
    writer << "out <- ode(func=model,y=Y,times=time,parms=parms,method='euler')\n";
    writer << "plot(out)\n";

    writer.close();
}

int main(int argc,char *argv[])
{
    FILE *fent;

    if (argc==2)
    {
        std::string fileName { argv[1] };
        fileName += ".tmp";

        parseFile(std::string(argv[1]));

        fent = fopen(fileName.c_str(),"rt");
        if (fent)
        {
            yyin = fent;
            yyparse();
            fclose(fent);
            writeOutputFile(fileName);
        }
        else
            fprintf(stderr,"Cannot open the file\n");
    }
    else
        fprintf(stderr,"Use: example <name of file>\n");

    std::string fileName { argv[1] };

    fileName += ".tmp";

    std::remove(fileName.c_str());
}
