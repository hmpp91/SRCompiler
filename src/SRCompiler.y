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

%token tkInit tkDT tkComa 
%token tkIf tkElse tkNot tkOr tkThen tkAnd
%token tkT
%token tkGraph 
%token tkBuiltin

%token id id2 
%token opas opmul oprel opExp
%token numentero numreal pari pard
%token pyc coma dosp
%token lbra
%token rbra
%token asig
%token tkfloat tkint

%{

const int ERRYADECL=1,ERRNODECL=2,ERRTIPOS=3,ERRNOSIMPLE=4,ERRNOENTERO=5;

#define YYMAXDEPTH 31000
#define YYINITDEPTH 30000

#include <sstream>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <iostream>
#include <map>
#include <fstream>
#include <algorithm>

const char* LOGO = 
"                      ////&&&&               \n \
               //////%&&&////#&&&&%         \n \
            ////.&&&&&&../////////&&&%      \n \
          ./// &&&(      ///    ///* &&/    \n \
         ///   &&&       ///    ////  (&&   \n \
        *//     &&&&     /////////.    &&&  \n \
        ///        &&&&  /////*         &&  \n \
        ///           &&&/// ///,       &&  \n \
        (//           &&&///  ////     /&&  \n \
         ///          &&&///    ///   /&&   \n \
          ///%&&&    &&& ///     ///.&&&    \n \
            ///(&&&&&&&  ///      (&&&      \n \
               /////     ///   &&&&         \n \
                   //////&&&&&/             \n";

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

A   : id { YValues.push_back($1.lexema); } pari tkT pard asig id pari tkT opas tkDT pard opas pari Op  {
            char prefix = 'd';
            std::string varName { $1.lexema };
            varName = prefix + varName;
            DValues[varName] = $15.lexema; 
    } pard opmul tkDT A{};
    | tkInit id asig Op {
        InitValues[$2.lexema] = atof($4.lexema);
    } A{};  
    | id asig Op { 
        if ($3.tipo == REAL || $3.tipo == ENTERO) {
            ParamValues[$1.lexema] = atof($3.lexema);
        } else {
            BValues[$1.lexema] = $3.lexema;
        }
    } A{ };
    | {};

// Input parameters of Builtins
OpFparams : F {
            $$.lexema = $1.lexema;
        };
        | F tkComa OpFparams
        {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
        };
        | F pyc OpFparams
        {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
        };

OpFpars : pari OpFparams pard {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
        };  

OpBuiltin : tkBuiltin OpBuiltin {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
          };
        | tkBuiltin OpFpars 
        {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
        };
        | tkBuiltin  
        {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, "(");
            $$.lexema = strcat($$.lexema, ")");
        };

// Logical Builtins 
OpIfparams1 : pari F oprel OpIfparams1 {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
        };
           | F pard oprel OpIfparams1 {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
            $$.lexema = strcat($$.lexema, $4.lexema);
        };
           | F pard OpIfparams2 {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
        };
           | F oprel OpIfparams1 {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, $3.lexema);
        };
           | F OpIfparams2 {
            $$.lexema = $1.lexema;
            $$.lexema = strcat($$.lexema, $2.lexema);
        };

OpIfparams2 : tkThen F tkElse F {
            std::stringstream ss;
            ss << "," << $2.lexema << "," << $4.lexema;
            $$.lexema = strdup(ss.str().c_str());
        };

OpIf        : tkIf OpIfparams1 {
            $$.lexema = strcat($$.lexema,  "ELSE(");
            $$.lexema = strcat($$.lexema, $2.lexema);
            $$.lexema = strcat($$.lexema, ")");
        };

// -----
Op     : pari Op pard arith { 
            std::stringstream ss;
            ss << $1.lexema << " " << $2.lexema << " " << $3.lexema << " " << $4.lexema;
            $$.lexema = strdup(ss.str().c_str()); 
       };
       | pari Op pard {
            std::stringstream ss;
            ss << $1.lexema << " " << $2.lexema << " " << $3.lexema;
            $$.lexema = strdup(ss.str().c_str());
       };
       | F arith {
            std::stringstream ss;
            ss << $1.lexema << " " << $2.lexema;
            $$.lexema = strdup(ss.str().c_str());
       }; 
       | F {
            std::stringstream ss;
            ss << $1.lexema;
            $$.lexema = strdup(ss.str().c_str());
       };

arith  : opas Op  {
            std::stringstream ss;
            ss << $1.lexema << " " << $2.lexema;
            $$.lexema = strdup(ss.str().c_str());
       }; 
       | opmul Op {
            std::stringstream ss;
            ss << $1.lexema << " " << $2.lexema;
            $$.lexema = strdup(ss.str().c_str());
       };
       | OpExpo   {
            std::stringstream ss;
            ss << $1.lexema;
            $$.lexema = strdup(ss.str().c_str());
       };

OpExpo : opExp Op {
            std::stringstream ss;
            ss << $1.lexema << " " << $2.lexema;
            $$.lexema = strdup(ss.str().c_str()); };
       | opExp { $$.tipo = $1.tipo; };

F   : numentero { $$.tipo = ENTERO; };
    | numreal   { $$.tipo = REAL; };
    | opas F    { $$.lexema = $1.lexema;
                 $$.lexema = strcat($$.lexema, $2.lexema);
                };
    | OpBuiltin { $$.lexema = $1.lexema; }; 
    | OpIf      { $$.lexema = $1.lexema; }; 
    | id      { $$.lexema = $1.lexema; }; 
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
        
     //exit(1);
}

int yyerror(char *s)
{
    std::cout << "Error from yyerror: " << s << "\n";
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
            buffer.replace(buffer.find(" NOT "), 5, " !");
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

    writer << "source('" + fileName.substr( 0, fileName.length() - 8 ).substr( fileName.find_last_of("/")+1 ) + "_functions.R" + "')\n";
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
            fclose(fent) ;
            writeOutputFile(fileName);
            std::cout << LOGO << "\n";
            std::cout << "Translation completed! Thanks for using SRCompiler!\n\n";
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
