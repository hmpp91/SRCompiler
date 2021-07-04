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

#include <string>
#include <vector>

using namespace std;

const int ENTERO=1;
const int REAL=2;
const int CLASSFUN=3;

struct Simbolo {

  string nombre;
  int tipo;
  string nomtrad;
};


class TablaSimbolos {

   public:
   
      TablaSimbolos *padre;
      vector<Simbolo> simbolos;
   
   
   TablaSimbolos(TablaSimbolos *padre);

   bool buscarAmbito(Simbolo s); // ver si está en el ámbito actual
   
   bool anyadir(Simbolo s);
   Simbolo* buscar(string nombre);
};


