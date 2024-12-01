# Compiler and flags
CC=gcc
CFLAGS=-Wall

# Build targets
all: patrick

# Generate parser from parser.y
parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

# Generate lexer from lexer.l
lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

# Build final executable
patrick: lex.yy.c parser.tab.c
	$(CC) $(CFLAGS) -o patrick lex.yy.c parser.tab.c

# Clean generated files
clean:
	rm -f patrick parser.tab.c parser.tab.h lex.yy.c
