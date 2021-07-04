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


using namespace std;

#include "TablaSimbolos.h"

TablaSimbolos::TablaSimbolos(TablaSimbolos *padre)
{
      this->padre = padre;
}

bool TablaSimbolos::buscarAmbito(Simbolo s)
{
     for (unsigned i=0;i<simbolos.size();i++)
       if (simbolos[i].nombre == s.nombre)
          return true;
     return false;
}

bool TablaSimbolos::anyadir(Simbolo s)
{
     if (buscarAmbito(s))  // repetido en el ámbito
       return false;
     simbolos.push_back(s);
     return true;
}

Simbolo* TablaSimbolos::buscar(string nombre)
{
     for (unsigned i=0;i<simbolos.size();i++)
       if (simbolos[i].nombre == nombre) return &(simbolos[i]);
       
     if (padre != NULL)
       return padre->buscar(nombre);
     else
       return NULL;
}
