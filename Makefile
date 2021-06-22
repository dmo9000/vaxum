
all: vaxum

vaxum.tab.c vaxum.tab.h: vaxum.y
	bison -d vaxum.y

lex.yy.c: vaxum.l vaxum.tab.h
	flex vaxum.l

vaxum: lex.yy.c vaxum.tab.c vaxum.tab.h
	g++ vaxum.tab.c lex.yy.c util.c -lfl -o vaxum

clean:
	rm -f  vaxum.tab.{c,h} lex.yy.c vaxum{,.exe}
	
