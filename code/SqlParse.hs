{-# OPTIONS_GHC -w #-}
module SqlParse (sqlParse) where
import Parsing (parse,identifier,integer,char,many,letter,alphanum,string2,dateTime,date,time,intParse)
import AST
import Data.Char
import ParseResult
import qualified Data.HashMap.Strict as H
import qualified Avl
import Error (errorComOpen,errorComClose)
import qualified Data.Array as Happy_Data_Array
import qualified Data.Bits as Bits
import Control.Applicative(Applicative(..))
import Control.Monad (ap)

-- parser produced by Happy Version 1.19.8

data HappyAbsSyn t9 t10 t11 t12 t13 t14 t15
	= HappyTerminal (Token)
	| HappyErrorToken Int
	| HappyAbsSyn4 (SQL)
	| HappyAbsSyn5 (ManUsers)
	| HappyAbsSyn6 (DML)
	| HappyAbsSyn9 t9
	| HappyAbsSyn10 t10
	| HappyAbsSyn11 t11
	| HappyAbsSyn12 t12
	| HappyAbsSyn13 t13
	| HappyAbsSyn14 t14
	| HappyAbsSyn15 t15
	| HappyAbsSyn16 ([Args])
	| HappyAbsSyn17 (Args)
	| HappyAbsSyn22 (BoolExp)
	| HappyAbsSyn29 (Aggregate)
	| HappyAbsSyn30 (O)
	| HappyAbsSyn31 (JOINS)
	| HappyAbsSyn32 (Avl.AVL [Args])
	| HappyAbsSyn34 (([String],[Args]))
	| HappyAbsSyn35 (DDL)
	| HappyAbsSyn36 ([CArgs])
	| HappyAbsSyn37 (CArgs)
	| HappyAbsSyn38 ([String])
	| HappyAbsSyn39 (RefOption)
	| HappyAbsSyn41 (Type)

happyExpList :: Happy_Data_Array.Array Int Int
happyExpList = Happy_Data_Array.listArray (0,895) ([0,0,7680,0,2048,56832,49153,3,0,0,3840,0,1024,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,512,0,0,0,0,0,0,0,256,0,0,0,0,0,0,7936,4485,4096,0,0,0,0,4,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,1,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32768,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,512,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,1920,0,512,30592,61440,0,0,0,0,0,512,0,0,0,0,0,31232,0,516,0,0,0,0,0,0,0,33280,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,1,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,0,0,0,0,0,0,16384,0,10488,132,128,0,0,0,0,0,0,16,0,0,0,0,0,0,2622,33,32,0,0,0,0,0,34079,16,16,0,0,0,0,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,0,2048,0,0,0,0,0,0,0,0,0,64,0,0,0,0,0,64,0,32,0,0,0,0,0,32,0,16,0,0,0,0,0,16,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,1008,0,0,0,0,0,10494,132,504,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,53248,3,4128,0,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,512,0,0,0,0,0,0,0,1280,15,0,0,0,0,128,61440,2129,1,1,0,0,0,0,0,3072,0,0,0,0,0,0,0,1536,0,0,0,0,0,0,0,768,0,0,0,0,0,0,0,384,0,0,0,0,0,0,0,192,0,0,0,0,0,0,0,32,0,0,0,0,0,0,41952,528,512,0,0,0,0,0,20976,264,256,0,0,0,0,0,10488,132,128,0,0,0,0,0,5244,66,64,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1056,0,0,0,0,0,0,32512,16916,64512,0,0,0,0,0,0,264,0,0,0,0,0,0,8128,4229,16128,0,0,0,0,0,0,64,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,41952,528,512,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16386,0,8,0,0,0,0,12288,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4064,0,0,0,0,0,256,0,0,0,0,0,0,0,128,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,67,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,15376,0,0,0,0,0,0,0,0,0,0,0,0,0,3136,1024,0,0,0,0,0,0,63488,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,57344,17039,32776,31,0,0,0,512,61440,8519,49156,15,0,0,0,0,0,32768,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,384,4096,8,0,0,0,0,0,0,32768,8,0,0,7,0,0,1,32768,16,0,0,0,0,0,0,0,0,0,0,0,0,0,796,256,0,0,0,0,0,0,32256,0,0,0,0,0,0,0,16384,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,512,0,0,0,0,0,0,61440,8519,49156,15,0,0,0,256,63488,4259,57346,7,0,0,0,15360,0,258,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,49152,0,0,0,0,0,0,0,24576,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,16,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,2048,0,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,512,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,128,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32,0,8,0,0,0,0,0,8192,0,0,0,0,0,0,0,3072,0,0,0,0,0,0,0,0,32768,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,128,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,64512,0,0,0,0,0,16256,8458,32256,0,0,0,0,0,8128,4229,16128,0,0,0,0,0,36736,2114,8064,0,0,0,0,0,18416,1057,4032,0,0,0,0,0,0,16,0,0,0,0,0,0,0,8,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,64,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,132,0,0,0,0,0,12288,0,4,0,0,0,0,0,2,18416,1057,4032,0,0,0,0,3072,0,0,0,0,0,0,32768,0,16384,0,0,0,0,0,0,0,0,0,64,0,0,0,0,0,4096,0,0,0,0,0,0,0,2622,33,126,0,0,0,0,0,34079,16,63,0,0,0,0,32768,17039,32776,31,0,0,0,0,49152,8519,49156,15,0,0,0,0,57344,4259,57346,7,0,0,0,0,61440,2129,61441,3,0,0,0,0,0,0,0,0,0,0,0,0,0,32,0,0,0,0,0,0,0,84,0,0,56,0,0,8,0,132,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,32,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32768,0,0,0,0,0,0,48,1024,0,0,0,0,0,512,61440,8519,49156,15,0,0,0,0,12,0,0,0,0,0,0,128,0,64,0,0,0,0,0,0,0,0,16384,0,0,0,0,0,31744,16916,64512,0,0,0,0,0,15872,8458,32256,0,0,0,0,0,7936,4229,16128,0,0,0,0,0,36736,2114,8064,0,0,0,0,0,18368,1057,4032,0,0,0,0,0,41952,528,2016,0,0,0,0,0,0,0,0,0,0,0,0,0,10494,132,504,0,0,0,0,0,5247,66,252,0,0,0,0,0,0,1,0,0,0,0,0,0,32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,2048,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8193,0,4,0,0,0,0,4096,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1536,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,384,0,0,0,0,0,0,0,128,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,14,1024,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,384,0,0,0,0,0,0,0,528,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,1024,0,63,0,0,0,0,0,0,0,0,0,0,0,0,7,512,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,1536,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,512,0,0,0,0,0,0,0,768,0,0,0,0,0,0,0,544,0,0,464,0,0,0,0,1024,0,0,0,0,0,0,0,512,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,0,0,0,0,0,32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,128,0,0,0,0,0,0,0,0,512,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,192,0,0,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,57344,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1792,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	])

{-# NOINLINE happyExpListPerState #-}
happyExpListPerState st =
    token_strs_expected
  where token_strs = ["error","%dummy","%start_sql","SQL","MANUSERS","DML","Query","Query0","Query1","Query2","Query3","Query4","Query5","Query6","Query7","ArgS","Exp","IntExp","ArgF","ArgF2","Fields","BoolExpW","BoolExpH","ValueH","ValueW","VarList","Var","Value","Aggregate","Order","SomeJoin","TreeListArgs","ListArgs","ToUpdate","DDL","LCArgs","CArgs","FieldList","DelReferenceOption","UpdReferenceOption","TYPE","INSERT","DELETE","UPDATE","SELECT","FROM","';'","WHERE","GROUPBY","HAVING","ORDERBY","UNION","DIFF","INTERSECT","AND","OR","'='","\"<>\"","'>'","'<'","\">=\"","\"<=\"","LIKE","EXIST","NOT","Sum","Count","Avg","Min","Max","LIMIT","Asc","Desc","ALL","COLUMN","'('","')'","','","AS","SET","FIELD","DISTINCT","IN","'.'","'+'","'-'","'*'","'/'","NEG","CTABLE","CBASE","DTABLE","DBASE","PKEY","USE","SHOWB","SHOWT","DATTIM","DAT","TIM","STR","NUM","NULL","INT","FLOAT","STRING","BOOL","DATETIME","DATE","TIME","SRC","CUSER","DUSER","SUSER","FKEY","REFERENCE","DEL","UPD","RESTRICTED","CASCADES","NULLIFIES","ON","JOIN","LEFT","RIGHT","INNER","%eof"]
        bit_start = st * 127
        bit_end = (st + 1) * 127
        read_bit = readArrayBit happyExpList
        bits = map read_bit [bit_start..bit_end - 1]
        bits_indexed = zip bits [0..126]
        token_strs_expected = concatMap f bits_indexed
        f (False, _) = []
        f (True, nr) = [token_strs !! nr]

action_0 (42) = happyShift action_6
action_0 (43) = happyShift action_7
action_0 (44) = happyShift action_8
action_0 (45) = happyShift action_9
action_0 (76) = happyShift action_10
action_0 (90) = happyShift action_14
action_0 (91) = happyShift action_15
action_0 (92) = happyShift action_16
action_0 (93) = happyShift action_17
action_0 (95) = happyShift action_18
action_0 (96) = happyShift action_19
action_0 (97) = happyShift action_20
action_0 (111) = happyShift action_21
action_0 (112) = happyShift action_22
action_0 (113) = happyShift action_23
action_0 (114) = happyShift action_24
action_0 (4) = happyGoto action_11
action_0 (5) = happyGoto action_12
action_0 (6) = happyGoto action_2
action_0 (7) = happyGoto action_3
action_0 (8) = happyGoto action_4
action_0 (9) = happyGoto action_5
action_0 (35) = happyGoto action_13
action_0 _ = happyFail (happyExpListPerState 0)

action_1 (42) = happyShift action_6
action_1 (43) = happyShift action_7
action_1 (44) = happyShift action_8
action_1 (45) = happyShift action_9
action_1 (76) = happyShift action_10
action_1 (6) = happyGoto action_2
action_1 (7) = happyGoto action_3
action_1 (8) = happyGoto action_4
action_1 (9) = happyGoto action_5
action_1 _ = happyFail (happyExpListPerState 1)

action_2 _ = happyReduce_1

action_3 (52) = happyShift action_54
action_3 (53) = happyShift action_55
action_3 (54) = happyShift action_56
action_3 _ = happyReduce_12

action_4 _ = happyReduce_16

action_5 _ = happyReduce_17

action_6 (81) = happyShift action_53
action_6 _ = happyFail (happyExpListPerState 6)

action_7 (81) = happyShift action_52
action_7 _ = happyFail (happyExpListPerState 7)

action_8 (81) = happyShift action_51
action_8 _ = happyFail (happyExpListPerState 8)

action_9 (66) = happyShift action_40
action_9 (67) = happyShift action_41
action_9 (68) = happyShift action_42
action_9 (69) = happyShift action_43
action_9 (70) = happyShift action_44
action_9 (74) = happyShift action_45
action_9 (76) = happyShift action_46
action_9 (81) = happyShift action_47
action_9 (82) = happyShift action_48
action_9 (86) = happyShift action_49
action_9 (102) = happyShift action_50
action_9 (16) = happyGoto action_36
action_9 (17) = happyGoto action_37
action_9 (18) = happyGoto action_38
action_9 (29) = happyGoto action_39
action_9 _ = happyFail (happyExpListPerState 9)

action_10 (45) = happyShift action_9
action_10 (9) = happyGoto action_35
action_10 _ = happyFail (happyExpListPerState 10)

action_11 (47) = happyShift action_34
action_11 (127) = happyAccept
action_11 _ = happyFail (happyExpListPerState 11)

action_12 _ = happyReduce_3

action_13 _ = happyReduce_2

action_14 (81) = happyShift action_33
action_14 _ = happyFail (happyExpListPerState 14)

action_15 (81) = happyShift action_32
action_15 _ = happyFail (happyExpListPerState 15)

action_16 (81) = happyShift action_31
action_16 _ = happyFail (happyExpListPerState 16)

action_17 (81) = happyShift action_30
action_17 _ = happyFail (happyExpListPerState 17)

action_18 (81) = happyShift action_29
action_18 _ = happyFail (happyExpListPerState 18)

action_19 _ = happyReduce_130

action_20 _ = happyReduce_131

action_21 (101) = happyShift action_28
action_21 _ = happyFail (happyExpListPerState 21)

action_22 (81) = happyShift action_27
action_22 _ = happyFail (happyExpListPerState 22)

action_23 (81) = happyShift action_26
action_23 _ = happyFail (happyExpListPerState 23)

action_24 (81) = happyShift action_25
action_24 _ = happyFail (happyExpListPerState 24)

action_25 _ = happyReduce_8

action_26 _ = happyReduce_7

action_27 _ = happyReduce_6

action_28 _ = happyReduce_5

action_29 _ = happyReduce_129

action_30 _ = happyReduce_128

action_31 _ = happyReduce_126

action_32 _ = happyReduce_127

action_33 (76) = happyShift action_95
action_33 _ = happyFail (happyExpListPerState 33)

action_34 (42) = happyShift action_6
action_34 (43) = happyShift action_7
action_34 (44) = happyShift action_8
action_34 (45) = happyShift action_9
action_34 (76) = happyShift action_10
action_34 (90) = happyShift action_14
action_34 (91) = happyShift action_15
action_34 (92) = happyShift action_16
action_34 (93) = happyShift action_17
action_34 (95) = happyShift action_18
action_34 (96) = happyShift action_19
action_34 (97) = happyShift action_20
action_34 (111) = happyShift action_21
action_34 (112) = happyShift action_22
action_34 (113) = happyShift action_23
action_34 (114) = happyShift action_24
action_34 (4) = happyGoto action_94
action_34 (5) = happyGoto action_12
action_34 (6) = happyGoto action_2
action_34 (7) = happyGoto action_3
action_34 (8) = happyGoto action_4
action_34 (9) = happyGoto action_5
action_34 (35) = happyGoto action_13
action_34 _ = happyFail (happyExpListPerState 34)

action_35 (77) = happyShift action_93
action_35 _ = happyFail (happyExpListPerState 35)

action_36 (46) = happyShift action_86
action_36 (48) = happyShift action_87
action_36 (49) = happyShift action_88
action_36 (50) = happyShift action_89
action_36 (51) = happyShift action_90
action_36 (71) = happyShift action_91
action_36 (78) = happyShift action_92
action_36 (10) = happyGoto action_80
action_36 (11) = happyGoto action_81
action_36 (12) = happyGoto action_82
action_36 (13) = happyGoto action_83
action_36 (14) = happyGoto action_84
action_36 (15) = happyGoto action_85
action_36 _ = happyReduce_32

action_37 (79) = happyShift action_75
action_37 (85) = happyShift action_76
action_37 (86) = happyShift action_77
action_37 (87) = happyShift action_78
action_37 (88) = happyShift action_79
action_37 _ = happyReduce_34

action_38 _ = happyReduce_40

action_39 _ = happyReduce_36

action_40 (76) = happyShift action_74
action_40 _ = happyFail (happyExpListPerState 40)

action_41 (76) = happyShift action_73
action_41 _ = happyFail (happyExpListPerState 41)

action_42 (76) = happyShift action_72
action_42 _ = happyFail (happyExpListPerState 42)

action_43 (76) = happyShift action_71
action_43 _ = happyFail (happyExpListPerState 43)

action_44 (76) = happyShift action_70
action_44 _ = happyFail (happyExpListPerState 44)

action_45 _ = happyReduce_41

action_46 (45) = happyShift action_9
action_46 (66) = happyShift action_40
action_46 (67) = happyShift action_41
action_46 (68) = happyShift action_42
action_46 (69) = happyShift action_43
action_46 (70) = happyShift action_44
action_46 (74) = happyShift action_45
action_46 (76) = happyShift action_69
action_46 (81) = happyShift action_47
action_46 (86) = happyShift action_49
action_46 (102) = happyShift action_50
action_46 (8) = happyGoto action_67
action_46 (9) = happyGoto action_5
action_46 (17) = happyGoto action_68
action_46 (18) = happyGoto action_38
action_46 (29) = happyGoto action_39
action_46 _ = happyFail (happyExpListPerState 46)

action_47 (84) = happyShift action_66
action_47 _ = happyReduce_35

action_48 (66) = happyShift action_40
action_48 (67) = happyShift action_41
action_48 (68) = happyShift action_42
action_48 (69) = happyShift action_43
action_48 (70) = happyShift action_44
action_48 (74) = happyShift action_45
action_48 (76) = happyShift action_46
action_48 (81) = happyShift action_47
action_48 (86) = happyShift action_49
action_48 (102) = happyShift action_50
action_48 (16) = happyGoto action_65
action_48 (17) = happyGoto action_37
action_48 (18) = happyGoto action_38
action_48 (29) = happyGoto action_39
action_48 _ = happyFail (happyExpListPerState 48)

action_49 (66) = happyShift action_40
action_49 (67) = happyShift action_41
action_49 (68) = happyShift action_42
action_49 (69) = happyShift action_43
action_49 (70) = happyShift action_44
action_49 (74) = happyShift action_45
action_49 (76) = happyShift action_46
action_49 (81) = happyShift action_47
action_49 (86) = happyShift action_49
action_49 (102) = happyShift action_50
action_49 (17) = happyGoto action_64
action_49 (18) = happyGoto action_38
action_49 (29) = happyGoto action_39
action_49 _ = happyFail (happyExpListPerState 49)

action_50 _ = happyReduce_48

action_51 (80) = happyShift action_63
action_51 _ = happyFail (happyExpListPerState 51)

action_52 (48) = happyShift action_62
action_52 _ = happyFail (happyExpListPerState 52)

action_53 (76) = happyShift action_61
action_53 (32) = happyGoto action_60
action_53 _ = happyFail (happyExpListPerState 53)

action_54 (45) = happyShift action_9
action_54 (76) = happyShift action_10
action_54 (7) = happyGoto action_59
action_54 (8) = happyGoto action_4
action_54 (9) = happyGoto action_5
action_54 _ = happyFail (happyExpListPerState 54)

action_55 (45) = happyShift action_9
action_55 (76) = happyShift action_10
action_55 (7) = happyGoto action_58
action_55 (8) = happyGoto action_4
action_55 (9) = happyGoto action_5
action_55 _ = happyFail (happyExpListPerState 55)

action_56 (45) = happyShift action_9
action_56 (76) = happyShift action_10
action_56 (7) = happyGoto action_57
action_56 (8) = happyGoto action_4
action_56 (9) = happyGoto action_5
action_56 _ = happyFail (happyExpListPerState 56)

action_57 _ = happyReduce_15

action_58 _ = happyReduce_14

action_59 _ = happyReduce_13

action_60 (78) = happyShift action_164
action_60 _ = happyReduce_9

action_61 (98) = happyShift action_158
action_61 (99) = happyShift action_159
action_61 (100) = happyShift action_160
action_61 (101) = happyShift action_161
action_61 (102) = happyShift action_162
action_61 (103) = happyShift action_163
action_61 (33) = happyGoto action_157
action_61 _ = happyFail (happyExpListPerState 61)

action_62 (64) = happyShift action_130
action_62 (65) = happyShift action_131
action_62 (66) = happyShift action_40
action_62 (67) = happyShift action_41
action_62 (68) = happyShift action_42
action_62 (69) = happyShift action_43
action_62 (70) = happyShift action_44
action_62 (74) = happyShift action_45
action_62 (76) = happyShift action_132
action_62 (81) = happyShift action_116
action_62 (86) = happyShift action_49
action_62 (98) = happyShift action_117
action_62 (99) = happyShift action_118
action_62 (100) = happyShift action_119
action_62 (101) = happyShift action_120
action_62 (102) = happyShift action_50
action_62 (103) = happyShift action_121
action_62 (17) = happyGoto action_106
action_62 (18) = happyGoto action_107
action_62 (22) = happyGoto action_156
action_62 (25) = happyGoto action_127
action_62 (27) = happyGoto action_128
action_62 (28) = happyGoto action_129
action_62 (29) = happyGoto action_39
action_62 _ = happyFail (happyExpListPerState 62)

action_63 (81) = happyShift action_155
action_63 (34) = happyGoto action_154
action_63 _ = happyFail (happyExpListPerState 63)

action_64 _ = happyReduce_47

action_65 (46) = happyShift action_86
action_65 (48) = happyShift action_87
action_65 (49) = happyShift action_88
action_65 (50) = happyShift action_89
action_65 (51) = happyShift action_90
action_65 (71) = happyShift action_91
action_65 (78) = happyShift action_92
action_65 (10) = happyGoto action_153
action_65 (11) = happyGoto action_81
action_65 (12) = happyGoto action_82
action_65 (13) = happyGoto action_83
action_65 (14) = happyGoto action_84
action_65 (15) = happyGoto action_85
action_65 _ = happyReduce_32

action_66 (81) = happyShift action_152
action_66 _ = happyFail (happyExpListPerState 66)

action_67 (77) = happyShift action_151
action_67 _ = happyFail (happyExpListPerState 67)

action_68 (77) = happyShift action_150
action_68 (79) = happyShift action_75
action_68 (85) = happyShift action_76
action_68 (86) = happyShift action_77
action_68 (87) = happyShift action_78
action_68 (88) = happyShift action_79
action_68 _ = happyFail (happyExpListPerState 68)

action_69 (45) = happyShift action_9
action_69 (66) = happyShift action_40
action_69 (67) = happyShift action_41
action_69 (68) = happyShift action_42
action_69 (69) = happyShift action_43
action_69 (70) = happyShift action_44
action_69 (74) = happyShift action_45
action_69 (76) = happyShift action_69
action_69 (81) = happyShift action_47
action_69 (86) = happyShift action_49
action_69 (102) = happyShift action_50
action_69 (8) = happyGoto action_67
action_69 (9) = happyGoto action_149
action_69 (17) = happyGoto action_68
action_69 (18) = happyGoto action_38
action_69 (29) = happyGoto action_39
action_69 _ = happyFail (happyExpListPerState 69)

action_70 (81) = happyShift action_105
action_70 (82) = happyShift action_148
action_70 (27) = happyGoto action_147
action_70 _ = happyFail (happyExpListPerState 70)

action_71 (81) = happyShift action_105
action_71 (82) = happyShift action_146
action_71 (27) = happyGoto action_145
action_71 _ = happyFail (happyExpListPerState 71)

action_72 (81) = happyShift action_105
action_72 (82) = happyShift action_144
action_72 (27) = happyGoto action_143
action_72 _ = happyFail (happyExpListPerState 72)

action_73 (81) = happyShift action_105
action_73 (82) = happyShift action_142
action_73 (27) = happyGoto action_141
action_73 _ = happyFail (happyExpListPerState 73)

action_74 (81) = happyShift action_105
action_74 (82) = happyShift action_140
action_74 (27) = happyGoto action_139
action_74 _ = happyFail (happyExpListPerState 74)

action_75 (81) = happyShift action_138
action_75 _ = happyFail (happyExpListPerState 75)

action_76 (66) = happyShift action_40
action_76 (67) = happyShift action_41
action_76 (68) = happyShift action_42
action_76 (69) = happyShift action_43
action_76 (70) = happyShift action_44
action_76 (74) = happyShift action_45
action_76 (76) = happyShift action_46
action_76 (81) = happyShift action_47
action_76 (86) = happyShift action_49
action_76 (102) = happyShift action_50
action_76 (17) = happyGoto action_137
action_76 (18) = happyGoto action_38
action_76 (29) = happyGoto action_39
action_76 _ = happyFail (happyExpListPerState 76)

action_77 (66) = happyShift action_40
action_77 (67) = happyShift action_41
action_77 (68) = happyShift action_42
action_77 (69) = happyShift action_43
action_77 (70) = happyShift action_44
action_77 (74) = happyShift action_45
action_77 (76) = happyShift action_46
action_77 (81) = happyShift action_47
action_77 (86) = happyShift action_49
action_77 (102) = happyShift action_50
action_77 (17) = happyGoto action_136
action_77 (18) = happyGoto action_38
action_77 (29) = happyGoto action_39
action_77 _ = happyFail (happyExpListPerState 77)

action_78 (66) = happyShift action_40
action_78 (67) = happyShift action_41
action_78 (68) = happyShift action_42
action_78 (69) = happyShift action_43
action_78 (70) = happyShift action_44
action_78 (74) = happyShift action_45
action_78 (76) = happyShift action_46
action_78 (81) = happyShift action_47
action_78 (86) = happyShift action_49
action_78 (102) = happyShift action_50
action_78 (17) = happyGoto action_135
action_78 (18) = happyGoto action_38
action_78 (29) = happyGoto action_39
action_78 _ = happyFail (happyExpListPerState 78)

action_79 (66) = happyShift action_40
action_79 (67) = happyShift action_41
action_79 (68) = happyShift action_42
action_79 (69) = happyShift action_43
action_79 (70) = happyShift action_44
action_79 (74) = happyShift action_45
action_79 (76) = happyShift action_46
action_79 (81) = happyShift action_47
action_79 (86) = happyShift action_49
action_79 (102) = happyShift action_50
action_79 (17) = happyGoto action_134
action_79 (18) = happyGoto action_38
action_79 (29) = happyGoto action_39
action_79 _ = happyFail (happyExpListPerState 79)

action_80 _ = happyReduce_19

action_81 _ = happyReduce_22

action_82 _ = happyReduce_24

action_83 _ = happyReduce_26

action_84 _ = happyReduce_28

action_85 _ = happyReduce_30

action_86 (76) = happyShift action_124
action_86 (81) = happyShift action_125
action_86 (19) = happyGoto action_133
action_86 (20) = happyGoto action_123
action_86 _ = happyFail (happyExpListPerState 86)

action_87 (64) = happyShift action_130
action_87 (65) = happyShift action_131
action_87 (66) = happyShift action_40
action_87 (67) = happyShift action_41
action_87 (68) = happyShift action_42
action_87 (69) = happyShift action_43
action_87 (70) = happyShift action_44
action_87 (74) = happyShift action_45
action_87 (76) = happyShift action_132
action_87 (81) = happyShift action_116
action_87 (86) = happyShift action_49
action_87 (98) = happyShift action_117
action_87 (99) = happyShift action_118
action_87 (100) = happyShift action_119
action_87 (101) = happyShift action_120
action_87 (102) = happyShift action_50
action_87 (103) = happyShift action_121
action_87 (17) = happyGoto action_106
action_87 (18) = happyGoto action_107
action_87 (22) = happyGoto action_126
action_87 (25) = happyGoto action_127
action_87 (27) = happyGoto action_128
action_87 (28) = happyGoto action_129
action_87 (29) = happyGoto action_39
action_87 _ = happyFail (happyExpListPerState 87)

action_88 (76) = happyShift action_124
action_88 (81) = happyShift action_125
action_88 (19) = happyGoto action_122
action_88 (20) = happyGoto action_123
action_88 _ = happyFail (happyExpListPerState 88)

action_89 (64) = happyShift action_113
action_89 (65) = happyShift action_114
action_89 (66) = happyShift action_40
action_89 (67) = happyShift action_41
action_89 (68) = happyShift action_42
action_89 (69) = happyShift action_43
action_89 (70) = happyShift action_44
action_89 (74) = happyShift action_45
action_89 (76) = happyShift action_115
action_89 (81) = happyShift action_116
action_89 (86) = happyShift action_49
action_89 (98) = happyShift action_117
action_89 (99) = happyShift action_118
action_89 (100) = happyShift action_119
action_89 (101) = happyShift action_120
action_89 (102) = happyShift action_50
action_89 (103) = happyShift action_121
action_89 (17) = happyGoto action_106
action_89 (18) = happyGoto action_107
action_89 (23) = happyGoto action_108
action_89 (24) = happyGoto action_109
action_89 (27) = happyGoto action_110
action_89 (28) = happyGoto action_111
action_89 (29) = happyGoto action_112
action_89 _ = happyFail (happyExpListPerState 89)

action_90 (81) = happyShift action_105
action_90 (26) = happyGoto action_103
action_90 (27) = happyGoto action_104
action_90 _ = happyFail (happyExpListPerState 90)

action_91 (102) = happyShift action_102
action_91 _ = happyFail (happyExpListPerState 91)

action_92 (66) = happyShift action_40
action_92 (67) = happyShift action_41
action_92 (68) = happyShift action_42
action_92 (69) = happyShift action_43
action_92 (70) = happyShift action_44
action_92 (74) = happyShift action_45
action_92 (76) = happyShift action_46
action_92 (81) = happyShift action_47
action_92 (86) = happyShift action_49
action_92 (102) = happyShift action_50
action_92 (16) = happyGoto action_101
action_92 (17) = happyGoto action_37
action_92 (18) = happyGoto action_38
action_92 (29) = happyGoto action_39
action_92 _ = happyFail (happyExpListPerState 92)

action_93 _ = happyReduce_18

action_94 (47) = happyShift action_34
action_94 _ = happyReduce_4

action_95 (81) = happyShift action_98
action_95 (94) = happyShift action_99
action_95 (115) = happyShift action_100
action_95 (36) = happyGoto action_96
action_95 (37) = happyGoto action_97
action_95 _ = happyFail (happyExpListPerState 95)

action_96 (77) = happyShift action_239
action_96 (78) = happyShift action_240
action_96 _ = happyFail (happyExpListPerState 96)

action_97 _ = happyReduce_132

action_98 (104) = happyShift action_232
action_98 (105) = happyShift action_233
action_98 (106) = happyShift action_234
action_98 (107) = happyShift action_235
action_98 (108) = happyShift action_236
action_98 (109) = happyShift action_237
action_98 (110) = happyShift action_238
action_98 (41) = happyGoto action_231
action_98 _ = happyFail (happyExpListPerState 98)

action_99 (76) = happyShift action_230
action_99 _ = happyFail (happyExpListPerState 99)

action_100 (76) = happyShift action_229
action_100 _ = happyFail (happyExpListPerState 100)

action_101 (78) = happyShift action_92
action_101 _ = happyReduce_33

action_102 _ = happyReduce_31

action_103 (72) = happyShift action_226
action_103 (73) = happyShift action_227
action_103 (78) = happyShift action_228
action_103 (30) = happyGoto action_225
action_103 _ = happyFail (happyExpListPerState 103)

action_104 _ = happyReduce_89

action_105 (84) = happyShift action_224
action_105 _ = happyReduce_91

action_106 (79) = happyShift action_75
action_106 (85) = happyShift action_76
action_106 (86) = happyShift action_77
action_106 (87) = happyShift action_78
action_106 (88) = happyShift action_79
action_106 _ = happyFail (happyExpListPerState 106)

action_107 (77) = happyReduce_97
action_107 (79) = happyReduce_40
action_107 (85) = happyReduce_40
action_107 (86) = happyReduce_40
action_107 (87) = happyReduce_40
action_107 (88) = happyReduce_40
action_107 _ = happyReduce_97

action_108 (51) = happyShift action_90
action_108 (55) = happyShift action_222
action_108 (56) = happyShift action_223
action_108 (71) = happyShift action_91
action_108 (14) = happyGoto action_221
action_108 (15) = happyGoto action_85
action_108 _ = happyReduce_32

action_109 (57) = happyShift action_215
action_109 (58) = happyShift action_216
action_109 (59) = happyShift action_217
action_109 (60) = happyShift action_218
action_109 (61) = happyShift action_219
action_109 (62) = happyShift action_220
action_109 _ = happyFail (happyExpListPerState 109)

action_110 (63) = happyShift action_214
action_110 _ = happyFail (happyExpListPerState 110)

action_111 _ = happyReduce_85

action_112 (77) = happyReduce_86
action_112 (79) = happyReduce_36
action_112 (85) = happyReduce_36
action_112 (86) = happyReduce_36
action_112 (87) = happyReduce_36
action_112 (88) = happyReduce_36
action_112 _ = happyReduce_86

action_113 (76) = happyShift action_213
action_113 _ = happyFail (happyExpListPerState 113)

action_114 (64) = happyShift action_113
action_114 (65) = happyShift action_114
action_114 (66) = happyShift action_40
action_114 (67) = happyShift action_41
action_114 (68) = happyShift action_42
action_114 (69) = happyShift action_43
action_114 (70) = happyShift action_44
action_114 (74) = happyShift action_45
action_114 (76) = happyShift action_115
action_114 (81) = happyShift action_116
action_114 (86) = happyShift action_49
action_114 (98) = happyShift action_117
action_114 (99) = happyShift action_118
action_114 (100) = happyShift action_119
action_114 (101) = happyShift action_120
action_114 (102) = happyShift action_50
action_114 (103) = happyShift action_121
action_114 (17) = happyGoto action_106
action_114 (18) = happyGoto action_107
action_114 (23) = happyGoto action_212
action_114 (24) = happyGoto action_109
action_114 (27) = happyGoto action_110
action_114 (28) = happyGoto action_111
action_114 (29) = happyGoto action_112
action_114 _ = happyFail (happyExpListPerState 114)

action_115 (45) = happyShift action_9
action_115 (64) = happyShift action_113
action_115 (65) = happyShift action_114
action_115 (66) = happyShift action_40
action_115 (67) = happyShift action_41
action_115 (68) = happyShift action_42
action_115 (69) = happyShift action_43
action_115 (70) = happyShift action_44
action_115 (74) = happyShift action_45
action_115 (76) = happyShift action_211
action_115 (81) = happyShift action_116
action_115 (86) = happyShift action_49
action_115 (98) = happyShift action_117
action_115 (99) = happyShift action_118
action_115 (100) = happyShift action_119
action_115 (101) = happyShift action_120
action_115 (102) = happyShift action_50
action_115 (103) = happyShift action_121
action_115 (8) = happyGoto action_67
action_115 (9) = happyGoto action_5
action_115 (17) = happyGoto action_68
action_115 (18) = happyGoto action_107
action_115 (23) = happyGoto action_210
action_115 (24) = happyGoto action_109
action_115 (27) = happyGoto action_110
action_115 (28) = happyGoto action_111
action_115 (29) = happyGoto action_112
action_115 _ = happyFail (happyExpListPerState 115)

action_116 (77) = happyReduce_91
action_116 (79) = happyReduce_35
action_116 (84) = happyShift action_209
action_116 (85) = happyReduce_35
action_116 (86) = happyReduce_35
action_116 (87) = happyReduce_35
action_116 (88) = happyReduce_35
action_116 _ = happyReduce_91

action_117 _ = happyReduce_94

action_118 _ = happyReduce_95

action_119 _ = happyReduce_96

action_120 _ = happyReduce_93

action_121 _ = happyReduce_98

action_122 (50) = happyShift action_89
action_122 (51) = happyShift action_90
action_122 (71) = happyShift action_91
action_122 (78) = happyShift action_185
action_122 (13) = happyGoto action_208
action_122 (14) = happyGoto action_84
action_122 (15) = happyGoto action_85
action_122 _ = happyReduce_32

action_123 (75) = happyShift action_203
action_123 (79) = happyShift action_204
action_123 (124) = happyShift action_205
action_123 (125) = happyShift action_206
action_123 (126) = happyShift action_207
action_123 (31) = happyGoto action_202
action_123 _ = happyReduce_49

action_124 (45) = happyShift action_9
action_124 (76) = happyShift action_201
action_124 (81) = happyShift action_125
action_124 (8) = happyGoto action_199
action_124 (9) = happyGoto action_5
action_124 (20) = happyGoto action_200
action_124 _ = happyFail (happyExpListPerState 124)

action_125 _ = happyReduce_54

action_126 (49) = happyShift action_88
action_126 (50) = happyShift action_89
action_126 (51) = happyShift action_90
action_126 (55) = happyShift action_168
action_126 (56) = happyShift action_169
action_126 (71) = happyShift action_91
action_126 (12) = happyGoto action_198
action_126 (13) = happyGoto action_83
action_126 (14) = happyGoto action_84
action_126 (15) = happyGoto action_85
action_126 _ = happyReduce_32

action_127 (57) = happyShift action_192
action_127 (58) = happyShift action_193
action_127 (59) = happyShift action_194
action_127 (60) = happyShift action_195
action_127 (61) = happyShift action_196
action_127 (62) = happyShift action_197
action_127 _ = happyFail (happyExpListPerState 127)

action_128 (63) = happyShift action_190
action_128 (83) = happyShift action_191
action_128 _ = happyReduce_87

action_129 _ = happyReduce_88

action_130 (76) = happyShift action_189
action_130 _ = happyFail (happyExpListPerState 130)

action_131 (64) = happyShift action_130
action_131 (65) = happyShift action_131
action_131 (66) = happyShift action_40
action_131 (67) = happyShift action_41
action_131 (68) = happyShift action_42
action_131 (69) = happyShift action_43
action_131 (70) = happyShift action_44
action_131 (74) = happyShift action_45
action_131 (76) = happyShift action_132
action_131 (81) = happyShift action_116
action_131 (86) = happyShift action_49
action_131 (98) = happyShift action_117
action_131 (99) = happyShift action_118
action_131 (100) = happyShift action_119
action_131 (101) = happyShift action_120
action_131 (102) = happyShift action_50
action_131 (103) = happyShift action_121
action_131 (17) = happyGoto action_106
action_131 (18) = happyGoto action_107
action_131 (22) = happyGoto action_188
action_131 (25) = happyGoto action_127
action_131 (27) = happyGoto action_128
action_131 (28) = happyGoto action_129
action_131 (29) = happyGoto action_39
action_131 _ = happyFail (happyExpListPerState 131)

action_132 (45) = happyShift action_9
action_132 (64) = happyShift action_130
action_132 (65) = happyShift action_131
action_132 (66) = happyShift action_40
action_132 (67) = happyShift action_41
action_132 (68) = happyShift action_42
action_132 (69) = happyShift action_43
action_132 (70) = happyShift action_44
action_132 (74) = happyShift action_45
action_132 (76) = happyShift action_187
action_132 (81) = happyShift action_116
action_132 (86) = happyShift action_49
action_132 (98) = happyShift action_117
action_132 (99) = happyShift action_118
action_132 (100) = happyShift action_119
action_132 (101) = happyShift action_120
action_132 (102) = happyShift action_50
action_132 (103) = happyShift action_121
action_132 (8) = happyGoto action_67
action_132 (9) = happyGoto action_5
action_132 (17) = happyGoto action_68
action_132 (18) = happyGoto action_107
action_132 (22) = happyGoto action_186
action_132 (25) = happyGoto action_127
action_132 (27) = happyGoto action_128
action_132 (28) = happyGoto action_129
action_132 (29) = happyGoto action_39
action_132 _ = happyFail (happyExpListPerState 132)

action_133 (48) = happyShift action_87
action_133 (49) = happyShift action_88
action_133 (50) = happyShift action_89
action_133 (51) = happyShift action_90
action_133 (71) = happyShift action_91
action_133 (78) = happyShift action_185
action_133 (11) = happyGoto action_184
action_133 (12) = happyGoto action_82
action_133 (13) = happyGoto action_83
action_133 (14) = happyGoto action_84
action_133 (15) = happyGoto action_85
action_133 _ = happyReduce_32

action_134 _ = happyReduce_45

action_135 _ = happyReduce_44

action_136 (87) = happyShift action_78
action_136 (88) = happyShift action_79
action_136 _ = happyReduce_43

action_137 (87) = happyShift action_78
action_137 (88) = happyShift action_79
action_137 _ = happyReduce_42

action_138 _ = happyReduce_37

action_139 (77) = happyShift action_183
action_139 _ = happyFail (happyExpListPerState 139)

action_140 (81) = happyShift action_105
action_140 (27) = happyGoto action_182
action_140 _ = happyFail (happyExpListPerState 140)

action_141 (77) = happyShift action_181
action_141 _ = happyFail (happyExpListPerState 141)

action_142 (81) = happyShift action_105
action_142 (27) = happyGoto action_180
action_142 _ = happyFail (happyExpListPerState 142)

action_143 (77) = happyShift action_179
action_143 _ = happyFail (happyExpListPerState 143)

action_144 (81) = happyShift action_105
action_144 (27) = happyGoto action_178
action_144 _ = happyFail (happyExpListPerState 144)

action_145 (77) = happyShift action_177
action_145 _ = happyFail (happyExpListPerState 145)

action_146 (81) = happyShift action_105
action_146 (27) = happyGoto action_176
action_146 _ = happyFail (happyExpListPerState 146)

action_147 (77) = happyShift action_175
action_147 _ = happyFail (happyExpListPerState 147)

action_148 (81) = happyShift action_105
action_148 (27) = happyGoto action_174
action_148 _ = happyFail (happyExpListPerState 148)

action_149 (77) = happyShift action_93
action_149 _ = happyFail (happyExpListPerState 149)

action_150 _ = happyReduce_46

action_151 (79) = happyShift action_173
action_151 _ = happyFail (happyExpListPerState 151)

action_152 _ = happyReduce_39

action_153 _ = happyReduce_20

action_154 (48) = happyShift action_171
action_154 (78) = happyShift action_172
action_154 _ = happyFail (happyExpListPerState 154)

action_155 (57) = happyShift action_170
action_155 _ = happyFail (happyExpListPerState 155)

action_156 (55) = happyShift action_168
action_156 (56) = happyShift action_169
action_156 _ = happyReduce_10

action_157 (77) = happyShift action_166
action_157 (78) = happyShift action_167
action_157 _ = happyFail (happyExpListPerState 157)

action_158 _ = happyReduce_118

action_159 _ = happyReduce_119

action_160 _ = happyReduce_120

action_161 _ = happyReduce_116

action_162 _ = happyReduce_117

action_163 _ = happyReduce_121

action_164 (76) = happyShift action_61
action_164 (32) = happyGoto action_165
action_164 _ = happyFail (happyExpListPerState 164)

action_165 (78) = happyShift action_164
action_165 _ = happyReduce_115

action_166 _ = happyReduce_114

action_167 (98) = happyShift action_158
action_167 (99) = happyShift action_159
action_167 (100) = happyShift action_160
action_167 (101) = happyShift action_161
action_167 (102) = happyShift action_162
action_167 (103) = happyShift action_163
action_167 (33) = happyGoto action_289
action_167 _ = happyFail (happyExpListPerState 167)

action_168 (64) = happyShift action_130
action_168 (65) = happyShift action_131
action_168 (66) = happyShift action_40
action_168 (67) = happyShift action_41
action_168 (68) = happyShift action_42
action_168 (69) = happyShift action_43
action_168 (70) = happyShift action_44
action_168 (74) = happyShift action_45
action_168 (76) = happyShift action_132
action_168 (81) = happyShift action_116
action_168 (86) = happyShift action_49
action_168 (98) = happyShift action_117
action_168 (99) = happyShift action_118
action_168 (100) = happyShift action_119
action_168 (101) = happyShift action_120
action_168 (102) = happyShift action_50
action_168 (103) = happyShift action_121
action_168 (17) = happyGoto action_106
action_168 (18) = happyGoto action_107
action_168 (22) = happyGoto action_288
action_168 (25) = happyGoto action_127
action_168 (27) = happyGoto action_128
action_168 (28) = happyGoto action_129
action_168 (29) = happyGoto action_39
action_168 _ = happyFail (happyExpListPerState 168)

action_169 (64) = happyShift action_130
action_169 (65) = happyShift action_131
action_169 (66) = happyShift action_40
action_169 (67) = happyShift action_41
action_169 (68) = happyShift action_42
action_169 (69) = happyShift action_43
action_169 (70) = happyShift action_44
action_169 (74) = happyShift action_45
action_169 (76) = happyShift action_132
action_169 (81) = happyShift action_116
action_169 (86) = happyShift action_49
action_169 (98) = happyShift action_117
action_169 (99) = happyShift action_118
action_169 (100) = happyShift action_119
action_169 (101) = happyShift action_120
action_169 (102) = happyShift action_50
action_169 (103) = happyShift action_121
action_169 (17) = happyGoto action_106
action_169 (18) = happyGoto action_107
action_169 (22) = happyGoto action_287
action_169 (25) = happyGoto action_127
action_169 (27) = happyGoto action_128
action_169 (28) = happyGoto action_129
action_169 (29) = happyGoto action_39
action_169 _ = happyFail (happyExpListPerState 169)

action_170 (66) = happyShift action_40
action_170 (67) = happyShift action_41
action_170 (68) = happyShift action_42
action_170 (69) = happyShift action_43
action_170 (70) = happyShift action_44
action_170 (74) = happyShift action_45
action_170 (76) = happyShift action_46
action_170 (81) = happyShift action_47
action_170 (86) = happyShift action_49
action_170 (98) = happyShift action_117
action_170 (99) = happyShift action_118
action_170 (100) = happyShift action_119
action_170 (101) = happyShift action_120
action_170 (102) = happyShift action_50
action_170 (103) = happyShift action_121
action_170 (17) = happyGoto action_106
action_170 (18) = happyGoto action_107
action_170 (28) = happyGoto action_286
action_170 (29) = happyGoto action_39
action_170 _ = happyFail (happyExpListPerState 170)

action_171 (64) = happyShift action_130
action_171 (65) = happyShift action_131
action_171 (66) = happyShift action_40
action_171 (67) = happyShift action_41
action_171 (68) = happyShift action_42
action_171 (69) = happyShift action_43
action_171 (70) = happyShift action_44
action_171 (74) = happyShift action_45
action_171 (76) = happyShift action_132
action_171 (81) = happyShift action_116
action_171 (86) = happyShift action_49
action_171 (98) = happyShift action_117
action_171 (99) = happyShift action_118
action_171 (100) = happyShift action_119
action_171 (101) = happyShift action_120
action_171 (102) = happyShift action_50
action_171 (103) = happyShift action_121
action_171 (17) = happyGoto action_106
action_171 (18) = happyGoto action_107
action_171 (22) = happyGoto action_285
action_171 (25) = happyGoto action_127
action_171 (27) = happyGoto action_128
action_171 (28) = happyGoto action_129
action_171 (29) = happyGoto action_39
action_171 _ = happyFail (happyExpListPerState 171)

action_172 (81) = happyShift action_155
action_172 (34) = happyGoto action_284
action_172 _ = happyFail (happyExpListPerState 172)

action_173 (81) = happyShift action_283
action_173 _ = happyFail (happyExpListPerState 173)

action_174 (77) = happyShift action_282
action_174 _ = happyFail (happyExpListPerState 174)

action_175 _ = happyReduce_107

action_176 (77) = happyShift action_281
action_176 _ = happyFail (happyExpListPerState 176)

action_177 _ = happyReduce_105

action_178 (77) = happyShift action_280
action_178 _ = happyFail (happyExpListPerState 178)

action_179 _ = happyReduce_103

action_180 (77) = happyShift action_279
action_180 _ = happyFail (happyExpListPerState 180)

action_181 _ = happyReduce_101

action_182 (77) = happyShift action_278
action_182 _ = happyFail (happyExpListPerState 182)

action_183 _ = happyReduce_99

action_184 _ = happyReduce_21

action_185 (76) = happyShift action_124
action_185 (81) = happyShift action_125
action_185 (19) = happyGoto action_277
action_185 (20) = happyGoto action_123
action_185 _ = happyFail (happyExpListPerState 185)

action_186 (55) = happyShift action_168
action_186 (56) = happyShift action_169
action_186 (77) = happyShift action_276
action_186 _ = happyFail (happyExpListPerState 186)

action_187 (45) = happyShift action_9
action_187 (64) = happyShift action_130
action_187 (65) = happyShift action_131
action_187 (66) = happyShift action_40
action_187 (67) = happyShift action_41
action_187 (68) = happyShift action_42
action_187 (69) = happyShift action_43
action_187 (70) = happyShift action_44
action_187 (74) = happyShift action_45
action_187 (76) = happyShift action_187
action_187 (81) = happyShift action_116
action_187 (86) = happyShift action_49
action_187 (98) = happyShift action_117
action_187 (99) = happyShift action_118
action_187 (100) = happyShift action_119
action_187 (101) = happyShift action_120
action_187 (102) = happyShift action_50
action_187 (103) = happyShift action_121
action_187 (8) = happyGoto action_67
action_187 (9) = happyGoto action_149
action_187 (17) = happyGoto action_68
action_187 (18) = happyGoto action_107
action_187 (22) = happyGoto action_186
action_187 (25) = happyGoto action_127
action_187 (27) = happyGoto action_128
action_187 (28) = happyGoto action_129
action_187 (29) = happyGoto action_39
action_187 _ = happyFail (happyExpListPerState 187)

action_188 (55) = happyShift action_168
action_188 (56) = happyShift action_169
action_188 _ = happyReduce_68

action_189 (45) = happyShift action_9
action_189 (76) = happyShift action_10
action_189 (7) = happyGoto action_275
action_189 (8) = happyGoto action_4
action_189 (9) = happyGoto action_5
action_189 _ = happyFail (happyExpListPerState 189)

action_190 (101) = happyShift action_274
action_190 _ = happyFail (happyExpListPerState 190)

action_191 (76) = happyShift action_273
action_191 _ = happyFail (happyExpListPerState 191)

action_192 (66) = happyShift action_40
action_192 (67) = happyShift action_41
action_192 (68) = happyShift action_42
action_192 (69) = happyShift action_43
action_192 (70) = happyShift action_44
action_192 (74) = happyShift action_45
action_192 (76) = happyShift action_46
action_192 (81) = happyShift action_116
action_192 (86) = happyShift action_49
action_192 (98) = happyShift action_117
action_192 (99) = happyShift action_118
action_192 (100) = happyShift action_119
action_192 (101) = happyShift action_120
action_192 (102) = happyShift action_50
action_192 (103) = happyShift action_121
action_192 (17) = happyGoto action_106
action_192 (18) = happyGoto action_107
action_192 (25) = happyGoto action_272
action_192 (27) = happyGoto action_269
action_192 (28) = happyGoto action_129
action_192 (29) = happyGoto action_39
action_192 _ = happyFail (happyExpListPerState 192)

action_193 (66) = happyShift action_40
action_193 (67) = happyShift action_41
action_193 (68) = happyShift action_42
action_193 (69) = happyShift action_43
action_193 (70) = happyShift action_44
action_193 (74) = happyShift action_45
action_193 (76) = happyShift action_46
action_193 (81) = happyShift action_116
action_193 (86) = happyShift action_49
action_193 (98) = happyShift action_117
action_193 (99) = happyShift action_118
action_193 (100) = happyShift action_119
action_193 (101) = happyShift action_120
action_193 (102) = happyShift action_50
action_193 (103) = happyShift action_121
action_193 (17) = happyGoto action_106
action_193 (18) = happyGoto action_107
action_193 (25) = happyGoto action_271
action_193 (27) = happyGoto action_269
action_193 (28) = happyGoto action_129
action_193 (29) = happyGoto action_39
action_193 _ = happyFail (happyExpListPerState 193)

action_194 (66) = happyShift action_40
action_194 (67) = happyShift action_41
action_194 (68) = happyShift action_42
action_194 (69) = happyShift action_43
action_194 (70) = happyShift action_44
action_194 (74) = happyShift action_45
action_194 (76) = happyShift action_46
action_194 (81) = happyShift action_116
action_194 (86) = happyShift action_49
action_194 (98) = happyShift action_117
action_194 (99) = happyShift action_118
action_194 (100) = happyShift action_119
action_194 (101) = happyShift action_120
action_194 (102) = happyShift action_50
action_194 (103) = happyShift action_121
action_194 (17) = happyGoto action_106
action_194 (18) = happyGoto action_107
action_194 (25) = happyGoto action_270
action_194 (27) = happyGoto action_269
action_194 (28) = happyGoto action_129
action_194 (29) = happyGoto action_39
action_194 _ = happyFail (happyExpListPerState 194)

action_195 (66) = happyShift action_40
action_195 (67) = happyShift action_41
action_195 (68) = happyShift action_42
action_195 (69) = happyShift action_43
action_195 (70) = happyShift action_44
action_195 (74) = happyShift action_45
action_195 (76) = happyShift action_46
action_195 (81) = happyShift action_116
action_195 (86) = happyShift action_49
action_195 (98) = happyShift action_117
action_195 (99) = happyShift action_118
action_195 (100) = happyShift action_119
action_195 (101) = happyShift action_120
action_195 (102) = happyShift action_50
action_195 (103) = happyShift action_121
action_195 (17) = happyGoto action_106
action_195 (18) = happyGoto action_107
action_195 (25) = happyGoto action_268
action_195 (27) = happyGoto action_269
action_195 (28) = happyGoto action_129
action_195 (29) = happyGoto action_39
action_195 _ = happyFail (happyExpListPerState 195)

action_196 (66) = happyShift action_40
action_196 (67) = happyShift action_41
action_196 (68) = happyShift action_42
action_196 (69) = happyShift action_43
action_196 (70) = happyShift action_44
action_196 (74) = happyShift action_45
action_196 (76) = happyShift action_46
action_196 (81) = happyShift action_47
action_196 (86) = happyShift action_49
action_196 (98) = happyShift action_117
action_196 (99) = happyShift action_118
action_196 (100) = happyShift action_119
action_196 (101) = happyShift action_120
action_196 (102) = happyShift action_50
action_196 (103) = happyShift action_121
action_196 (17) = happyGoto action_106
action_196 (18) = happyGoto action_107
action_196 (28) = happyGoto action_267
action_196 (29) = happyGoto action_39
action_196 _ = happyFail (happyExpListPerState 196)

action_197 (66) = happyShift action_40
action_197 (67) = happyShift action_41
action_197 (68) = happyShift action_42
action_197 (69) = happyShift action_43
action_197 (70) = happyShift action_44
action_197 (74) = happyShift action_45
action_197 (76) = happyShift action_46
action_197 (81) = happyShift action_47
action_197 (86) = happyShift action_49
action_197 (98) = happyShift action_117
action_197 (99) = happyShift action_118
action_197 (100) = happyShift action_119
action_197 (101) = happyShift action_120
action_197 (102) = happyShift action_50
action_197 (103) = happyShift action_121
action_197 (17) = happyGoto action_106
action_197 (18) = happyGoto action_107
action_197 (28) = happyGoto action_266
action_197 (29) = happyGoto action_39
action_197 _ = happyFail (happyExpListPerState 197)

action_198 _ = happyReduce_23

action_199 (77) = happyShift action_265
action_199 _ = happyFail (happyExpListPerState 199)

action_200 (75) = happyShift action_203
action_200 (77) = happyShift action_264
action_200 (79) = happyShift action_204
action_200 (124) = happyShift action_205
action_200 (125) = happyShift action_206
action_200 (126) = happyShift action_207
action_200 (31) = happyGoto action_202
action_200 _ = happyFail (happyExpListPerState 200)

action_201 (45) = happyShift action_9
action_201 (76) = happyShift action_201
action_201 (81) = happyShift action_125
action_201 (8) = happyGoto action_199
action_201 (9) = happyGoto action_149
action_201 (20) = happyGoto action_200
action_201 _ = happyFail (happyExpListPerState 201)

action_202 (123) = happyShift action_263
action_202 _ = happyFail (happyExpListPerState 202)

action_203 (81) = happyShift action_244
action_203 (38) = happyGoto action_262
action_203 _ = happyFail (happyExpListPerState 203)

action_204 (81) = happyShift action_261
action_204 _ = happyFail (happyExpListPerState 204)

action_205 _ = happyReduce_112

action_206 _ = happyReduce_113

action_207 _ = happyReduce_111

action_208 _ = happyReduce_25

action_209 (81) = happyShift action_260
action_209 _ = happyFail (happyExpListPerState 209)

action_210 (55) = happyShift action_222
action_210 (56) = happyShift action_223
action_210 (77) = happyShift action_259
action_210 _ = happyFail (happyExpListPerState 210)

action_211 (45) = happyShift action_9
action_211 (64) = happyShift action_113
action_211 (65) = happyShift action_114
action_211 (66) = happyShift action_40
action_211 (67) = happyShift action_41
action_211 (68) = happyShift action_42
action_211 (69) = happyShift action_43
action_211 (70) = happyShift action_44
action_211 (74) = happyShift action_45
action_211 (76) = happyShift action_211
action_211 (81) = happyShift action_116
action_211 (86) = happyShift action_49
action_211 (98) = happyShift action_117
action_211 (99) = happyShift action_118
action_211 (100) = happyShift action_119
action_211 (101) = happyShift action_120
action_211 (102) = happyShift action_50
action_211 (103) = happyShift action_121
action_211 (8) = happyGoto action_67
action_211 (9) = happyGoto action_149
action_211 (17) = happyGoto action_68
action_211 (18) = happyGoto action_107
action_211 (23) = happyGoto action_210
action_211 (24) = happyGoto action_109
action_211 (27) = happyGoto action_110
action_211 (28) = happyGoto action_111
action_211 (29) = happyGoto action_112
action_211 _ = happyFail (happyExpListPerState 211)

action_212 (55) = happyShift action_222
action_212 (56) = happyShift action_223
action_212 _ = happyReduce_82

action_213 (45) = happyShift action_9
action_213 (76) = happyShift action_10
action_213 (7) = happyGoto action_258
action_213 (8) = happyGoto action_4
action_213 (9) = happyGoto action_5
action_213 _ = happyFail (happyExpListPerState 213)

action_214 (101) = happyShift action_257
action_214 _ = happyFail (happyExpListPerState 214)

action_215 (66) = happyShift action_40
action_215 (67) = happyShift action_41
action_215 (68) = happyShift action_42
action_215 (69) = happyShift action_43
action_215 (70) = happyShift action_44
action_215 (74) = happyShift action_45
action_215 (76) = happyShift action_46
action_215 (81) = happyShift action_47
action_215 (86) = happyShift action_49
action_215 (98) = happyShift action_117
action_215 (99) = happyShift action_118
action_215 (100) = happyShift action_119
action_215 (101) = happyShift action_120
action_215 (102) = happyShift action_50
action_215 (103) = happyShift action_121
action_215 (17) = happyGoto action_106
action_215 (18) = happyGoto action_107
action_215 (24) = happyGoto action_256
action_215 (28) = happyGoto action_111
action_215 (29) = happyGoto action_112
action_215 _ = happyFail (happyExpListPerState 215)

action_216 (66) = happyShift action_40
action_216 (67) = happyShift action_41
action_216 (68) = happyShift action_42
action_216 (69) = happyShift action_43
action_216 (70) = happyShift action_44
action_216 (74) = happyShift action_45
action_216 (76) = happyShift action_46
action_216 (81) = happyShift action_47
action_216 (86) = happyShift action_49
action_216 (98) = happyShift action_117
action_216 (99) = happyShift action_118
action_216 (100) = happyShift action_119
action_216 (101) = happyShift action_120
action_216 (102) = happyShift action_50
action_216 (103) = happyShift action_121
action_216 (17) = happyGoto action_106
action_216 (18) = happyGoto action_107
action_216 (24) = happyGoto action_255
action_216 (28) = happyGoto action_111
action_216 (29) = happyGoto action_112
action_216 _ = happyFail (happyExpListPerState 216)

action_217 (66) = happyShift action_40
action_217 (67) = happyShift action_41
action_217 (68) = happyShift action_42
action_217 (69) = happyShift action_43
action_217 (70) = happyShift action_44
action_217 (74) = happyShift action_45
action_217 (76) = happyShift action_46
action_217 (81) = happyShift action_47
action_217 (86) = happyShift action_49
action_217 (98) = happyShift action_117
action_217 (99) = happyShift action_118
action_217 (100) = happyShift action_119
action_217 (101) = happyShift action_120
action_217 (102) = happyShift action_50
action_217 (103) = happyShift action_121
action_217 (17) = happyGoto action_106
action_217 (18) = happyGoto action_107
action_217 (24) = happyGoto action_254
action_217 (28) = happyGoto action_111
action_217 (29) = happyGoto action_112
action_217 _ = happyFail (happyExpListPerState 217)

action_218 (66) = happyShift action_40
action_218 (67) = happyShift action_41
action_218 (68) = happyShift action_42
action_218 (69) = happyShift action_43
action_218 (70) = happyShift action_44
action_218 (74) = happyShift action_45
action_218 (76) = happyShift action_46
action_218 (81) = happyShift action_47
action_218 (86) = happyShift action_49
action_218 (98) = happyShift action_117
action_218 (99) = happyShift action_118
action_218 (100) = happyShift action_119
action_218 (101) = happyShift action_120
action_218 (102) = happyShift action_50
action_218 (103) = happyShift action_121
action_218 (17) = happyGoto action_106
action_218 (18) = happyGoto action_107
action_218 (24) = happyGoto action_253
action_218 (28) = happyGoto action_111
action_218 (29) = happyGoto action_112
action_218 _ = happyFail (happyExpListPerState 218)

action_219 (66) = happyShift action_40
action_219 (67) = happyShift action_41
action_219 (68) = happyShift action_42
action_219 (69) = happyShift action_43
action_219 (70) = happyShift action_44
action_219 (74) = happyShift action_45
action_219 (76) = happyShift action_46
action_219 (81) = happyShift action_47
action_219 (86) = happyShift action_49
action_219 (98) = happyShift action_117
action_219 (99) = happyShift action_118
action_219 (100) = happyShift action_119
action_219 (101) = happyShift action_120
action_219 (102) = happyShift action_50
action_219 (103) = happyShift action_121
action_219 (17) = happyGoto action_106
action_219 (18) = happyGoto action_107
action_219 (28) = happyGoto action_252
action_219 (29) = happyGoto action_39
action_219 _ = happyFail (happyExpListPerState 219)

action_220 (66) = happyShift action_40
action_220 (67) = happyShift action_41
action_220 (68) = happyShift action_42
action_220 (69) = happyShift action_43
action_220 (70) = happyShift action_44
action_220 (74) = happyShift action_45
action_220 (76) = happyShift action_46
action_220 (81) = happyShift action_47
action_220 (86) = happyShift action_49
action_220 (98) = happyShift action_117
action_220 (99) = happyShift action_118
action_220 (100) = happyShift action_119
action_220 (101) = happyShift action_120
action_220 (102) = happyShift action_50
action_220 (103) = happyShift action_121
action_220 (17) = happyGoto action_106
action_220 (18) = happyGoto action_107
action_220 (28) = happyGoto action_251
action_220 (29) = happyGoto action_39
action_220 _ = happyFail (happyExpListPerState 220)

action_221 _ = happyReduce_27

action_222 (64) = happyShift action_113
action_222 (65) = happyShift action_114
action_222 (66) = happyShift action_40
action_222 (67) = happyShift action_41
action_222 (68) = happyShift action_42
action_222 (69) = happyShift action_43
action_222 (70) = happyShift action_44
action_222 (74) = happyShift action_45
action_222 (76) = happyShift action_115
action_222 (81) = happyShift action_116
action_222 (86) = happyShift action_49
action_222 (98) = happyShift action_117
action_222 (99) = happyShift action_118
action_222 (100) = happyShift action_119
action_222 (101) = happyShift action_120
action_222 (102) = happyShift action_50
action_222 (103) = happyShift action_121
action_222 (17) = happyGoto action_106
action_222 (18) = happyGoto action_107
action_222 (23) = happyGoto action_250
action_222 (24) = happyGoto action_109
action_222 (27) = happyGoto action_110
action_222 (28) = happyGoto action_111
action_222 (29) = happyGoto action_112
action_222 _ = happyFail (happyExpListPerState 222)

action_223 (64) = happyShift action_113
action_223 (65) = happyShift action_114
action_223 (66) = happyShift action_40
action_223 (67) = happyShift action_41
action_223 (68) = happyShift action_42
action_223 (69) = happyShift action_43
action_223 (70) = happyShift action_44
action_223 (74) = happyShift action_45
action_223 (76) = happyShift action_115
action_223 (81) = happyShift action_116
action_223 (86) = happyShift action_49
action_223 (98) = happyShift action_117
action_223 (99) = happyShift action_118
action_223 (100) = happyShift action_119
action_223 (101) = happyShift action_120
action_223 (102) = happyShift action_50
action_223 (103) = happyShift action_121
action_223 (17) = happyGoto action_106
action_223 (18) = happyGoto action_107
action_223 (23) = happyGoto action_249
action_223 (24) = happyGoto action_109
action_223 (27) = happyGoto action_110
action_223 (28) = happyGoto action_111
action_223 (29) = happyGoto action_112
action_223 _ = happyFail (happyExpListPerState 223)

action_224 (81) = happyShift action_248
action_224 _ = happyFail (happyExpListPerState 224)

action_225 (71) = happyShift action_91
action_225 (15) = happyGoto action_247
action_225 _ = happyReduce_32

action_226 _ = happyReduce_109

action_227 _ = happyReduce_110

action_228 (81) = happyShift action_105
action_228 (26) = happyGoto action_246
action_228 (27) = happyGoto action_104
action_228 _ = happyFail (happyExpListPerState 228)

action_229 (81) = happyShift action_244
action_229 (38) = happyGoto action_245
action_229 _ = happyFail (happyExpListPerState 229)

action_230 (81) = happyShift action_244
action_230 (38) = happyGoto action_243
action_230 _ = happyFail (happyExpListPerState 230)

action_231 (103) = happyShift action_242
action_231 _ = happyReduce_135

action_232 _ = happyReduce_148

action_233 _ = happyReduce_149

action_234 _ = happyReduce_151

action_235 _ = happyReduce_150

action_236 _ = happyReduce_152

action_237 _ = happyReduce_153

action_238 _ = happyReduce_154

action_239 _ = happyReduce_125

action_240 (81) = happyShift action_98
action_240 (94) = happyShift action_99
action_240 (115) = happyShift action_100
action_240 (36) = happyGoto action_241
action_240 (37) = happyGoto action_97
action_240 _ = happyFail (happyExpListPerState 240)

action_241 (78) = happyShift action_240
action_241 _ = happyReduce_133

action_242 _ = happyReduce_134

action_243 (77) = happyShift action_298
action_243 (78) = happyShift action_294
action_243 _ = happyFail (happyExpListPerState 243)

action_244 _ = happyReduce_138

action_245 (77) = happyShift action_297
action_245 (78) = happyShift action_294
action_245 _ = happyFail (happyExpListPerState 245)

action_246 (78) = happyShift action_228
action_246 _ = happyReduce_90

action_247 _ = happyReduce_29

action_248 _ = happyReduce_92

action_249 _ = happyReduce_75

action_250 _ = happyReduce_73

action_251 _ = happyReduce_80

action_252 _ = happyReduce_78

action_253 _ = happyReduce_81

action_254 _ = happyReduce_79

action_255 _ = happyReduce_77

action_256 _ = happyReduce_76

action_257 _ = happyReduce_84

action_258 (52) = happyShift action_54
action_258 (53) = happyShift action_55
action_258 (54) = happyShift action_56
action_258 (77) = happyShift action_296
action_258 _ = happyFail (happyExpListPerState 258)

action_259 _ = happyReduce_74

action_260 (77) = happyReduce_92
action_260 (79) = happyReduce_39
action_260 (85) = happyReduce_39
action_260 (86) = happyReduce_39
action_260 (87) = happyReduce_39
action_260 (88) = happyReduce_39
action_260 _ = happyReduce_92

action_261 _ = happyReduce_52

action_262 (78) = happyShift action_294
action_262 (79) = happyShift action_295
action_262 _ = happyFail (happyExpListPerState 262)

action_263 (76) = happyShift action_124
action_263 (81) = happyShift action_125
action_263 (20) = happyGoto action_293
action_263 _ = happyFail (happyExpListPerState 263)

action_264 _ = happyReduce_51

action_265 _ = happyReduce_55

action_266 _ = happyReduce_67

action_267 _ = happyReduce_65

action_268 _ = happyReduce_66

action_269 _ = happyReduce_87

action_270 _ = happyReduce_64

action_271 _ = happyReduce_63

action_272 _ = happyReduce_62

action_273 (45) = happyShift action_9
action_273 (76) = happyShift action_10
action_273 (98) = happyShift action_158
action_273 (99) = happyShift action_159
action_273 (100) = happyShift action_160
action_273 (101) = happyShift action_161
action_273 (102) = happyShift action_162
action_273 (103) = happyShift action_163
action_273 (7) = happyGoto action_291
action_273 (8) = happyGoto action_4
action_273 (9) = happyGoto action_5
action_273 (33) = happyGoto action_292
action_273 _ = happyFail (happyExpListPerState 273)

action_274 _ = happyReduce_70

action_275 (52) = happyShift action_54
action_275 (53) = happyShift action_55
action_275 (54) = happyShift action_56
action_275 (77) = happyShift action_290
action_275 _ = happyFail (happyExpListPerState 275)

action_276 _ = happyReduce_60

action_277 (78) = happyShift action_185
action_277 _ = happyReduce_50

action_278 _ = happyReduce_100

action_279 _ = happyReduce_102

action_280 _ = happyReduce_104

action_281 _ = happyReduce_106

action_282 _ = happyReduce_108

action_283 _ = happyReduce_38

action_284 (78) = happyShift action_172
action_284 _ = happyReduce_124

action_285 (55) = happyShift action_168
action_285 (56) = happyShift action_169
action_285 _ = happyReduce_11

action_286 _ = happyReduce_123

action_287 _ = happyReduce_61

action_288 _ = happyReduce_59

action_289 (78) = happyShift action_167
action_289 _ = happyReduce_122

action_290 _ = happyReduce_69

action_291 (52) = happyShift action_54
action_291 (53) = happyShift action_55
action_291 (54) = happyShift action_56
action_291 (77) = happyShift action_304
action_291 _ = happyFail (happyExpListPerState 291)

action_292 (77) = happyShift action_303
action_292 (78) = happyShift action_167
action_292 _ = happyFail (happyExpListPerState 292)

action_293 (75) = happyShift action_203
action_293 (79) = happyShift action_204
action_293 (122) = happyShift action_302
action_293 (124) = happyShift action_205
action_293 (125) = happyShift action_206
action_293 (126) = happyShift action_207
action_293 (31) = happyGoto action_202
action_293 _ = happyFail (happyExpListPerState 293)

action_294 (81) = happyShift action_244
action_294 (38) = happyGoto action_301
action_294 _ = happyFail (happyExpListPerState 294)

action_295 (81) = happyShift action_244
action_295 (38) = happyGoto action_300
action_295 _ = happyFail (happyExpListPerState 295)

action_296 _ = happyReduce_83

action_297 (116) = happyShift action_299
action_297 _ = happyFail (happyExpListPerState 297)

action_298 _ = happyReduce_136

action_299 (81) = happyShift action_306
action_299 _ = happyFail (happyExpListPerState 299)

action_300 _ = happyReduce_53

action_301 (78) = happyShift action_294
action_301 _ = happyReduce_139

action_302 (81) = happyShift action_105
action_302 (27) = happyGoto action_305
action_302 _ = happyFail (happyExpListPerState 302)

action_303 _ = happyReduce_72

action_304 _ = happyReduce_71

action_305 (57) = happyShift action_308
action_305 _ = happyFail (happyExpListPerState 305)

action_306 (76) = happyShift action_307
action_306 _ = happyFail (happyExpListPerState 306)

action_307 (81) = happyShift action_244
action_307 (38) = happyGoto action_310
action_307 _ = happyFail (happyExpListPerState 307)

action_308 (81) = happyShift action_105
action_308 (27) = happyGoto action_309
action_308 _ = happyFail (happyExpListPerState 308)

action_309 _ = happyReduce_56

action_310 (77) = happyShift action_311
action_310 (78) = happyShift action_294
action_310 _ = happyFail (happyExpListPerState 310)

action_311 (117) = happyShift action_313
action_311 (39) = happyGoto action_312
action_311 _ = happyReduce_140

action_312 (118) = happyShift action_318
action_312 (40) = happyGoto action_317
action_312 _ = happyReduce_144

action_313 (119) = happyShift action_314
action_313 (120) = happyShift action_315
action_313 (121) = happyShift action_316
action_313 _ = happyFail (happyExpListPerState 313)

action_314 _ = happyReduce_141

action_315 _ = happyReduce_142

action_316 _ = happyReduce_143

action_317 _ = happyReduce_137

action_318 (119) = happyShift action_319
action_318 (120) = happyShift action_320
action_318 (121) = happyShift action_321
action_318 _ = happyFail (happyExpListPerState 318)

action_319 _ = happyReduce_145

action_320 _ = happyReduce_146

action_321 _ = happyReduce_147

happyReduce_1 = happySpecReduce_1  4 happyReduction_1
happyReduction_1 (HappyAbsSyn6  happy_var_1)
	 =  HappyAbsSyn4
		 (S1 happy_var_1
	)
happyReduction_1 _  = notHappyAtAll 

happyReduce_2 = happySpecReduce_1  4 happyReduction_2
happyReduction_2 (HappyAbsSyn35  happy_var_1)
	 =  HappyAbsSyn4
		 (S2 happy_var_1
	)
happyReduction_2 _  = notHappyAtAll 

happyReduce_3 = happySpecReduce_1  4 happyReduction_3
happyReduction_3 (HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn4
		 (S3 happy_var_1
	)
happyReduction_3 _  = notHappyAtAll 

happyReduce_4 = happySpecReduce_3  4 happyReduction_4
happyReduction_4 (HappyAbsSyn4  happy_var_3)
	_
	(HappyAbsSyn4  happy_var_1)
	 =  HappyAbsSyn4
		 (Seq happy_var_1 happy_var_3
	)
happyReduction_4 _ _ _  = notHappyAtAll 

happyReduce_5 = happySpecReduce_2  4 happyReduction_5
happyReduction_5 (HappyTerminal (TStr happy_var_2))
	_
	 =  HappyAbsSyn4
		 (Source happy_var_2
	)
happyReduction_5 _ _  = notHappyAtAll 

happyReduce_6 = happySpecReduce_2  5 happyReduction_6
happyReduction_6 (HappyTerminal (TField happy_var_2))
	_
	 =  HappyAbsSyn5
		 (CUser happy_var_2
	)
happyReduction_6 _ _  = notHappyAtAll 

happyReduce_7 = happySpecReduce_2  5 happyReduction_7
happyReduction_7 (HappyTerminal (TField happy_var_2))
	_
	 =  HappyAbsSyn5
		 (DUser happy_var_2
	)
happyReduction_7 _ _  = notHappyAtAll 

happyReduce_8 = happySpecReduce_2  5 happyReduction_8
happyReduction_8 (HappyTerminal (TField happy_var_2))
	_
	 =  HappyAbsSyn5
		 (SUser happy_var_2
	)
happyReduction_8 _ _  = notHappyAtAll 

happyReduce_9 = happySpecReduce_3  6 happyReduction_9
happyReduction_9 (HappyAbsSyn32  happy_var_3)
	(HappyTerminal (TField happy_var_2))
	_
	 =  HappyAbsSyn6
		 (Insert happy_var_2 happy_var_3
	)
happyReduction_9 _ _ _  = notHappyAtAll 

happyReduce_10 = happyReduce 4 6 happyReduction_10
happyReduction_10 ((HappyAbsSyn22  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TField happy_var_2)) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn6
		 (Delete happy_var_2 happy_var_4
	) `HappyStk` happyRest

happyReduce_11 = happyReduce 6 6 happyReduction_11
happyReduction_11 ((HappyAbsSyn22  happy_var_6) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn34  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TField happy_var_2)) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn6
		 (Update happy_var_2 happy_var_4 happy_var_6
	) `HappyStk` happyRest

happyReduce_12 = happySpecReduce_1  6 happyReduction_12
happyReduction_12 (HappyAbsSyn6  happy_var_1)
	 =  HappyAbsSyn6
		 (happy_var_1
	)
happyReduction_12 _  = notHappyAtAll 

happyReduce_13 = happySpecReduce_3  7 happyReduction_13
happyReduction_13 (HappyAbsSyn6  happy_var_3)
	_
	(HappyAbsSyn6  happy_var_1)
	 =  HappyAbsSyn6
		 (Union happy_var_1 happy_var_3
	)
happyReduction_13 _ _ _  = notHappyAtAll 

happyReduce_14 = happySpecReduce_3  7 happyReduction_14
happyReduction_14 (HappyAbsSyn6  happy_var_3)
	_
	(HappyAbsSyn6  happy_var_1)
	 =  HappyAbsSyn6
		 (Diff happy_var_1 happy_var_3
	)
happyReduction_14 _ _ _  = notHappyAtAll 

happyReduce_15 = happySpecReduce_3  7 happyReduction_15
happyReduction_15 (HappyAbsSyn6  happy_var_3)
	_
	(HappyAbsSyn6  happy_var_1)
	 =  HappyAbsSyn6
		 (Intersect happy_var_1 happy_var_3
	)
happyReduction_15 _ _ _  = notHappyAtAll 

happyReduce_16 = happySpecReduce_1  7 happyReduction_16
happyReduction_16 (HappyAbsSyn6  happy_var_1)
	 =  HappyAbsSyn6
		 (happy_var_1
	)
happyReduction_16 _  = notHappyAtAll 

happyReduce_17 = happySpecReduce_1  8 happyReduction_17
happyReduction_17 (HappyAbsSyn9  happy_var_1)
	 =  HappyAbsSyn6
		 (happy_var_1
	)
happyReduction_17 _  = notHappyAtAll 

happyReduce_18 = happySpecReduce_3  8 happyReduction_18
happyReduction_18 _
	(HappyAbsSyn9  happy_var_2)
	_
	 =  HappyAbsSyn6
		 (happy_var_2
	)
happyReduction_18 _ _ _  = notHappyAtAll 

happyReduce_19 = happySpecReduce_3  9 happyReduction_19
happyReduction_19 (HappyAbsSyn10  happy_var_3)
	(HappyAbsSyn16  happy_var_2)
	_
	 =  HappyAbsSyn9
		 (Select False happy_var_2 happy_var_3
	)
happyReduction_19 _ _ _  = notHappyAtAll 

happyReduce_20 = happyReduce 4 9 happyReduction_20
happyReduction_20 ((HappyAbsSyn10  happy_var_4) `HappyStk`
	(HappyAbsSyn16  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn9
		 (Select True happy_var_3 happy_var_4
	) `HappyStk` happyRest

happyReduce_21 = happySpecReduce_3  10 happyReduction_21
happyReduction_21 (HappyAbsSyn11  happy_var_3)
	(HappyAbsSyn16  happy_var_2)
	_
	 =  HappyAbsSyn10
		 (From happy_var_2 happy_var_3
	)
happyReduction_21 _ _ _  = notHappyAtAll 

happyReduce_22 = happySpecReduce_1  10 happyReduction_22
happyReduction_22 (HappyAbsSyn11  happy_var_1)
	 =  HappyAbsSyn10
		 (happy_var_1
	)
happyReduction_22 _  = notHappyAtAll 

happyReduce_23 = happySpecReduce_3  11 happyReduction_23
happyReduction_23 (HappyAbsSyn12  happy_var_3)
	(HappyAbsSyn22  happy_var_2)
	_
	 =  HappyAbsSyn11
		 (Where happy_var_2 happy_var_3
	)
happyReduction_23 _ _ _  = notHappyAtAll 

happyReduce_24 = happySpecReduce_1  11 happyReduction_24
happyReduction_24 (HappyAbsSyn12  happy_var_1)
	 =  HappyAbsSyn11
		 (happy_var_1
	)
happyReduction_24 _  = notHappyAtAll 

happyReduce_25 = happySpecReduce_3  12 happyReduction_25
happyReduction_25 (HappyAbsSyn13  happy_var_3)
	(HappyAbsSyn16  happy_var_2)
	_
	 =  HappyAbsSyn12
		 (GroupBy happy_var_2 happy_var_3
	)
happyReduction_25 _ _ _  = notHappyAtAll 

happyReduce_26 = happySpecReduce_1  12 happyReduction_26
happyReduction_26 (HappyAbsSyn13  happy_var_1)
	 =  HappyAbsSyn12
		 (happy_var_1
	)
happyReduction_26 _  = notHappyAtAll 

happyReduce_27 = happySpecReduce_3  13 happyReduction_27
happyReduction_27 (HappyAbsSyn14  happy_var_3)
	(HappyAbsSyn22  happy_var_2)
	_
	 =  HappyAbsSyn13
		 (Having happy_var_2 happy_var_3
	)
happyReduction_27 _ _ _  = notHappyAtAll 

happyReduce_28 = happySpecReduce_1  13 happyReduction_28
happyReduction_28 (HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn13
		 (happy_var_1
	)
happyReduction_28 _  = notHappyAtAll 

happyReduce_29 = happyReduce 4 14 happyReduction_29
happyReduction_29 ((HappyAbsSyn15  happy_var_4) `HappyStk`
	(HappyAbsSyn30  happy_var_3) `HappyStk`
	(HappyAbsSyn16  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn14
		 (OrderBy happy_var_2 happy_var_3 happy_var_4
	) `HappyStk` happyRest

happyReduce_30 = happySpecReduce_1  14 happyReduction_30
happyReduction_30 (HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn14
		 (happy_var_1
	)
happyReduction_30 _  = notHappyAtAll 

happyReduce_31 = happySpecReduce_2  15 happyReduction_31
happyReduction_31 (HappyTerminal (TNum happy_var_2))
	_
	 =  HappyAbsSyn15
		 (Limit happy_var_2 End
	)
happyReduction_31 _ _  = notHappyAtAll 

happyReduce_32 = happySpecReduce_0  15 happyReduction_32
happyReduction_32  =  HappyAbsSyn15
		 (End
	)

happyReduce_33 = happySpecReduce_3  16 happyReduction_33
happyReduction_33 (HappyAbsSyn16  happy_var_3)
	_
	(HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn16
		 (happy_var_1 ++ happy_var_3
	)
happyReduction_33 _ _ _  = notHappyAtAll 

happyReduce_34 = happySpecReduce_1  16 happyReduction_34
happyReduction_34 (HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn16
		 ([happy_var_1]
	)
happyReduction_34 _  = notHappyAtAll 

happyReduce_35 = happySpecReduce_1  17 happyReduction_35
happyReduction_35 (HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn17
		 (Field happy_var_1
	)
happyReduction_35 _  = notHappyAtAll 

happyReduce_36 = happySpecReduce_1  17 happyReduction_36
happyReduction_36 (HappyAbsSyn29  happy_var_1)
	 =  HappyAbsSyn17
		 (A2 happy_var_1
	)
happyReduction_36 _  = notHappyAtAll 

happyReduce_37 = happySpecReduce_3  17 happyReduction_37
happyReduction_37 (HappyTerminal (TField happy_var_3))
	_
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn17
		 (As happy_var_1 happy_var_3
	)
happyReduction_37 _ _ _  = notHappyAtAll 

happyReduce_38 = happyReduce 5 17 happyReduction_38
happyReduction_38 ((HappyTerminal (TField happy_var_5)) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn6  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn17
		 (As (Subquery happy_var_2) happy_var_5
	) `HappyStk` happyRest

happyReduce_39 = happySpecReduce_3  17 happyReduction_39
happyReduction_39 (HappyTerminal (TField happy_var_3))
	_
	(HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn17
		 (Dot happy_var_1 happy_var_3
	)
happyReduction_39 _ _ _  = notHappyAtAll 

happyReduce_40 = happySpecReduce_1  17 happyReduction_40
happyReduction_40 (HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn17
		 (happy_var_1
	)
happyReduction_40 _  = notHappyAtAll 

happyReduce_41 = happySpecReduce_1  17 happyReduction_41
happyReduction_41 _
	 =  HappyAbsSyn17
		 (All
	)

happyReduce_42 = happySpecReduce_3  18 happyReduction_42
happyReduction_42 (HappyAbsSyn17  happy_var_3)
	_
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn17
		 (Plus happy_var_1 happy_var_3
	)
happyReduction_42 _ _ _  = notHappyAtAll 

happyReduce_43 = happySpecReduce_3  18 happyReduction_43
happyReduction_43 (HappyAbsSyn17  happy_var_3)
	_
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn17
		 (Minus happy_var_1 happy_var_3
	)
happyReduction_43 _ _ _  = notHappyAtAll 

happyReduce_44 = happySpecReduce_3  18 happyReduction_44
happyReduction_44 (HappyAbsSyn17  happy_var_3)
	_
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn17
		 (Times happy_var_1 happy_var_3
	)
happyReduction_44 _ _ _  = notHappyAtAll 

happyReduce_45 = happySpecReduce_3  18 happyReduction_45
happyReduction_45 (HappyAbsSyn17  happy_var_3)
	_
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn17
		 (Div happy_var_1 happy_var_3
	)
happyReduction_45 _ _ _  = notHappyAtAll 

happyReduce_46 = happySpecReduce_3  18 happyReduction_46
happyReduction_46 _
	(HappyAbsSyn17  happy_var_2)
	_
	 =  HappyAbsSyn17
		 (Brack happy_var_2
	)
happyReduction_46 _ _ _  = notHappyAtAll 

happyReduce_47 = happySpecReduce_2  18 happyReduction_47
happyReduction_47 (HappyAbsSyn17  happy_var_2)
	_
	 =  HappyAbsSyn17
		 (Negate happy_var_2
	)
happyReduction_47 _ _  = notHappyAtAll 

happyReduce_48 = happySpecReduce_1  18 happyReduction_48
happyReduction_48 (HappyTerminal (TNum happy_var_1))
	 =  HappyAbsSyn17
		 (A3 happy_var_1
	)
happyReduction_48 _  = notHappyAtAll 

happyReduce_49 = happySpecReduce_1  19 happyReduction_49
happyReduction_49 (HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn16
		 ([happy_var_1]
	)
happyReduction_49 _  = notHappyAtAll 

happyReduce_50 = happySpecReduce_3  19 happyReduction_50
happyReduction_50 (HappyAbsSyn16  happy_var_3)
	_
	(HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn16
		 (happy_var_1 ++ happy_var_3
	)
happyReduction_50 _ _ _  = notHappyAtAll 

happyReduce_51 = happySpecReduce_3  20 happyReduction_51
happyReduction_51 _
	(HappyAbsSyn17  happy_var_2)
	_
	 =  HappyAbsSyn17
		 (happy_var_2
	)
happyReduction_51 _ _ _  = notHappyAtAll 

happyReduce_52 = happySpecReduce_3  20 happyReduction_52
happyReduction_52 (HappyTerminal (TField happy_var_3))
	_
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn17
		 (As happy_var_1 happy_var_3
	)
happyReduction_52 _ _ _  = notHappyAtAll 

happyReduce_53 = happyReduce 5 20 happyReduction_53
happyReduction_53 ((HappyAbsSyn38  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn38  happy_var_3) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn17  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn17
		 (ColAs happy_var_1 happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_54 = happySpecReduce_1  20 happyReduction_54
happyReduction_54 (HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn17
		 (Field happy_var_1
	)
happyReduction_54 _  = notHappyAtAll 

happyReduce_55 = happySpecReduce_3  20 happyReduction_55
happyReduction_55 _
	(HappyAbsSyn6  happy_var_2)
	_
	 =  HappyAbsSyn17
		 (Subquery happy_var_2
	)
happyReduction_55 _ _ _  = notHappyAtAll 

happyReduce_56 = happyReduce 8 20 happyReduction_56
happyReduction_56 ((HappyAbsSyn17  happy_var_8) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn17  happy_var_6) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn17  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn31  happy_var_2) `HappyStk`
	(HappyAbsSyn17  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn17
		 (Join happy_var_2 happy_var_1 happy_var_4 (Equal happy_var_6 happy_var_8)
	) `HappyStk` happyRest

happyReduce_57 = happySpecReduce_1  21 happyReduction_57
happyReduction_57 (HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn16
		 ([Field happy_var_1]
	)
happyReduction_57 _  = notHappyAtAll 

happyReduce_58 = happySpecReduce_3  21 happyReduction_58
happyReduction_58 (HappyAbsSyn16  happy_var_3)
	_
	(HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn16
		 (happy_var_1 ++ happy_var_3
	)
happyReduction_58 _ _ _  = notHappyAtAll 

happyReduce_59 = happySpecReduce_3  22 happyReduction_59
happyReduction_59 (HappyAbsSyn22  happy_var_3)
	_
	(HappyAbsSyn22  happy_var_1)
	 =  HappyAbsSyn22
		 (And happy_var_1 happy_var_3
	)
happyReduction_59 _ _ _  = notHappyAtAll 

happyReduce_60 = happySpecReduce_3  22 happyReduction_60
happyReduction_60 _
	(HappyAbsSyn22  happy_var_2)
	_
	 =  HappyAbsSyn22
		 (happy_var_2
	)
happyReduction_60 _ _ _  = notHappyAtAll 

happyReduce_61 = happySpecReduce_3  22 happyReduction_61
happyReduction_61 (HappyAbsSyn22  happy_var_3)
	_
	(HappyAbsSyn22  happy_var_1)
	 =  HappyAbsSyn22
		 (Or happy_var_1 happy_var_3
	)
happyReduction_61 _ _ _  = notHappyAtAll 

happyReduce_62 = happySpecReduce_3  22 happyReduction_62
happyReduction_62 (HappyAbsSyn17  happy_var_3)
	_
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn22
		 (Equal happy_var_1 happy_var_3
	)
happyReduction_62 _ _ _  = notHappyAtAll 

happyReduce_63 = happySpecReduce_3  22 happyReduction_63
happyReduction_63 (HappyAbsSyn17  happy_var_3)
	_
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn22
		 (NotEq happy_var_1 happy_var_3
	)
happyReduction_63 _ _ _  = notHappyAtAll 

happyReduce_64 = happySpecReduce_3  22 happyReduction_64
happyReduction_64 (HappyAbsSyn17  happy_var_3)
	_
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn22
		 (Great happy_var_1 happy_var_3
	)
happyReduction_64 _ _ _  = notHappyAtAll 

happyReduce_65 = happySpecReduce_3  22 happyReduction_65
happyReduction_65 (HappyAbsSyn17  happy_var_3)
	_
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn22
		 (GrOrEq happy_var_1 happy_var_3
	)
happyReduction_65 _ _ _  = notHappyAtAll 

happyReduce_66 = happySpecReduce_3  22 happyReduction_66
happyReduction_66 (HappyAbsSyn17  happy_var_3)
	_
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn22
		 (Less happy_var_1 happy_var_3
	)
happyReduction_66 _ _ _  = notHappyAtAll 

happyReduce_67 = happySpecReduce_3  22 happyReduction_67
happyReduction_67 (HappyAbsSyn17  happy_var_3)
	_
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn22
		 (LsOrEq happy_var_1 happy_var_3
	)
happyReduction_67 _ _ _  = notHappyAtAll 

happyReduce_68 = happySpecReduce_2  22 happyReduction_68
happyReduction_68 (HappyAbsSyn22  happy_var_2)
	_
	 =  HappyAbsSyn22
		 (Not happy_var_2
	)
happyReduction_68 _ _  = notHappyAtAll 

happyReduce_69 = happyReduce 4 22 happyReduction_69
happyReduction_69 (_ `HappyStk`
	(HappyAbsSyn6  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn22
		 (Exist happy_var_3
	) `HappyStk` happyRest

happyReduce_70 = happySpecReduce_3  22 happyReduction_70
happyReduction_70 (HappyTerminal (TStr happy_var_3))
	_
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn22
		 (Like happy_var_1 happy_var_3
	)
happyReduction_70 _ _ _  = notHappyAtAll 

happyReduce_71 = happyReduce 5 22 happyReduction_71
happyReduction_71 (_ `HappyStk`
	(HappyAbsSyn6  happy_var_4) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn17  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn22
		 (InQuery happy_var_1 happy_var_4
	) `HappyStk` happyRest

happyReduce_72 = happyReduce 5 22 happyReduction_72
happyReduction_72 (_ `HappyStk`
	(HappyAbsSyn16  happy_var_4) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn17  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn22
		 (InVals happy_var_1 happy_var_4
	) `HappyStk` happyRest

happyReduce_73 = happySpecReduce_3  23 happyReduction_73
happyReduction_73 (HappyAbsSyn22  happy_var_3)
	_
	(HappyAbsSyn22  happy_var_1)
	 =  HappyAbsSyn22
		 (And happy_var_1 happy_var_3
	)
happyReduction_73 _ _ _  = notHappyAtAll 

happyReduce_74 = happySpecReduce_3  23 happyReduction_74
happyReduction_74 _
	(HappyAbsSyn22  happy_var_2)
	_
	 =  HappyAbsSyn22
		 (happy_var_2
	)
happyReduction_74 _ _ _  = notHappyAtAll 

happyReduce_75 = happySpecReduce_3  23 happyReduction_75
happyReduction_75 (HappyAbsSyn22  happy_var_3)
	_
	(HappyAbsSyn22  happy_var_1)
	 =  HappyAbsSyn22
		 (Or happy_var_1 happy_var_3
	)
happyReduction_75 _ _ _  = notHappyAtAll 

happyReduce_76 = happySpecReduce_3  23 happyReduction_76
happyReduction_76 (HappyAbsSyn17  happy_var_3)
	_
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn22
		 (Equal happy_var_1 happy_var_3
	)
happyReduction_76 _ _ _  = notHappyAtAll 

happyReduce_77 = happySpecReduce_3  23 happyReduction_77
happyReduction_77 (HappyAbsSyn17  happy_var_3)
	_
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn22
		 (NotEq happy_var_1 happy_var_3
	)
happyReduction_77 _ _ _  = notHappyAtAll 

happyReduce_78 = happySpecReduce_3  23 happyReduction_78
happyReduction_78 (HappyAbsSyn17  happy_var_3)
	_
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn22
		 (GrOrEq happy_var_1 happy_var_3
	)
happyReduction_78 _ _ _  = notHappyAtAll 

happyReduce_79 = happySpecReduce_3  23 happyReduction_79
happyReduction_79 (HappyAbsSyn17  happy_var_3)
	_
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn22
		 (Great happy_var_1 happy_var_3
	)
happyReduction_79 _ _ _  = notHappyAtAll 

happyReduce_80 = happySpecReduce_3  23 happyReduction_80
happyReduction_80 (HappyAbsSyn17  happy_var_3)
	_
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn22
		 (LsOrEq happy_var_1 happy_var_3
	)
happyReduction_80 _ _ _  = notHappyAtAll 

happyReduce_81 = happySpecReduce_3  23 happyReduction_81
happyReduction_81 (HappyAbsSyn17  happy_var_3)
	_
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn22
		 (Less happy_var_1 happy_var_3
	)
happyReduction_81 _ _ _  = notHappyAtAll 

happyReduce_82 = happySpecReduce_2  23 happyReduction_82
happyReduction_82 (HappyAbsSyn22  happy_var_2)
	_
	 =  HappyAbsSyn22
		 (Not happy_var_2
	)
happyReduction_82 _ _  = notHappyAtAll 

happyReduce_83 = happyReduce 4 23 happyReduction_83
happyReduction_83 (_ `HappyStk`
	(HappyAbsSyn6  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn22
		 (Exist happy_var_3
	) `HappyStk` happyRest

happyReduce_84 = happySpecReduce_3  23 happyReduction_84
happyReduction_84 (HappyTerminal (TStr happy_var_3))
	_
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn22
		 (Like happy_var_1 happy_var_3
	)
happyReduction_84 _ _ _  = notHappyAtAll 

happyReduce_85 = happySpecReduce_1  24 happyReduction_85
happyReduction_85 (HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn17
		 (happy_var_1
	)
happyReduction_85 _  = notHappyAtAll 

happyReduce_86 = happySpecReduce_1  24 happyReduction_86
happyReduction_86 (HappyAbsSyn29  happy_var_1)
	 =  HappyAbsSyn17
		 (A2 happy_var_1
	)
happyReduction_86 _  = notHappyAtAll 

happyReduce_87 = happySpecReduce_1  25 happyReduction_87
happyReduction_87 (HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn17
		 (happy_var_1
	)
happyReduction_87 _  = notHappyAtAll 

happyReduce_88 = happySpecReduce_1  25 happyReduction_88
happyReduction_88 (HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn17
		 (happy_var_1
	)
happyReduction_88 _  = notHappyAtAll 

happyReduce_89 = happySpecReduce_1  26 happyReduction_89
happyReduction_89 (HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn16
		 ([happy_var_1]
	)
happyReduction_89 _  = notHappyAtAll 

happyReduce_90 = happySpecReduce_3  26 happyReduction_90
happyReduction_90 (HappyAbsSyn16  happy_var_3)
	_
	(HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn16
		 (happy_var_1 ++ happy_var_3
	)
happyReduction_90 _ _ _  = notHappyAtAll 

happyReduce_91 = happySpecReduce_1  27 happyReduction_91
happyReduction_91 (HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn17
		 (Field happy_var_1
	)
happyReduction_91 _  = notHappyAtAll 

happyReduce_92 = happySpecReduce_3  27 happyReduction_92
happyReduction_92 (HappyTerminal (TField happy_var_3))
	_
	(HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn17
		 (Dot happy_var_1 happy_var_3
	)
happyReduction_92 _ _ _  = notHappyAtAll 

happyReduce_93 = happySpecReduce_1  28 happyReduction_93
happyReduction_93 (HappyTerminal (TStr happy_var_1))
	 =  HappyAbsSyn17
		 (A1 happy_var_1
	)
happyReduction_93 _  = notHappyAtAll 

happyReduce_94 = happySpecReduce_1  28 happyReduction_94
happyReduction_94 (HappyTerminal (TDatTim happy_var_1))
	 =  HappyAbsSyn17
		 (A5 happy_var_1
	)
happyReduction_94 _  = notHappyAtAll 

happyReduce_95 = happySpecReduce_1  28 happyReduction_95
happyReduction_95 (HappyTerminal (TDat happy_var_1))
	 =  HappyAbsSyn17
		 (A6 happy_var_1
	)
happyReduction_95 _  = notHappyAtAll 

happyReduce_96 = happySpecReduce_1  28 happyReduction_96
happyReduction_96 (HappyTerminal (TTim happy_var_1))
	 =  HappyAbsSyn17
		 (A7 happy_var_1
	)
happyReduction_96 _  = notHappyAtAll 

happyReduce_97 = happySpecReduce_1  28 happyReduction_97
happyReduction_97 (HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn17
		 (happy_var_1
	)
happyReduction_97 _  = notHappyAtAll 

happyReduce_98 = happySpecReduce_1  28 happyReduction_98
happyReduction_98 _
	 =  HappyAbsSyn17
		 (Nulo
	)

happyReduce_99 = happyReduce 4 29 happyReduction_99
happyReduction_99 (_ `HappyStk`
	(HappyAbsSyn17  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn29
		 (Sum False happy_var_3
	) `HappyStk` happyRest

happyReduce_100 = happyReduce 5 29 happyReduction_100
happyReduction_100 (_ `HappyStk`
	(HappyAbsSyn17  happy_var_4) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn29
		 (Sum True happy_var_4
	) `HappyStk` happyRest

happyReduce_101 = happyReduce 4 29 happyReduction_101
happyReduction_101 (_ `HappyStk`
	(HappyAbsSyn17  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn29
		 (Count False happy_var_3
	) `HappyStk` happyRest

happyReduce_102 = happyReduce 5 29 happyReduction_102
happyReduction_102 (_ `HappyStk`
	(HappyAbsSyn17  happy_var_4) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn29
		 (Count True happy_var_4
	) `HappyStk` happyRest

happyReduce_103 = happyReduce 4 29 happyReduction_103
happyReduction_103 (_ `HappyStk`
	(HappyAbsSyn17  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn29
		 (Avg False happy_var_3
	) `HappyStk` happyRest

happyReduce_104 = happyReduce 5 29 happyReduction_104
happyReduction_104 (_ `HappyStk`
	(HappyAbsSyn17  happy_var_4) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn29
		 (Avg True happy_var_4
	) `HappyStk` happyRest

happyReduce_105 = happyReduce 4 29 happyReduction_105
happyReduction_105 (_ `HappyStk`
	(HappyAbsSyn17  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn29
		 (Min False happy_var_3
	) `HappyStk` happyRest

happyReduce_106 = happyReduce 5 29 happyReduction_106
happyReduction_106 (_ `HappyStk`
	(HappyAbsSyn17  happy_var_4) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn29
		 (Min True happy_var_4
	) `HappyStk` happyRest

happyReduce_107 = happyReduce 4 29 happyReduction_107
happyReduction_107 (_ `HappyStk`
	(HappyAbsSyn17  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn29
		 (Max False happy_var_3
	) `HappyStk` happyRest

happyReduce_108 = happyReduce 5 29 happyReduction_108
happyReduction_108 (_ `HappyStk`
	(HappyAbsSyn17  happy_var_4) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn29
		 (Max True happy_var_4
	) `HappyStk` happyRest

happyReduce_109 = happySpecReduce_1  30 happyReduction_109
happyReduction_109 _
	 =  HappyAbsSyn30
		 (A
	)

happyReduce_110 = happySpecReduce_1  30 happyReduction_110
happyReduction_110 _
	 =  HappyAbsSyn30
		 (D
	)

happyReduce_111 = happySpecReduce_1  31 happyReduction_111
happyReduction_111 _
	 =  HappyAbsSyn31
		 (Inner
	)

happyReduce_112 = happySpecReduce_1  31 happyReduction_112
happyReduction_112 _
	 =  HappyAbsSyn31
		 (JLeft
	)

happyReduce_113 = happySpecReduce_1  31 happyReduction_113
happyReduction_113 _
	 =  HappyAbsSyn31
		 (JRight
	)

happyReduce_114 = happySpecReduce_3  32 happyReduction_114
happyReduction_114 _
	(HappyAbsSyn16  happy_var_2)
	_
	 =  HappyAbsSyn32
		 (Avl.singletonT happy_var_2
	)
happyReduction_114 _ _ _  = notHappyAtAll 

happyReduce_115 = happySpecReduce_3  32 happyReduction_115
happyReduction_115 (HappyAbsSyn32  happy_var_3)
	_
	(HappyAbsSyn32  happy_var_1)
	 =  HappyAbsSyn32
		 (Avl.join happy_var_1  happy_var_3
	)
happyReduction_115 _ _ _  = notHappyAtAll 

happyReduce_116 = happySpecReduce_1  33 happyReduction_116
happyReduction_116 (HappyTerminal (TStr happy_var_1))
	 =  HappyAbsSyn16
		 ([A1 happy_var_1]
	)
happyReduction_116 _  = notHappyAtAll 

happyReduce_117 = happySpecReduce_1  33 happyReduction_117
happyReduction_117 (HappyTerminal (TNum happy_var_1))
	 =  HappyAbsSyn16
		 ([A3 happy_var_1]
	)
happyReduction_117 _  = notHappyAtAll 

happyReduce_118 = happySpecReduce_1  33 happyReduction_118
happyReduction_118 (HappyTerminal (TDatTim happy_var_1))
	 =  HappyAbsSyn16
		 ([A5 happy_var_1]
	)
happyReduction_118 _  = notHappyAtAll 

happyReduce_119 = happySpecReduce_1  33 happyReduction_119
happyReduction_119 (HappyTerminal (TDat happy_var_1))
	 =  HappyAbsSyn16
		 ([A6 happy_var_1]
	)
happyReduction_119 _  = notHappyAtAll 

happyReduce_120 = happySpecReduce_1  33 happyReduction_120
happyReduction_120 (HappyTerminal (TTim happy_var_1))
	 =  HappyAbsSyn16
		 ([A7 happy_var_1]
	)
happyReduction_120 _  = notHappyAtAll 

happyReduce_121 = happySpecReduce_1  33 happyReduction_121
happyReduction_121 _
	 =  HappyAbsSyn16
		 ([Nulo]
	)

happyReduce_122 = happySpecReduce_3  33 happyReduction_122
happyReduction_122 (HappyAbsSyn16  happy_var_3)
	_
	(HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn16
		 (happy_var_1 ++ happy_var_3
	)
happyReduction_122 _ _ _  = notHappyAtAll 

happyReduce_123 = happySpecReduce_3  34 happyReduction_123
happyReduction_123 (HappyAbsSyn17  happy_var_3)
	_
	(HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn34
		 (([happy_var_1],[happy_var_3])
	)
happyReduction_123 _ _ _  = notHappyAtAll 

happyReduce_124 = happySpecReduce_3  34 happyReduction_124
happyReduction_124 (HappyAbsSyn34  happy_var_3)
	_
	(HappyAbsSyn34  happy_var_1)
	 =  HappyAbsSyn34
		 (let ((k1,m1),(k2,m2)) = (happy_var_1,happy_var_3)
                                  in (k1 ++ k2, m1 ++ m2)
	)
happyReduction_124 _ _ _  = notHappyAtAll 

happyReduce_125 = happyReduce 5 35 happyReduction_125
happyReduction_125 (_ `HappyStk`
	(HappyAbsSyn36  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TField happy_var_2)) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn35
		 (CTable happy_var_2 happy_var_4
	) `HappyStk` happyRest

happyReduce_126 = happySpecReduce_2  35 happyReduction_126
happyReduction_126 (HappyTerminal (TField happy_var_2))
	_
	 =  HappyAbsSyn35
		 (DTable happy_var_2
	)
happyReduction_126 _ _  = notHappyAtAll 

happyReduce_127 = happySpecReduce_2  35 happyReduction_127
happyReduction_127 (HappyTerminal (TField happy_var_2))
	_
	 =  HappyAbsSyn35
		 (CBase happy_var_2
	)
happyReduction_127 _ _  = notHappyAtAll 

happyReduce_128 = happySpecReduce_2  35 happyReduction_128
happyReduction_128 (HappyTerminal (TField happy_var_2))
	_
	 =  HappyAbsSyn35
		 (DBase happy_var_2
	)
happyReduction_128 _ _  = notHappyAtAll 

happyReduce_129 = happySpecReduce_2  35 happyReduction_129
happyReduction_129 (HappyTerminal (TField happy_var_2))
	_
	 =  HappyAbsSyn35
		 (Use happy_var_2
	)
happyReduction_129 _ _  = notHappyAtAll 

happyReduce_130 = happySpecReduce_1  35 happyReduction_130
happyReduction_130 _
	 =  HappyAbsSyn35
		 (ShowB
	)

happyReduce_131 = happySpecReduce_1  35 happyReduction_131
happyReduction_131 _
	 =  HappyAbsSyn35
		 (ShowT
	)

happyReduce_132 = happySpecReduce_1  36 happyReduction_132
happyReduction_132 (HappyAbsSyn37  happy_var_1)
	 =  HappyAbsSyn36
		 ([happy_var_1]
	)
happyReduction_132 _  = notHappyAtAll 

happyReduce_133 = happySpecReduce_3  36 happyReduction_133
happyReduction_133 (HappyAbsSyn36  happy_var_3)
	_
	(HappyAbsSyn36  happy_var_1)
	 =  HappyAbsSyn36
		 (happy_var_1 ++ happy_var_3
	)
happyReduction_133 _ _ _  = notHappyAtAll 

happyReduce_134 = happySpecReduce_3  37 happyReduction_134
happyReduction_134 _
	(HappyAbsSyn41  happy_var_2)
	(HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn37
		 (Col happy_var_1 happy_var_2 True
	)
happyReduction_134 _ _ _  = notHappyAtAll 

happyReduce_135 = happySpecReduce_2  37 happyReduction_135
happyReduction_135 (HappyAbsSyn41  happy_var_2)
	(HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn37
		 (Col happy_var_1 happy_var_2 False
	)
happyReduction_135 _ _  = notHappyAtAll 

happyReduce_136 = happyReduce 4 37 happyReduction_136
happyReduction_136 (_ `HappyStk`
	(HappyAbsSyn38  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn37
		 (PKey happy_var_3
	) `HappyStk` happyRest

happyReduce_137 = happyReduce 11 37 happyReduction_137
happyReduction_137 ((HappyAbsSyn39  happy_var_11) `HappyStk`
	(HappyAbsSyn39  happy_var_10) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn38  happy_var_8) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TField happy_var_6)) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn38  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn37
		 (FKey happy_var_3 happy_var_6 happy_var_8 happy_var_10 happy_var_11
	) `HappyStk` happyRest

happyReduce_138 = happySpecReduce_1  38 happyReduction_138
happyReduction_138 (HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn38
		 ([happy_var_1]
	)
happyReduction_138 _  = notHappyAtAll 

happyReduce_139 = happySpecReduce_3  38 happyReduction_139
happyReduction_139 (HappyAbsSyn38  happy_var_3)
	_
	(HappyAbsSyn38  happy_var_1)
	 =  HappyAbsSyn38
		 (happy_var_1 ++ happy_var_3
	)
happyReduction_139 _ _ _  = notHappyAtAll 

happyReduce_140 = happySpecReduce_0  39 happyReduction_140
happyReduction_140  =  HappyAbsSyn39
		 (Restricted
	)

happyReduce_141 = happySpecReduce_2  39 happyReduction_141
happyReduction_141 _
	_
	 =  HappyAbsSyn39
		 (Restricted
	)

happyReduce_142 = happySpecReduce_2  39 happyReduction_142
happyReduction_142 _
	_
	 =  HappyAbsSyn39
		 (Cascades
	)

happyReduce_143 = happySpecReduce_2  39 happyReduction_143
happyReduction_143 _
	_
	 =  HappyAbsSyn39
		 (Nullifies
	)

happyReduce_144 = happySpecReduce_0  40 happyReduction_144
happyReduction_144  =  HappyAbsSyn39
		 (Restricted
	)

happyReduce_145 = happySpecReduce_2  40 happyReduction_145
happyReduction_145 _
	_
	 =  HappyAbsSyn39
		 (Restricted
	)

happyReduce_146 = happySpecReduce_2  40 happyReduction_146
happyReduction_146 _
	_
	 =  HappyAbsSyn39
		 (Cascades
	)

happyReduce_147 = happySpecReduce_2  40 happyReduction_147
happyReduction_147 _
	_
	 =  HappyAbsSyn39
		 (Nullifies
	)

happyReduce_148 = happySpecReduce_1  41 happyReduction_148
happyReduction_148 _
	 =  HappyAbsSyn41
		 (Int
	)

happyReduce_149 = happySpecReduce_1  41 happyReduction_149
happyReduction_149 _
	 =  HappyAbsSyn41
		 (Float
	)

happyReduce_150 = happySpecReduce_1  41 happyReduction_150
happyReduction_150 _
	 =  HappyAbsSyn41
		 (Bool
	)

happyReduce_151 = happySpecReduce_1  41 happyReduction_151
happyReduction_151 _
	 =  HappyAbsSyn41
		 (String
	)

happyReduce_152 = happySpecReduce_1  41 happyReduction_152
happyReduction_152 _
	 =  HappyAbsSyn41
		 (Datetime
	)

happyReduce_153 = happySpecReduce_1  41 happyReduction_153
happyReduction_153 _
	 =  HappyAbsSyn41
		 (Dates
	)

happyReduce_154 = happySpecReduce_1  41 happyReduction_154
happyReduction_154 _
	 =  HappyAbsSyn41
		 (Tim
	)

happyNewToken action sts stk
	= lexer(\tk -> 
	let cont i = action i i tk (HappyState action) sts stk in
	case tk of {
	TEOF -> action 127 127 tk (HappyState action) sts stk;
	TInsert -> cont 42;
	TDelete -> cont 43;
	TUpdate -> cont 44;
	TSelect -> cont 45;
	TFrom -> cont 46;
	TSemiColon -> cont 47;
	TWhere -> cont 48;
	TGroupBy -> cont 49;
	THaving -> cont 50;
	TOrderBy -> cont 51;
	TUnion -> cont 52;
	TDiff -> cont 53;
	TIntersect -> cont 54;
	TAnd -> cont 55;
	TOr -> cont 56;
	TEqual -> cont 57;
	TNotEq -> cont 58;
	TGreat -> cont 59;
	TLess -> cont 60;
	TGrOrEq -> cont 61;
	TLsOrEq -> cont 62;
	TLike -> cont 63;
	TExist -> cont 64;
	TNot -> cont 65;
	TSum -> cont 66;
	TCount -> cont 67;
	TAvg -> cont 68;
	TMin -> cont 69;
	TMax -> cont 70;
	TLimit -> cont 71;
	TAsc -> cont 72;
	TDesc -> cont 73;
	TAll -> cont 74;
	TColumn -> cont 75;
	TOpen -> cont 76;
	TClose -> cont 77;
	TComa -> cont 78;
	TAs -> cont 79;
	TSet -> cont 80;
	TField happy_dollar_dollar -> cont 81;
	TDistinct -> cont 82;
	TIn -> cont 83;
	TDot -> cont 84;
	TPlus -> cont 85;
	TMinus -> cont 86;
	TTimes -> cont 87;
	TDiv -> cont 88;
	TNeg -> cont 89;
	TCTable -> cont 90;
	TCBase -> cont 91;
	TDTable -> cont 92;
	TDBase -> cont 93;
	TPkey -> cont 94;
	TUse -> cont 95;
	TShowB -> cont 96;
	TShowT -> cont 97;
	TDatTim happy_dollar_dollar -> cont 98;
	TDat happy_dollar_dollar -> cont 99;
	TTim happy_dollar_dollar -> cont 100;
	TStr happy_dollar_dollar -> cont 101;
	TNum happy_dollar_dollar -> cont 102;
	TNull -> cont 103;
	TInt -> cont 104;
	TFloat -> cont 105;
	TString -> cont 106;
	TBool -> cont 107;
	TDateTime -> cont 108;
	TDate -> cont 109;
	TTime -> cont 110;
	TSrc -> cont 111;
	TCUser -> cont 112;
	TDUser -> cont 113;
	TSUser -> cont 114;
	TFKey -> cont 115;
	TRef -> cont 116;
	TDel -> cont 117;
	TUpd -> cont 118;
	TRestricted -> cont 119;
	TCascades -> cont 120;
	TNullifies -> cont 121;
	TOn -> cont 122;
	TJoin -> cont 123;
	TLeft -> cont 124;
	TRight -> cont 125;
	TInner -> cont 126;
	_ -> happyError' (tk, [])
	})

happyError_ explist 127 tk = happyError' (tk, explist)
happyError_ explist _ tk = happyError' (tk, explist)

happyThen :: () => P a -> (a -> P b) -> P b
happyThen = (thenP)
happyReturn :: () => a -> P a
happyReturn = (returnP)
happyThen1 :: () => P a -> (a -> P b) -> P b
happyThen1 = happyThen
happyReturn1 :: () => a -> P a
happyReturn1 = happyReturn
happyError' :: () => ((Token), [String]) -> P a
happyError' tk = (\(tokens, explist) -> happyError) tk
sql = happySomeParser where
 happySomeParser = happyThen (happyParse action_0) (\x -> case x of {HappyAbsSyn4 z -> happyReturn z; _other -> notHappyAtAll })

happySeq = happyDontSeq


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
             | TNotEq
             | TEqual
             | TGreat
             | TGrOrEq
             | TLess
             | TLsOrEq
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
             | TColumn
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
             | TCBase
             | TDBase
             | TStr String
             | TNum Int
             | TString
             | TFloat
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
             | TDat   Date
             | TTim Time

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
         ('U':'N':'I':'O':'N':xs) -> \(s1,s2) -> cont TUnion xs (s1,5 + s2)
         ('I':'N':'T':'E':'R':'S':'E':'C':'T':xs) -> \(s1,s2) -> cont TIntersect xs (s1,9 + s2)
         ('D':'I':'F':'F':xs) -> \(s1,s2) -> cont TDiff xs (s1,5 + s2)
         ('O':'R':'D':'E':'R':' ':'B':'Y':xs) -> \(s1,s2) -> cont TOrderBy xs (s1,8 + s2)
         ('A':'S':'C':xs) -> \(s1,s2) ->  cont TAsc xs (s1,3 + s2)
         ('D':'E':'S':'C':xs) -> \(s1,s2) ->  cont TDesc xs (s1,4 + s2)


         ('A':'N':'D':xs) -> \(s1,s2) ->  cont TAnd xs (s1,3 + s2)
         ('O':'R':xs) ->  \(s1,s2) ->  cont TOr xs (s1,2 + s2)
         ('N':'O':'T':xs) -> \(s1,s2) ->  cont TNot xs (s1,3 + s2)
         ('L':'I':'K':'E':xs) -> \(s1,s2) ->  cont TLike xs (s1,4 + s2)
         ('E':'X':'I':'S':'T':xs) -> \(s1,s2) ->  cont TExist xs (s1,5 + s2)
         ('I':'N':xs) -> \(s1,s2) ->  cont TIn xs (s1,2 + s2)
         ('G':'R':'O':'U':'P':' ':'B':'Y':xs) -> \(s1,s2) ->  cont TGroupBy xs (s1,8 + s2)
         ('<':'>':xs) -> \(s1,s2) -> cont TNotEq xs (s1,2 + s2)
         ('=':xs) -> \(s1,s2) ->  cont TEqual xs (s1,1 + s2)
         ('>':'=':xs) -> \(s1,s2) ->  cont TGrOrEq xs (s1,2 + s2)
         ('<':'=':xs) -> \(s1,s2) ->  cont TLsOrEq xs (s1,2 + s2)
         ('>':xs) -> \(s1,s2) ->  cont TGreat xs (s1,1 + s2)
         ('<':xs) -> \(s1,s2) ->  cont TLess xs (s1,1 + s2)

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
         ('C':'O':'L':'U':'M':'N':xs) -> \(s1,s2) -> cont TColumn xs (s1,6+ s2)


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

        dif s1 s2 = (length s1) - (length s2)


lexField cont xs = \(s1,s2) -> cont (TField s) r (s1,s2 + (length s))
  where [(s,r)] = parse (many alphanum) xs


lexString cont  xs = \(s1,s2) -> cont (TStr s) r (s1,s2 + (length s))
   where [(s,r)] = parse st xs
         st = do char '\"'
                 s <- string2
                 char '\"'
                 return s






sqlParse s = sql s (1,1)
{-# LINE 1 "templates/GenericTemplate.hs" #-}
{-# LINE 1 "templates/GenericTemplate.hs" #-}
{-# LINE 1 "<built-in>" #-}
{-# LINE 1 "<command-line>" #-}
{-# LINE 8 "<command-line>" #-}
# 1 "/usr/include/stdc-predef.h" 1 3 4

# 17 "/usr/include/stdc-predef.h" 3 4














































{-# LINE 8 "<command-line>" #-}
{-# LINE 1 "/usr/lib/ghc/include/ghcversion.h" #-}

















{-# LINE 8 "<command-line>" #-}
{-# LINE 1 "/tmp/ghc8814_0/ghc_2.h" #-}




























































































































































{-# LINE 8 "<command-line>" #-}
{-# LINE 1 "templates/GenericTemplate.hs" #-}
-- Id: GenericTemplate.hs,v 1.26 2005/01/14 14:47:22 simonmar Exp 









{-# LINE 43 "templates/GenericTemplate.hs" #-}

data Happy_IntList = HappyCons Int Happy_IntList







{-# LINE 65 "templates/GenericTemplate.hs" #-}

{-# LINE 75 "templates/GenericTemplate.hs" #-}

{-# LINE 84 "templates/GenericTemplate.hs" #-}

infixr 9 `HappyStk`
data HappyStk a = HappyStk a (HappyStk a)

-----------------------------------------------------------------------------
-- starting the parse

happyParse start_state = happyNewToken start_state notHappyAtAll notHappyAtAll

-----------------------------------------------------------------------------
-- Accepting the parse

-- If the current token is (1), it means we've just accepted a partial
-- parse (a %partial parser).  We must ignore the saved token on the top of
-- the stack in this case.
happyAccept (1) tk st sts (_ `HappyStk` ans `HappyStk` _) =
        happyReturn1 ans
happyAccept j tk st sts (HappyStk ans _) = 
         (happyReturn1 ans)

-----------------------------------------------------------------------------
-- Arrays only: do the next action

{-# LINE 137 "templates/GenericTemplate.hs" #-}

{-# LINE 147 "templates/GenericTemplate.hs" #-}
indexShortOffAddr arr off = arr Happy_Data_Array.! off


{-# INLINE happyLt #-}
happyLt x y = (x < y)






readArrayBit arr bit =
    Bits.testBit (indexShortOffAddr arr (bit `div` 16)) (bit `mod` 16)






-----------------------------------------------------------------------------
-- HappyState data type (not arrays)



newtype HappyState b c = HappyState
        (Int ->                    -- token number
         Int ->                    -- token number (yes, again)
         b ->                           -- token semantic value
         HappyState b c ->              -- current state
         [HappyState b c] ->            -- state stack
         c)



-----------------------------------------------------------------------------
-- Shifting a token

happyShift new_state (1) tk st sts stk@(x `HappyStk` _) =
     let i = (case x of { HappyErrorToken (i) -> i }) in
--     trace "shifting the error token" $
     new_state i i tk (HappyState (new_state)) ((st):(sts)) (stk)

happyShift new_state i tk st sts stk =
     happyNewToken new_state ((st):(sts)) ((HappyTerminal (tk))`HappyStk`stk)

-- happyReduce is specialised for the common cases.

happySpecReduce_0 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_0 nt fn j tk st@((HappyState (action))) sts stk
     = action nt j tk st ((st):(sts)) (fn `HappyStk` stk)

happySpecReduce_1 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_1 nt fn j tk _ sts@(((st@(HappyState (action))):(_))) (v1`HappyStk`stk')
     = let r = fn v1 in
       happySeq r (action nt j tk st sts (r `HappyStk` stk'))

happySpecReduce_2 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_2 nt fn j tk _ ((_):(sts@(((st@(HappyState (action))):(_))))) (v1`HappyStk`v2`HappyStk`stk')
     = let r = fn v1 v2 in
       happySeq r (action nt j tk st sts (r `HappyStk` stk'))

happySpecReduce_3 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_3 nt fn j tk _ ((_):(((_):(sts@(((st@(HappyState (action))):(_))))))) (v1`HappyStk`v2`HappyStk`v3`HappyStk`stk')
     = let r = fn v1 v2 v3 in
       happySeq r (action nt j tk st sts (r `HappyStk` stk'))

happyReduce k i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happyReduce k nt fn j tk st sts stk
     = case happyDrop (k - ((1) :: Int)) sts of
         sts1@(((st1@(HappyState (action))):(_))) ->
                let r = fn stk in  -- it doesn't hurt to always seq here...
                happyDoSeq r (action nt j tk st1 sts1 r)

happyMonadReduce k nt fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happyMonadReduce k nt fn j tk st sts stk =
      case happyDrop k ((st):(sts)) of
        sts1@(((st1@(HappyState (action))):(_))) ->
          let drop_stk = happyDropStk k stk in
          happyThen1 (fn stk tk) (\r -> action nt j tk st1 sts1 (r `HappyStk` drop_stk))

happyMonad2Reduce k nt fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happyMonad2Reduce k nt fn j tk st sts stk =
      case happyDrop k ((st):(sts)) of
        sts1@(((st1@(HappyState (action))):(_))) ->
         let drop_stk = happyDropStk k stk





             _ = nt :: Int
             new_state = action

          in
          happyThen1 (fn stk tk) (\r -> happyNewToken new_state sts1 (r `HappyStk` drop_stk))

happyDrop (0) l = l
happyDrop n ((_):(t)) = happyDrop (n - ((1) :: Int)) t

happyDropStk (0) l = l
happyDropStk n (x `HappyStk` xs) = happyDropStk (n - ((1)::Int)) xs

-----------------------------------------------------------------------------
-- Moving to a new state after a reduction

{-# LINE 267 "templates/GenericTemplate.hs" #-}
happyGoto action j tk st = action j j tk (HappyState action)


-----------------------------------------------------------------------------
-- Error recovery ((1) is the error token)

-- parse error if we are in recovery and we fail again
happyFail explist (1) tk old_st _ stk@(x `HappyStk` _) =
     let i = (case x of { HappyErrorToken (i) -> i }) in
--      trace "failing" $ 
        happyError_ explist i tk

{-  We don't need state discarding for our restricted implementation of
    "error".  In fact, it can cause some bogus parses, so I've disabled it
    for now --SDM

-- discard a state
happyFail  (1) tk old_st (((HappyState (action))):(sts)) 
                                                (saved_tok `HappyStk` _ `HappyStk` stk) =
--      trace ("discarding state, depth " ++ show (length stk))  $
        action (1) (1) tk (HappyState (action)) sts ((saved_tok`HappyStk`stk))
-}

-- Enter error recovery: generate an error token,
--                       save the old token and carry on.
happyFail explist i tk (HappyState (action)) sts stk =
--      trace "entering error recovery" $
        action (1) (1) tk (HappyState (action)) sts ( (HappyErrorToken (i)) `HappyStk` stk)

-- Internal happy errors:

notHappyAtAll :: a
notHappyAtAll = error "Internal Happy error\n"

-----------------------------------------------------------------------------
-- Hack to get the typechecker to accept our action functions







-----------------------------------------------------------------------------
-- Seq-ing.  If the --strict flag is given, then Happy emits 
--      happySeq = happyDoSeq
-- otherwise it emits
--      happySeq = happyDontSeq

happyDoSeq, happyDontSeq :: a -> b -> b
happyDoSeq   a b = a `seq` b
happyDontSeq a b = b

-----------------------------------------------------------------------------
-- Don't inline any functions from the template.  GHC has a nasty habit
-- of deciding to inline happyGoto everywhere, which increases the size of
-- the generated parser quite a bit.

{-# LINE 333 "templates/GenericTemplate.hs" #-}
{-# NOINLINE happyShift #-}
{-# NOINLINE happySpecReduce_0 #-}
{-# NOINLINE happySpecReduce_1 #-}
{-# NOINLINE happySpecReduce_2 #-}
{-# NOINLINE happySpecReduce_3 #-}
{-# NOINLINE happyReduce #-}
{-# NOINLINE happyMonadReduce #-}
{-# NOINLINE happyGoto #-}
{-# NOINLINE happyFail #-}

-- end of Happy Template.
