%{
    #include <cstdio>
    #include <cstdlib>

    #include "node.h"

    using namespace std;

    Block*    pProgramBlock; /* the top level root node of our final AST */
    MainDefn* pMain;

    extern int yylex();
    extern unsigned int lineNo;
    extern char *yytext;
    extern char linebuf[50];

    void yyerror(char *s)
    {
         printf("Line %d: %s at %s in this line:\n%s\n",
                lineNo, s, yytext, linebuf);
    }
%}

/* Represents the many different ways we can access our data */
%union
{
    Node                                      *node;
    Block                                     *block;
    Expr                                      *expr;
    Stmt                                      *stmt;
    Identifier                                *ident;
    Variable                                  *var_decl;
    DataType                                  *data_type;
    std::vector<Variable*>                    *varvec;
    std::vector<Expr*>                        *exprvec;
    std::string                               *string;
    int                                        token;
}

/* Define our terminal symbols (tokens). This should
   match our tokens.l lex file. We also define the node type
   they represent.
 */

/* constant types */
%token <string> IDENTIFIER 
%token <string> INTEGER_NUM 
%token <string> DOUBLE_NUM 
%token <string> FLOAT_NUM 
%token <string> BOOL_LITERAL

/* data types */
%token <string> MAIN 
%token <string> INT
%token <string> FLOAT
%token <string> DOUBLE
%token <string> VOID
%token <string> BOOL
%token <string> CHAR

/* Conditional Expression */
%token <token> CEQ 
%token <token> CNE 
%token <token> CLT 
%token <token> CLE 
%token <token> CGT 
%token <token> CGE 
%token <token> EQUAL

/* other indicators */
%token <token> LPAREN 
%token <token> RPAREN 
%token <token> LBRACE 
%token <token> RBRACE 
%token <token> COMMA 
%token <token> DOT 
%token <token> SEMICOLON

/* Operations */
%token <token> PLUS 
%token <token> MINUS 
%token <token> MUL 
%token <token> DIV
%token <token> MODULUS
%token <token> LSHIFT
%token <token> RSHIFT

/* Conditions branches */
%token <token> IF 
%token <token> ELSE 
%token <token> WHILE 
%token <token> RETURN

/* Define the type of node our nonterminal symbols represent.
   The types refer to the %union declaration above. Ex: when
   we call an ident (defined by union type ident) we are really
   calling an (Identifier*). It makes the compiler happy.
 */

%type <stmt> main_decl 
%type <stmt> main_defn 
%type <stmt> func_decl 
%type <stmt> func_defn
%type <ident> ident
%type <expr> numeric 
%type <expr> expr 
%type <varvec> func_args
%type <exprvec> call_args
%type <block> program 
%type <block> stmts 
%type <block> block
%type <stmt> stmt 
%type <stmt> var_decl
%type <token> comparison
%type <data_type> data_type

/* Operator precedence for mathematical operators */
%left PLUS MINUS
%left MUL DIV

%start program

%%

data_type : INT    { $$ = new DataType(C_INT, lineNo); delete $1; }
          | FLOAT  { $$ = new DataType(C_FLOAT, lineNo); delete $1; }
          | DOUBLE { $$ = new DataType(C_DOUBLE, lineNo); delete $1; }
          ;

program : stmts { pProgramBlock = $1; }
        ;
        
stmts : stmt { $$ = new Block(lineNo); $$->AddStmt($<stmt>1); }
      | stmts stmt { $1->AddStmt($<stmt>2); }
      ;

stmt : var_decl 
     | main_decl
     | func_decl 
     | func_defn 
     | main_defn
     | expr { $$ = new ExprStmt($1, lineNo); }
     ;

block : LBRACE stmts RBRACE { $$ = $2; }
      | LBRACE RBRACE { $$ = new Block(lineNo); }
      ;

var_decl : data_type ident SEMICOLON { $$ = new Variable($1, $2, lineNo); }
         | data_type ident EQUAL expr SEMICOLON { $$ = new Variable($1, $2, $4, lineNo); }
         | data_type ident
         ;

main_decl : data_type MAIN LPAREN func_args RPAREN SEMICOLON 
            {
                std::cout << "Errorrrrrrrrrrrrrrrrrrrrrr" << std::endl;
                yyerror("WARNING: Main Declaration not allowed\n");
            }
          ;

main_defn : data_type MAIN LPAREN func_args RPAREN block
            { 
                pMain = new MainDefn($1, *$4, $6, lineNo); 
                $$ = pMain; 
            }
          ;

func_decl : data_type ident LPAREN func_args RPAREN SEMICOLON 
            { 
                $$ = new FuncDecl($1, $2, *$4, lineNo);
            }
          ;

func_defn : data_type ident LPAREN func_args RPAREN block 
            { 
                $$ = new FuncDefn($1, $2, *$4, $6, lineNo);
            }
          ;	
                  
func_args : /*blank*/  { $$ = new VariableList(lineNo); }
          | var_decl { $$ = new VariableList(); $$->push_back($<var_decl>1); }
          | func_args COMMA var_decl { $1->push_back($<var_decl>3); }
          ;

ident : IDENTIFIER { $$ = new Identifier(*$1, lineNo); }
      ;

numeric : INTEGER_NUM { $$ = new Integer(atol($1->c_str()), lineNo); }
        | DOUBLE_NUM  { $$ = new Double(atof($1->c_str()), lineNo); }
        | FLOAT_NUM   { $$ = new Float(atof($1->c_str()), lineNo); }
        ;
    
expr : ident EQUAL expr SEMICOLON { $$ = new Assignment($<ident>1, $3, lineNo); }
     | ident LPAREN call_args RPAREN { $$ = new FunctionCall($1, *$3, lineNo); }
     | ident { $<ident>$ = $1; }
     | numeric
     | expr comparison expr { $$ = new BinaryOperator($1, $2, $3, lineNo); }
     | LPAREN expr RPAREN { $$ = $2; }
     ;
    
call_args : /*blank*/  { $$ = new ExprList(lineNo); }
          | expr { $$ = new ExprList(lineNo); $$->push_back($1); }
          | call_args COMMA expr  { $1->push_back($3); }
          ;

comparison : CEQ | CNE | CLT | CLE | CGT | CGE 
           | PLUS | MINUS | MUL | DIV
           ;

%%