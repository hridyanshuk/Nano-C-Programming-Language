%{
	#include <stdio.h>
	#include <string.h>
	#include "AS6_23_translator.h"
	#include "AS6_23.tab.h"
    extern YYSTYPE yylval;
    extern int line;
    int line = 1;
%}

%option noyywrap
%option yylineno

LETTER          [a-zA-Z]
DIGIT           [0-9]
NON_ZERO        [1-9]
DIGIT_SEQ       {DIGIT}{DIGIT}*
ESCAPE_SEQ      "\\\'"|"\\\""|"\\\?"|"\\\\"|"\\a"|"\\b"|"\\f"|"\\n"|"\\r"|"\\t"|"\\v"
C_CHAR          [^\'\\\n]|{ESCAPE_SEQ}
S_CHAR          [^\"\\\n]|{ESCAPE_SEQ}
CHAR_SEQ        {C_CHAR}{C_CHAR}*
STRING_SEQ      {S_CHAR}{S_CHAR}*

IDENTIFIER      ({LETTER}|"_")({LETTER}|{DIGIT}|"_")*

FRAC            {DIGIT_SEQ}\.|\.{DIGIT_SEQ}|{DIGIT_SEQ}\.{DIGIT_SEQ}
INT_CONST       {NON_ZERO}{DIGIT}*|"0"+
CHAR_CONST      \'{CHAR_SEQ}\'

STRING          \"{STRING_SEQ}\"|\"\"
COMMENT_LINE    "//".*
COMMENT_MULTI   "/*"([^*]|\*+[^/*])*\**(\*"/")? 
WS              [ \t]
NEWLINE         [\n]

%%

{COMMENT_LINE}          { /*printf("This single line comment will be ignored by the parser\n");*/ }
{COMMENT_MULTI}         { /*printf("This multi line comment will be ignored by the parser\n");*/  }

"if"                    { return IF;       }
"for"                   { return FOR;      }
"int"                   { return INT;      }
"else"                  { return ELSE;     }
"char"                  { return CHAR;     }
"void"                  { return VOID;     }
"return"                { return RETURN;   }
"->"                    { return ARROW;      }
"<="                    { return LTE;      }
">="                    { return GTE;      }
"=="                    { return EQ;       }
"!="                    { return NEQ;      }
"&&"                    { return AND;      }
"||"                    { return OR;       }


"["                     { return SQUARE_O;   }
"]"                     { return SQUARE_C;  }
"("                     { return BRACKET_O;   }
")"                     { return BRACKET_C;  }
"{"                     { return CURLY_O;  }
"}"                     { return CURLY_C; }

";"                     { return SEMICOLON; }

"&"                     { return AMP;       }
"*"                     { return MUL;       }
"+"                     { return PLUS;       }
"-"                     { return MINUS;       }
"~"                     { return NEG;       }
"/"                     { return DIV;       }
":"                     { return COLON;     }
","                     { return COMMA;     }
"="                     { return ASSIGN;    }
"<"                     { return L_T;    }
">"                     { return G_T;    }
"%"                     { return MODULO;    }
"!"                     { return EXCLAIM;   }
"?"                     { return QUESTION;  }

{INT_CONST}             { 
	                        yylval.intval = atoi(yytext);
							return INTEGER_CONSTANT; /* Constant Rule */ 
                        }
{CHAR_CONST}            { 
	                        yylval.charval = yytext;
							return CHARACTER_CONSTANT; /* Constant Rule */ 
						}

{IDENTIFIER}            { 
	                        yylval.symp = table->lookup(yytext);
							return IDENTIFIER; /* Identifier Rule */ 
						}

{STRING}                { 
	                        yylval.charval = yytext;
							return STRING_LITERAL; /* String-literal */ 
						}

{WS}                    { /*White-space Rule*/ }

{NEWLINE}               { /* printf("\n\n============================== Parsing line %d ============================== \n\n", ++line ); */ }

%%