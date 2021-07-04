OPTS=-Wall -g -Wno-write-strings -Wno-unused-function -Wno-sign-compare -std=c++20
OBJS=lex.yy.o SRCompiler.tab.o TablaSimbolos.o
CC=g++ 

SRCompiler: $(OBJS)
	$(CC) $(OPTS) $(OBJS) -o SRCompiler

lex.yy.o: lex.yy.c comun.h SRCompiler.tab.h
	$(CC) $(OPTS) -c lex.yy.c

SRCompiler.tab.o: SRCompiler.tab.c lex.yy.c comun.h
	$(CC) $(OPTS) -c SRCompiler.tab.c

TablaSimbolos.o: TablaSimbolos.cc TablaSimbolos.h
	$(CC) $(OPTS) -c TablaSimbolos.cc

lex.yy.c : SRCompiler.l comun.h
	flex SRCompiler.l
	
SRCompiler.tab.c SRCompiler.tab.h: SRCompiler.y lex.yy.c comun.h TablaSimbolos.h
	bison -d SRCompiler.y	


clean:
	rm -f $(OBJS)
	rm lex.*
	rm SRCompiler.tab*
	rm -f SRCompiler
