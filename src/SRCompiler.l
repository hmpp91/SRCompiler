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
"!"                     {return ret(oprel);}
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
"INIT"                  {return ret(tkInit);}

%{
/* Data Builtins */
%}
"ENDVAL"                {return ret(tkBuiltin);}
"HISTORY"               {return ret(tkBuiltin);}
"PREVIOUS"              {return ret(tkBuiltin);}

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
"RANDOM"                {return ret(tkBuiltin);}
"NORMAL"                {return ret(tkBuiltin);}
"POISSON"               {return ret(tkBuiltin);}
"LOGNORMAL"             {return ret(tkBuiltin);}
"EXPRAND"               {return ret(tkBuiltin);}

%{
/* Miscellaneous Builtins */
%}
"COUNTER"               {return ret(tkBuiltin);}
"TREND"                 {return ret(tkBuiltin);}

%{
/* Simulation Builtins */
%}
"TIME"                  {return ret(tkBuiltin);}
"DT"                    {return ret(tkBuiltin);}
"STARTTIME"             {return ret(tkBuiltin);}
"STOPTIME"              {return ret(tkBuiltin);}

%{
/* Mathematical Builtins */
%}
"MAX"                   {return ret(tkBuiltin);}
"MIN"                   {return ret(tkBuiltin);}
"EXP"                   {return ret(tkBuiltin);}
"ABS"                  {return ret(tkBuiltin);}
"LN"                    {return ret(tkBuiltin);}
"INT"                   {return ret(tkBuiltin);}
"LOG10"                 {return ret(tkBuiltin);}
"MOD"                   {return ret(tkBuiltin);}
"PERCENT"               {return ret(tkBuiltin);}
"PI"                    {return ret(tkBuiltin);}
"ROOTN"                 {return ret(tkBuiltin);}
"ROUND"                 {return ret(tkBuiltin);}
"SAFEDIV"               {return ret(tkBuiltin);}
"SQRT"                  {return ret(tkBuiltin);}

%{
/* Trigonometric Builtins */
%}
"ARCCOS"                {return ret(tkBuiltin);}
"ARCSIN"                {return ret(tkBuiltin);}
"ARCTAN"                {return ret(tkBuiltin);}
"COS"                   {return ret(tkBuiltin);}
"COSWAVE"               {return ret(tkBuiltin);}
"SIN"                   {return ret(tkBuiltin);}
"SINWAVE"               {return ret(tkBuiltin);}
"TAN"                   {return ret(tkBuiltin);}

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
