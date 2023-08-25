%{
#include <iostream>
#include <cstdlib>
#include <string>
#include <stdio.h>
#include <sstream>
#include "AS6_23_translator.h"

extern int yylex();
extern int yylineno;
void yyerror(string s);
extern string Type;
vector <string> allstrings;

using namespace std;
%}


%union {
  int intval;
  char* charval;
  int instr;
  sym* symp;
  symtype* symtp;
  expr* E;
  statement* S;
  Array* A;
  char unaryOperator;
} 
%token RETURN VOID CHAR FOR IF INT ELSE
%token<symp> IDENTIFIER
%token<intval> INTEGER_CONSTANT
%token<charval> CHARACTER_CONSTANT
%token<charval> STRING_LITERAL
%token SQUARE_O SQUARE_C BRACKET_O BRACKET_C CURLY_O CURLY_C
%token ARROW AMP MUL PLUS MINUS NEG EXCLAIM
%token DIV MODULO L_T G_T LTE GTE EQ NEQ AND OR
%token QUESTION COLON SEMICOLON ASSIGN COMMA

%start translation_unit

%right THEN ELSE


%type <E>
	expression
	primary_expression 
	multiplicative_expression
	additive_expression
	relational_expression
	equality_expression
	logical_AND_expression
	logical_OR_expression
	conditional_expression
	assignment_expression
	expression_statement

%type <intval> argument_expression_list


%type <A> postfix_expression
	unary_expression

%type <unaryOperator> unary_operator
%type <symp> constant initializer
%type <symp> direct_declarator init_declarator declarator
%type <symtp> pointer


%type <instr> M
%type <S> N



%type <S>  statement 
	compound_statement
	selection_statement
	iteration_statement
	jump_statement
	block_item
	block_item_list

%%

primary_expression: 
	IDENTIFIER
	{
		$$ = new expr();
		$$->loc = $1;
		$$->type = "NONBOOL";
	}
	| constant 								
	{
		$$ = new expr();
		$$->loc = $1;
	}
	| STRING_LITERAL 
	{
		$$ = new expr();
		symtype* tmp = new symtype("PTR");
		$$->loc = gentemp(tmp, $1);
		$$->loc->type->ptr = new symtype("CHAR");

		allstrings.push_back($1);
		stringstream strs;
		strs << allstrings.size()-1;
		string temp_str = strs.str();
		char* intStr = (char*) temp_str.c_str();
		string str = string(intStr);
		emit("EQUALSTR", $$->loc->name, str);
	}
	| BRACKET_O expression BRACKET_C
	{
		$$=$2;
	}
	;

constant:
	INTEGER_CONSTANT 
	{
		stringstream strs;
		strs << $1;
		string temp_str = strs.str();
		char* intStr = (char*) temp_str.c_str();
		string str = string(intStr);
		$$ = gentemp(new symtype("INTEGER"), str);
		emit("EQUAL", $$->name, $1);
	}
	
	|CHARACTER_CONSTANT 
	{
		$$ = gentemp(new symtype("CHAR"),$1);
		emit("EQUALCHAR", $$->name, string($1));
	}
	;


postfix_expression:
	primary_expression 
	{
		$$ = new Array ();
		$$->Array = $1->loc;
		$$->loc = $$->Array;
		$$->type = $1->loc->type;
	}
	|postfix_expression SQUARE_O expression SQUARE_C 
	{
		$$ = new Array();
		
		$$->Array = $1->loc;
		$$->type = $1->type->ptr;
		$$->loc = gentemp(new symtype("INTEGER"));
		
		
		if ($1->cat=="ARR") 
		{						
			
			sym* t = gentemp(new symtype("INTEGER"));
			stringstream strs;
		    strs <<size_type($$->type);
		    string temp_str = strs.str();
		    char* intStr = (char*) temp_str.c_str();
			string str = string(intStr);				
 			emit ("MUL", t->name, $3->loc->name, str);
			emit ("PLUS", $$->loc->name, $1->loc->name, t->name);
		}
 		else 
		{
			
 			stringstream strs;
		    strs <<size_type($$->type);
		    string temp_str = strs.str();
		    char* intStr1 = (char*) temp_str.c_str();
			string str1 = string(intStr1);		
	 		emit("MUL", $$->loc->name, $3->loc->name, str1);
 		}

		$$->cat = "ARR";
	}
	|postfix_expression BRACKET_O argument_expression_list BRACKET_C 
	{
		
		$$ = new Array();
		$$->Array = gentemp($1->type);
		stringstream strs;
	    strs <<$3;
	    string temp_str = strs.str();
	    char* intStr = (char*) temp_str.c_str();
		string str = string(intStr);		
		emit("CALL", $$->Array->name, $1->Array->name, str);
	}
	
	;

argument_expression_list:
	assignment_expression 
	{
		
		emit ("PARAM", $1->loc->name);
		$$ = 1;
	}
	|argument_expression_list COMMA assignment_expression 
	{
		
		emit ("PARAM", $3->loc->name);
		$$ = $1+1;
	}
	;

unary_expression:
	postfix_expression 
	{
		
		$$ = $1;
	}
	
	|unary_operator unary_expression 
	{
		
		$$ = new Array();
		switch ($1) {
			case '&':
				
				$$->Array = gentemp((new symtype("PTR")));
				$$->Array->type->ptr = $2->Array->type; 
				emit ("ADDRESS", $$->Array->name, $2->Array->name);
				break;
			case '*':
				
				$$->cat = "PTR";
				$$->loc = gentemp ($2->Array->type->ptr);
				emit ("PTRR", $$->loc->name, $2->Array->name);
				$$->Array = $2->Array;
				break;
			case '+':
				
				$$ = $2;
				break;
			case '-':
				
				$$->Array = gentemp(new symtype($2->Array->type->type));
				emit ("UMINUS", $$->Array->name, $2->Array->name);
				break;
			case '~':
				
				$$->Array = gentemp(new symtype($2->Array->type->type));
				emit ("BNOT", $$->Array->name, $2->Array->name);
				break;
			case '!':
				
				$$->Array = gentemp(new symtype($2->Array->type->type));
				emit ("LNOT", $$->Array->name, $2->Array->name);
				break;
			default:
				break;
		}
	}
	;

unary_operator:
	AMP 
	{
		
		$$ = '&';
	}
	|MUL 
	{
		$$ = '*';
	}
	|PLUS 
	{
		$$ = '+';
	}
	|MINUS 
	{
		$$ = '-';
	}
	|NEG 
	{
		$$ = '~';
	}
	|EXCLAIM 
	{
		$$ = '!';
	}
	;

multiplicative_expression:
	unary_expression 
	{
		$$ = new expr();		
		if ($1->cat=="ARR") 
		{ 
			
			$$->loc = gentemp($1->loc->type);
			emit("ARRR", $$->loc->name, $1->Array->name, $1->loc->name);		
			
		}
		else if ($1->cat=="PTR") 
		{ 
			
			$$->loc = $1->loc;
		}
		else 
		{ 
			
			$$->loc = $1->Array;
		}
	}
	|multiplicative_expression MUL unary_expression 
	{
		
		if (typecheck ($1->loc, $3->Array) ) 
		{
			
			$$ = new expr();
			$$->loc = gentemp(new symtype($1->loc->type->type));
			emit ("MUL", $$->loc->name, $1->loc->name, $3->Array->name);
		}
		
		else cout << "Type Error"<< endl;
	}
	|multiplicative_expression DIV unary_expression 
	{
		
		if (typecheck ($1->loc, $3->Array) ) 
		{
			
			$$ = new expr();
			$$->loc = gentemp(new symtype($1->loc->type->type));
			emit ("DIV", $$->loc->name, $1->loc->name, $3->Array->name);
		}
		
		else cout << "Type Error"<< endl;
	}
	|multiplicative_expression MODULO unary_expression 
	{
		
		if (typecheck ($1->loc, $3->Array) ) 
		{
			
			$$ = new expr();
			$$->loc = gentemp(new symtype($1->loc->type->type));
			emit ("MODOP", $$->loc->name, $1->loc->name, $3->Array->name);
		}
		
		else cout << "Type Error"<< endl;
	}
	;

additive_expression:
	multiplicative_expression 
	{
		
		$$=$1;
	}
	|additive_expression PLUS multiplicative_expression 
	{	
		
		if (typecheck ($1->loc, $3->loc) ) 
		{
			
			$$ = new expr();
			$$->loc = gentemp(new symtype($1->loc->type->type));
			emit ("PLUS", $$->loc->name, $1->loc->name, $3->loc->name);
		}
		
		else cout << "Type Error"<< endl;
	}
	|additive_expression MINUS multiplicative_expression 
	{
		
		if (typecheck ($1->loc, $3->loc) ) 
		{
			
			$$ = new expr();
			$$->loc = gentemp(new symtype($1->loc->type->type));
			emit ("MINUS", $$->loc->name, $1->loc->name, $3->loc->name);
		}
		
		else cout << "Type Error"<< endl;
	}
	;

relational_expression:
	additive_expression 
	{
		
		$$=$1;
	}	
	|relational_expression L_T additive_expression 
	{
		
		if (typecheck ($1->loc, $3->loc) ) 
		{
			$$ = new expr();
			$$->type = "BOOL";

			$$->truelist = makelist (nextinstr());					
			$$->falselist = makelist (nextinstr()+1);				
			emit("LT", "", $1->loc->name, $3->loc->name);			
			emit ("GOTOOP", "");									
		}
		
		else cout << "Type Error"<< endl;
	}
	|relational_expression G_T additive_expression 
	{
		
		if (typecheck ($1->loc, $3->loc) ) 
		{
			$$ = new expr();
			$$->type = "BOOL";

			$$->truelist = makelist (nextinstr());					
			$$->falselist = makelist (nextinstr()+1);				
			emit("GT", "", $1->loc->name, $3->loc->name);			
			emit ("GOTOOP", "");									
		}
		
		else cout << "Type Error"<< endl;
	}
	|relational_expression LTE additive_expression 
	{
		
		if (typecheck ($1->loc, $3->loc) ) 
		{
			$$ = new expr();
			$$->type = "BOOL";

			$$->truelist = makelist (nextinstr());
			$$->falselist = makelist (nextinstr()+1);
			emit("LE", "", $1->loc->name, $3->loc->name);
			emit ("GOTOOP", "");
		}
		
		else cout << "Type Error"<< endl;
	}
	|relational_expression GTE additive_expression 
	{
		
		if (typecheck ($1->loc, $3->loc) ) 
		{
			$$ = new expr();
			$$->type = "BOOL";

			$$->truelist = makelist (nextinstr());
			$$->falselist = makelist (nextinstr()+1);
			emit("GE", "", $1->loc->name, $3->loc->name);
			emit ("GOTOOP", "");
		}
		
		else cout << "Type Error"<< endl;
	}
	;

equality_expression:
	relational_expression 
	{
		
		$$=$1;
	}
	|equality_expression EQ relational_expression 
	{
		
		if (typecheck ($1->loc, $3->loc))         
		{
			
			convertBool2Int ($1);			
			convertBool2Int ($3);

			$$ = new expr();
			$$->type = "BOOL";

			$$->truelist = makelist (nextinstr());
			$$->falselist = makelist (nextinstr()+1);
			emit("EQOP", "", $1->loc->name, $3->loc->name);
			emit ("GOTOOP", "");
		}
		else cout << "Type Error"<< endl;
	}
	|equality_expression NEQ relational_expression 
	{
		if (typecheck ($1->loc, $3->loc) ) 
		{
			convertBool2Int ($1);
			convertBool2Int ($3);

			$$ = new expr();
			$$->type = "BOOL";

			$$->truelist = makelist (nextinstr());
			$$->falselist = makelist (nextinstr()+1);
			emit("NEOP", "", $1->loc->name, $3->loc->name);
			emit ("GOTOOP", "");
		}
		else cout << "Type Error"<< endl;
	}
	;

logical_AND_expression:
	equality_expression 
	{
		$$=$1;
	}
	|logical_AND_expression N AND M equality_expression 
	{
		convertInt2Bool($5);

		backpatch($2->nextlist, nextinstr());
		convertInt2Bool($1);

		$$ = new expr();
		$$->type = "BOOL";

		backpatch($1->truelist, $4);
		$$->truelist = $5->truelist;
		$$->falselist = merge ($1->falselist, $5->falselist);
	}
	;

logical_OR_expression:
	logical_AND_expression 
	{
		$$=$1;
	}
	|logical_OR_expression N OR M logical_AND_expression 
	{
		convertInt2Bool($5);

		backpatch($2->nextlist, nextinstr());
		convertInt2Bool($1);

		$$ = new expr();
		$$->type = "BOOL";

		backpatch ($1->falselist, $4);
		$$->truelist = merge ($1->truelist, $5->truelist);
		$$->falselist = $5->falselist;
	}
	;

M: 
	%empty
	{	
		$$ = nextinstr();
	};

N: 
	%empty 
	{ 	
		$$  = new statement();
		$$->nextlist = makelist(nextinstr());
		emit ("GOTOOP","");
	};

conditional_expression:
	logical_OR_expression 
	{
		$$=$1;
	}
	|logical_OR_expression N QUESTION M expression N COLON M conditional_expression 
	{
		$$->loc = gentemp($5->loc->type);
		$$->loc->update($5->loc->type);
		
		emit("EQUAL", $$->loc->name, $9->loc->name);
		list<int> l = makelist(nextinstr());
		emit ("GOTOOP", "");

		backpatch($6->nextlist, nextinstr());
		emit("EQUAL", $$->loc->name, $5->loc->name);
		list<int> m = makelist(nextinstr());
		l = merge (l, m);
		emit ("GOTOOP", "");

		backpatch($2->nextlist, nextinstr());
		convertInt2Bool($1);
		backpatch ($1->truelist, $4);
		backpatch ($1->falselist, $8);
		backpatch (l, nextinstr());
	}
	;

assignment_expression:
	conditional_expression 
	{
		$$=$1;
	}
	|unary_expression assignment_operator assignment_expression 
	{
		if($1->cat=="ARR") 
		{
			emit("ARRL", $1->Array->name, $1->loc->name, $3->loc->name);	
		}
		else if($1->cat=="PTR") 
		{
			emit("PTRL", $1->Array->name, $3->loc->name);	
		}
		else
		{
			emit("EQUAL", $1->Array->name, $3->loc->name);
		}
		$$ = $3;
	}
	;

assignment_operator:
	ASSIGN {}
	;

expression:
	assignment_expression 
	{
		$$=$1;
	}
	;


declaration:
	type_specifier init_declarator_list SEMICOLON {	}
	;



init_declarator_list:
	init_declarator {}
	|init_declarator_list COMMA init_declarator {}
	;

init_declarator:
	declarator {$$=$1;}
	|declarator ASSIGN initializer 
	{
		if ($3->initial_value!="") $1->initial_value=$3->initial_value;
		emit ("EQUAL", $1->name, $3->name);
	}
	;


type_specifier: 
	VOID {Type="VOID";}
	| CHAR {Type="CHAR";}
	| INT {Type="INTEGER";}
	;




declarator:
	pointer direct_declarator 
	{
		symtype * t = $1;
		while (t->ptr !=NULL) t = t->ptr;
		t->ptr = $2->type;
		$$ = $2->update($1);
	}
	|direct_declarator {}
	;


direct_declarator:
	IDENTIFIER 
	{
		$$ = $1->update(new symtype(Type));
		currentSymbol = $$;
	}
	| direct_declarator SQUARE_O assignment_expression SQUARE_C 
	{
		symtype * t = $1 -> type;
		symtype * prev = NULL;
		while (t->type == "ARR") 
		{
			prev = t;
			t = t->ptr;
		}
		if (prev==NULL) 
		{
			int temp = atoi($3->loc->initial_value.c_str());
			symtype* s = new symtype("ARR", $1->type, temp);
			$$ = $1->update(s);
		}
		else 
		{
			prev->ptr =  new symtype("ARR", t, atoi($3->loc->initial_value.c_str()));
			$$ = $1->update ($1->type);
		}
	}
	| direct_declarator SQUARE_O SQUARE_C 
	{
		symtype * t = $1 -> type;
		symtype * prev = NULL;
		while (t->type == "ARR") 
		{
			prev = t;
			t = t->ptr;
		}
		if (prev==NULL) 
		{
			symtype* s = new symtype("ARR", $1->type, 0);
			$$ = $1->update(s);
		}
		else 
		{
			prev->ptr =  new symtype("ARR", t, 0);
			$$ = $1->update ($1->type);
		}
	}
	| direct_declarator BRACKET_O CT parameter_type_list BRACKET_C 
	{
		table->name = $1->name;

		if ($1->type->type !="VOID") 
		{
			sym *s = table->lookup("return");
			s->update($1->type);		
		}
		$1->nested=table;
		$1->category = "function";
		table->parent = globalTable;

		changeTable (globalTable);				
		currentSymbol = $$;
	}
	| direct_declarator BRACKET_O CT BRACKET_C 
	{
		table->name = $1->name;

		if ($1->type->type !="VOID") 
		{
			sym *s = table->lookup("return");
			s->update($1->type);		
		}
		$1->nested=table;
		$1->category = "function";
		
		table->parent = globalTable;

		changeTable (globalTable);				
		currentSymbol = $$;
	}
	;

CT: 
	%empty 
	{ 															
		if (currentSymbol->nested==NULL) changeTable(new symtable(""));	
		else 
		{
			changeTable (currentSymbol ->nested);						
			emit ("FUNC", table->name);
		}
	}
	;

pointer:
	MUL 
	{
		$$ = new symtype("PTR");
	}
	;


parameter_type_list:
	parameter_list {}
	;

parameter_list:
	parameter_declaration {}
	|parameter_list COMMA parameter_declaration {}
	;

parameter_declaration:
	type_specifier declarator 
	{
		$2->category = "param";
	}
	;


initializer:
	assignment_expression 
	{
		
		$$ = $1->loc;
	}
	;


statement:
	compound_statement 
	{
		
		$$=$1;
	}
	|expression_statement 
	{
		
		$$ = new statement();
		$$->nextlist = $1->nextlist;
	}
	|selection_statement 
	{
		
		$$=$1;
	}
	|iteration_statement 
	{
		
		$$=$1;
	}
	|jump_statement 
	{
		
		$$=$1;
	}
	;



compound_statement:
	CURLY_O block_item_list CURLY_C 
	{
		
		$$=$2;
	}
	|CURLY_O CURLY_C 
	{
		
		$$ = new statement();
	}
	;

block_item_list:
	block_item 
	{
		
		$$=$1;
	}
	|block_item_list M block_item 
	{
		
		$$=$3;
		backpatch ($1->nextlist, $2);
	}
	;

block_item:
	declaration 
	{
		
		$$ = new statement();
	}
	|statement 
	{
		
		$$ = $1;
	}
	;

expression_statement:
	expression SEMICOLON 
	{
		
		$$=$1;
	}
	|SEMICOLON 
	{
		
		$$ = new expr();
	}
	;

selection_statement:
	IF BRACKET_O expression N BRACKET_C M statement N %prec THEN
	{
		
		backpatch ($4->nextlist, nextinstr());
		convertInt2Bool($3);
		$$ = new statement();
		backpatch ($3->truelist, $6);
		list<int> temp = merge ($3->falselist, $7->nextlist);
		$$->nextlist = merge ($8->nextlist, temp);
	}
	|IF BRACKET_O expression N BRACKET_C M statement N ELSE M statement 
	{
		
		backpatch ($4->nextlist, nextinstr());
		convertInt2Bool($3);
		$$ = new statement();
		backpatch ($3->truelist, $6);
		backpatch ($3->falselist, $10);
		list<int> temp = merge ($7->nextlist, $8->nextlist);
		$$->nextlist = merge ($11->nextlist,temp);
	}
	;

iteration_statement:
	FOR BRACKET_O expression_statement M expression_statement BRACKET_C M statement
	{
		
		$$ = new statement();
		
		convertInt2Bool($5);

		
		backpatch ($5->truelist, $7);
		backpatch ($8->nextlist, $4);

		stringstream strs;
	    strs << $4;
	    string temp_str = strs.str();
	    char* intStr = (char*) temp_str.c_str();
		string str = string(intStr);

		emit ("GOTOOP", str);
		$$->nextlist = $5->falselist;
	}
	|FOR BRACKET_O expression_statement M expression_statement M expression N BRACKET_C M statement
	{
		
		$$ = new statement();
		
		convertInt2Bool($5);

		
		backpatch ($5->truelist, $10);
		backpatch ($8->nextlist, $4);
		backpatch ($11->nextlist, $6);

		stringstream strs;
	    strs << $6;
	    string temp_str = strs.str();
	    char* intStr = (char*) temp_str.c_str();
		string str = string(intStr);

		emit ("GOTOOP", str);
		$$->nextlist = $5->falselist;
	}
	;

jump_statement:
	RETURN expression SEMICOLON 
	{
		$$ = new statement();
		emit("RETURN",$2->loc->name);
	}
	|RETURN SEMICOLON
	{
		$$ = new statement();
		emit("RETURN","");
	}
	;

translation_unit:
	external_declaration {}
	|translation_unit external_declaration {}
	;

external_declaration:
	function_definition {}
	|declaration {}
	;

function_definition:
	type_specifier declarator CT compound_statement 
	{
		emit ("FUNCEND", table->name);
		table->parent = globalTable;
		changeTable (globalTable);
	}
	;


%%

void yyerror(string s) {
    cout<<s<<"At line number : "<<yylineno<<endl;
}