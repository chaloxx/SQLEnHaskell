{
module SqlParse (sqlParse) where
import Parsing (parse,identifier,integer,char,many,letter,alphanum,string2,dateTime,date,time,intParse)
import AST
import Data.Char
import ParseResult
import qualified Data.HashMap.Strict as H
import qualified Avl
import Error (errorComOpen,errorComClose)


}


%name sql
%tokentype { Token }
%monad { P } { thenP } { returnP }
%lexer {lexer} {TEOF}


%token
     INSERT           {TInsert}
     DELETE           {TDelete}
     UPDATE           {TUpdate}
     SELECT           {TSelect}
     FROM             {TFrom}
     ';'              {TSemiColon}
     WHERE            {TWhere}
     GROUPBY          {TGroupBy}
     HAVING           {THaving}
     ORDERBY          {TOrderBy}
     UNION            {TUnion}
     DIFF             {TDiff}
     INTERSECT        {TIntersect}
     AND              {TAnd}
     OR               {TOr}
     NE               {TNEqual}
     GE               {TGEqual}
     LE               {TLEqual}
     '='              {TEqual}
     '>'              {TGreat}
     '<'              {TLess}
     LIKE             {TLike}
     EXIST            {TExist}
     NOT              {TNot}
     Sum              {TSum}
     Count            {TCount}
     Avg              {TAvg}
     Min              {TMin}
     Max              {TMax}
     LIMIT            {TLimit}
     Asc              {TAsc}
     Desc             {TDesc}
     ALL              {TAll}
     '('              {TOpen}
     ')'              {TClose}
     ','              {TComa}
     AS               {TAs}
     SET              {TSet}
     FIELD            {TField $$}
     DISTINCT         {TDistinct}
     IN               {TIn}
     '.'              {TDot}
     '+'              {TPlus}
     '-'              {TMinus}
     '*'              {TTimes}
     '/'              {TDiv}
     NEG              {TNeg}

     CTABLE           {TCTable}
     CBASE            {TCBase}
     DTABLE           {TDTable}
     DALLTABLE        {TDAllTable}
     DBASE            {TDBase}
     PKEY             {TPkey}
     USE              {TUse}
     SHOWB            {TShowB}
     SHOWT            {TShowT}

     DATTIM           {TDatTim $$}
     DAT              {TDat $$}
     TIM              {TTim $$}
     STR              {TStr $$}
     NUM              {TNum $$}
     NUMFLOAT         {TNumFloat $$}
     NULL             {TNull}
     INT              {TInt}
     FLOAT            {TFloat}
     STRING           {TString}
     BOOL             {TBool}
     DATETIME         {TDateTime}
     DATE             {TDate}
     TIME             {TTime}

     SRC              {TSrc}
     CUSER            {TCUser}
     DUSER            {TDUser}
     SUSER            {TSUser}
     FKEY             {TFKey}

     REFERENCE        {TRef}
     DEL              {TDel}
     UPD              {TUpd}
     RESTRICTED       {TRestricted}
     CASCADES         {TCascades}
     NULLIFIES        {TNullifies}

     ON                {TOn}
     JOIN              {TJoin}
     LEFT              {TLeft}
     RIGHT             {TRight}
     INNER             {TInner}





%left NOT
%left OR
%left AND
%right ','
%nonassoc '=' '>' '<'
%nonassoc LIKE EXIST AS
%nonassoc ListString STRING
%nonassoc ToUpdate
%left '+' '-'
%left '*' '/'
%left NEG
%%


SQL :: {SQL}
SQL :   DML {S1 $1}
      | DDL {S2 $1}
      | MANUSERS {S3 $1}
      | SQL ';' {$1}
      | SQL ';' SQL  {Seq $1 $3}
      | SRC STR   {Source $2}


{--------------------------------}


MANUSERS :: {ManUsers}
MANUSERS : CUSER FIELD FIELD {CUser $2 $3}
         | DUSER FIELD FIELD {DUser $2 $3}
         | SUSER FIELD FIELD {SUser $2 $3}

{--------------------------------}

DML ::  {DML}
         : INSERT FIELD TreeListArgs {Insert $2 $3}
         | DELETE FIELD WHERE BoolExpW {Delete $2 $4}
         | UPDATE FIELD SET ToUpdate WHERE BoolExpW {Update $2 $4 $6}
         | Query {$1}

Query :: {DML}
       :  Query UNION Query {Union $1 $3}
       |  Query DIFF Query {Diff $1 $3}
       |  Query INTERSECT Query {Intersect $1 $3}
       | Query0 {$1}

Query0 :: { DML }
       : Query1 {$1}
       | '('Query1')' {$2}



Query1 : SELECT ArgS Query2     {Select False $2 $3}
      | SELECT DISTINCT ArgS Query2 {Select True $3 $4}


Query2  : FROM ArgF Query3    {From $2 $3}
       | Query3 {$1}



Query3 : WHERE BoolExpW Query4 {Where $2 $3}
      | Query4 {$1}

Query4 : GROUPBY ArgF Query5  {GroupBy $2 $3}
      | Query6 {$1}

Query5 : HAVING BoolExpH Query6 {Having $2 $3}
      | Query6 {$1}


Query6 : ORDERBY ArgF Order Query7   {OrderBy $2 $3 $4}
      | ORDERBY ArgF Query7          {OrderBy $2 A $3}
      | Query7 {$1}

Query7 : LIMIT NUM  {Limit $2 End}
       | {End}


ArgS :: {[Args]}
     : ArgS ',' ArgS {$1 ++ $3}
     | Exp {[$1]}

Exp  :: {Args}
     : FIELD {Field $1}
     | Aggregate {A2 $1}
     | Exp AS FIELD {As $1 (Field $3)}
     | '(' Query1')' AS FIELD {As (Subquery $2) (Field $5)}
     | FIELD'.'FIELD {Dot $1 $3}
     | IntExp {$1}
     | ALL {All}


IntExp :: {Args}
       : '('Exp ')' {$2}
       | Exp '+' Exp {Plus $1 $3}
       | Exp '-' Exp {Minus $1 $3}
       | Exp '*' Exp {Times $1 $3}
       | Exp '/' Exp {Div $1 $3}
       | '-' Exp %prec NEG {Negate $2}
       | NUM         {A3 $1}
       | NUMFLOAT       {A4 $1}

ArgF :: {[Args]}
    : ArgF AS FIELD {let [arg] = $1 in [As arg (Field $3)]}
    |'('ArgF')' {$2}
    | ArgF ',' ArgF    {$1 ++ $3}
    | FIELD {[Field $1]}
    | Query {[Subquery $1]}
    | ArgF JOIN ArgF ON Var '=' Var {let ([arg1],[arg2]) =($1,$3) in [Join Inner arg1 arg2 (Equal $5 $7)]}
    | ArgF  SomeJoin  JOIN ArgF ON Var '=' Var {let ([arg1],[arg2]) =($1,$4) in [Join $2 arg1 arg2 (Equal $6 $8)]}



Fields :: {[Args]}
     : FIELD            {[Field $1]}
     | Fields ',' Fields {$1 ++ $3}

BoolExpW :: {BoolExp}
         : '(' BoolExpW ')'          {$2}
         | BoolExpW AND BoolExpW     {And $1 $3}
         | BoolExpW OR  BoolExpW     {Or $1 $3}
         | ValueW GE ValueW          {GEqual $1 $3}
         | ValueW LE ValueW           {LEqual $1 $3}
         | ValueW '=' ValueW         {Equal $1 $3}
         | ValueW NE ValueW          {NEqual $1 $3}
         | ValueW '>' ValueW         {Great $1 $3}
         | ValueW '<' ValueW         {Less $1 $3}
         | NOT BoolExpW              {Not $2}
         | EXIST '(' Query ')'       {Exist $3}
         | Var LIKE STR              {Like $1 $3}
         | Var IN '(' Query ')'      {InQuery $1 $4}
         | Var IN '(' ListArgs ')'   {InVals $1 $4}


BoolExpH :: {BoolExp}
         : BoolExpH AND BoolExpH     {And $1 $3}
         | '(' BoolExpH ')'          {$2}
         | BoolExpH OR  BoolExpH     {Or $1 $3}
         | ValueH '=' ValueH         {Equal $1 $3}
         | ValueH '>' ValueH         {Great $1 $3}
         | ValueH '<' ValueH         {Less $1 $3}
         | NOT BoolExpH              {Not $2}
         | EXIST '(' Query ')'       {Exist $3}
         | Var LIKE STR              {Like $1 $3}




ValueH :: {Args}
       : Value                    {$1}
       | Aggregate                {A2 $1}

ValueW :: {Args}
       : Var   {$1}
       | Value {$1}


Var :: {Args}
       : FIELD         {Field $1}
       | FIELD'.'FIELD {Dot $1 $3}

Value :: {Args}
       : STR                      {A1 $1}
       | DATTIM                   {A5 $1}
       | DAT                      {A6 $1}
       | TIM                      {A7 $1}
       | IntExp                   {$1}
       | NULL                     {Nulo}


Aggregate :: {Aggregate}
          : Sum '('Var')'              {Sum False $3}
          | Sum '(' DISTINCT Var')'    {Sum True $4}

          | Count '('Var')'            {Count False $3}
          | Count '(' DISTINCT Var ')' {Count True $4}

          | Avg '('Var')'              {Avg False $3}
          | Avg '(' DISTINCT Var')'    {Avg True $4}

          | Min '('Var')'              {Min False $3}
          | Min '(' DISTINCT Var')'    {Min True $4}

          | Max '('Var')'              {Max False $3}
          | Max '(' DISTINCT Var')'    {Max True $4}



Order :: {O}
      : Asc             {A}
      | Desc            {D}



SomeJoin :: {JOINS}
         : INNER {Inner}
         | LEFT  {JLeft}
         | RIGHT {JRight}



TreeListArgs :: {Avl.AVL [Args]}
               :'(' ListArgs ')'              {Avl.singletonT $2}
               | TreeListArgs ',' TreeListArgs {Avl.join $1  $3}



ListArgs :: {[Args]}
        : STR {[A1 $1]}
        | NUM    {[A3 $1]}
        | DATTIM {[A5 $1]}
        | DAT {[A6 $1]}
        | TIM {[A7 $1]}
        | NULL   {[Nulo]}
        | ListArgs ',' ListArgs  { $1 ++ $3}




ToUpdate :: {([String],[Args])}
         : FIELD '=' Value {([$1],[$3])}
         | ToUpdate ',' ToUpdate {let ((k1,m1),(k2,m2)) = ($1,$3)
                                  in (k1 ++ k2, m1 ++ m2)}


{--------------------}

DDL :: {DDL}
    : CTABLE FIELD '('LCArgs')'   {CTable $2 $4}
    | DTABLE FIELD                {DTable $2}
    | DALLTABLE                   {DAllTable}
    | CBASE FIELD                 {CBase $2}
    | DBASE FIELD                 {DBase $2}
    | USE FIELD                   {Use $2}
    | SHOWB                     {ShowB}
    | SHOWT                     {ShowT}

LCArgs :: {[CArgs]}
      : CArgs   {[$1]}
      | LCArgs ',' LCArgs {$1 ++ $3}


CArgs :: {CArgs}
    : FIELD TYPE NULL {Col $1 $2 True}
    | FIELD TYPE      {Col $1 $2 False}
    | PKEY  '('FieldList')'     {PKey $3}
    | FKEY  '('FieldList')'
      REFERENCE FIELD '('FieldList')'
      DelReferenceOption
      UpdReferenceOption
      {FKey $3 $6 $8 $10 $11}



FieldList  :: {[String]}
            : FIELD {[$1]}
            | FieldList ',' FieldList {$1 ++ $3}




DelReferenceOption :: {RefOption}
                :                {Restricted}
                | DEL RESTRICTED {Restricted}
                | DEL CASCADES   {Cascades}
                | DEL NULLIFIES  {Nullifies}

UpdReferenceOption :: {RefOption}
                :                {Restricted}
                | UPD RESTRICTED {Restricted}
                | UPD CASCADES   {Cascades}
                | UPD NULLIFIES  {Nullifies}




TYPE :: {Type}
     : INT      {Int}
     | FLOAT    {Float}
     | BOOL     {Bool}
     | STRING   {String}
     | DATETIME {Datetime}
     | DATE     {Date}
     | TIME     {Time}



{

data Token =   TCUser
             | TDUser
             | TSUser
             | TInsert
             | TDelete
             | TUpdate
             | TLimit
             | TSet
             | TSelect
             | TFrom
             | TWhere
             | TGroupBy
             | THaving
             | TOrderBy
             | TAnd
             | TOr
             | TEqual
             | TNEqual
             | TGreat
             | TLess
             | TGEqual
             | TLEqual
             | TLike
             | TIn
             | TNot
             | TExist
             | TSum
             | TCount
             | TMin
             | TMax
             | TDistinct
             | TAvg
             | TSemiColon
             | TField String
             | TAsc
             | TDesc
             | TAll
             | TComa
             | TOpen
             | TClose
             | TAs
             | TDot
             | TPlus
             | TMinus
             | TTimes
             | TDiv
             | TNeg
             | TEOF

             | TCTable
             | TDTable
             | TDAllTable
             | TCBase
             | TDBase
             | TStr String
             | TNum Int
             | TString
             | TFloat
             | TNumFloat Float
             | TInt
             | TBool
             | TNull
             | TUse
             | TShowB
             | TShowT
             | TPkey
             | TSrc
             | TRef
             | TFKey
             | TDel
             | TUpd
             | TRestricted
             | TNullifies
             | TCascades

             | TUnion
             | TIntersect
             | TDiff
             | TDateTime
             | TDate
             | TTime
             | TDatTim DateTime
             | TDat   Dates
             | TTim Times

             | TOn
             | TJoin
             | TInner
             | TLeft
             | TRight



lexer cont  s = case s of
         [] -> cont TEOF []
         ('\n':xs) -> \(s1,s2) -> lexer cont xs (1 + s1,1)
         ('C':'R':'E':'A':'T':'E':' ':'U':'S':'E':'R':xs) -> \(s1,s2) ->  cont TCUser xs (s1,11 + s2)
         ('S':'E':'L':'E':'C':'T':' ':'U':'S':'E':'R':xs) -> \(s1,s2) ->  cont TSUser xs (s1,11 + s2)
         ('D':'E':'L':'E':'T':'E':' ':'U':'S':'E':'R':xs) -> \(s1,s2) ->  cont TDUser xs (s1,11 + s2)


         ('J':'O':'I':'N':xs) -> \(s1,s2) -> cont TJoin xs (s1,4 + s2)
         ('L':'E':'F':'T':xs) -> \(s1,s2) -> cont TLeft xs (s1,4 + s2)
         ('R':'I':'G':'H':'T':xs) -> \(s1,s2) -> cont TRight xs (s1,5 + s2)
         ('I':'N':'N':'E':'R':xs) -> \(s1,s2) -> cont TInner xs (s1,5 + s2)
         ('I':'N':'S':'E':'R':'T':xs) -> \(s1,s2) ->  cont TInsert xs (s1,6 + s2)
         ('O':'R':'D':'E':'R':' ':'B':'Y':xs) -> \(s1,s2) -> cont TOrderBy xs (s1,8 + s2)

         ('A':'N':'D':xs) -> \(s1,s2) ->  cont TAnd xs (s1,3 + s2)
         ('O':'R':xs) ->  \(s1,s2) ->  cont TOr xs (s1,2 + s2)
         ('N':'O':'T':xs) -> \(s1,s2) ->  cont TNot xs (s1,3 + s2)
         ('L':'I':'K':'E':xs) -> \(s1,s2) ->  cont TLike xs (s1,4 + s2)
         ('E':'X':'I':'S':'T':'S':xs) -> \(s1,s2) ->  cont TExist xs (s1,6 + s2)
         ('I':'N':xs) -> \(s1,s2) ->  cont TIn xs (s1,2 + s2)
         ('G':'R':'O':'U':'P':' ':'B':'Y':xs) -> \(s1,s2) ->  cont TGroupBy xs (s1,8 + s2)
         ('<':'>':xs) -> \(s1,s2) ->  cont TNEqual xs (s1,8 + s2)
         ('<':'=':xs) -> \(s1,s2) ->  cont TLEqual xs (s1,2 + s2)
         ('>':'=':xs) -> \(s1,s2) ->  cont TGEqual xs (s1,2 + s2)
         ('=':xs) -> \(s1,s2) ->  cont TEqual xs (s1,1 + s2)
         ('>':xs) -> \(s1,s2) ->  cont TGreat xs (s1,1 + s2)
         ('<':xs) -> \(s1,s2) ->  cont TLess xs (s1,1 + s2)

         ('A':'S':'C':xs) -> \(s1,s2) ->  cont TAsc xs (s1,3 + s2)
         ('D':'E':'S':'C':xs) -> \(s1,s2) ->  cont TDesc xs (s1,4 + s2)
         ('C':'O':'U':'N':'T':xs) -> \(s1,s2) ->  cont TCount xs (s1,5 + s2)
         ('S':'U':'M':xs) -> \(s1,s2) ->  cont TSum xs (s1,3 + s2)
         ('A':'V':'G':xs) -> \(s1,s2) ->  cont TAvg xs (s1,3 + s2)
         ('M':'I':'N':xs) -> \(s1,s2) ->  cont TMin xs (s1,3 + s2)
         ('M':'A':'X':xs) -> \(s1,s2) ->  cont TMax xs (s1,3 + s2)
         ('D':'I':'S':'T':'I':'N':'C':'T':xs) -> \(s1,s2) ->  cont TDistinct xs (s1,8 + s2)
         ('A':'S':xs) -> \(s1,s2) ->  cont TAs xs (s1,2 + s2)
         ('A':'L':'L':xs) -> \(s1,s2) ->  cont TAll xs (s1,3 + s2)
         ('N':'E':'G':xs) -> \(s1,s2) ->  cont TNeg xs (s1,3 + s2)



         ('C':'R':'E':'A':'T':'E':' ':'T':'A':'B':'L':'E':xs) -> \(s1,s2) ->  cont TCTable xs (s1,12 + s2)
         ('C':'R':'E':'A':'T':'E':' ':'D':'A':'T':'A':'B':'A':'S':'E':xs) -> \(s1,s2) -> cont TCBase xs (s1,14 + s2)
         ('D':'R':'O':'P':' ':'T':'A':'B':'L':'E':xs) -> \(s1,s2) -> cont TDTable xs (s1,10 + s2)
         ('D':'R':'O':'P':' ':'A':'L':'L':' ':'T':'A':'B':'L':'E':xs) -> \(s1,s2) -> cont TDAllTable xs (s1,14 + s2)
         ('D':'R':'O':'P':' ':'D':'A':'T':'A':'B':'A':'S':'E':xs) -> \(s1,s2) -> cont TDBase xs (s1,13 + s2)
         ('S':'H':'O':'W':' ':'D':'A':'T':'A':'B':'A':'S':'E':xs) -> \(s1,s2) -> cont TShowB xs (s1,13 + s2)
         ('S':'H':'O':'W':' ':'T':'A':'B':'L':'E':xs) -> \(s1,s2) -> cont TShowT xs (s1,10 + s2)
         ('K':'E':'Y':xs) -> \(s1,s2) -> cont TPkey xs (s1,3 + s2)
         ('U':'S':'E':xs) -> \(s1,s2) -> cont TUse xs (s1,3 + s2)
         ('S':'t':'r':'i':'n':'g':xs) -> \(s1,s2) -> cont TString xs (s1,6 + s2)
         ('F':'l':'o':'a':'t':xs) -> \(s1,s2) -> cont TFloat xs (s1,5 + s2)
         ('I':'n':'t':xs) -> \(s1,s2) -> cont TInt xs (s1,3 + s2)
         ('B':'o':'o':'l':xs) -> \(s1,s2) -> cont TBool xs (s1,4 + s2)
         ('D':'a':'t':'e':'T':'i':'m':'e':xs) -> \(s1,s2) -> cont TDateTime xs (s1,8 + s2)
         ('D':'a':'t':'e':xs) -> \(s1,s2) -> cont TDate xs (s1,4 + s2)
         ('T':'i':'m':'e':xs) -> \(s1,s2) -> cont TTime xs (s1,4 + s2)

         ('S':'O':'U':'R':'C':'E':xs) -> \(s1,s2) -> cont TSrc xs (s1,6 + s2)

         ('F':'O':'R':'E':'I':'G':'N':' ':'K':'E':'Y':xs) -> \(s1,s2) -> cont TFKey xs (s1,11 + s2)
         ('R':'E':'F':'E':'R':'E':'N':'C':'E':xs) -> \(s1,s2) -> cont TRef xs (s1,10 + s2)
         ('O':'N':' ':'D':'E':'L':'E':'T':'E':xs) -> \(s1,s2) -> cont TDel xs (s1,6 + s2)
         ('O':'N':' ':'U':'P':'D':'A':'T':'E':xs) -> \(s1,s2) -> cont TUpd xs (s1,6 + s2)
         ('R':'E':'S':'T':'R':'I':'C':'T':'E':'D':xs) -> \(s1,s2) -> cont TRestricted xs (s1,10 + s2)
         ('C':'A':'S':'C':'A':'D':'E':xs) -> \(s1,s2) -> cont TCascades xs (s1,7 + s2)
         ('N':'U':'L':'L':'I':'F':'I':'E':xs) -> \(s1,s2) -> cont TNullifies xs (s1,8 + s2)
         ('N':'U':'L':'L':xs) -> \(s1,s2) -> cont TNull xs (s1,4 + s2)


         ('D':'E':'L':'E':'T':'E':xs) -> \(s1,s2) ->  cont TDelete xs (s1,6 + s2)
         ('U':'P':'D':'A':'T':'E':xs) -> \(s1,s2) ->  cont TUpdate xs (s1,6 + s2)
         ('S':'E':'T':xs) -> \(s1,s2) -> cont TSet xs (s1,3 + s2)
         ('S':'E':'L':'E':'C':'T':xs) -> \(s1,s2) -> cont TSelect xs (s1,6 + s2)
         ('F':'R':'O':'M':xs) -> \(s1,s2) -> cont TFrom xs (s1,4 + s2)
         ('W':'H':'E':'R':'E':xs) -> \(s1,s2) -> cont TWhere xs (s1,5 + s2)
         ('G':'R':'O':'U':'P':' ':'B':'Y':xs) -> \(s1,s2) -> cont TGroupBy xs (s1,8 + s2)
         ('H':'A':'V':'I':'N':'G':xs) -> \(s1,s2) -> cont THaving xs (s1,6 + s2)


         ('L':'I':'M':'I':'T':xs) -> \(s1,s2) -> cont TLimit xs (s1, 5 + s2)
         ('O':'N':xs) -> \(s1,s2) -> cont TOn xs (s1,2 + s2)


         ('.':xs) -> \(s1,s2) -> cont TDot xs (s1,1 + s2)
         (',':xs) -> \(s1,s2) -> cont TComa xs (s1,1 + s2)
         ('(':xs) -> \(s1,s2) -> cont TOpen xs (s1,1 + s2)
         (')':xs) -> \(s1,s2) -> cont TClose xs (s1,1 + s2)
         ('+':xs) -> \(s1,s2) -> cont TPlus xs (s1,1 + s2)
         ('-':xs) -> \(s1,s2) -> cont TMinus xs (s1,1 + s2)
         ('*':xs) -> \(s1,s2) -> cont TTimes xs (s1,1 + s2)
         ('/':'*':xs) -> consume xs
                         where consume ('/':'*':xs) = \i -> errorComOpen
                               consume ('*':'/':xs) = lexer cont xs
                               consume ('\n':xs) = \(s1,s2) -> consume xs (1 + s1,0)
                               consume (x:xs) = \(s1,s2) -> consume xs (s1,1 + s2)
                               consume "" =  \i -> errorComClose

         ('*':'/':xs) -> \i -> errorComClose

         ('/':xs) -> \(s1,s2) -> cont TDiv xs (s1,1 + s2)


         (';':xs) -> \(s1,s2) -> cont TSemiColon xs (s1,1 + s2)
         (x:xs)  | isSpace x -> \(s1,s2) ->  lexer cont xs (s1,s2+1)
                 | x == '\"' -> lexString cont (x:xs)
                 | isLetter x -> lexField cont (x:xs)
                 | isDigit x -> lexNum cont (x:xs)






lexNum cont xs =  \(s1,s2) -> cont val r (s1,s2 + (dif xs r) )
  where (val,r) = case parse intParse xs of
                   [(A5 v,r)] -> (TDatTim v,r)
                   [(A6 v,r)] -> (TDat v,r)
                   [(A7 v,r)] -> (TTim v,r)
                   [(A3 v,r)] -> (TNum v,r)
                   [(A4 v,r)] -> (TNumFloat v,r)

        dif s1 s2 = (length s1) - (length s2)


lexField cont xs = \(s1,s2) -> cont (TField s) r (s1,s2 + (length s))
  where [(s,r)] = parse (many (do alphanum <|> char '_')) xs


lexString cont  xs = \(s1,s2) -> cont (TStr s) r (s1,s2 + (length s))
   where [(s,r)] = parse st xs
         st = do char '\"'
                 s <- string2
                 char '\"'
                 return s






sqlParse s = sql s (1,1)




 }
