CPPFLAGS = -g -ggdb


all: vaxum

SRCS=lex.yy.c main.c parser.c
OBJS=lex.yy.o util.o main.o tokens.o parser.o stack.o list.o tree.o interface.o

%.o: %.c
	$(CXX) ${CPPFLAGS} -c $< -o $@

# vaxum: vaxum.tab.c vaxum.tab.h lex.yy.c ${OBJS}
vaxum: lex.yy.c ${OBJS}
	$(CXX) ${CPPFLAGS} -o  vaxum ${OBJS} -lfl

# vaxum.tab.c vaxum.tab.h: vaxum.y
	# bison -t -d vaxum.y

lex.yy.c: vaxum.l  
	flex vaxum.l

clean:
	rm -f  vaxum.tab.{c,h} lex.yy.c vaxum vaxum.exe *.exe.stackdump vaxum2{,.exe} *.o vaxum2 vaxum2.exe *.orig
	
	
