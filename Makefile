all:
	lex limbaj.l
	yacc -d limbaj.y
	gcc y.tab.c lex.yy.c -o limbaj
clean:
	rm -f *~limbaj y.tab.c y.tab.h lex.yy.c
