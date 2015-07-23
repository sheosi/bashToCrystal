grammar bash;

//Gobo-specific
importStm: 'Import' space* STRING;
params: 'Parameters' (space* STRING)+;
//Parser tokens->program
sheBang: '#!'(STRING|'/')+  (space+ '('STRING')')? '\n';
function: 'function' SPACE+ STRING SPACE*'()' '{' (program|pipe)*'}';
ifStmt: 'if' testContent NEWLINE 'then' ('elif' testContent NEWLINE'then')* ('else')? 'fi';
case: 'case' QUOTEDSTRING 'in' caseStatement+ 'esac';
caseStatement: (QUOTEDSTRING|'*' )')'  NEWLINE NEWLINE;
forLoop:  'for' STRING 'in' QUOTEDSTRING NEWLINE 'do' NEWLINE;
testContent: '[' testPrefix? testStatement (testPrefix? testConnector testStatement)']';
testStatement: assignment|comparation;
testConnector: '-a'| '-o';
testPrefix: '-n';
assignment:  rvariable '=' variable;
comparation: variable '==' variable;
rvariable: STRING;
variable: '"' '$' '{'STRING'}' '"';
bashFile: sheBang? (COMMENT|function|importStm);
space: (' '|'\t');
pipe: program'|'program;
program: STRING (argument|longArg)*;
argument:'-'SMALLCAPS (SPACE QUOTEDSTRING)? '\\'?;
longArg:'--'STRING (SPACE QUOTEDSTRING)? '\\'?;

SPACE: ' ';
NEWLINE:  ENDCHAR|';';
STRING: (SMALLCAPS|BIGCAPS|'_')+;
QUOTEDSTRING: '"'(STRING|'@'|'$'|'|'|'.')+'"';
COMMENT:'#'(SMALLCAPS|BIGCAPS|SPACE)+ NEWLINE;
fragment ENDCHAR: '\n';
SMALLCAPS: [a-z];
fragment BIGCAPS: [A-Z];