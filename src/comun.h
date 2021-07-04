/*----------------------- comun.h -----------------------------*/
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

/* common definitions for files .l and .y*/

typedef struct {
   char *lexema;
   int nlin,ncol;
   int tipo;
   string cod;
   string prefijo;
} MITIPO;

#define YYSTYPE MITIPO

#define ERRLEXICO    1
#define ERRSINT      2
#define ERREOF       3
#define ERRLEXEOF    4

void msgError(int nerror,int nlin,int ncol,const char *s);
void errorSemantico(int nerror,char *lexema,int fila,int columna);
