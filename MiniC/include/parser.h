typedef union
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
} YYSTYPE;
#define	IDENTIFIER	258
#define	INTEGER_NUM	259
#define	DOUBLE_NUM	260
#define	FLOAT_NUM	261
#define	BOOL_LITERAL	262
#define	MAIN	263
#define	INT	264
#define	FLOAT	265
#define	DOUBLE	266
#define	VOID	267
#define	BOOL	268
#define	CHAR	269
#define	CEQ	270
#define	CNE	271
#define	CLT	272
#define	CLE	273
#define	CGT	274
#define	CGE	275
#define	EQUAL	276
#define	LPAREN	277
#define	RPAREN	278
#define	LBRACE	279
#define	RBRACE	280
#define	COMMA	281
#define	DOT	282
#define	SEMICOLON	283
#define	PLUS	284
#define	MINUS	285
#define	MUL	286
#define	DIV	287
#define	MOD	288
#define	LSHIFT	289
#define	RSHIFT	290
#define	NOT	291
#define	TILDA	292
#define	IF	293
#define	ELSE	294
#define	WHILE	295
#define	RETURN	296
#define	OR	297
#define	AND	298
#define	LE	299
#define	LT	300
#define	GT	301
#define	GE	302
#define	EQ	303
#define	NE	304
#define	UNARY_OP	305


extern YYSTYPE yylval;
