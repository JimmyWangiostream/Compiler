/* Definition section */
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	/* Symbol table function */
	void create_symbol();
	void insert_symbol();
	int lookup_symbol();
	void dump_symbol();
	int i=0;
	int ans=0;
	int slashcom=0;
	int starcom=0;
	int commandnum=0;
	int linenum=0;
	int starfinish=0;
	int tablenum=0;
	char tablenumber[20];
	char check[30];
	char tmp[30];
	char s[50];
	char type[30];
	char table[600];
	char id[80][150];
	int created=0;
	int last=0;
	int p=0; 
	/*
			var=1; var ID=2;var ID int/double ; =>(creat table) insert_symbol
			  	
		    */	

%}

/* Define regular expression label */

letter [a-zA-Z]
digit [0-9]
id {letter}+({letter}|{digit})*
number {digit}+

/* Rules section */
%%

"("	{	
	 if((slashcom==0)&&(starcom==0)){
		 printf("%s \t LB \n", yytext);
	 }
	 else
		printf("%s",yytext); 
	}

")"	{	
	 if((slashcom==0)&&(starcom==0)){
		 if(p=1)
			p=0;
		 printf("%s \t RB \n", yytext);
	 }
	 else
		printf("%s",yytext);
	}

"{"	{	
	 if((slashcom==0)&&(starcom==0)){
		 printf("%s \t LCB \n", yytext);
	 }
	 else
		printf("%s",yytext);
	}

"}"	{	
	 if((slashcom==0)&&(starcom==0)){
		 printf("%s \t RCB \n", yytext);
	 }
	 else
		printf("%s",yytext);
	}

"“"	{	
	 if((slashcom==0)&&(starcom==0)){
		 printf("%s \t LQ \n", yytext);
	 }
	 else
		printf("%s",yytext);
	}

"”"	{	
	 if((slashcom==0)&&(starcom==0)){
		 printf("%s \t RQ \n", yytext);
	 }
	 else
		printf("%s",yytext);
	}
"int"   {
	 if((slashcom==0)&&(starcom==0)){
	 	if(last==2){//var ID type
			if(lookup_symbol(tmp)!=0)//ID has existed in table
			{	
				printf("Syntax Error: Redefined variables %s\n",tmp);
				printf("%s \t ID \n",tmp);
			}
			else{	
				strcpy(type,yytext);
				printf("%s        %s TYPE VAR\n",tmp,type);
	 			if(created==0){		
				created=1;
				create_symbol();
				}
				insert_symbol();
			}
 			last=0;
	 	}
	 }
  	 else
		printf("%s",yytext);
	}

"float32"   {
	 if((slashcom==0)&&(starcom==0)){
	 	if(last==2){//var ID type
			if(lookup_symbol(tmp)!=0)//ID has existed in table
			{
				printf("Syntax Error: Redefined variables %s\n",tmp);
				printf("%s \t ID \n",tmp);
			}
			else{	
				strcpy(type,yytext);
				printf("%s        %s TYPE VAR\n",tmp,type);
	 			if(created==0){		
				created=1;
				create_symbol();
				}
				insert_symbol();
			}
 			last=0;
	 	}
	 }
  	 else
		printf("%s",yytext);
	}
"var"	{	
	 if((slashcom==0)&&(starcom==0))
		last=1;
	 else printf("%s",yytext);
	}
"/*"	{
	 if((slashcom==0)&&(starcom==0))
	 {
		starcom=1;
	 }
	 printf("%s",yytext);
	}
"*/"    {
	 if(starcom==1)
	{
		starcom=0;
		commandnum++;
		printf("%s      C Comment\n",yytext);
	}
	 else
         	printf("%s",yytext);
	}
		
"//"	{
	 if((slashcom==0)&&(starcom==0)){
		slashcom=1;	
	 }
	 printf("%s",yytext);
	}
"+" 	{
	 if((slashcom==0)&&(starcom==0)){
		 printf("%s \t Add \n", yytext); 
	 }
	 else printf("%s",yytext);
	}
"++" 	{
	 if((slashcom==0)&&(starcom==0)){
		 printf("%s \t Increment \n", yytext); 
	 }
	 else printf("%s",yytext);
	}

"--" 	{
	 if((slashcom==0)&&(starcom==0)){
		 printf("%s \t Decrement \n", yytext); 
	 }
	 else printf("%s",yytext);
	}

"*" 	{
	 if((slashcom==0)&&(starcom==0)){
		 printf("%s \t Mul \n", yytext); 
	 }
	 else printf("%s",yytext);
	}

"/" 	{
	 if((slashcom==0)&&(starcom==0)){
		 printf("%s \t Divison \n", yytext); 
	 }
	 else printf("%s",yytext);
	}

"%" 	{
	 if((slashcom==0)&&(starcom==0)){
		 printf("%s \t Remainder \n", yytext); 
	 }
	 else printf("%s",yytext);
	}
"-"	{
	 if((slashcom==0)&&(starcom==0)){
 		printf("%s \t Sub \n", yytext); 
	 }
	 else printf("%s",yytext);
	}

"<" 	{
	 if((slashcom==0)&&(starcom==0)){
		 printf("%s \t Less than \n", yytext); 
	 }
	 else printf("%s",yytext);
	}

">" 	{
	 if((slashcom==0)&&(starcom==0)){
		 printf("%s \t Greater than \n", yytext); 
	 }
	 else printf("%s",yytext);
	}

"<=" 	{
	 if((slashcom==0)&&(starcom==0)){
		 printf("%s \t Less than or equal to \n", yytext); 
	 }
	 else printf("%s",yytext);
	}

">=" 	{
	 if((slashcom==0)&&(starcom==0)){
		 printf("%s \t Greater than or equal to \n", yytext); 
	 }
	 else printf("%s",yytext);
	}

"==" 	{
	 if((slashcom==0)&&(starcom==0)){
		 printf("%s \t Equal to \n", yytext); 
	 }
	 else printf("%s",yytext);
	}

"!=" 	{
	 if((slashcom==0)&&(starcom==0)){
		 printf("%s \t Not equal to \n", yytext); 
	 }
	 else printf("%s",yytext);
	}

"if"	{ 
	 	if((slashcom==0)&&(starcom==0))
			printf("%s     IF function\n",yytext);
	 	else printf("%s",yytext);
		}

"else"	{ 
	 	if((slashcom==0)&&(starcom==0))
			printf("%s     ELSE function\n",yytext);
	 	else printf("%s",yytext);
		}

"for"	{ 
	 	if((slashcom==0)&&(starcom==0))
			printf("%s     FOR function\n",yytext);
	 	else printf("%s",yytext);
		}
"print"	{ 
	 	if((slashcom==0)&&(starcom==0)){
			p=1;
			printf("%s     PRINT function\n",yytext);
		}
	 	else printf("%s",yytext);
		}
"println"	{ 
	 	if((slashcom==0)&&(starcom==0)){
			p=1;
			printf("%s     PRINTLN function\n",yytext);
		}
	 	else printf("%s",yytext);
		}
{id}	{
	 
	 if((slashcom==0)&&(starcom==0)){
 	 	if(last==1){//var ID =>save ID
			last=2;
			strcpy(tmp,yytext);
	 	}
	
	 /*	else if(last==2){//var ID type
			if(lookup_symbol(tmp)!=0)//ID has existed in table
				printf("\nSyntax Error: Redefined variables\n");	
			strcpy(type,yytext);
			printf("%s        %s TYPE VAR\n",tmp,type);
	 		if(created==0){		
			created=1;
			create_symbol();
			}
			insert_symbol();
 			last=0;
	 	}*/
		else if(last==0){
			strcpy(check,yytext);
			if(p==0){
				if(lookup_symbol(check)==0)//ID not in table
					printf("Syntax Error: Undeclared variables %s\n",check);
					printf("%s \t ID \n",yytext);
			}
			else printf("%s \t ID \n", yytext);
	 	}			
	 } 
	 else printf("%s",yytext);
	}
\n	{ 
	 if(slashcom==1){
		commandnum++;
		printf("     C++ Comment");
		slashcom=0;
		printf("%s",yytext);
	 }
	 else if(starcom==1){
		commandnum++;
		printf("%s",yytext);
	 }	
	 linenum++; 
	}
"="	{ 
	 if((slashcom==0)&&(starcom==0))
		printf("%s \t ASSIGN\n",yytext);
	 else printf("%s",yytext);
	}

"+="	{ 
	 if((slashcom==0)&&(starcom==0))
		printf("%s \t Increment left by right \n",yytext);
	 else printf("%s",yytext);
	}

"-="	{ 
	 if((slashcom==0)&&(starcom==0))
		printf("%s \t Decrement left by right\n",yytext);
	 else printf("%s",yytext);
	}

"*="	{ 
	 if((slashcom==0)&&(starcom==0))
		printf("%s \t left value Mul right value assign to left\n",yytext);
	 else printf("%s",yytext);
	}

"/="	{ 
	 if((slashcom==0)&&(starcom==0))
		printf("%s \t left value Div right value assign to left\n",yytext);
	 else printf("%s",yytext);
	}

"%="	{ 
	 if((slashcom==0)&&(starcom==0))
		printf("%s \t left value Rem right value assign to left\n",yytext);
	 else printf("%s",yytext);
	}

"&&"	{ 
	 if((slashcom==0)&&(starcom==0))
		printf("%s \t Logical AND\n",yytext);
	 else printf("%s",yytext);
	}

"||"	{ 
	 if((slashcom==0)&&(starcom==0))
		printf("%s \t Logical OR\n",yytext);
	 else printf("%s",yytext);
	}

"!"	{ 
	 if((slashcom==0)&&(starcom==0))
		printf("%s \t Logical NOT\n",yytext);
	 else printf("%s",yytext);
	}
.       {
	 if((slashcom==0)&&(starcom==0))
		  ;
	 else printf("%s",yytext);
	}

%%

/*	C Code section */
int yywrap(void)
{
    return 1;
}

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

int main(int argc,char *argv[])
{
	yyin = fopen(argv[1],"r");
	yylex();

	printf("\nParse over ,the line number is %d.\n",linenum);
	printf("\ncomment: %d lines\n",commandnum);
	dump_symbol();
	strcpy(s,"c");
	ans=lookup_symbol(s);
/*	if(ans!=0)
		printf("The symbol %s index is %d\n",s,ans);
        else
		printf("The symbol %s unexist in symbol table\n",s);
*/
	return 0;
}
