/*	Definition section */
%{
extern int yylineno;
extern int yylex();
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
/* Symbol table function - you can add new function if need. */
int lookup_symbol();
//int checktype(float c);
void create_symbol();
void insert_symbol();
void dump_symbol();
float  numbertable[30];
int inumbertable[30];
char idtable[30][150];
int tablenum=0;
char tmp[30];
int declarenum=0;
int depth=0;
float tempf=0.0;
int tempi=0;
int type=0;//get_val type
int ntype=0;//variable type
int typetable[30];
int op1=0;
int op2=0;
//int enable=1;
int create=0;
%}

/* Using union to define nonterminal and token type */
%union {
    int i_val;
    double f_val;
    char* str;
}

/* Token without return */
%token PRINT PRINTLN 
%token IF ELSE ELSEIF FOR
%token VAR NEWLINE
%token LB RB LCB RCB LQ RQ LSTARS RSTARS SLS
%token ADD INC SUB DEC MUL DIV REM
%token LESS GRT LESSEQ GRTEQ EQT NEQ
%token ADDEQ SUBEQ MULEQ DIVEQ REMEQ
%token AND OR NOT
%token ASSIGN
/* Token with return, which need to sepcify type */
%token <i_val> I_CONST
%token <f_val> F_CONST
%token <str> STRING
%token <str> ID
%token  INT
%token  FLOAT
%token STRSYM
/* Nonterminal with return, which need to sepcify type */
/*%type <f_val> stat */
%type <str> numtype
%type <f_val> number
%type <i_val> get_logic LOGIC_F
%type <f_val> get_val
%type <f_val> F
%left OR
%left AND
%left LESS GRT LESSEQ GRTEQ EQT NEQ
%left ADD SUB 
%left MUL DIV REM
%left INC DEC
/* Yacc will start at this nonterminal */
%start program

/* Grammar section */
%%

program
    : program stat newl
    |
;

newl
    : NEWLINE
    |   
;
stat
    : declaration
    | expression_stat {ntype=0;}	
    | print_stat
    | if_stat {;}
    | newl
    | get_val
    | stat
;

print_stat
    :PRINT LB STRING RB {char *s=strtok($3,"\"");printf("PRINT : %s\n",s);}
    |PRINT LB get_val RB
	{
//	 strcpy(tmp,$3);
//	 op1=lookup_symbol(tmp);
	 //printf("HAHA");	
//	 if(op1==0) printf("<ERROR> can't find variable %s (line %d)\n",tmp,yylineno); 
//	 else {
//		if(typetable[op1-1]==1)
		if($3==(int)$3)
			printf("PRINT : %d\n",(int)$3);
//			printf("PRINT : %d\n",(int)numbertable[op1-1]);		
//		if(typetable[op1-1]==2)
		else
			printf("PRINT : %f\n",$3);
//			printf("PRINT : %f\n",numbertable[op1-1]);
//	 }
	}
    |PRINTLN LB STRING RB {char *s=strtok($3,"\""); printf("PRINTLN : %s\n",s);}
    |PRINTLN LB get_val RB
	{
//	 strcpy(tmp,$3);
//	 op1=lookup_symbol(tmp);	
//	 if(op1==0) printf("<ERROR> can't find variable %s (line %d)\n",tmp,yylineno); 
//	 else {
//		if(typetable[op1-1]==1)
		if($3==(int)$3)
			printf("PRINTLN : %d\n",(int)$3);
//			printf("PRINTLN : %d\n",(int)numbertable[op1-1]);		
//		if(typetable[op1-1]==2)
		else		
			printf("PRINTLN : %f\n",$3);
//			printf("PRINTLN : %f\n",numbertable[op1-1]);
	 }
	
;


if_stat
    :IF LB get_val RB newl LCB newl stat  newl RCB newl else_stat
{;}
    ;
else_stat
    :ELSEIF LB get_val RB newl LCB newl stat newl RCB newl else_stat newl{;}
    |ELSE LCB newl stat newl RCB newl{;}
    |
;

/*
get_logic
    :get_val GRT get_val  {if($1>$3) $$=1;else $$=-1;}
    |get_val LESS get_val {if($1>$3) $$=1;else $$=-1;}
    |get_val EQT get_val  {if($1==$3) $$=1;else $$=-1;}
    |get_val NEQ get_val  {if($1!=$3) $$=1;else $$=-1;}
    |get_logic AND LOGIC_F {if($1==1&&$3==1) $$=1;else $$=-1;}
    |get_logic OR LOGIC_F {if($1==1||$3==1) $$=1;else $$=-1;}
    |LOGIC_F
;
LOGIC_F
    :LB get_logic RB {$$=$2;}
    |get_logic
;
*/

get_val
	: get_val ADD get_val 	{printf("Add\n");$$=$1+$3;}	
	| get_val SUB get_val	{printf("Sub\n");$$=$1-$3;}
	| get_val MUL get_val	{printf("Mul\n");$$=$1*$3;}
	| get_val DIV get_val	{printf("Div\n");
			if($3==0) {printf("<ERROR> The divisor can't be 0 (line %d)\n",yylineno);$$=0;}
			else $$=$1/$3;}
	| get_val REM get_val	{
			printf("Mod\n");
			// printf("typeis :%d\n",type);			                
			 
	 		 if(type==2||ntype==2) {
			 type=yylineno+1;
			 printf("<ERROR> opetator Mod has float oprands (line %d)\n",type);
				type=0;ntype=0;
			}
			 else{
			 // printf("Mod\n");
			  $$=(int)$1%(int)$3;
			}
	}
	|ID INC	{
		strcpy(tmp,$1);
		int index=lookup_symbol(tmp);
		if(index==0) { printf("<ERROR> can't find variable %s (line %d)\n",tmp,yylineno); $$=0;}
	 	else {
			printf("INC\n");
			$$=numbertable[index-1];
			numbertable[index-1]++;
		 }
		}
	|INC ID  {
		strcpy(tmp,$2);
		int index=lookup_symbol(tmp);
		if(index==0) { printf("<ERROR> can't find variable %s (line %d)\n",tmp,yylineno); $$=0;}
	 	else {
			printf("INC\n");
			numbertable[index-1]++;
			$$=numbertable[index-1];
		 }
		}
	|ID DEC  {
		strcpy(tmp,$1);
		int index=lookup_symbol(tmp);
		if(index==0) { printf("<ERROR> can't find variable %s (line %d)\n",tmp,yylineno); $$=0;}
	 	else {
			printf("DEC\n");
			$$=numbertable[index-1];
			numbertable[index-1]--;
		 }
		}
	|DEC ID {
		strcpy(tmp,$2);
		int index=lookup_symbol(tmp);
		if(index==0) { printf("<ERROR> can't find variable %s (line %d)\n",tmp,yylineno); $$=0;}
	 	else {
			printf("DEC\n");
			numbertable[index-1]--;
			$$=numbertable[index-1];
		 }
		}
    	|get_val GRT get_val  {if($1>$3) {printf("true\n"); $$=1;}else{printf("false\n");  $$=-1;}}
	|get_val GRTEQ get_val {if($1>=$3) {printf("true\n"); $$=1;}else{printf("false\n");  $$=-1;}}
	|get_val LESSEQ	get_val {if($1<=$3) {printf("true\n"); $$=1;}else{printf("false\n");  $$=-1;}}
    	|get_val LESS get_val {if($1>$3) {printf("true\n"); $$=1;}else{printf("false\n");  $$=-1;}}
    	|get_val EQT get_val  {if($1==$3) {printf("true\n"); $$=1;}else{printf("false\n");  $$=-1;}}
    	|get_val NEQ get_val  {if($1!=$3) {printf("true\n"); $$=1;}else{printf("false\n");  $$=-1;}}
    	|get_val AND get_val {if($1==1&&$3==1) {printf("true\n"); $$=1;}else{printf("false\n");  $$=-1;}}
    	|get_val OR get_val {if($1==1||$3==1) {printf("true\n"); $$=1;}else{printf("false\n");  $$=-1;}}
	|F
;

F
	: LB get_val RB		{$$=$2;}
	| number		{$$=$1;}
;
	
number
    :F_CONST	{type=2;$$=$1;}
    |I_CONST	{$$=$1;}
    | ID	{
		strcpy(tmp,$1);
		int index=lookup_symbol(tmp);
		if(index==0) { printf("<ERROR> can't find variable %s (line %d)\n",tmp,yylineno); $$=0;}
	 	else {
			if(typetable[index-1]==2)
				type=2;
			else type=1;
			$$=numbertable[index-1];
			//printf("%stype is %d",idtable[index-1],type);
		 }
		}
;		

declaration
    : VAR ID numtype ASSIGN get_val
	{
	 declarenum=1;
	 strcpy(tmp,$2);
	 //printf("%s",tmp);
	 if(lookup_symbol(tmp)!=0) printf("<ERROR> re-declaration for variable %s (line %d)\n",tmp,yylineno); 
	 else {//if(type==2&&ntype!=2) printf("Line %d  Semantic Error : assign float32 to int type variable\n",yylineno);
		 { tempf=$5;insert_symbol();tempf=0;}		
	      } 
	}
    
    | VAR ID numtype
	{
	 declarenum=1;
	 strcpy(tmp,$2);
	 //printf("%s",tmp);
	 if(lookup_symbol(tmp)!=0) printf("<ERROR> re-declaration for variable %s (line %d)\n",tmp,yylineno); 
	 else {//if(type==2&&ntype!=2) printf("Line %d  Semantic Error : assign float32 to int type variable\n",yylineno);
		{ tempf=0;insert_symbol();}		
	      } 
	}
;
	
numtype
    : INT 	{ntype=1;}
    | FLOAT	{ntype=2;}
;

expression_stat
    :ID ASSIGN get_val
	{
	 printf("ASSIGN\n");
	 strcpy(tmp,$1);
	 op1=lookup_symbol(tmp);	
	 if(op1==0) printf("<ERROR> can't find variable %s (line %d)\n",tmp,yylineno); 
	 else {
		numbertable[op1-1]=$3;
		//if(type==2&&typetable[op1-1]!=2){
		// printf("Line %d  Semantic Error : assign float32 to int type variable\n",yylineno);}		
	}
	 //type=0;
	}
    |ID ADDEQ get_val
	{
	 printf("ADDEQ\n");
	 strcpy(tmp,$1);
	 op1=lookup_symbol(tmp);	
	 if(op1==0) printf("<ERROR> can't find variable %s (line %d)\n",tmp,yylineno); 
	 else {
		float tmpnum=numbertable[op1-1]+$3;
		numbertable[op1-1]=tmpnum;		
		//if(type==2&&typetable[op1-1]!=2){
		 //printf("Line %d  Semantic Error : assign float32 to int type variable\n",yylineno);}		
	}
	 //type=0;
	}
    |ID SUBEQ get_val
	{
	 printf("SUBEQ\n");
	 strcpy(tmp,$1);
	 op1=lookup_symbol(tmp);	
	 if(op1==0) printf("<ERROR> can't find variable %s (line %d)\n",tmp,yylineno); 
	 else {
		float tmpnum=numbertable[op1-1]-$3;
		numbertable[op1-1]=tmpnum;
		//if(type==2&&typetable[op1-1]!=2){
		 //printf("Line %d  Semantic Error : assign float32 to int type variable\n",yylineno);}		
	}
	// type=0;
	}
    |ID MULEQ get_val
	{
	 printf("MULEQ\n");
	 strcpy(tmp,$1);
	 op1=lookup_symbol(tmp);	
	 if(op1==0) printf("<ERROR> can't find variable %s (line %d)\n",tmp,yylineno); 
	 else {
		float tmpnum=numbertable[op1-1]*$3;
		numbertable[op1-1]=tmpnum;		
		//if(type==2&&typetable[op1-1]!=2){
		 //printf("Line %d  typetable is %d Semantic Error  assign float32 to int type variable\n",yylineno,typetable[op1-1]);}		
	}
	 //type=0;
	}

    |ID DIVEQ get_val
	{
	 printf("DIVEQ\n");
	 strcpy(tmp,$1);
	 op1=lookup_symbol(tmp);	
	 if($3==0){ printf("<ERROR> The divisor can't be 0 (line %d)\n",yylineno); tempf=-1;}
	 if(op1==0) printf("<ERROR> can't find variable %s (line %d)\n",tmp,yylineno); 
	 else {
		float tmpnum=numbertable[op1-1]/$3;
		numbertable[op1-1]=tmpnum;	
		//if(type==2&&typetable[op1-1]!=2){
		 //printf("Line %d  Semantic Error : assign float32 to int type variable\n",yylineno);}		
	}
	}
    |ID REMEQ get_val
	{
	 printf("ModEQ\n");
	 strcpy(tmp,$1);
	 op1=lookup_symbol(tmp);	
	 if(op1==0) printf("<ERROR> can't find variable %s (line %d)\n",tmp,yylineno); 
	 else {
			if((int)$3==$3){
			int tmpnu=((int)numbertable[op1-1])%(int)$3;
			numbertable[op1-1]=tmpnu;
			}
		//	printf("type is%d\n",type);
	 		if(type==2||ntype==2){ printf("<ERROR> opetator ModEQ has float oprands (line %d)\n",yylineno);
			type=0;ntype=0;
			}
			//else printf("ModEQ\n");
			
	}
	} 
;
/*
stat
    : declaration
    | compound_stat
    | expression_stat
    | print_func
;

declaration
    : VAR ID type '=' initializer NEWLINE
    | VAR ID type NEWLINE
;

initializer
    :
;
type
    : INT { $$ = $1; }
    | FLOAT { $$ = $1; }
    | VOID { $$ = $1; }
;
*/
%%
void yyerror(char* msg)
{
	printf("error %d\n",yylineno);
	exit(1);
}
/* C code section */

void create_symbol() {
	printf("Create a symbol table\n");
}
void insert_symbol() {
	if(create==0)
	{
	 create_symbol();
	 create=1;
	}
	printf("Insert symbol: %s\n",tmp);
	strcpy(idtable[tablenum],tmp);
	if (declarenum==1){
		declarenum=0;
		numbertable[tablenum]=tempf;
		if(ntype==1) typetable[tablenum]=1;
		if(ntype==2) typetable[tablenum]=2;
	//	ntype=0;
	}
	tablenum++;
	
	return;
}
	
int lookup_symbol(char find[]) {
for(int i=0;i<tablenum;i++)
	if(strcmp(find,idtable[i])==0)
		return i+1;
return 0;
}
void dump_symbol() {
	printf("The symbol table:\n\nID    Type    Data\n");
	for(int i=0;i<tablenum;i++)
	{
	if(typetable[i]==1){
		printf("%s     int     %d\n",idtable[i],(int)numbertable[i]);
	 }
	if(typetable[i]==2){
		printf("%s     float32    %f\n",idtable[i],numbertable[i]);
	 }
	}
}
/*
int checktype(float a){
	int check=0;
	int tmpint=(int)a;
	if(a==tmpint)
		check=1;//type a is int
	else
		check=2;//type a is float
	return check;
} */	       
int main(int argc, char** argv)
{
    yylineno=0;
    yyparse();
    printf("\nTotal lines:%d\n\n",yylineno);
    if(create==1)
    	dump_symbol();
    return 0;
}
