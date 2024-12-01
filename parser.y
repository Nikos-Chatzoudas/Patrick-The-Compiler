%{
/* Header section - include necessary C libraries */
#include <stdio.h>
#include <stdlib.h>

/* Function declarations */
void yyerror(const char *s);
int yylex(void);

/* Track line numbers for error reporting */
extern int yylineno;
%}

/* Define the possible types our grammar can work with */
%union {
    int int_val;        /* For integer values */
    double float_val;   /* For floating point values */
    char *id;          /* For variable names */
    char char_val;      /* For character values */
    char *str_val;     /* For string values */
}

/* Token declarations - define all tokens the lexer can return */
%token <int_val> INT_NUMBER     /* Integer numbers like 42 */
%token <float_val> FLOAT_NUMBER /* Float numbers like 3.14 */
%token <id> IDENTIFIER         /* Variable names like x, y, count */
%token <str_val> STRING_LITERAL /* String literals like "hello" */
%token INT FLOAT CHAR            /* int and float keywords */
%token PLUS MINUS MULTIPLY DEVIDE    /* + and - operators */
%token SEMICOLON             /* ; symbol */
%token ASSIGN                /* = symbol */
%token PRINT                 /* print keyword */
%token LPAREN RPAREN        /* ( and ) symbols */
%token LCURLY RCURLY        /* { and } symbols */
%token <char_val> CHAR_LITERAL /* Char literal like 'a' */

/* Define operator precedence (lower = higher precedence) */
%left PLUS MINUS
%left MULTIPLY DEVIDE

/* Define the types for expressions */
%type <int_val> int_expr
%type <float_val> float_expr
%type <float_val> expr      /* Default expression type is float for mixed operations */

%%
/* Grammar rules section */

/* A program is a list of statements */
program:
    /* empty program */
    | program statement    /* A program followed by another statement */
    ;

/* A statement can be a declaration, assignment, print, or expression */
statement:
    declaration           /* int x; or float x; */
    | assignment         /* x = 42; or x = 3.14; */
    | print_stmt         /* print(expr); */
    | expr SEMICOLON     /* 1 + 2; or 3.14 + 2.5; */
    | int_expr SEMICOLON /* Integer-only expression */
    ;

/* Print statement: print(expr); */
print_stmt:
    PRINT LPAREN expr RPAREN SEMICOLON {
        printf("%g\n", $3);
    }
    | PRINT LPAREN int_expr RPAREN SEMICOLON {
        printf("%d\n", $3);
    }
    | PRINT LPAREN CHAR_LITERAL RPAREN SEMICOLON {
        printf("%c\n", $3);
    }
    | PRINT LPAREN STRING_LITERAL RPAREN SEMICOLON {
        printf("%s\n", $3);
        free($3);  /* Free the allocated string */
    }
    ;

/* Variable declaration: "int x;" or "float x;" or "int x = 1;" */
declaration:
    INT IDENTIFIER SEMICOLON {
        printf("Declared integer variable: %s\n", $2);
        free($2);
    }
    | FLOAT IDENTIFIER SEMICOLON {
        printf("Declared float variable: %s\n", $2);
        free($2);
    }
    | CHAR IDENTIFIER SEMICOLON {
        printf("Declared char variable: %s\n", $2);
        free($2);
    }
    | INT IDENTIFIER ASSIGN int_expr SEMICOLON {
        printf("Declared and initialized integer variable %s with value %d\n", $2, $4);
        free($2);
    }
    | FLOAT IDENTIFIER ASSIGN float_expr SEMICOLON {
        printf("Declared and initialized float variable %s with value %g\n", $2, $4);
        free($2);
    }
    | CHAR IDENTIFIER ASSIGN CHAR_LITERAL SEMICOLON {
        printf("Declared and initialized char variable %s with value '%c'\n", $2, $4);
        free($2);
    }
    ;

/* Variable assignment: "x = 42;" or "x = 3.14;" */
assignment:
    IDENTIFIER ASSIGN expr SEMICOLON {
        printf("Assigned to %s\n", $1);
        free($1);
    }
    | IDENTIFIER ASSIGN CHAR_LITERAL SEMICOLON {
        printf("Assigned char '%c' to %s\n", $3, $1);
        free($1);
    }
    | IDENTIFIER ASSIGN STRING_LITERAL SEMICOLON {
        printf("Assigned string \"%s\" to %s\n", $3, $1);
        free($1);
        free($3);
    }
    ;

/* Expression rules for mixed arithmetic */
expr:
    float_expr {
        $$ = $1;
    }
    | expr PLUS expr {
        $$ = $1 + $3;
    }
    | expr MINUS expr {
        $$ = $1 - $3;
    }
    | expr MULTIPLY expr {
        $$ = $1 * $3;
    }
    | expr DEVIDE expr {
        $$ = $1 / $3;
    }
    | LPAREN expr RPAREN {
        $$ = $2;  /* Handle parenthesized expressions */
    }
    ;

/* Integer-specific expressions */
int_expr:
    INT_NUMBER {
        $$ = $1;
    }
    | int_expr PLUS int_expr {
        $$ = $1 + $3;
    }
    | int_expr MINUS int_expr {
        $$ = $1 - $3;
    }
    | int_expr MULTIPLY int_expr {
        $$ = $1 * $3;
    }
    | int_expr DEVIDE int_expr {
        if ($3 == 0) {
            yyerror("Division by zero");
            $$ = 0;
        } else {
            $$ = $1 / $3;
        }
    }
    | LPAREN int_expr RPAREN {
        $$ = $2;  /* Handle parenthesized expressions */
    }
    ;

/* Float-specific expressions */
float_expr:
    FLOAT_NUMBER {
        $$ = $1;
    }
    ;

%%

/* C code section */

/* Error handling function */
void yyerror(const char *s) {
    fprintf(stderr, "Error at line %d: %s\n", yylineno, s);
}

/* Main function - entry point of the parser */
int main() {
    int result = yyparse();
    return result;
}
