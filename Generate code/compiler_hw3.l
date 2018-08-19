/* Definition section */
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "y.tab.h"
	extern YYSTYPE yylval;
	/* Symbol table function */
//	void create_symbol();
//	void insert_symbol();
//	int lookup_symbol();
//	void dump_symbol();
	int i=0;
	int ans=0;
	int slashcom=0;
	int starcom=0;
	int commandnum=0;
	int linenum=0;
	int starfinish=0;
//	int tablenum=0;
//	char tablenumber[20];
//	char check[30];
//	char tmp[30];
//	char s[50];
//	char type[30];
//	char table[600];
//	char id[80][150];
	int created=0;
	int last=0;
	int p=0;
	int pnum=0; 
	/*
			var=1; var ID=2;var ID int/double ; =>(creat table) insert_symbol
			  	
		    */	

%}

letter [a-zA-Z]
digit [0-9]
id {letter}+({letter}|{digit})*
intnum {digit}+
floatnum [0-9]+"."[0-9]+
%option yylineno
%x C_COMMENT CPLUS_COMMENT STRING_STATE
%%

"/*"			{ BEGIN C_COMMENT;}
<C_COMMENT>[^*\n]+	{}
<C_COMMENT>\n		{}
<C_COMMENT>"*"		{}
<C_COMMENT>"*/"		{ BEGIN INITIAL;}
		
\"       		{ BEGIN STRING_STATE;yylval.str=yytext;}
<STRING_STATE>\"	{ BEGIN INITIAL;return STRING;}
<STRING_STATE>[^"]*	{ }

"//"			{ BEGIN CPLUS_COMMENT;}
<CPLUS_COMMENT>[^\n]+    {}
<CPLUS_COMMENT>\n        { BEGIN INITIAL; }

{intnum} {
		yylval.i_val=atoi(yytext);
		return I_CONST;
	}

{floatnum} {
		yylval.f_val=atof(yytext);
		return F_CONST;
	}

"("	{	
		return LB;
	}

")"	{	
		return RB;
	}

"{"	{	
		 return LCB;
	}

"}"	{	
		return RCB;
	}

"int"   {
		return INT;
	}

"float32"   {
		return FLOAT;
	}
  	 
"var"	{	
		return VAR;
	}
"+" 	{
		return ADD;
	}

"++" 	{
		return INC;
	}

"--" 	{
		return DEC;
	}

"*" 	{
		return MUL;
	}

"/" 	{
		return DIV;
	}

"%" 	{
		return REM;
	}

"-"	{ 
		return SUB;
	}

"<" 	{
		return LESS; 
	}

">" 	{
		return GRT;
	}

"<=" 	{
		return LESSEQ; 
	}

">=" 	{
		return GRTEQ; 
	}

"==" 	{
		return EQT;
	}

"!=" 	{
		return NEQ; 
	}

"if"	{ 
			return IF;
	}
"else if"	{
			return ELSEIF;
	 	}

"else"	{ 
			return ELSE;
	}

"for"	{ 
			return FOR;	
	}

"print"	{ 
			return PRINT;
	}

"println" { 
			return PRINTLN;
	 }

{id}	{	 
		yylval.str=strdup(yytext);
			return ID;				
	}

\n	{ 
		yylval.str=strdup(yytext);
		return NEWLINE;
	}

"="	{ 
		return ASSIGN;
	}

"+="	{ 
		return ADDEQ;
	}

"-="	{ 
		return SUBEQ;
	}

"*="	{ 
		return MULEQ; 
	}

"/="	{ 
		return DIVEQ; 
	}

"%="	{ 
		return REMEQ; 
	}

"&&"	{ 
		return AND;
	}

"||"	{ 
		return OR;
	}

"!"	{ 
		return NOT;
	}

" "          		{ }
[ \t]		 	{ }
[^; \t]			{ }
.       { }

%%

/*	C Code section */
int yywrap(void)
{
    return 1;
}
/*
void create_symbol() {
	printf("Create a symbol table\n");
	return;
}
void insert_symbol() {
	strcpy(id[tablenum],tmp);
	tablenum++;
	sprintf(tablenumber,"%d        ",tablenum);
	strcat(table,tablenumber);
	strcat(table,tmp);
	strcat(table,"       ");
	strcat(table,type);
	strcat(table,"\n");
	printf("Insert a symbol: %s\n",tmp); 
	return;
}
int lookup_symbol(char find[] ) {
for(i=0;i<tablenum;i++)
	if(strcmp(find,id[i])==0)
		return i+1;
return 0;
}
void dump_symbol() {
	if(created==1){
		printf("\nThe symbol table dump:\n");
		printf("%s\n",table);
 	}
	return;
}
*/
/*
int main(int argc,char *argv[])
{
	yyin = fopen(argv[1],"r");
	yylex();

	printf("\nParse over ,the line number is %d.\n",linenum);
	printf("\ncomment: %d lines\n",commandnum);
	dump_symbol();
	strcpy(s,"c");
	ans=lookup_symbol(s);
//	if(ans!=0)
//		printf("The symbol %s index is %d\n",s,ans);
//        else
//		printf("The symbol %s unexist in symbol table\n",s);
*/
//	return 0;
//}
