%{
#include "pheading.h"
#include "scanner.c"
#include "tac.h"

struct tacnode*	spdltac;

int yyerror(char *s);
int yylex(void);

%}

%union{
	char*  		str;
	struct tacnode*	tac;
	Symbol		symb;
}

%token 	<symb>	ID
%token 		PROTOCOL
%token 		ROLE
%token 		READT
%token 		SENDT
%token 		CLAIMT
%token 		VAR
%token 		CONST
%token 		RUN
%token 		SECRET
%token 		COMPROMISED
%token 		INVERSEKEYS
%token 		UNTRUSTED
%token 		USERTYPE

%type	<tac>	spdlcomplete
%type	<tac>	spdlrep
%type	<tac>	spdl
%type	<tac>	roles
%type	<tac>	role
%type	<tac>	roledef
%type	<tac>	event
%type	<tac>	declaration
%type	<tac>	secretpref
%type	<tac>	typeinfo1
%type	<tac>	typeinfoN
%type	<tac>	term
%type	<tac>	termlist
%type	<tac>	key
%type	<tac>	roleref

%type	<symb>	label

%start spdlcomplete


%%

spdlcomplete	: spdlrep
		  {	spdltac = $1; }
		;

spdlrep		: /* empty */
		  {	$$ = NULL; }
		| spdl spdlrep
		  {	$$ = tacCat($1,$2); }
		;

spdl		: UNTRUSTED termlist ';'
		  {	
		  	Tac t = tacCreate(TAC_UNTRUSTED);
		  	t->tac1 = $2;
			$$ = t;
		  }
		| RUN roleref '(' termlist ')' ';'
		  {	
		  	Tac t = tacCreate(TAC_RUN);
		  	t->tac1 = $2;
			t->tac2 = $4;
			$$ = t;
		  }
		| PROTOCOL ID '(' termlist ')' '{' roles '}' optclosing
	 	  {
		  	Tac t = tacCreate(TAC_PROTOCOL);
			t->sym1 = $2;
			t->tac2 = $7;
			t->tac3 = $4;
			$$ = t;
		  }
		| USERTYPE termlist ';'
		  {
			Tac t = tacCreate(TAC_USERTYPE);
			t->tac1 = $2;
			$$ = t;
		  }
		| declaration
		  {
		  	$$ = $1;
		  }
		;

roles		: /* empty */
       		  {	$$ = NULL; }
       		| role roles
		  {	$$ = tacCat($1,$2); }
		| declaration roles
		  {	$$ = tacCat($1,$2); }
		;

role		: ROLE ID '{' roledef '}' optclosing
      		  { 
		  	Tac t = tacCreate(TAC_ROLE);
			t->sym1 = $2;
			t->tac2 = $4;
			$$ = t;
		  }
		;

optclosing	: /* empty */
		  { }
		| ';'
		  { }
		;

roledef		: /* empty */
		  {	$$ = NULL; }
		| event roledef
		  {	$$ = tacCat($1,$2); }
		| declaration roledef
		  {	$$ = tacCat($1,$2); }
		;

event		: READT label '(' termlist ')' ';'
		  {	Tac t = tacCreate(TAC_READ);
		  	t->sym1 = $2;
			/* TODO test here: tac2 should have at least 3 elements */
			t->tac2 = $4;
			$$ = t;
		  }
		| SENDT label '(' termlist ')' ';'
		  {	Tac t = tacCreate(TAC_SEND);
		  	t->sym1 = $2;
			/* TODO test here: tac2 should have at least 3 elements */
			t->tac2 = $4;
			$$ = t;
		  }
		| CLAIMT label '(' termlist ')' ';'
		/* TODO maybe claims should be in the syntax */
		  {	Tac t = tacCreate(TAC_CLAIM);
		  	t->sym1 = $2;
			t->tac2 = $4;
			$$ = t;
		  }
		;

roleref		: ID '.' ID
		  {	Tac t = tacCreate(TAC_ROLEREF);
		  	t->sym1 = $1;
			t->sym2 = $3;
			$$ = t;
		  }
		;

declaration	: secretpref CONST termlist typeinfo1 ';'
		  {	Tac t = tacCreate(TAC_CONST);
		  	t->tac1 = $3;
			t->tac2 = $4;
			t->tac3 = $1;
			$$ = t;
		  }
		| secretpref VAR termlist typeinfoN ';'
		  {	Tac t = tacCreate(TAC_VAR);
		  	t->tac1 = $3;
			t->tac2 = $4;
			t->tac3 = $1;
			$$ = t;
		  }
		| SECRET termlist typeinfo1 ';'
		  {	Tac t = tacCreate(TAC_SECRET);
		  	t->tac1 = $2;
			t->tac2 = $3;
			$$ = t;
		  }
		| INVERSEKEYS '(' term ',' term ')' ';'
		  {	Tac t = tacCreate(TAC_INVERSEKEYS);
			t->tac1 = $3;
			t->tac2 = $5;
			$$ = t;
		  }
		| COMPROMISED termlist ';'
		  {	Tac t = tacCreate(TAC_COMPROMISED);
		  	t->tac1= $2;
			$$ = t;
		  }
		;

secretpref	: /* empty */
		  {	
			$$ = NULL;
		  }
		| SECRET
		  {
			Tac t = tacCreate(TAC_SECRET);
			$$ = t;
		  }
		;

typeinfo1	: /* empty */
		  {
		  	Tac t = tacCreate(TAC_UNDEF);
			$$ = t;
		  }
		| ':' ID
		  {	Tac t = tacCreate(TAC_STRING);
		  	t->sym1 = $2;
			$$ = t;
		  }
		;

typeinfoN	: /* empty */
		  {
		  	Tac t = tacCreate(TAC_UNDEF);
			$$ = t;
		  }
		| ':' termlist
		  {	
		  	$$ = $2;
		  }
		;

label		: /* empty */
		  { $$ = NULL; }
		| '_' ID
		  { $$ = $2; }
		;

term  		: ID
		  {
		  	Tac t = tacCreate(TAC_STRING);
			t->sym1 = $1;
			$$ = t;
		  }
		| ID '(' termlist ')'
		  {
		  	Tac t = tacCreate(TAC_STRING);
			t->sym1 = $1;
			$$ = tacJoin(TAC_ENCRYPT,tacTuple($3),t,NULL);
		  }
		| '{' termlist '}' key
		  {
		  	$$ = tacJoin(TAC_ENCRYPT,tacTuple($2),$4,NULL);
		  }
		| '(' termlist ')'
		  { 
		  	$$ = tacTuple($2);
		  }
		;

termlist	: term
		  { }
		| term ',' termlist
		  {	$$ = tacCat($1,$3); }
		;

key		: term
		  { }
		;



%%

// error handler routing
int yyerror(char *s)
{
	extern int yylineno;	// defined and maintained in lex.c
	extern char *yytext;	// defined and maintained in lex.c
  
	printf("\nERROR %s at symbol %s on line %i.\n", s, yytext, yylineno);
	exit(1);
}

