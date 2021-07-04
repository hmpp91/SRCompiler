/*--------------------------------plp4.l--------------------------------------*/
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

D [0-9]
L [A-Za-z]
LD [0-9a-zA-Z_]
%{
    #include <string.h>
    #include <string>
    #include <iostream>

    using namespace std;

    #include "comun.h"
    #include "SRCompiler.tab.h"

    int ncol = 1,
        nlin = 1;

    int findefichero = 0;

    int ret(int token);

    void msgError(int nerror, int nlin, int ncol, const char *s);
%}

%x COMENTARIO

%%

%{
/* Local Code */
%}

" "                     {ncol++;}
[\t]                    {ncol++; std::cout << "Finds rubbish";}
[\n]                    {nlin++;ncol=1;}
[\r]                    {ncol=1;}
"{"                     {ncol += strlen(yytext);BEGIN(COMENTARIO);}
<COMENTARIO>[^{\n]+     {ncol += strlen(yytext);}
<COMENTARIO>\n          {nlin++;ncol=1;}
<COMENTARIO><<EOF>>     {msgError(ERRLEXEOF,-1,-1,"");}
<COMENTARIO>"}"         {ncol+=strlen(yytext); BEGIN(INITIAL);}
<COMENTARIO>[}]         {ncol += strlen(yytext);}

"("                     {return ret(pari);}
")"                     {return ret(pard);}
":"                     {return ret(dosp);}
"{"                     {return ret(lbra);}
"}"                     {return ret(rbra);}
"="                     {return ret(asig);}
";"                     {return ret(pyc);}
"^"                     {return ret(opExp);}
"<"                     {return ret(oprel);}
","                     {return ret(tkComa);}
"<="                    {return ret(oprel);}
">"                     {return ret(oprel);}
">="                    {return ret(oprel);}
"=="                    {return ret(oprel);}
"!="                    {return ret(oprel);}
"||"                    {return ret(oprel);}
"&&"                    {return ret(oprel);}
"+"                     {return ret(opas);}
"-"                     {return ret(opas);}
"*"                     {return ret(opmul);}
"/"                     {return ret(opmul);}
"t"                     {return ret(tkT);}
"dt"                    {return ret(tkDT);}

%{
/* Builtins (AKA functions) */
%}
"GRAPH"                 {return ret(tkGraph);}

%{
/* Data Builtins */
%}
"INIT"                  {return ret(tkInit);}
"ENDVAL"                {return ret(tkEndval);}
"HISTORY"               {return ret(tkHistory);}
"PREVIOUS"              {return ret(tkPrevious);}

%{
/* Logical Builtins */
%}
"IF"                    {return ret(tkIf);}
"ELSE"                  {return ret(tkElse);}
"NOT"                   {return ret(tkNot);}
"OR"                    {return ret(tkOr);}
"THEN"                  {return ret(tkThen);}
"AND"                   {return ret(tkAnd);}

%{
/* Statistical Builtins */
%}
"RANDOM"                {return ret(tkRandom);}
"NORMAL"                {return ret(tkNormal);}
"POISSON"               {return ret(tkPoisson);}
"LOGNORMAL"             {return ret(tkLognormal);}
"EXPRAND"               {return ret(tkExprand);}

%{
/* Miscellaneous Builtins */
%}
"COUNTER"               {return ret(tkCter);}
"TREND"                 {return ret(tkTrend);}

%{
/* Simulation Builtins */
%}
"TIME"                  {return ret(tkTime);}
"DT"                    {return ret(tkDiT);}
"STARTTIME"             {return ret(tkStartTime);}
"STOPTIME"              {return ret(tkStopTime);}

%{
/* Mathematical Builtins */
%}
"MAX"                   {return ret(tkMax);}
"MIN"                   {return ret(tkMin);}
"EXP"                   {return ret(tkExp);}
"ABS"                   {return ret(tkAbs);}
"LN"                    {return ret(tkLn);}
"INT"                   {return ret(tkInt);}
"LOG10"                 {return ret(tkLog);}
"MOD"                   {return ret(tkMod);}
"PERCENT"               {return ret(tkPer);}
"PI"                    {return ret(tkPi);}
"ROOTN"                 {return ret(tkRtn);}
"ROUND"                 {return ret(tkRond);}
"SAFEDIV"               {return ret(tkSfDiv);}
"SQRT"                  {return ret(tkSqrt);}

%{
/* Trigonometric Builtins */
%}
"ARCCOS"                {return ret(tkArccos);}
"ARCSIN"                {return ret(tkArcsin);}
"ARCTAN"                {return ret(tkArctan);}
"COS"                   {return ret(tkCos);}
"COSWAVE"               {return ret(tkCoswave);}
"SIN"                   {return ret(tkSin);}
"SINWAVE"               {return ret(tkSinwave);}
"TAN"                   {return ret(tkTan);}

{L}({LD})*              {return ret(id);}
{D}+                    {return ret(numentero);}
{D}+(\.){D}+            {return ret(numreal);}
.                       {msgError(ERRLEXICO,nlin,ncol,yytext);}
%%

int yywrap(void) {findefichero=1; return 1;}
 
int ret(int token)
{
    yylval.lexema=strdup(yytext);
    yylval.nlin=nlin;
    yylval.ncol=ncol;
    ncol +=(strlen(yytext));
    return(token);
}
