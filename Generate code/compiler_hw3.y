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
int jerror=0;
int lnum=0;
int e_num=0;
char jar_word[1000][100];
int type_stack[30];
int tl=0;
int ll=0;
int jar_line=0;
FILE* jac;
int var_num=0;
void create_symbol();
void insert_symbol();
int pop();
int lpop();
void lpush(int a);
void push(int a);
int lstack[30];
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
    |newl
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
//    |newl stat newl
;

print_stat
    :PRINT LB STRING RB {
	char *s=strtok($3,"\"");
	printf("PRINT : %s\n",s);
	sprintf(jar_word[jar_line++],"\tldc \"%s\"\n",s);
	sprintf(jar_word[jar_line++],"\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
	sprintf(jar_word[jar_line++],"\tswap\n");
	sprintf(jar_word[jar_line++],"\tinvokevirtual java/io/PrintStream/print(Ljava/lang/String;)V\n");
	}
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
	int cc=pop();
	if(cc==2){
		sprintf(jar_word[jar_line++],"\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
		sprintf(jar_word[jar_line++],"\tswap\n");
		sprintf(jar_word[jar_line++],"\tinvokevirtual java/io/PrintStream/print(F)V\n");
		type=0;
		}
		else{
		sprintf(jar_word[jar_line++],"\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
		sprintf(jar_word[jar_line++],"\tswap\n");
		sprintf(jar_word[jar_line++],"\tinvokevirtual java/io/PrintStream/print(I)V\n");
		type=0;
		}
	}
    |PRINTLN LB STRING RB {
	char *s=strtok($3,"\""); 
	printf("PRINTLN : %s\n",s);
	sprintf(jar_word[jar_line++],"\tldc \"%s\"\n",s);
	sprintf(jar_word[jar_line++],"\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
	sprintf(jar_word[jar_line++],"\tswap\n");
	sprintf(jar_word[jar_line++],"\tinvokevirtual java/io/PrintStream/println(Ljava/lang/String;)V\n");
	}
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
		int cc=pop();
		if(cc==2){
		sprintf(jar_word[jar_line++],"\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
		sprintf(jar_word[jar_line++],"\tswap\n");
		sprintf(jar_word[jar_line++],"\tinvokevirtual java/io/PrintStream/println(F)V\n");
		type=0;
		}
		else if(cc==1){
		sprintf(jar_word[jar_line++],"\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
		sprintf(jar_word[jar_line++],"\tswap\n");
		sprintf(jar_word[jar_line++],"\tinvokevirtual java/io/PrintStream/println(I)V\n");
		type=0;
		}
	 }
	
;


if_stat
    :IF LB get_logic RB newl block newl elif_stat newl{
	sprintf(jar_word[jar_line++],"EXIT_%d:\n",e_num);
	e_num++;
	}
    ;
elif_stat
    :newl ELSEIF LB get_logic RB newl block newl elif_stat newl{;}
    |newl else_stat newl block newl{;}
    |
;
else_stat
    :ELSE {
	lpush(lnum);
	lnum++;
	}
    |
;

block
    : LCB newl program stat newl RCB newl{
	sprintf(jar_word[jar_line++],"\tgoto EXIT_%d\n",e_num);
	int a=lpop();
	sprintf(jar_word[jar_line++],"Label_%d:\n",a);
	//lpush
	}
    |LCB newl newl RCB newl{
	sprintf(jar_word[jar_line++],"\tgoto EXIT_%d\n",e_num);
	int a=lpop();
	sprintf(jar_word[jar_line++],"Label_%d:\n",a);
	}
;
get_logic
    :get_val GRT get_val  {if($1>$3) $$=1;//>
	else $$=-1;
	int a=pop();
	int b=pop();
	printf("Sub GRT\n");$$=$1-$3;
	if(a==1&&b==2) {
	sprintf(jar_word[jar_line++],"\ti2f\n");
	sprintf(jar_word[jar_line++],"\tfsub\n"); 
	//push(2);
	}
	else if(a==2&&b==1){
	sprintf(jar_word[jar_line++],"\tswap\n");
	sprintf(jar_word[jar_line++],"\ti2f\n");
	sprintf(jar_word[jar_line++],"\tswap\n");
	sprintf(jar_word[jar_line++],"\tfsub\n");
	//push(2);
	}
	else if(a+b==4){
	sprintf(jar_word[jar_line++],"\tfsub\n");
	//push(2);
	}
	else {sprintf(jar_word[jar_line++],"\tisub\n"); 
	//push(1);
	}	
	lpush(lnum);
	sprintf(jar_word[jar_line++],"\tifle Label_%d\n",lnum);
	lnum++;
	}
    |get_val LESS get_val {if($1>$3) $$=1;else $$=-1;//<
	int a=pop();
	int b=pop();
	printf("Sub LESS\n");$$=$1-$3;
	if(a+b==2) {sprintf(jar_word[jar_line++],"\tisub\n"); 
	//push(1);
	}
	else if(a==1&&b==2) {
	sprintf(jar_word[jar_line++],"\ti2f\n");
	sprintf(jar_word[jar_line++],"\tfsub\n"); 
	//push(2);
	}
	else if(a==2&&b==1){
	sprintf(jar_word[jar_line++],"\tswap\n");
	sprintf(jar_word[jar_line++],"\ti2f\n");
	sprintf(jar_word[jar_line++],"\tswap\n");
	sprintf(jar_word[jar_line++],"\tfsub\n");
	//push(2);
	}
	else if(a+b==4){
	sprintf(jar_word[jar_line++],"\tfsub\n");
	//push(2);
	}	
	lpush(lnum);
	sprintf(jar_word[jar_line++],"\tifge Label_%d\n",lnum);
	lnum++;
	}
    |get_val EQT get_val  {if($1==$3) $$=1;else $$=-1;//==
	int a=pop();
	int b=pop();
	printf("Sub EQT\n");$$=$1-$3;
	if(a+b==2) {sprintf(jar_word[jar_line++],"\tisub\n"); 
	//push(1);
	}
	else if(a==1&&b==2) {
	sprintf(jar_word[jar_line++],"\ti2f\n");
	sprintf(jar_word[jar_line++],"\tfsub\n"); 
	//push(2);
	}
	else if(a==2&&b==1){
	sprintf(jar_word[jar_line++],"\tswap\n");
	sprintf(jar_word[jar_line++],"\ti2f\n");
	sprintf(jar_word[jar_line++],"\tswap\n");
	sprintf(jar_word[jar_line++],"\tfsub\n");
	//push(2);
	}
	else if(a+b==4){
	sprintf(jar_word[jar_line++],"\tfsub\n");
	//push(2);
	}	
	lpush(lnum);
	sprintf(jar_word[jar_line++],"\tifne Label_%d\n",lnum);	
	lnum++;	
	}
    |get_val NEQ get_val  {if($1!=$3) $$=1;else $$=-1;//!=
	int a=pop();
	int b=pop();
	printf("Sub NEQ\n");$$=$1-$3;
	if(a+b==2) {sprintf(jar_word[jar_line++],"\tisub\n"); 
	//push(1);
	}
	else if(a==1&&b==2) {
	sprintf(jar_word[jar_line++],"\ti2f\n");
	sprintf(jar_word[jar_line++],"\tfsub\n"); 
	//push(2);
	}
	else if(a==2&&b==1){
	sprintf(jar_word[jar_line++],"\tswap\n");
	sprintf(jar_word[jar_line++],"\ti2f\n");
	sprintf(jar_word[jar_line++],"\tswap\n");
	sprintf(jar_word[jar_line++],"\tfsub\n");
	//push(2);
	}
	else if(a+b==4){
	sprintf(jar_word[jar_line++],"\tfsub\n");
	//push(2);
	}
	lpush(lnum);	
	sprintf(jar_word[jar_line++],"\tifeq Label_%d\n",lnum);
	lnum++;
	}
    |get_val GRTEQ get_val {if($1>=$3) {printf("true\n"); $$=1;}else{printf("false\n");  $$=-1;}//>=
	int a=pop();
	int b=pop();
	printf("Sub GRTEQ\n");$$=$1-$3;
	if(a+b==2) {sprintf(jar_word[jar_line++],"\tisub\n"); 
	//push(1);
	}
	else if(a==1&&b==2) {
	sprintf(jar_word[jar_line++],"\ti2f\n");
	sprintf(jar_word[jar_line++],"\tfsub\n"); 
	//push(2);
	}
	else if(a==2&&b==1){
	sprintf(jar_word[jar_line++],"\tswap\n");
	sprintf(jar_word[jar_line++],"\ti2f\n");
	sprintf(jar_word[jar_line++],"\tswap\n");
	sprintf(jar_word[jar_line++],"\tfsub\n");
	//push(2);
	}
	else if(a+b==4){
	sprintf(jar_word[jar_line++],"\tfsub\n");
	//push(2);
	}	
	lpush(lnum);
	sprintf(jar_word[jar_line++],"\tiflt Label_%d\n",lnum);
	lnum++;
	}
    |get_val LESSEQ get_val {if($1<=$3) {printf("true\n"); $$=1;}else{printf("false\n");  $$=-1;}//<=
	int a=pop();
	int b=pop();
	printf("Sub LESSEQ\n");$$=$1-$3;
	if(a+b==2) {sprintf(jar_word[jar_line++],"\tisub\n"); 
	//push(1);
	}
	else if(a==1&&b==2) {
	sprintf(jar_word[jar_line++],"\ti2f\n");
	sprintf(jar_word[jar_line++],"\tfsub\n"); 
	//push(2);
	}
	else if(a==2&&b==1){
	sprintf(jar_word[jar_line++],"\tswap\n");
	sprintf(jar_word[jar_line++],"\ti2f\n");
	sprintf(jar_word[jar_line++],"\tswap\n");
	sprintf(jar_word[jar_line++],"\tfsub\n");
	//push(2);
	}
	else if(a+b==4){
	sprintf(jar_word[jar_line++],"\tfsub\n");
	//push(2);
	}	
	lpush(lnum);
	sprintf(jar_word[jar_line++],"\tifgt Label_%d\n",lnum);
	lnum++;
	}
   // |get_val LESS get_val {if($1>$3) {printf("true\n"); $$=1;}else{printf("false\n");  $$=-1;}}
   // |get_val EQT get_val  {if($1==$3) {printf("true\n"); $$=1;}else{printf("false\n");  $$=-1;}}
   // |get_val NEQ get_val  {if($1!=$3) {printf("true\n"); $$=1;}else{printf("false\n");  $$=-1;}}
    //|get_val AND get_val {if($1==1&&$3==1) {printf("true\n"); $$=1;}else{printf("false\n");  $$=-1;}}
  //  |get_val OR get_val {if($1==1||$3==1) {printf("true\n"); $$=1;}else{printf("false\n");  $$=-1;}}    
//    |LOGIC_F
;

LOGIC_F
//    :LB get_logic RB {$$=$2;}
//    |get_logic
	:{;}
;


get_val
	: get_val ADD get_val 	{printf("Add\n");$$=$1+$3;
				int a=pop();
				int b=pop();
				if(a+b==2) {sprintf(jar_word[jar_line++],"\tiadd\n"); push(1);}
				else if(a==1&&b==2) {
				sprintf(jar_word[jar_line++],"\ti2f\n");
				sprintf(jar_word[jar_line++],"\tfadd\n"); 
				push(2);
				}
				else if(a==2&&b==1){
				sprintf(jar_word[jar_line++],"\tswap\n");
				sprintf(jar_word[jar_line++],"\ti2f\n");
				sprintf(jar_word[jar_line++],"\tswap\n");
				sprintf(jar_word[jar_line++],"\tfadd\n");
				push(2);
				}
				else if(a+b==4){
				sprintf(jar_word[jar_line++],"\tfadd\n");
				push(2);
				}	
				}
	| get_val SUB get_val	{int a=pop();
				int b=pop();
				printf("Sub\n");$$=$1-$3;
				if(a+b==2) {sprintf(jar_word[jar_line++],"\tisub\n"); push(1);}
				else if(a==1&&b==2) {
				sprintf(jar_word[jar_line++],"\ti2f\n");
				sprintf(jar_word[jar_line++],"\tfsub\n"); 
				push(2);
				}
				else if(a==2&&b==1){
				sprintf(jar_word[jar_line++],"\tswap\n");
				sprintf(jar_word[jar_line++],"\ti2f\n");
				sprintf(jar_word[jar_line++],"\tswap\n");
				sprintf(jar_word[jar_line++],"\tfsub\n");
				push(2);
				}
				else if(a+b==4){
				sprintf(jar_word[jar_line++],"\tfsub\n");
				push(2);
				}					
				}
	| get_val MUL get_val	{int a=pop();
				int b=pop();
				printf("Mul\n");$$=$1*$3;
				if(a+b==2) {sprintf(jar_word[jar_line++],"\timul\n"); push(1);}
				else if(a==1&&b==2) {
				sprintf(jar_word[jar_line++],"\ti2f\n");
				sprintf(jar_word[jar_line++],"\tfmul\n"); 
				push(2);
				}
				else if(a==2&&b==1){
				sprintf(jar_word[jar_line++],"\tswap\n");
				sprintf(jar_word[jar_line++],"\ti2f\n");
				sprintf(jar_word[jar_line++],"\tswap\n");
				sprintf(jar_word[jar_line++],"\tfmul\n");
				push(2);
				}
				else if(a+b==4){
				sprintf(jar_word[jar_line++],"\tfmul\n");
				push(2);
				}	
				}
	| get_val DIV get_val	{int a=pop();
				int b=pop();
			printf("Div\n");
			if($3==0) {printf("<ERROR> The divisor can't be 0 (line %d)\n",yylineno+1);$$=0;jerror=1;}
			else $$=$1/$3;
				//hw3
			if(a+b==2) {sprintf(jar_word[jar_line++],"\tidiv\n"); push(1);}
				else if(a==1&&b==2) {
				sprintf(jar_word[jar_line++],"\ti2f\n");
				sprintf(jar_word[jar_line++],"\tfdiv\n"); 
				push(2);
				}
				else if(a==2&&b==1){
				sprintf(jar_word[jar_line++],"\tswap\n");
				sprintf(jar_word[jar_line++],"\ti2f\n");
				sprintf(jar_word[jar_line++],"\tswap\n");
				sprintf(jar_word[jar_line++],"\tfdiv\n");
				push(2);
				}
				else if(a+b==4){
				sprintf(jar_word[jar_line++],"\tfdiv\n");
				push(2);
				}				
			}
	| get_val REM get_val	{
			printf("Mod\n");
			// printf("typeis :%d\n",type);			                
			 if($3==0) {
				printf("<ERROR> divisor can't be zero (line %d)\n",yylineno+1);
				jerror=1;		
			  }
	 		 else if(type_stack[tl-2]==2||type_stack[tl-1]==2) {
			 type=yylineno+1;
			 printf("<ERROR> opetator Mod has float oprands (line %d)\n",type);
			 jerror=1;
				type=0;ntype=0;
			}
			 else{
			 // printf("Mod\n");
			  $$=(int)$1%(int)$3;
			//hw3
			//int k=(int)$3;
			sprintf(jar_word[jar_line++],"\tirem\n");
			pop();pop();
			push(1);
			}
	}
	|ID INC	{
		strcpy(tmp,$1);
		int op1=lookup_symbol(tmp);
		if(op1==0) { printf("<ERROR> can't find variable %s (line %d)\n",tmp,yylineno); $$=0;jerror=1;}

	 	else {
			printf("INC\n");
			$$=numbertable[op1-1];
			numbertable[op1-1]++;
		
			sprintf(jar_word[jar_line++],"\tldc 1\n");
			push(1);
			if(typetable[op1-1]==1){
				sprintf(jar_word[jar_line++],"\tiload %d\n",op1-1);
				push(1);
				type=0;
			}	
			
		
			else if(typetable[op1-1]==2){
				sprintf(jar_word[jar_line++],"\tfload %d\n",op1-1);
				push(2);
				type=0;
			
			}
			int a=pop();
			int b=pop();
			if(a+b==2) {sprintf(jar_word[jar_line++],"\tiadd\n"); push(1);}
			else if(a==1&&b==2) {
				sprintf(jar_word[jar_line++],"\ti2f\n");
				sprintf(jar_word[jar_line++],"\tfadd\n"); 
				push(2);
			}
			else if(a==2&&b==1){
				sprintf(jar_word[jar_line++],"\tswap\n");
				sprintf(jar_word[jar_line++],"\ti2f\n");
				sprintf(jar_word[jar_line++],"\tswap\n");
				sprintf(jar_word[jar_line++],"\tfadd\n");
				push(2);
			}
				else if(a+b==4){
				sprintf(jar_word[jar_line++],"\tfadd\n");
				push(2);
			}
		int cc=pop();
		if(typetable[op1-1]==2){
			if(cc==1) sprintf(jar_word[jar_line++],"\ti2f\n");
			sprintf(jar_word[jar_line++],"\tfstore %d\n",op1-1);
		}
		else if(typetable[op1-1]==1){
			if(cc==2) sprintf(jar_word[jar_line++],"\tf2i\n");
			sprintf(jar_word[jar_line++],"\tistore %d\n",op1-1);
		}
		 }
		}
	|INC ID  {
		strcpy(tmp,$2);
		int index=lookup_symbol(tmp);
		if(index==0) { printf("<ERROR> can't find variable %s (line %d)\n",tmp,yylineno); $$=0;jerror=1;}
	 	else {
			printf("INC\n");
			numbertable[index-1]++;
			$$=numbertable[index-1];
		 }
		}
	|ID DEC  {
		strcpy(tmp,$1);
		int op1=lookup_symbol(tmp);
		if(op1==0) { printf("<ERROR> can't find variable %s (line %d)\n",tmp,yylineno); $$=0;jerror=1;}
	 	else {
			printf("DEC\n");
			$$=numbertable[op1-1];
			numbertable[op1-1]--;
			sprintf(jar_word[jar_line++],"\tldc -1\n");
			push(1);
			if(typetable[op1-1]==1){
			sprintf(jar_word[jar_line++],"\tiload %d\n",op1-1);
			push(1);
			type=0;
		}	
			
		
		else if(typetable[op1-1]==2){
			sprintf(jar_word[jar_line++],"\tfload %d\n",op1-1);
			push(2);
			type=0;
			
		}
		int a=pop();
		int b=pop();
		if(a+b==2) {sprintf(jar_word[jar_line++],"\tiadd\n"); push(1);}
				else if(a==1&&b==2) {
				sprintf(jar_word[jar_line++],"\ti2f\n");
				sprintf(jar_word[jar_line++],"\tfadd\n"); 
				push(2);
				}
				else if(a==2&&b==1){
				sprintf(jar_word[jar_line++],"\tswap\n");
				sprintf(jar_word[jar_line++],"\ti2f\n");
				sprintf(jar_word[jar_line++],"\tswap\n");
				sprintf(jar_word[jar_line++],"\tfadd\n");
				push(2);
				}
				else if(a+b==4){
				sprintf(jar_word[jar_line++],"\tfadd\n");
				push(2);
				}
		if(typetable[op1-1]==2){
			if(pop()==1) sprintf(jar_word[jar_line++],"\ti2f\n");
			sprintf(jar_word[jar_line++],"\tfstore %d\n",op1-1);
		}
		else if(typetable[op1-1]==1){
			if(pop()==2) sprintf(jar_word[jar_line++],"\tf2i\n");
			sprintf(jar_word[jar_line++],"\tistore %d\n",op1-1);
		}
		 }
		}
	|DEC ID {
		strcpy(tmp,$2);
		int index=lookup_symbol(tmp);
		if(index==0) { printf("<ERROR> can't find variable %s (line %d)\n",tmp,yylineno); $$=0;jerror=1;}
	 	else {
			printf("DEC\n");
			numbertable[index-1]--;
			$$=numbertable[index-1];
		 }
		}
    	//|get_val GRT get_val  {if($1>$3) {printf("true\n"); $$=1;}else{printf("false\n");  $$=-1;}}
	//|get_val GRTEQ get_val {if($1>=$3) {printf("true\n"); $$=1;}else{printf("false\n");  $$=-1;}}
	//|get_val LESSEQ	get_val {if($1<=$3) {printf("true\n"); $$=1;}else{printf("false\n");  $$=-1;}}
    	//|get_val LESS get_val {if($1>$3) {printf("true\n"); $$=1;}else{printf("false\n");  $$=-1;}}
    	//|get_val EQT get_val  {if($1==$3) {printf("true\n"); $$=1;}else{printf("false\n");  $$=-1;}}
    	//|get_val NEQ get_val  {if($1!=$3) {printf("true\n"); $$=1;}else{printf("false\n");  $$=-1;}}
    	//|get_val AND get_val {if($1==1&&$3==1) {printf("true\n"); $$=1;}else{printf("false\n");  $$=-1;}}
    	//|get_val OR get_val {if($1==1||$3==1) {printf("true\n"); $$=1;}else{printf("false\n");  $$=-1;}}
	|F
;

F
	: LB get_val RB		{$$=$2;}
	| number		{$$=$1;}
;
	
number //define type
    :F_CONST	{type=2;
		$$=$1;
		sprintf(jar_word[jar_line++],"\tldc %lf\n",$1);
		push(2);
		}
    |I_CONST	{$$=$1;
		type=1;
		sprintf(jar_word[jar_line++],"\tldc %d\n",$1);
		push(1);
		}
    | ID	{
		strcpy(tmp,$1);
		int index=lookup_symbol(tmp);
		if(index==0) { printf("<ERROR> can't find variable %s (line %d)\n",tmp,yylineno+1); $$=0;jerror=1;}
	 	else {
			if(typetable[index-1]==2)//type is float
			{	
				type=2;
				push(2);
				int a=index-1;
				sprintf(jar_word[jar_line++],"\tfload %d\n",a);
			}	

			else {
				//type=1;
				int a=index-1;
				push(1);
				sprintf(jar_word[jar_line++],"\tiload %d\n",a);
				//if(type==2){
				//sprintf(jar_word[jar_line++],"\ti2f\n");
				//}
			}
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
	 if(lookup_symbol(tmp)!=0){ printf("<ERROR> re-declaration for variable %s (line %d)\n",tmp,yylineno); jerror=1;}
	 else {//if(type==2&&ntype!=2) printf("Line %d  Semantic Error : assign float32 to int type variable\n",yylineno);
		 { tempf=$5;insert_symbol();tempf=0;}	
		//sprintf(jar_word[jar_line++],"\tldc %lf\n",$5);
		printf("$3:");
		printf("%s\n",$3);
		if(strcmp($3,"int")==0){
			int cc=pop();
			if(cc==2) sprintf(jar_word[jar_line++],"\tf2i\n");
			sprintf(jar_word[jar_line++],"\tistore %d\n",var_num);
		}
		else 	{
		int cc=pop();
			if(cc==1) sprintf(jar_word[jar_line++],"\ti2f\n");
		sprintf(jar_word[jar_line++],"\tfstore %d\n",var_num);
		}
		var_num++;	
	      } 
	}
    
    | VAR ID numtype
	{
	 declarenum=1;
	 strcpy(tmp,$2);
	 //printf("%s",tmp);
	 if(lookup_symbol(tmp)!=0) {printf("<ERROR> re-declaration for variable %s (line %d)\n",tmp,yylineno);jerror=1;} 
	 else {//if(type==2&&ntype!=2) printf("Line %d  Semantic Error : assign float32 to int type variable\n",yylineno);
		{ tempf=0;insert_symbol();}
		//sprintf(jar_word[jar_line++],"\tldc 0\n");
		sprintf(jar_word[jar_line++],"\tldc 0\n");
		if(strcmp($3,"int")==0)	
			sprintf(jar_word[jar_line++],"\tistore %d\n",var_num);
		else 	sprintf(jar_word[jar_line++],"\tfstore %d\n",var_num);
		var_num++;	
	      } 
	}
;
	
numtype
    : INT 	{ntype=1;$$="int";}
    | FLOAT	{ntype=2;$$="float32";}
;

expression_stat
    :ID ASSIGN get_val
	{
	 printf("ASSIGN\n");
	 strcpy(tmp,$1);
	 op1=lookup_symbol(tmp);	
	 if(op1==0) {printf("<ERROR> can't find variable %s (line %d)\n",tmp,yylineno); jerror=1;}
	 else {
		numbertable[op1-1]=$3;
		int a=pop();
		if(typetable[op1-1]==1){
			if(a==1){
			sprintf(jar_word[jar_line++],"\tistore %d\n",op1-1);
			}
			else if(a==2){
			sprintf(jar_word[jar_line++],"\tf2i\n");
			sprintf(jar_word[jar_line++],"\tistore %d\n",op1-1);
			}
		}
		if(typetable[op1-1]==2){
			if(a==1){
			sprintf(jar_word[jar_line++],"\ti2f\n");
			sprintf(jar_word[jar_line++],"\tfstore %d\n",op1-1);
			}
			else if(a==2){
			
			sprintf(jar_word[jar_line++],"\tfstore %d\n",op1-1);
			}
		}
		// printf("Line %d  Semantic Error : assign float32 to int type variable\n",yylineno);}		
	}
	 //type=0;
	}
    |ID ADDEQ get_val
	{
	 printf("ADDEQ\n");
	 strcpy(tmp,$1);
	 op1=lookup_symbol(tmp);	
	 if(op1==0) {printf("<ERROR> can't find variable %s (line %d)\n",tmp,yylineno); jerror=1;}
	 else {
		float tmpnum=numbertable[op1-1]+$3;
		numbertable[op1-1]=tmpnum;		
		//hw3
		if(typetable[op1-1]==1){
			sprintf(jar_word[jar_line++],"\tiload %d\n",op1-1);
			push(1);
			type=0;
		}	
			
		
		else if(typetable[op1-1]==2){
			sprintf(jar_word[jar_line++],"\tfload %d\n",op1-1);
			push(2);
			type=0;
			
		}
		int a=pop();
		int b=pop();
		sprintf(jar_word[jar_line++],"\tswap\n");
		if(a+b==2) {sprintf(jar_word[jar_line++],"\tiadd\n"); push(1);}
				else if(a==1&&b==2) {
				sprintf(jar_word[jar_line++],"\ti2f\n");
				sprintf(jar_word[jar_line++],"\tfadd\n"); 
				push(2);
				}
				else if(a==2&&b==1){
				sprintf(jar_word[jar_line++],"\tswap\n");
				sprintf(jar_word[jar_line++],"\ti2f\n");
				sprintf(jar_word[jar_line++],"\tswap\n");
				sprintf(jar_word[jar_line++],"\tfadd\n");
				push(2);
				}
				else if(a+b==4){
				sprintf(jar_word[jar_line++],"\tfadd\n");
				push(2);
				}
		if(typetable[op1-1]==2){
			if(pop()==1) sprintf(jar_word[jar_line++],"\ti2f\n");
			sprintf(jar_word[jar_line++],"\tfstore %d\n",op1-1);
		}
		else if(typetable[op1-1]==1){
			if(pop()==2) sprintf(jar_word[jar_line++],"\tf2i\n");
			sprintf(jar_word[jar_line++],"\tistore %d\n",op1-1);
		}
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
	 if(op1==0) {printf("<ERROR> can't find variable %s (line %d)\n",tmp,yylineno); jerror=1;}
	 else {
		float tmpnum=numbertable[op1-1]-$3;
		numbertable[op1-1]=tmpnum;
		//if(type==2&&typetable[op1-1]!=2){
		 //printf("Line %d  Semantic Error : assign float32 to int type variable\n",yylineno);}	
		if(typetable[op1-1]==1){
			sprintf(jar_word[jar_line++],"\tiload %d\n",op1-1);
			push(1);
			type=0;
		}	
			
		
		else if(typetable[op1-1]==2){
			sprintf(jar_word[jar_line++],"\tfload %d\n",op1-1);
			push(2);
			type=0;
			
		}
		int a=pop();
		int b=pop();
		sprintf(jar_word[jar_line++],"\tswap\n");
		if(a+b==2) {sprintf(jar_word[jar_line++],"\tisub\n"); push(1);}
				else if(a==1&&b==2) {
				sprintf(jar_word[jar_line++],"\ti2f\n");
				sprintf(jar_word[jar_line++],"\tfsub\n"); 
				push(2);
				}
				else if(a==2&&b==1){
				sprintf(jar_word[jar_line++],"\tswap\n");
				sprintf(jar_word[jar_line++],"\ti2f\n");
				sprintf(jar_word[jar_line++],"\tswap\n");
				sprintf(jar_word[jar_line++],"\tfsub\n");
				push(2);
				}
				else if(a+b==4){
				sprintf(jar_word[jar_line++],"\tfsub\n");
				push(2);
				}
		if(typetable[op1-1]==2){
			if(pop()==1) sprintf(jar_word[jar_line++],"\ti2f\n");
			sprintf(jar_word[jar_line++],"\tfstore %d\n",op1-1);
		}
		else if(typetable[op1-1]==1){
			if(pop()==2) sprintf(jar_word[jar_line++],"\tf2i\n");
			sprintf(jar_word[jar_line++],"\tistore %d\n",op1-1);
		}	
	}
	// type=0;
	}
    |ID MULEQ get_val
	{
	 printf("MULEQ\n");
	 strcpy(tmp,$1);
	 op1=lookup_symbol(tmp);	
	 if(op1==0) {printf("<ERROR> can't find variable %s (line %d)\n",tmp,yylineno); jerror=1;}
	 else {
		float tmpnum=numbertable[op1-1]*$3;
		numbertable[op1-1]=tmpnum;		
		//if(type==2&&typetable[op1-1]!=2){
		 //printf("Line %d  typetable is %d Semantic Error  assign float32 to int type variable\n",yylineno,typetable[op1-1]);}		
	if(typetable[op1-1]==1){
			sprintf(jar_word[jar_line++],"\tiload %d\n",op1-1);
			push(1);
			type=0;
		}	
			
		
		else if(typetable[op1-1]==2){
			sprintf(jar_word[jar_line++],"\tfload %d\n",op1-1);
			push(2);
			type=0;
			
		}
		int a=pop();
		int b=pop();
		sprintf(jar_word[jar_line++],"\tswap\n");
		if(a+b==2) {sprintf(jar_word[jar_line++],"\timul\n"); push(1);}
				else if(a==1&&b==2) {
				sprintf(jar_word[jar_line++],"\ti2f\n");
				sprintf(jar_word[jar_line++],"\tfmul\n"); 
				push(2);
				}
				else if(a==2&&b==1){
				sprintf(jar_word[jar_line++],"\tswap\n");
				sprintf(jar_word[jar_line++],"\ti2f\n");
				sprintf(jar_word[jar_line++],"\tswap\n");
				sprintf(jar_word[jar_line++],"\tfmul\n");
				push(2);
				}
				else if(a+b==4){
				sprintf(jar_word[jar_line++],"\tfmul\n");
				push(2);
				}
		if(typetable[op1-1]==2){
			if(pop()==1) sprintf(jar_word[jar_line++],"\ti2f\n");
			sprintf(jar_word[jar_line++],"\tfstore %d\n",op1-1);
		}
		else if(typetable[op1-1]==1){
			if(pop()==2) sprintf(jar_word[jar_line++],"\tf2i\n");
			sprintf(jar_word[jar_line++],"\tistore %d\n",op1-1);
		}
	}
	 //type=0;
	}

    |ID DIVEQ get_val
	{
	 printf("DIVEQ\n");
	 strcpy(tmp,$1);
	 op1=lookup_symbol(tmp);	
	 if($3==0){ printf("<ERROR> The divisor can't be 0 (line %d)\n",yylineno); tempf=-1;jerror=1;}
	 if(op1==0) {printf("<ERROR> can't find variable %s (line %d)\n",tmp,yylineno); jerror=1;}
	 else {
		float tmpnum=numbertable[op1-1]/$3;
		numbertable[op1-1]=tmpnum;	
		//if(type==2&&typetable[op1-1]!=2){
		 //printf("Line %d  Semantic Error : assign float32 to int type variable\n",yylineno);}	
		if(typetable[op1-1]==1){
			sprintf(jar_word[jar_line++],"\tiload %d\n",op1-1);
			push(1);
			type=0;
		}	
			
		
		else if(typetable[op1-1]==2){
			sprintf(jar_word[jar_line++],"\tfload %d\n",op1-1);
			push(2);
			type=0;
			
		}
		int a=pop();
		int b=pop();
		sprintf(jar_word[jar_line++],"\tswap\n");
		if(a+b==2) {sprintf(jar_word[jar_line++],"\tidiv\n"); push(1);}
				else if(a==1&&b==2) {
				sprintf(jar_word[jar_line++],"\ti2f\n");
				sprintf(jar_word[jar_line++],"\tfdiv\n"); 
				push(2);
				}
				else if(a==2&&b==1){
				sprintf(jar_word[jar_line++],"\tswap\n");
				sprintf(jar_word[jar_line++],"\ti2f\n");
				sprintf(jar_word[jar_line++],"\tswap\n");
				sprintf(jar_word[jar_line++],"\tfdiv\n");
				push(2);
				}
				else if(a+b==4){
				sprintf(jar_word[jar_line++],"\tfdiv\n");
				push(2);
				}
		if(typetable[op1-1]==2){
			if(pop()==1) sprintf(jar_word[jar_line++],"\ti2f\n");
			sprintf(jar_word[jar_line++],"\tfstore %d\n",op1-1);
		}
		else if(typetable[op1-1]==1){
			if(pop()==2) sprintf(jar_word[jar_line++],"\tf2i\n");
			sprintf(jar_word[jar_line++],"\tistore %d\n",op1-1);
		}	
	}
	}
    |ID REMEQ get_val
	{
	 printf("ModEQ\n");
	 strcpy(tmp,$1);
	 op1=lookup_symbol(tmp);	
	 if(op1==0){ printf("<ERROR> can't find variable %s (line %d)\n",tmp,yylineno); jerror=1;}
	 else {	
	 
		float tmpnum=numbertable[op1-1]/$3;
		numbertable[op1-1]=tmpnum;	
		//if(type==2&&typetable[op1-1]!=2){
		 //printf("Line %d  Semantic Error : assign float32 to int type variable\n",yylineno);}	
		if(typetable[op1-1]==1){
			sprintf(jar_word[jar_line++],"\tiload %d\n",op1-1);
			push(1);
			type=0;
		}	
			
		
		else if(typetable[op1-1]==2){
			sprintf(jar_word[jar_line++],"\tfload %d\n",op1-1);
			push(2);
			type=0;
			
		}
		int a=pop();
		int b=pop();
		sprintf(jar_word[jar_line++],"\tswap\n");
		if(a+b==2) {
			sprintf(jar_word[jar_line++],"\tirem\n");
			sprintf(jar_word[jar_line++],"\tistore %d\n",op1-1);
		}
		else if($3==0){
		printf("<ERROR> divisor can't be zero (line %d)\n",yylineno);
			jerror=1;
		}
		else {
			//Error
			printf("<ERROR> opetator ModEQ has float oprands (line %d)\n",yylineno);
			jerror=1;
		}	
	}
			
	}
	
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
void push(int a){
	if(a==1){
	type_stack[tl++]=1;
	printf("push 1\n");
	}
	else if (a==2){
		type_stack[tl++]=2;
		printf("push 2\n");
	}
}
/* C code section */
void lpush(int a){
lstack[ll++]=a;
printf("lpush %d\n",a);
}
int lpop(){
int a=lstack[ll-1];
lstack[ll-1]=0;
ll--;
printf("lpop %d\n",a);
return a;
}
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
int tcheck(){
if(type_stack[tl-1]+type_stack[tl-2]==3) return 3;
if(type_stack[tl-1]+type_stack[tl-2]==4) return 4;
if(type_stack[tl-1]+type_stack[tl-2]==2) return 2; 
}
int pop(){
	printf("pop\n");
	int a=type_stack[tl-1];
	type_stack[tl-1]=0;
	tl--;
	return a;
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
    sprintf(jar_word[jar_line++],".class public main\n");
    sprintf(jar_word[jar_line++],".super java/lang/Object\n");
    sprintf(jar_word[jar_line++],".method public static main([Ljava/lang/String;)V\n");
    sprintf(jar_word[jar_line++],".limit stack 10\n");
    sprintf(jar_word[jar_line++],".limit locals 10\n");
    
    yyparse();
    
    sprintf(jar_word[jar_line++],"\treturn\n");
    sprintf(jar_word[jar_line++],".end method");
    if(jerror==0){
    	jac=fopen("Computer.j","w");
    	for(int i=0;i<jar_line;i++)
        	fprintf(jac,jar_word[i]);
    	fclose(jac);
    }
    printf("\nTotal lines:%d\n\n",yylineno);
    if(create==1)
    	dump_symbol();
    return 0;
}
