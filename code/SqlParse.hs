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

-- parser produced by Happy Version 1.19.11

data HappyAbsSyn t9 t10 t11 t12 t13 t14 t15 t16
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
	| HappyAbsSyn16 t16
	| HappyAbsSyn17 ([Args])
	| HappyAbsSyn18 (Args)
	| HappyAbsSyn22 (BoolExp)
	| HappyAbsSyn28 (Aggregate)
	| HappyAbsSyn29 (O)
	| HappyAbsSyn30 (JOINS)
	| HappyAbsSyn31 (Avl.AVL [Args])
	| HappyAbsSyn33 (([String],[Args]))
	| HappyAbsSyn34 (DDL)
	| HappyAbsSyn35 ([CArgs])
	| HappyAbsSyn36 (CArgs)
	| HappyAbsSyn37 ([String])
	| HappyAbsSyn38 (RefOption)
	| HappyAbsSyn40 (Type)

happyExpList :: Happy_Data_Array.Array Int Int
happyExpList = Happy_Data_Array.listArray (0,802) ([0,0,3840,0,64,3824,7680,0,0,0,60,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,128,0,0,0,0,0,0,0,2,0,0,0,0,0,0,2048,0,0,0,0,0,0,36736,1121,1024,0,0,0,32768,0,0,0,0,0,0,0,2048,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,128,0,0,0,0,0,0,0,2,0,0,0,0,0,0,2048,0,0,0,0,0,0,0,32,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,128,0,0,0,0,0,0,0,2,0,0,0,0,0,0,2048,0,0,0,0,0,0,0,32,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,512,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,61440,0,1024,61184,57344,1,0,0,0,0,32,0,0,0,0,0,976,1024,1,0,49152,1,0,0,0,2048,30,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,64,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,16,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,0,0,0,0,0,0,128,15872,4230,4096,0,0,0,0,0,0,16,0,0,0,0,0,57344,2147,1,1,0,0,0,0,36736,1057,1024,0,0,0,0,0,0,0,0,0,0,0,0,0,256,0,0,0,0,0,64,0,0,0,0,0,0,0,0,256,0,0,0,0,0,128,0,4,0,0,0,0,0,2,4096,0,0,0,0,0,2048,0,64,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,49152,15,0,0,0,0,16256,4230,16128,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,3904,4096,4,0,0,7,0,0,0,32768,0,0,0,0,0,0,0,32,0,0,0,0,0,0,32768,1922,0,0,0,0,0,0,24576,0,0,0,0,0,0,0,384,0,0,0,0,0,0,0,6,0,0,0,0,0,0,6144,0,0,0,0,0,0,0,96,0,0,0,0,0,0,32768,0,0,0,0,0,0,63488,16920,16384,0,0,0,0,0,25568,264,256,0,0,0,0,32768,8591,4,4,0,0,0,0,15872,4230,4096,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,4096,2,0,0,0,0,0,63488,2147,61441,3,0,0,0,0,0,33,0,0,0,0,0,32768,34367,16,63,0,0,0,0,0,528,0,0,0,0,0,0,0,0,256,0,0,0,0,32768,8591,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,512,64,2048,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,24576,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,61440,7,0,0,0,0,1024,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,32768,17,0,0,0,0,0,2,4096,0,0,0,0,0,0,0,512,0,0,0,0,0,0,0,7688,0,0,0,0,0,0,0,0,0,0,0,0,32768,24,1,0,0,0,0,0,32768,3,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,64,0,0,0,0,0,0,36832,1057,4032,0,0,0,32768,32768,34367,16,63,0,0,0,0,0,4096,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3072,4096,4,0,0,0,0,0,1592,64,0,0,0,0,0,0,224,0,0,0,0,0,0,0,4,32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,6398,66,252,0,0,0,2048,63488,2147,61441,3,0,0,0,3840,4096,4,0,0,7,0,0,0,32768,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,24,0,0,0,0,0,0,24576,0,0,0,0,0,0,0,0,0,0,0,0,0,0,128,0,0,0,0,0,0,0,256,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,32,0,0,0,0,0,0,0,8,0,0,0,0,0,0,512,0,0,0,0,0,0,0,128,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,2048,0,0,0,0,0,0,0,2,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16,16384,0,0,0,0,0,0,128,0,0,0,0,0,0,32768,1,0,0,0,0,0,0,0,6144,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1008,0,0,0,0,57344,8591,49156,15,0,0,0,0,16256,4230,16128,0,0,0,0,0,6392,66,252,0,0,0,0,63488,2147,61441,3,0,0,0,0,0,32,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,512,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,33,0,0,0,0,0,1536,2048,0,0,0,0,0,0,24,0,0,0,0,0,0,8,16384,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,4,0,0,0,0,0,0,6392,66,252,0,0,0,0,57344,2147,61441,3,0,0,0,0,36736,1057,4032,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,384,512,0,0,0,0,0,0,6,0,0,0,0,0,0,2,4096,0,0,0,0,0,0,0,0,32768,0,0,0,0,0,36736,1057,4032,0,0,0,0,0,34366,16,63,0,0,0,0,63488,16920,64512,0,0,0,0,0,0,0,0,0,0,0,0,57344,8591,49156,15,0,0,0,0,16256,4230,16128,0,0,0,0,0,0,2,0,0,0,0,0,28,128,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16386,0,8,0,0,0,0,256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6144,0,0,0,0,0,0,0,96,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,112,512,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,16384,0,1008,0,0,0,0,0,0,0,0,0,0,0,49152,1,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,32,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,24,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16384,0,0,0,0,0,0,128,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,7,32,0,0,0,0,0,0,32768,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,128,0,0,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,0,0,0,0,0,32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8192,0,0,0,0,0,15360,16384,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,2048,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6144,0,0,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,56,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,224,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	])

{-# NOINLINE happyExpListPerState #-}
happyExpListPerState st =
    token_strs_expected
  where token_strs = ["error","%dummy","%start_sql","SQL","MANUSERS","DML","Query","Query0","Query1","Query2","Query3","Query4","Query5","Query6","Query7","Query8","ArgS","Exp","IntExp","ArgF","Fields","BoolExpW","BoolExpH","ValueH","ValueW","Var","Value","Aggregate","Order","SomeJoin","TreeListArgs","ListArgs","ToUpdate","DDL","LCArgs","CArgs","FieldList","DelReferenceOption","UpdReferenceOption","TYPE","INSERT","DELETE","UPDATE","SELECT","FROM","';'","WHERE","GROUPBY","HAVING","ORDERBY","UNION","DIFF","INTERSECT","AND","OR","'='","'>'","'<'","LIKE","EXIST","NOT","Sum","Count","Avg","Min","Max","LIMIT","Asc","Desc","ALL","'('","')'","','","AS","SET","FIELD","DISTINCT","IN","'.'","'+'","'-'","'*'","'/'","NEG","CTABLE","CBASE","DTABLE","DBASE","PKEY","USE","SHOWB","SHOWT","DATTIM","DAT","TIM","STR","NUM","NULL","INT","FLOAT","STRING","BOOL","DATETIME","DATE","TIME","SRC","CUSER","DUSER","SUSER","FKEY","REFERENCE","DEL","UPD","RESTRICTED","CASCADES","NULLIFIES","ON","JOIN","LEFT","RIGHT","INNER","%eof"]
        bit_start = st * 122
        bit_end = (st + 1) * 122
        read_bit = readArrayBit happyExpList
        bits = map read_bit [bit_start..bit_end - 1]
        bits_indexed = zip bits [0..121]
        token_strs_expected = concatMap f bits_indexed
        f (False, _) = []
        f (True, nr) = [token_strs !! nr]

action_0 (41) = happyShift action_6
action_0 (42) = happyShift action_7
action_0 (43) = happyShift action_8
action_0 (44) = happyShift action_9
action_0 (71) = happyShift action_10
action_0 (85) = happyShift action_14
action_0 (86) = happyShift action_15
action_0 (87) = happyShift action_16
action_0 (88) = happyShift action_17
action_0 (90) = happyShift action_18
action_0 (91) = happyShift action_19
action_0 (92) = happyShift action_20
action_0 (106) = happyShift action_21
action_0 (107) = happyShift action_22
action_0 (108) = happyShift action_23
action_0 (109) = happyShift action_24
action_0 (4) = happyGoto action_11
action_0 (5) = happyGoto action_12
action_0 (6) = happyGoto action_2
action_0 (7) = happyGoto action_3
action_0 (8) = happyGoto action_4
action_0 (9) = happyGoto action_5
action_0 (34) = happyGoto action_13
action_0 _ = happyFail (happyExpListPerState 0)

action_1 (41) = happyShift action_6
action_1 (42) = happyShift action_7
action_1 (43) = happyShift action_8
action_1 (44) = happyShift action_9
action_1 (71) = happyShift action_10
action_1 (6) = happyGoto action_2
action_1 (7) = happyGoto action_3
action_1 (8) = happyGoto action_4
action_1 (9) = happyGoto action_5
action_1 _ = happyFail (happyExpListPerState 1)

action_2 _ = happyReduce_1

action_3 (51) = happyShift action_54
action_3 (52) = happyShift action_55
action_3 (53) = happyShift action_56
action_3 _ = happyReduce_12

action_4 _ = happyReduce_16

action_5 _ = happyReduce_17

action_6 (76) = happyShift action_53
action_6 _ = happyFail (happyExpListPerState 6)

action_7 (76) = happyShift action_52
action_7 _ = happyFail (happyExpListPerState 7)

action_8 (76) = happyShift action_51
action_8 _ = happyFail (happyExpListPerState 8)

action_9 (62) = happyShift action_40
action_9 (63) = happyShift action_41
action_9 (64) = happyShift action_42
action_9 (65) = happyShift action_43
action_9 (66) = happyShift action_44
action_9 (70) = happyShift action_45
action_9 (71) = happyShift action_46
action_9 (76) = happyShift action_47
action_9 (77) = happyShift action_48
action_9 (81) = happyShift action_49
action_9 (97) = happyShift action_50
action_9 (17) = happyGoto action_36
action_9 (18) = happyGoto action_37
action_9 (19) = happyGoto action_38
action_9 (28) = happyGoto action_39
action_9 _ = happyFail (happyExpListPerState 9)

action_10 (44) = happyShift action_9
action_10 (9) = happyGoto action_35
action_10 _ = happyFail (happyExpListPerState 10)

action_11 (46) = happyShift action_34
action_11 (122) = happyAccept
action_11 _ = happyFail (happyExpListPerState 11)

action_12 _ = happyReduce_3

action_13 _ = happyReduce_2

action_14 (76) = happyShift action_33
action_14 _ = happyFail (happyExpListPerState 14)

action_15 (76) = happyShift action_32
action_15 _ = happyFail (happyExpListPerState 15)

action_16 (76) = happyShift action_31
action_16 _ = happyFail (happyExpListPerState 16)

action_17 (76) = happyShift action_30
action_17 _ = happyFail (happyExpListPerState 17)

action_18 (76) = happyShift action_29
action_18 _ = happyFail (happyExpListPerState 18)

action_19 _ = happyReduce_120

action_20 _ = happyReduce_121

action_21 (96) = happyShift action_28
action_21 _ = happyFail (happyExpListPerState 21)

action_22 (76) = happyShift action_27
action_22 _ = happyFail (happyExpListPerState 22)

action_23 (76) = happyShift action_26
action_23 _ = happyFail (happyExpListPerState 23)

action_24 (76) = happyShift action_25
action_24 _ = happyFail (happyExpListPerState 24)

action_25 (76) = happyShift action_102
action_25 _ = happyFail (happyExpListPerState 25)

action_26 (76) = happyShift action_101
action_26 _ = happyFail (happyExpListPerState 26)

action_27 (76) = happyShift action_100
action_27 _ = happyFail (happyExpListPerState 27)

action_28 _ = happyReduce_5

action_29 _ = happyReduce_119

action_30 _ = happyReduce_118

action_31 _ = happyReduce_116

action_32 _ = happyReduce_117

action_33 (71) = happyShift action_99
action_33 _ = happyFail (happyExpListPerState 33)

action_34 (41) = happyShift action_6
action_34 (42) = happyShift action_7
action_34 (43) = happyShift action_8
action_34 (44) = happyShift action_9
action_34 (71) = happyShift action_10
action_34 (85) = happyShift action_14
action_34 (86) = happyShift action_15
action_34 (87) = happyShift action_16
action_34 (88) = happyShift action_17
action_34 (90) = happyShift action_18
action_34 (91) = happyShift action_19
action_34 (92) = happyShift action_20
action_34 (106) = happyShift action_21
action_34 (107) = happyShift action_22
action_34 (108) = happyShift action_23
action_34 (109) = happyShift action_24
action_34 (4) = happyGoto action_98
action_34 (5) = happyGoto action_12
action_34 (6) = happyGoto action_2
action_34 (7) = happyGoto action_3
action_34 (8) = happyGoto action_4
action_34 (9) = happyGoto action_5
action_34 (34) = happyGoto action_13
action_34 _ = happyFail (happyExpListPerState 34)

action_35 (72) = happyShift action_97
action_35 _ = happyFail (happyExpListPerState 35)

action_36 (45) = happyShift action_87
action_36 (47) = happyShift action_88
action_36 (48) = happyShift action_89
action_36 (49) = happyShift action_90
action_36 (50) = happyShift action_91
action_36 (67) = happyShift action_92
action_36 (73) = happyShift action_93
action_36 (119) = happyShift action_94
action_36 (120) = happyShift action_95
action_36 (121) = happyShift action_96
action_36 (10) = happyGoto action_79
action_36 (11) = happyGoto action_80
action_36 (12) = happyGoto action_81
action_36 (13) = happyGoto action_82
action_36 (14) = happyGoto action_83
action_36 (15) = happyGoto action_84
action_36 (16) = happyGoto action_85
action_36 (30) = happyGoto action_86
action_36 _ = happyReduce_34

action_37 (74) = happyShift action_74
action_37 (80) = happyShift action_75
action_37 (81) = happyShift action_76
action_37 (82) = happyShift action_77
action_37 (83) = happyShift action_78
action_37 _ = happyReduce_36

action_38 _ = happyReduce_42

action_39 _ = happyReduce_38

action_40 (71) = happyShift action_73
action_40 _ = happyFail (happyExpListPerState 40)

action_41 (71) = happyShift action_72
action_41 _ = happyFail (happyExpListPerState 41)

action_42 (71) = happyShift action_71
action_42 _ = happyFail (happyExpListPerState 42)

action_43 (71) = happyShift action_70
action_43 _ = happyFail (happyExpListPerState 43)

action_44 (71) = happyShift action_69
action_44 _ = happyFail (happyExpListPerState 44)

action_45 _ = happyReduce_43

action_46 (44) = happyShift action_9
action_46 (62) = happyShift action_40
action_46 (63) = happyShift action_41
action_46 (64) = happyShift action_42
action_46 (65) = happyShift action_43
action_46 (66) = happyShift action_44
action_46 (70) = happyShift action_45
action_46 (71) = happyShift action_46
action_46 (76) = happyShift action_47
action_46 (81) = happyShift action_49
action_46 (97) = happyShift action_50
action_46 (9) = happyGoto action_67
action_46 (18) = happyGoto action_68
action_46 (19) = happyGoto action_38
action_46 (28) = happyGoto action_39
action_46 _ = happyFail (happyExpListPerState 46)

action_47 (79) = happyShift action_66
action_47 _ = happyReduce_37

action_48 (62) = happyShift action_40
action_48 (63) = happyShift action_41
action_48 (64) = happyShift action_42
action_48 (65) = happyShift action_43
action_48 (66) = happyShift action_44
action_48 (70) = happyShift action_45
action_48 (71) = happyShift action_46
action_48 (76) = happyShift action_47
action_48 (81) = happyShift action_49
action_48 (97) = happyShift action_50
action_48 (17) = happyGoto action_65
action_48 (18) = happyGoto action_37
action_48 (19) = happyGoto action_38
action_48 (28) = happyGoto action_39
action_48 _ = happyFail (happyExpListPerState 48)

action_49 (62) = happyShift action_40
action_49 (63) = happyShift action_41
action_49 (64) = happyShift action_42
action_49 (65) = happyShift action_43
action_49 (66) = happyShift action_44
action_49 (70) = happyShift action_45
action_49 (71) = happyShift action_46
action_49 (76) = happyShift action_47
action_49 (81) = happyShift action_49
action_49 (97) = happyShift action_50
action_49 (18) = happyGoto action_64
action_49 (19) = happyGoto action_38
action_49 (28) = happyGoto action_39
action_49 _ = happyFail (happyExpListPerState 49)

action_50 _ = happyReduce_50

action_51 (75) = happyShift action_63
action_51 _ = happyFail (happyExpListPerState 51)

action_52 (47) = happyShift action_62
action_52 _ = happyFail (happyExpListPerState 52)

action_53 (71) = happyShift action_61
action_53 (31) = happyGoto action_60
action_53 _ = happyFail (happyExpListPerState 53)

action_54 (44) = happyShift action_9
action_54 (71) = happyShift action_10
action_54 (7) = happyGoto action_59
action_54 (8) = happyGoto action_4
action_54 (9) = happyGoto action_5
action_54 _ = happyFail (happyExpListPerState 54)

action_55 (44) = happyShift action_9
action_55 (71) = happyShift action_10
action_55 (7) = happyGoto action_58
action_55 (8) = happyGoto action_4
action_55 (9) = happyGoto action_5
action_55 _ = happyFail (happyExpListPerState 55)

action_56 (44) = happyShift action_9
action_56 (71) = happyShift action_10
action_56 (7) = happyGoto action_57
action_56 (8) = happyGoto action_4
action_56 (9) = happyGoto action_5
action_56 _ = happyFail (happyExpListPerState 56)

action_57 (51) = happyShift action_54
action_57 (52) = happyShift action_55
action_57 (53) = happyShift action_56
action_57 _ = happyReduce_15

action_58 (51) = happyShift action_54
action_58 (52) = happyShift action_55
action_58 (53) = happyShift action_56
action_58 _ = happyReduce_14

action_59 (51) = happyShift action_54
action_59 (52) = happyShift action_55
action_59 (53) = happyShift action_56
action_59 _ = happyReduce_13

action_60 (73) = happyShift action_169
action_60 _ = happyReduce_9

action_61 (93) = happyShift action_163
action_61 (94) = happyShift action_164
action_61 (95) = happyShift action_165
action_61 (96) = happyShift action_166
action_61 (97) = happyShift action_167
action_61 (98) = happyShift action_168
action_61 (32) = happyGoto action_162
action_61 _ = happyFail (happyExpListPerState 61)

action_62 (60) = happyShift action_134
action_62 (61) = happyShift action_135
action_62 (62) = happyShift action_40
action_62 (63) = happyShift action_41
action_62 (64) = happyShift action_42
action_62 (65) = happyShift action_43
action_62 (66) = happyShift action_44
action_62 (70) = happyShift action_45
action_62 (71) = happyShift action_136
action_62 (76) = happyShift action_123
action_62 (81) = happyShift action_49
action_62 (93) = happyShift action_124
action_62 (94) = happyShift action_125
action_62 (95) = happyShift action_126
action_62 (96) = happyShift action_127
action_62 (97) = happyShift action_50
action_62 (98) = happyShift action_128
action_62 (18) = happyGoto action_113
action_62 (19) = happyGoto action_114
action_62 (22) = happyGoto action_161
action_62 (25) = happyGoto action_131
action_62 (26) = happyGoto action_132
action_62 (27) = happyGoto action_133
action_62 (28) = happyGoto action_39
action_62 _ = happyFail (happyExpListPerState 62)

action_63 (76) = happyShift action_160
action_63 (33) = happyGoto action_159
action_63 _ = happyFail (happyExpListPerState 63)

action_64 _ = happyReduce_49

action_65 (45) = happyShift action_87
action_65 (47) = happyShift action_88
action_65 (48) = happyShift action_89
action_65 (49) = happyShift action_90
action_65 (50) = happyShift action_91
action_65 (67) = happyShift action_92
action_65 (73) = happyShift action_93
action_65 (119) = happyShift action_94
action_65 (120) = happyShift action_95
action_65 (121) = happyShift action_96
action_65 (10) = happyGoto action_158
action_65 (11) = happyGoto action_80
action_65 (12) = happyGoto action_81
action_65 (13) = happyGoto action_82
action_65 (14) = happyGoto action_83
action_65 (15) = happyGoto action_84
action_65 (16) = happyGoto action_85
action_65 (30) = happyGoto action_86
action_65 _ = happyReduce_34

action_66 (76) = happyShift action_157
action_66 _ = happyFail (happyExpListPerState 66)

action_67 (72) = happyShift action_156
action_67 _ = happyFail (happyExpListPerState 67)

action_68 (72) = happyShift action_155
action_68 (74) = happyShift action_74
action_68 (80) = happyShift action_75
action_68 (81) = happyShift action_76
action_68 (82) = happyShift action_77
action_68 (83) = happyShift action_78
action_68 _ = happyFail (happyExpListPerState 68)

action_69 (76) = happyShift action_145
action_69 (77) = happyShift action_154
action_69 (26) = happyGoto action_153
action_69 _ = happyFail (happyExpListPerState 69)

action_70 (76) = happyShift action_145
action_70 (77) = happyShift action_152
action_70 (26) = happyGoto action_151
action_70 _ = happyFail (happyExpListPerState 70)

action_71 (76) = happyShift action_145
action_71 (77) = happyShift action_150
action_71 (26) = happyGoto action_149
action_71 _ = happyFail (happyExpListPerState 71)

action_72 (76) = happyShift action_145
action_72 (77) = happyShift action_148
action_72 (26) = happyGoto action_147
action_72 _ = happyFail (happyExpListPerState 72)

action_73 (76) = happyShift action_145
action_73 (77) = happyShift action_146
action_73 (26) = happyGoto action_144
action_73 _ = happyFail (happyExpListPerState 73)

action_74 (76) = happyShift action_143
action_74 _ = happyFail (happyExpListPerState 74)

action_75 (62) = happyShift action_40
action_75 (63) = happyShift action_41
action_75 (64) = happyShift action_42
action_75 (65) = happyShift action_43
action_75 (66) = happyShift action_44
action_75 (70) = happyShift action_45
action_75 (71) = happyShift action_46
action_75 (76) = happyShift action_47
action_75 (81) = happyShift action_49
action_75 (97) = happyShift action_50
action_75 (18) = happyGoto action_142
action_75 (19) = happyGoto action_38
action_75 (28) = happyGoto action_39
action_75 _ = happyFail (happyExpListPerState 75)

action_76 (62) = happyShift action_40
action_76 (63) = happyShift action_41
action_76 (64) = happyShift action_42
action_76 (65) = happyShift action_43
action_76 (66) = happyShift action_44
action_76 (70) = happyShift action_45
action_76 (71) = happyShift action_46
action_76 (76) = happyShift action_47
action_76 (81) = happyShift action_49
action_76 (97) = happyShift action_50
action_76 (18) = happyGoto action_141
action_76 (19) = happyGoto action_38
action_76 (28) = happyGoto action_39
action_76 _ = happyFail (happyExpListPerState 76)

action_77 (62) = happyShift action_40
action_77 (63) = happyShift action_41
action_77 (64) = happyShift action_42
action_77 (65) = happyShift action_43
action_77 (66) = happyShift action_44
action_77 (70) = happyShift action_45
action_77 (71) = happyShift action_46
action_77 (76) = happyShift action_47
action_77 (81) = happyShift action_49
action_77 (97) = happyShift action_50
action_77 (18) = happyGoto action_140
action_77 (19) = happyGoto action_38
action_77 (28) = happyGoto action_39
action_77 _ = happyFail (happyExpListPerState 77)

action_78 (62) = happyShift action_40
action_78 (63) = happyShift action_41
action_78 (64) = happyShift action_42
action_78 (65) = happyShift action_43
action_78 (66) = happyShift action_44
action_78 (70) = happyShift action_45
action_78 (71) = happyShift action_46
action_78 (76) = happyShift action_47
action_78 (81) = happyShift action_49
action_78 (97) = happyShift action_50
action_78 (18) = happyGoto action_139
action_78 (19) = happyGoto action_38
action_78 (28) = happyGoto action_39
action_78 _ = happyFail (happyExpListPerState 78)

action_79 _ = happyReduce_19

action_80 _ = happyReduce_22

action_81 _ = happyReduce_24

action_82 _ = happyReduce_26

action_83 _ = happyReduce_28

action_84 _ = happyReduce_30

action_85 _ = happyReduce_32

action_86 (118) = happyShift action_138
action_86 _ = happyFail (happyExpListPerState 86)

action_87 (71) = happyShift action_111
action_87 (76) = happyShift action_112
action_87 (20) = happyGoto action_137
action_87 _ = happyFail (happyExpListPerState 87)

action_88 (60) = happyShift action_134
action_88 (61) = happyShift action_135
action_88 (62) = happyShift action_40
action_88 (63) = happyShift action_41
action_88 (64) = happyShift action_42
action_88 (65) = happyShift action_43
action_88 (66) = happyShift action_44
action_88 (70) = happyShift action_45
action_88 (71) = happyShift action_136
action_88 (76) = happyShift action_123
action_88 (81) = happyShift action_49
action_88 (93) = happyShift action_124
action_88 (94) = happyShift action_125
action_88 (95) = happyShift action_126
action_88 (96) = happyShift action_127
action_88 (97) = happyShift action_50
action_88 (98) = happyShift action_128
action_88 (18) = happyGoto action_113
action_88 (19) = happyGoto action_114
action_88 (22) = happyGoto action_130
action_88 (25) = happyGoto action_131
action_88 (26) = happyGoto action_132
action_88 (27) = happyGoto action_133
action_88 (28) = happyGoto action_39
action_88 _ = happyFail (happyExpListPerState 88)

action_89 (71) = happyShift action_111
action_89 (76) = happyShift action_112
action_89 (20) = happyGoto action_129
action_89 _ = happyFail (happyExpListPerState 89)

action_90 (60) = happyShift action_120
action_90 (61) = happyShift action_121
action_90 (62) = happyShift action_40
action_90 (63) = happyShift action_41
action_90 (64) = happyShift action_42
action_90 (65) = happyShift action_43
action_90 (66) = happyShift action_44
action_90 (70) = happyShift action_45
action_90 (71) = happyShift action_122
action_90 (76) = happyShift action_123
action_90 (81) = happyShift action_49
action_90 (93) = happyShift action_124
action_90 (94) = happyShift action_125
action_90 (95) = happyShift action_126
action_90 (96) = happyShift action_127
action_90 (97) = happyShift action_50
action_90 (98) = happyShift action_128
action_90 (18) = happyGoto action_113
action_90 (19) = happyGoto action_114
action_90 (23) = happyGoto action_115
action_90 (24) = happyGoto action_116
action_90 (26) = happyGoto action_117
action_90 (27) = happyGoto action_118
action_90 (28) = happyGoto action_119
action_90 _ = happyFail (happyExpListPerState 90)

action_91 (71) = happyShift action_111
action_91 (76) = happyShift action_112
action_91 (20) = happyGoto action_110
action_91 _ = happyFail (happyExpListPerState 91)

action_92 (97) = happyShift action_109
action_92 _ = happyFail (happyExpListPerState 92)

action_93 (62) = happyShift action_40
action_93 (63) = happyShift action_41
action_93 (64) = happyShift action_42
action_93 (65) = happyShift action_43
action_93 (66) = happyShift action_44
action_93 (70) = happyShift action_45
action_93 (71) = happyShift action_46
action_93 (76) = happyShift action_47
action_93 (81) = happyShift action_49
action_93 (97) = happyShift action_50
action_93 (17) = happyGoto action_108
action_93 (18) = happyGoto action_37
action_93 (19) = happyGoto action_38
action_93 (28) = happyGoto action_39
action_93 _ = happyFail (happyExpListPerState 93)

action_94 _ = happyReduce_102

action_95 _ = happyReduce_103

action_96 _ = happyReduce_101

action_97 _ = happyReduce_18

action_98 (46) = happyShift action_34
action_98 _ = happyReduce_4

action_99 (76) = happyShift action_105
action_99 (89) = happyShift action_106
action_99 (110) = happyShift action_107
action_99 (35) = happyGoto action_103
action_99 (36) = happyGoto action_104
action_99 _ = happyFail (happyExpListPerState 99)

action_100 _ = happyReduce_6

action_101 _ = happyReduce_7

action_102 _ = happyReduce_8

action_103 (72) = happyShift action_230
action_103 (73) = happyShift action_231
action_103 _ = happyFail (happyExpListPerState 103)

action_104 _ = happyReduce_122

action_105 (99) = happyShift action_223
action_105 (100) = happyShift action_224
action_105 (101) = happyShift action_225
action_105 (102) = happyShift action_226
action_105 (103) = happyShift action_227
action_105 (104) = happyShift action_228
action_105 (105) = happyShift action_229
action_105 (40) = happyGoto action_222
action_105 _ = happyFail (happyExpListPerState 105)

action_106 (71) = happyShift action_221
action_106 _ = happyFail (happyExpListPerState 106)

action_107 (71) = happyShift action_220
action_107 _ = happyFail (happyExpListPerState 107)

action_108 (73) = happyShift action_93
action_108 _ = happyReduce_35

action_109 _ = happyReduce_33

action_110 (68) = happyShift action_218
action_110 (69) = happyShift action_219
action_110 (73) = happyShift action_193
action_110 (29) = happyGoto action_217
action_110 _ = happyFail (happyExpListPerState 110)

action_111 (44) = happyShift action_9
action_111 (71) = happyShift action_10
action_111 (7) = happyGoto action_216
action_111 (8) = happyGoto action_4
action_111 (9) = happyGoto action_5
action_111 _ = happyFail (happyExpListPerState 111)

action_112 (74) = happyShift action_215
action_112 _ = happyReduce_51

action_113 (74) = happyShift action_74
action_113 (80) = happyShift action_75
action_113 (81) = happyShift action_76
action_113 (82) = happyShift action_77
action_113 (83) = happyShift action_78
action_113 _ = happyFail (happyExpListPerState 113)

action_114 (72) = happyReduce_87
action_114 (74) = happyReduce_42
action_114 (80) = happyReduce_42
action_114 (81) = happyReduce_42
action_114 (82) = happyReduce_42
action_114 (83) = happyReduce_42
action_114 _ = happyReduce_87

action_115 (50) = happyShift action_91
action_115 (54) = happyShift action_213
action_115 (55) = happyShift action_214
action_115 (67) = happyShift action_92
action_115 (15) = happyGoto action_212
action_115 (16) = happyGoto action_85
action_115 _ = happyReduce_34

action_116 (56) = happyShift action_209
action_116 (57) = happyShift action_210
action_116 (58) = happyShift action_211
action_116 _ = happyFail (happyExpListPerState 116)

action_117 (59) = happyShift action_208
action_117 _ = happyFail (happyExpListPerState 117)

action_118 _ = happyReduce_77

action_119 (72) = happyReduce_78
action_119 (74) = happyReduce_38
action_119 (80) = happyReduce_38
action_119 (81) = happyReduce_38
action_119 (82) = happyReduce_38
action_119 (83) = happyReduce_38
action_119 _ = happyReduce_78

action_120 (71) = happyShift action_207
action_120 _ = happyFail (happyExpListPerState 120)

action_121 (60) = happyShift action_120
action_121 (61) = happyShift action_121
action_121 (62) = happyShift action_40
action_121 (63) = happyShift action_41
action_121 (64) = happyShift action_42
action_121 (65) = happyShift action_43
action_121 (66) = happyShift action_44
action_121 (70) = happyShift action_45
action_121 (71) = happyShift action_122
action_121 (76) = happyShift action_123
action_121 (81) = happyShift action_49
action_121 (93) = happyShift action_124
action_121 (94) = happyShift action_125
action_121 (95) = happyShift action_126
action_121 (96) = happyShift action_127
action_121 (97) = happyShift action_50
action_121 (98) = happyShift action_128
action_121 (18) = happyGoto action_113
action_121 (19) = happyGoto action_114
action_121 (23) = happyGoto action_206
action_121 (24) = happyGoto action_116
action_121 (26) = happyGoto action_117
action_121 (27) = happyGoto action_118
action_121 (28) = happyGoto action_119
action_121 _ = happyFail (happyExpListPerState 121)

action_122 (44) = happyShift action_9
action_122 (60) = happyShift action_120
action_122 (61) = happyShift action_121
action_122 (62) = happyShift action_40
action_122 (63) = happyShift action_41
action_122 (64) = happyShift action_42
action_122 (65) = happyShift action_43
action_122 (66) = happyShift action_44
action_122 (70) = happyShift action_45
action_122 (71) = happyShift action_122
action_122 (76) = happyShift action_123
action_122 (81) = happyShift action_49
action_122 (93) = happyShift action_124
action_122 (94) = happyShift action_125
action_122 (95) = happyShift action_126
action_122 (96) = happyShift action_127
action_122 (97) = happyShift action_50
action_122 (98) = happyShift action_128
action_122 (9) = happyGoto action_67
action_122 (18) = happyGoto action_68
action_122 (19) = happyGoto action_114
action_122 (23) = happyGoto action_205
action_122 (24) = happyGoto action_116
action_122 (26) = happyGoto action_117
action_122 (27) = happyGoto action_118
action_122 (28) = happyGoto action_119
action_122 _ = happyFail (happyExpListPerState 122)

action_123 (72) = happyReduce_81
action_123 (74) = happyReduce_37
action_123 (79) = happyShift action_204
action_123 (80) = happyReduce_37
action_123 (81) = happyReduce_37
action_123 (82) = happyReduce_37
action_123 (83) = happyReduce_37
action_123 _ = happyReduce_81

action_124 _ = happyReduce_84

action_125 _ = happyReduce_85

action_126 _ = happyReduce_86

action_127 _ = happyReduce_83

action_128 _ = happyReduce_88

action_129 (49) = happyShift action_90
action_129 (50) = happyShift action_91
action_129 (67) = happyShift action_92
action_129 (73) = happyShift action_193
action_129 (14) = happyGoto action_203
action_129 (15) = happyGoto action_84
action_129 (16) = happyGoto action_85
action_129 _ = happyReduce_34

action_130 (48) = happyShift action_89
action_130 (49) = happyShift action_90
action_130 (50) = happyShift action_91
action_130 (54) = happyShift action_173
action_130 (55) = happyShift action_174
action_130 (67) = happyShift action_92
action_130 (13) = happyGoto action_202
action_130 (14) = happyGoto action_83
action_130 (15) = happyGoto action_84
action_130 (16) = happyGoto action_85
action_130 _ = happyReduce_34

action_131 (56) = happyShift action_199
action_131 (57) = happyShift action_200
action_131 (58) = happyShift action_201
action_131 _ = happyFail (happyExpListPerState 131)

action_132 (59) = happyShift action_197
action_132 (78) = happyShift action_198
action_132 _ = happyReduce_79

action_133 _ = happyReduce_80

action_134 (71) = happyShift action_196
action_134 _ = happyFail (happyExpListPerState 134)

action_135 (60) = happyShift action_134
action_135 (61) = happyShift action_135
action_135 (62) = happyShift action_40
action_135 (63) = happyShift action_41
action_135 (64) = happyShift action_42
action_135 (65) = happyShift action_43
action_135 (66) = happyShift action_44
action_135 (70) = happyShift action_45
action_135 (71) = happyShift action_136
action_135 (76) = happyShift action_123
action_135 (81) = happyShift action_49
action_135 (93) = happyShift action_124
action_135 (94) = happyShift action_125
action_135 (95) = happyShift action_126
action_135 (96) = happyShift action_127
action_135 (97) = happyShift action_50
action_135 (98) = happyShift action_128
action_135 (18) = happyGoto action_113
action_135 (19) = happyGoto action_114
action_135 (22) = happyGoto action_195
action_135 (25) = happyGoto action_131
action_135 (26) = happyGoto action_132
action_135 (27) = happyGoto action_133
action_135 (28) = happyGoto action_39
action_135 _ = happyFail (happyExpListPerState 135)

action_136 (44) = happyShift action_9
action_136 (60) = happyShift action_134
action_136 (61) = happyShift action_135
action_136 (62) = happyShift action_40
action_136 (63) = happyShift action_41
action_136 (64) = happyShift action_42
action_136 (65) = happyShift action_43
action_136 (66) = happyShift action_44
action_136 (70) = happyShift action_45
action_136 (71) = happyShift action_136
action_136 (76) = happyShift action_123
action_136 (81) = happyShift action_49
action_136 (93) = happyShift action_124
action_136 (94) = happyShift action_125
action_136 (95) = happyShift action_126
action_136 (96) = happyShift action_127
action_136 (97) = happyShift action_50
action_136 (98) = happyShift action_128
action_136 (9) = happyGoto action_67
action_136 (18) = happyGoto action_68
action_136 (19) = happyGoto action_114
action_136 (22) = happyGoto action_194
action_136 (25) = happyGoto action_131
action_136 (26) = happyGoto action_132
action_136 (27) = happyGoto action_133
action_136 (28) = happyGoto action_39
action_136 _ = happyFail (happyExpListPerState 136)

action_137 (47) = happyShift action_88
action_137 (48) = happyShift action_89
action_137 (49) = happyShift action_90
action_137 (50) = happyShift action_91
action_137 (67) = happyShift action_92
action_137 (73) = happyShift action_193
action_137 (119) = happyShift action_94
action_137 (120) = happyShift action_95
action_137 (121) = happyShift action_96
action_137 (11) = happyGoto action_192
action_137 (12) = happyGoto action_81
action_137 (13) = happyGoto action_82
action_137 (14) = happyGoto action_83
action_137 (15) = happyGoto action_84
action_137 (16) = happyGoto action_85
action_137 (30) = happyGoto action_86
action_137 _ = happyReduce_34

action_138 (76) = happyShift action_191
action_138 (37) = happyGoto action_190
action_138 _ = happyFail (happyExpListPerState 138)

action_139 _ = happyReduce_47

action_140 _ = happyReduce_46

action_141 (82) = happyShift action_77
action_141 (83) = happyShift action_78
action_141 _ = happyReduce_45

action_142 (82) = happyShift action_77
action_142 (83) = happyShift action_78
action_142 _ = happyReduce_44

action_143 _ = happyReduce_39

action_144 (72) = happyShift action_189
action_144 _ = happyFail (happyExpListPerState 144)

action_145 (79) = happyShift action_188
action_145 _ = happyReduce_81

action_146 (76) = happyShift action_145
action_146 (26) = happyGoto action_187
action_146 _ = happyFail (happyExpListPerState 146)

action_147 (72) = happyShift action_186
action_147 _ = happyFail (happyExpListPerState 147)

action_148 (76) = happyShift action_145
action_148 (26) = happyGoto action_185
action_148 _ = happyFail (happyExpListPerState 148)

action_149 (72) = happyShift action_184
action_149 _ = happyFail (happyExpListPerState 149)

action_150 (76) = happyShift action_145
action_150 (26) = happyGoto action_183
action_150 _ = happyFail (happyExpListPerState 150)

action_151 (72) = happyShift action_182
action_151 _ = happyFail (happyExpListPerState 151)

action_152 (76) = happyShift action_145
action_152 (26) = happyGoto action_181
action_152 _ = happyFail (happyExpListPerState 152)

action_153 (72) = happyShift action_180
action_153 _ = happyFail (happyExpListPerState 153)

action_154 (76) = happyShift action_145
action_154 (26) = happyGoto action_179
action_154 _ = happyFail (happyExpListPerState 154)

action_155 _ = happyReduce_48

action_156 (74) = happyShift action_178
action_156 _ = happyFail (happyExpListPerState 156)

action_157 _ = happyReduce_41

action_158 _ = happyReduce_20

action_159 (47) = happyShift action_176
action_159 (73) = happyShift action_177
action_159 _ = happyFail (happyExpListPerState 159)

action_160 (56) = happyShift action_175
action_160 _ = happyFail (happyExpListPerState 160)

action_161 (54) = happyShift action_173
action_161 (55) = happyShift action_174
action_161 _ = happyReduce_10

action_162 (72) = happyShift action_171
action_162 (73) = happyShift action_172
action_162 _ = happyFail (happyExpListPerState 162)

action_163 _ = happyReduce_108

action_164 _ = happyReduce_109

action_165 _ = happyReduce_110

action_166 _ = happyReduce_106

action_167 _ = happyReduce_107

action_168 _ = happyReduce_111

action_169 (71) = happyShift action_61
action_169 (31) = happyGoto action_170
action_169 _ = happyFail (happyExpListPerState 169)

action_170 (73) = happyShift action_169
action_170 _ = happyReduce_105

action_171 _ = happyReduce_104

action_172 (93) = happyShift action_163
action_172 (94) = happyShift action_164
action_172 (95) = happyShift action_165
action_172 (96) = happyShift action_166
action_172 (97) = happyShift action_167
action_172 (98) = happyShift action_168
action_172 (32) = happyGoto action_271
action_172 _ = happyFail (happyExpListPerState 172)

action_173 (60) = happyShift action_134
action_173 (61) = happyShift action_135
action_173 (62) = happyShift action_40
action_173 (63) = happyShift action_41
action_173 (64) = happyShift action_42
action_173 (65) = happyShift action_43
action_173 (66) = happyShift action_44
action_173 (70) = happyShift action_45
action_173 (71) = happyShift action_136
action_173 (76) = happyShift action_123
action_173 (81) = happyShift action_49
action_173 (93) = happyShift action_124
action_173 (94) = happyShift action_125
action_173 (95) = happyShift action_126
action_173 (96) = happyShift action_127
action_173 (97) = happyShift action_50
action_173 (98) = happyShift action_128
action_173 (18) = happyGoto action_113
action_173 (19) = happyGoto action_114
action_173 (22) = happyGoto action_270
action_173 (25) = happyGoto action_131
action_173 (26) = happyGoto action_132
action_173 (27) = happyGoto action_133
action_173 (28) = happyGoto action_39
action_173 _ = happyFail (happyExpListPerState 173)

action_174 (60) = happyShift action_134
action_174 (61) = happyShift action_135
action_174 (62) = happyShift action_40
action_174 (63) = happyShift action_41
action_174 (64) = happyShift action_42
action_174 (65) = happyShift action_43
action_174 (66) = happyShift action_44
action_174 (70) = happyShift action_45
action_174 (71) = happyShift action_136
action_174 (76) = happyShift action_123
action_174 (81) = happyShift action_49
action_174 (93) = happyShift action_124
action_174 (94) = happyShift action_125
action_174 (95) = happyShift action_126
action_174 (96) = happyShift action_127
action_174 (97) = happyShift action_50
action_174 (98) = happyShift action_128
action_174 (18) = happyGoto action_113
action_174 (19) = happyGoto action_114
action_174 (22) = happyGoto action_269
action_174 (25) = happyGoto action_131
action_174 (26) = happyGoto action_132
action_174 (27) = happyGoto action_133
action_174 (28) = happyGoto action_39
action_174 _ = happyFail (happyExpListPerState 174)

action_175 (62) = happyShift action_40
action_175 (63) = happyShift action_41
action_175 (64) = happyShift action_42
action_175 (65) = happyShift action_43
action_175 (66) = happyShift action_44
action_175 (70) = happyShift action_45
action_175 (71) = happyShift action_46
action_175 (76) = happyShift action_47
action_175 (81) = happyShift action_49
action_175 (93) = happyShift action_124
action_175 (94) = happyShift action_125
action_175 (95) = happyShift action_126
action_175 (96) = happyShift action_127
action_175 (97) = happyShift action_50
action_175 (98) = happyShift action_128
action_175 (18) = happyGoto action_113
action_175 (19) = happyGoto action_114
action_175 (27) = happyGoto action_268
action_175 (28) = happyGoto action_39
action_175 _ = happyFail (happyExpListPerState 175)

action_176 (60) = happyShift action_134
action_176 (61) = happyShift action_135
action_176 (62) = happyShift action_40
action_176 (63) = happyShift action_41
action_176 (64) = happyShift action_42
action_176 (65) = happyShift action_43
action_176 (66) = happyShift action_44
action_176 (70) = happyShift action_45
action_176 (71) = happyShift action_136
action_176 (76) = happyShift action_123
action_176 (81) = happyShift action_49
action_176 (93) = happyShift action_124
action_176 (94) = happyShift action_125
action_176 (95) = happyShift action_126
action_176 (96) = happyShift action_127
action_176 (97) = happyShift action_50
action_176 (98) = happyShift action_128
action_176 (18) = happyGoto action_113
action_176 (19) = happyGoto action_114
action_176 (22) = happyGoto action_267
action_176 (25) = happyGoto action_131
action_176 (26) = happyGoto action_132
action_176 (27) = happyGoto action_133
action_176 (28) = happyGoto action_39
action_176 _ = happyFail (happyExpListPerState 176)

action_177 (76) = happyShift action_160
action_177 (33) = happyGoto action_266
action_177 _ = happyFail (happyExpListPerState 177)

action_178 (76) = happyShift action_265
action_178 _ = happyFail (happyExpListPerState 178)

action_179 (72) = happyShift action_264
action_179 _ = happyFail (happyExpListPerState 179)

action_180 _ = happyReduce_97

action_181 (72) = happyShift action_263
action_181 _ = happyFail (happyExpListPerState 181)

action_182 _ = happyReduce_95

action_183 (72) = happyShift action_262
action_183 _ = happyFail (happyExpListPerState 183)

action_184 _ = happyReduce_93

action_185 (72) = happyShift action_261
action_185 _ = happyFail (happyExpListPerState 185)

action_186 _ = happyReduce_91

action_187 (72) = happyShift action_260
action_187 _ = happyFail (happyExpListPerState 187)

action_188 (76) = happyShift action_259
action_188 _ = happyFail (happyExpListPerState 188)

action_189 _ = happyReduce_89

action_190 (73) = happyShift action_257
action_190 (117) = happyShift action_258
action_190 _ = happyFail (happyExpListPerState 190)

action_191 _ = happyReduce_128

action_192 _ = happyReduce_21

action_193 (71) = happyShift action_111
action_193 (76) = happyShift action_112
action_193 (20) = happyGoto action_256
action_193 _ = happyFail (happyExpListPerState 193)

action_194 (54) = happyShift action_173
action_194 (55) = happyShift action_174
action_194 (72) = happyShift action_255
action_194 _ = happyFail (happyExpListPerState 194)

action_195 (54) = happyShift action_173
action_195 (55) = happyShift action_174
action_195 _ = happyReduce_63

action_196 (44) = happyShift action_9
action_196 (71) = happyShift action_10
action_196 (7) = happyGoto action_254
action_196 (8) = happyGoto action_4
action_196 (9) = happyGoto action_5
action_196 _ = happyFail (happyExpListPerState 196)

action_197 (96) = happyShift action_253
action_197 _ = happyFail (happyExpListPerState 197)

action_198 (71) = happyShift action_252
action_198 _ = happyFail (happyExpListPerState 198)

action_199 (62) = happyShift action_40
action_199 (63) = happyShift action_41
action_199 (64) = happyShift action_42
action_199 (65) = happyShift action_43
action_199 (66) = happyShift action_44
action_199 (70) = happyShift action_45
action_199 (71) = happyShift action_46
action_199 (76) = happyShift action_123
action_199 (81) = happyShift action_49
action_199 (93) = happyShift action_124
action_199 (94) = happyShift action_125
action_199 (95) = happyShift action_126
action_199 (96) = happyShift action_127
action_199 (97) = happyShift action_50
action_199 (98) = happyShift action_128
action_199 (18) = happyGoto action_113
action_199 (19) = happyGoto action_114
action_199 (25) = happyGoto action_251
action_199 (26) = happyGoto action_249
action_199 (27) = happyGoto action_133
action_199 (28) = happyGoto action_39
action_199 _ = happyFail (happyExpListPerState 199)

action_200 (62) = happyShift action_40
action_200 (63) = happyShift action_41
action_200 (64) = happyShift action_42
action_200 (65) = happyShift action_43
action_200 (66) = happyShift action_44
action_200 (70) = happyShift action_45
action_200 (71) = happyShift action_46
action_200 (76) = happyShift action_123
action_200 (81) = happyShift action_49
action_200 (93) = happyShift action_124
action_200 (94) = happyShift action_125
action_200 (95) = happyShift action_126
action_200 (96) = happyShift action_127
action_200 (97) = happyShift action_50
action_200 (98) = happyShift action_128
action_200 (18) = happyGoto action_113
action_200 (19) = happyGoto action_114
action_200 (25) = happyGoto action_250
action_200 (26) = happyGoto action_249
action_200 (27) = happyGoto action_133
action_200 (28) = happyGoto action_39
action_200 _ = happyFail (happyExpListPerState 200)

action_201 (62) = happyShift action_40
action_201 (63) = happyShift action_41
action_201 (64) = happyShift action_42
action_201 (65) = happyShift action_43
action_201 (66) = happyShift action_44
action_201 (70) = happyShift action_45
action_201 (71) = happyShift action_46
action_201 (76) = happyShift action_123
action_201 (81) = happyShift action_49
action_201 (93) = happyShift action_124
action_201 (94) = happyShift action_125
action_201 (95) = happyShift action_126
action_201 (96) = happyShift action_127
action_201 (97) = happyShift action_50
action_201 (98) = happyShift action_128
action_201 (18) = happyGoto action_113
action_201 (19) = happyGoto action_114
action_201 (25) = happyGoto action_248
action_201 (26) = happyGoto action_249
action_201 (27) = happyGoto action_133
action_201 (28) = happyGoto action_39
action_201 _ = happyFail (happyExpListPerState 201)

action_202 _ = happyReduce_25

action_203 _ = happyReduce_27

action_204 (76) = happyShift action_247
action_204 _ = happyFail (happyExpListPerState 204)

action_205 (54) = happyShift action_213
action_205 (55) = happyShift action_214
action_205 (72) = happyShift action_246
action_205 _ = happyFail (happyExpListPerState 205)

action_206 (54) = happyShift action_213
action_206 (55) = happyShift action_214
action_206 _ = happyReduce_74

action_207 (44) = happyShift action_9
action_207 (71) = happyShift action_10
action_207 (7) = happyGoto action_245
action_207 (8) = happyGoto action_4
action_207 (9) = happyGoto action_5
action_207 _ = happyFail (happyExpListPerState 207)

action_208 (96) = happyShift action_244
action_208 _ = happyFail (happyExpListPerState 208)

action_209 (62) = happyShift action_40
action_209 (63) = happyShift action_41
action_209 (64) = happyShift action_42
action_209 (65) = happyShift action_43
action_209 (66) = happyShift action_44
action_209 (70) = happyShift action_45
action_209 (71) = happyShift action_46
action_209 (76) = happyShift action_47
action_209 (81) = happyShift action_49
action_209 (93) = happyShift action_124
action_209 (94) = happyShift action_125
action_209 (95) = happyShift action_126
action_209 (96) = happyShift action_127
action_209 (97) = happyShift action_50
action_209 (98) = happyShift action_128
action_209 (18) = happyGoto action_113
action_209 (19) = happyGoto action_114
action_209 (24) = happyGoto action_243
action_209 (27) = happyGoto action_118
action_209 (28) = happyGoto action_119
action_209 _ = happyFail (happyExpListPerState 209)

action_210 (62) = happyShift action_40
action_210 (63) = happyShift action_41
action_210 (64) = happyShift action_42
action_210 (65) = happyShift action_43
action_210 (66) = happyShift action_44
action_210 (70) = happyShift action_45
action_210 (71) = happyShift action_46
action_210 (76) = happyShift action_47
action_210 (81) = happyShift action_49
action_210 (93) = happyShift action_124
action_210 (94) = happyShift action_125
action_210 (95) = happyShift action_126
action_210 (96) = happyShift action_127
action_210 (97) = happyShift action_50
action_210 (98) = happyShift action_128
action_210 (18) = happyGoto action_113
action_210 (19) = happyGoto action_114
action_210 (24) = happyGoto action_242
action_210 (27) = happyGoto action_118
action_210 (28) = happyGoto action_119
action_210 _ = happyFail (happyExpListPerState 210)

action_211 (62) = happyShift action_40
action_211 (63) = happyShift action_41
action_211 (64) = happyShift action_42
action_211 (65) = happyShift action_43
action_211 (66) = happyShift action_44
action_211 (70) = happyShift action_45
action_211 (71) = happyShift action_46
action_211 (76) = happyShift action_47
action_211 (81) = happyShift action_49
action_211 (93) = happyShift action_124
action_211 (94) = happyShift action_125
action_211 (95) = happyShift action_126
action_211 (96) = happyShift action_127
action_211 (97) = happyShift action_50
action_211 (98) = happyShift action_128
action_211 (18) = happyGoto action_113
action_211 (19) = happyGoto action_114
action_211 (24) = happyGoto action_241
action_211 (27) = happyGoto action_118
action_211 (28) = happyGoto action_119
action_211 _ = happyFail (happyExpListPerState 211)

action_212 _ = happyReduce_29

action_213 (60) = happyShift action_120
action_213 (61) = happyShift action_121
action_213 (62) = happyShift action_40
action_213 (63) = happyShift action_41
action_213 (64) = happyShift action_42
action_213 (65) = happyShift action_43
action_213 (66) = happyShift action_44
action_213 (70) = happyShift action_45
action_213 (71) = happyShift action_122
action_213 (76) = happyShift action_123
action_213 (81) = happyShift action_49
action_213 (93) = happyShift action_124
action_213 (94) = happyShift action_125
action_213 (95) = happyShift action_126
action_213 (96) = happyShift action_127
action_213 (97) = happyShift action_50
action_213 (98) = happyShift action_128
action_213 (18) = happyGoto action_113
action_213 (19) = happyGoto action_114
action_213 (23) = happyGoto action_240
action_213 (24) = happyGoto action_116
action_213 (26) = happyGoto action_117
action_213 (27) = happyGoto action_118
action_213 (28) = happyGoto action_119
action_213 _ = happyFail (happyExpListPerState 213)

action_214 (60) = happyShift action_120
action_214 (61) = happyShift action_121
action_214 (62) = happyShift action_40
action_214 (63) = happyShift action_41
action_214 (64) = happyShift action_42
action_214 (65) = happyShift action_43
action_214 (66) = happyShift action_44
action_214 (70) = happyShift action_45
action_214 (71) = happyShift action_122
action_214 (76) = happyShift action_123
action_214 (81) = happyShift action_49
action_214 (93) = happyShift action_124
action_214 (94) = happyShift action_125
action_214 (95) = happyShift action_126
action_214 (96) = happyShift action_127
action_214 (97) = happyShift action_50
action_214 (98) = happyShift action_128
action_214 (18) = happyGoto action_113
action_214 (19) = happyGoto action_114
action_214 (23) = happyGoto action_239
action_214 (24) = happyGoto action_116
action_214 (26) = happyGoto action_117
action_214 (27) = happyGoto action_118
action_214 (28) = happyGoto action_119
action_214 _ = happyFail (happyExpListPerState 214)

action_215 (76) = happyShift action_238
action_215 _ = happyFail (happyExpListPerState 215)

action_216 (51) = happyShift action_54
action_216 (52) = happyShift action_55
action_216 (53) = happyShift action_56
action_216 (72) = happyShift action_237
action_216 _ = happyFail (happyExpListPerState 216)

action_217 (67) = happyShift action_92
action_217 (16) = happyGoto action_236
action_217 _ = happyReduce_34

action_218 _ = happyReduce_99

action_219 _ = happyReduce_100

action_220 (76) = happyShift action_191
action_220 (37) = happyGoto action_235
action_220 _ = happyFail (happyExpListPerState 220)

action_221 (76) = happyShift action_191
action_221 (37) = happyGoto action_234
action_221 _ = happyFail (happyExpListPerState 221)

action_222 (98) = happyShift action_233
action_222 _ = happyReduce_125

action_223 _ = happyReduce_138

action_224 _ = happyReduce_139

action_225 _ = happyReduce_141

action_226 _ = happyReduce_140

action_227 _ = happyReduce_142

action_228 _ = happyReduce_143

action_229 _ = happyReduce_144

action_230 _ = happyReduce_115

action_231 (76) = happyShift action_105
action_231 (89) = happyShift action_106
action_231 (110) = happyShift action_107
action_231 (35) = happyGoto action_232
action_231 (36) = happyGoto action_104
action_231 _ = happyFail (happyExpListPerState 231)

action_232 (73) = happyShift action_231
action_232 _ = happyReduce_123

action_233 _ = happyReduce_124

action_234 (72) = happyShift action_280
action_234 (73) = happyShift action_257
action_234 _ = happyFail (happyExpListPerState 234)

action_235 (72) = happyShift action_279
action_235 (73) = happyShift action_257
action_235 _ = happyFail (happyExpListPerState 235)

action_236 _ = happyReduce_31

action_237 (74) = happyShift action_278
action_237 _ = happyFail (happyExpListPerState 237)

action_238 _ = happyReduce_52

action_239 _ = happyReduce_70

action_240 _ = happyReduce_68

action_241 _ = happyReduce_73

action_242 _ = happyReduce_72

action_243 _ = happyReduce_71

action_244 _ = happyReduce_76

action_245 (51) = happyShift action_54
action_245 (52) = happyShift action_55
action_245 (53) = happyShift action_56
action_245 (72) = happyShift action_277
action_245 _ = happyFail (happyExpListPerState 245)

action_246 _ = happyReduce_69

action_247 (72) = happyReduce_82
action_247 (74) = happyReduce_41
action_247 (80) = happyReduce_41
action_247 (81) = happyReduce_41
action_247 (82) = happyReduce_41
action_247 (83) = happyReduce_41
action_247 _ = happyReduce_82

action_248 _ = happyReduce_62

action_249 _ = happyReduce_79

action_250 _ = happyReduce_61

action_251 _ = happyReduce_60

action_252 (44) = happyShift action_9
action_252 (71) = happyShift action_10
action_252 (93) = happyShift action_163
action_252 (94) = happyShift action_164
action_252 (95) = happyShift action_165
action_252 (96) = happyShift action_166
action_252 (97) = happyShift action_167
action_252 (98) = happyShift action_168
action_252 (7) = happyGoto action_275
action_252 (8) = happyGoto action_4
action_252 (9) = happyGoto action_5
action_252 (32) = happyGoto action_276
action_252 _ = happyFail (happyExpListPerState 252)

action_253 _ = happyReduce_65

action_254 (51) = happyShift action_54
action_254 (52) = happyShift action_55
action_254 (53) = happyShift action_56
action_254 (72) = happyShift action_274
action_254 _ = happyFail (happyExpListPerState 254)

action_255 _ = happyReduce_58

action_256 (73) = happyShift action_193
action_256 _ = happyReduce_53

action_257 (76) = happyShift action_191
action_257 (37) = happyGoto action_273
action_257 _ = happyFail (happyExpListPerState 257)

action_258 (76) = happyShift action_145
action_258 (26) = happyGoto action_272
action_258 _ = happyFail (happyExpListPerState 258)

action_259 _ = happyReduce_82

action_260 _ = happyReduce_90

action_261 _ = happyReduce_92

action_262 _ = happyReduce_94

action_263 _ = happyReduce_96

action_264 _ = happyReduce_98

action_265 _ = happyReduce_40

action_266 (73) = happyShift action_177
action_266 _ = happyReduce_114

action_267 (54) = happyShift action_173
action_267 (55) = happyShift action_174
action_267 _ = happyReduce_11

action_268 _ = happyReduce_113

action_269 _ = happyReduce_59

action_270 _ = happyReduce_57

action_271 (73) = happyShift action_172
action_271 _ = happyReduce_112

action_272 (56) = happyShift action_285
action_272 _ = happyFail (happyExpListPerState 272)

action_273 (73) = happyShift action_257
action_273 _ = happyReduce_129

action_274 _ = happyReduce_64

action_275 (51) = happyShift action_54
action_275 (52) = happyShift action_55
action_275 (53) = happyShift action_56
action_275 (72) = happyShift action_284
action_275 _ = happyFail (happyExpListPerState 275)

action_276 (72) = happyShift action_283
action_276 (73) = happyShift action_172
action_276 _ = happyFail (happyExpListPerState 276)

action_277 _ = happyReduce_75

action_278 (76) = happyShift action_282
action_278 _ = happyFail (happyExpListPerState 278)

action_279 (111) = happyShift action_281
action_279 _ = happyFail (happyExpListPerState 279)

action_280 _ = happyReduce_126

action_281 (76) = happyShift action_287
action_281 _ = happyFail (happyExpListPerState 281)

action_282 _ = happyReduce_54

action_283 _ = happyReduce_67

action_284 _ = happyReduce_66

action_285 (76) = happyShift action_145
action_285 (26) = happyGoto action_286
action_285 _ = happyFail (happyExpListPerState 285)

action_286 (47) = happyShift action_88
action_286 (48) = happyShift action_89
action_286 (49) = happyShift action_90
action_286 (50) = happyShift action_91
action_286 (67) = happyShift action_92
action_286 (12) = happyGoto action_289
action_286 (13) = happyGoto action_82
action_286 (14) = happyGoto action_83
action_286 (15) = happyGoto action_84
action_286 (16) = happyGoto action_85
action_286 _ = happyReduce_34

action_287 (71) = happyShift action_288
action_287 _ = happyFail (happyExpListPerState 287)

action_288 (76) = happyShift action_191
action_288 (37) = happyGoto action_290
action_288 _ = happyFail (happyExpListPerState 288)

action_289 _ = happyReduce_23

action_290 (72) = happyShift action_291
action_290 (73) = happyShift action_257
action_290 _ = happyFail (happyExpListPerState 290)

action_291 (112) = happyShift action_293
action_291 (38) = happyGoto action_292
action_291 _ = happyReduce_130

action_292 (113) = happyShift action_298
action_292 (39) = happyGoto action_297
action_292 _ = happyReduce_134

action_293 (114) = happyShift action_294
action_293 (115) = happyShift action_295
action_293 (116) = happyShift action_296
action_293 _ = happyFail (happyExpListPerState 293)

action_294 _ = happyReduce_131

action_295 _ = happyReduce_132

action_296 _ = happyReduce_133

action_297 _ = happyReduce_127

action_298 (114) = happyShift action_299
action_298 (115) = happyShift action_300
action_298 (116) = happyShift action_301
action_298 _ = happyFail (happyExpListPerState 298)

action_299 _ = happyReduce_135

action_300 _ = happyReduce_136

action_301 _ = happyReduce_137

happyReduce_1 = happySpecReduce_1  4 happyReduction_1
happyReduction_1 (HappyAbsSyn6  happy_var_1)
	 =  HappyAbsSyn4
		 (S1 happy_var_1
	)
happyReduction_1 _  = notHappyAtAll 

happyReduce_2 = happySpecReduce_1  4 happyReduction_2
happyReduction_2 (HappyAbsSyn34  happy_var_1)
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

happyReduce_6 = happySpecReduce_3  5 happyReduction_6
happyReduction_6 (HappyTerminal (TField happy_var_3))
	(HappyTerminal (TField happy_var_2))
	_
	 =  HappyAbsSyn5
		 (CUser happy_var_2 happy_var_3
	)
happyReduction_6 _ _ _  = notHappyAtAll 

happyReduce_7 = happySpecReduce_3  5 happyReduction_7
happyReduction_7 (HappyTerminal (TField happy_var_3))
	(HappyTerminal (TField happy_var_2))
	_
	 =  HappyAbsSyn5
		 (DUser happy_var_2 happy_var_3
	)
happyReduction_7 _ _ _  = notHappyAtAll 

happyReduce_8 = happySpecReduce_3  5 happyReduction_8
happyReduction_8 (HappyTerminal (TField happy_var_3))
	(HappyTerminal (TField happy_var_2))
	_
	 =  HappyAbsSyn5
		 (SUser happy_var_2 happy_var_3
	)
happyReduction_8 _ _ _  = notHappyAtAll 

happyReduce_9 = happySpecReduce_3  6 happyReduction_9
happyReduction_9 (HappyAbsSyn31  happy_var_3)
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
	(HappyAbsSyn33  happy_var_4) `HappyStk`
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
	(HappyAbsSyn17  happy_var_2)
	_
	 =  HappyAbsSyn9
		 (Select False happy_var_2 happy_var_3
	)
happyReduction_19 _ _ _  = notHappyAtAll 

happyReduce_20 = happyReduce 4 9 happyReduction_20
happyReduction_20 ((HappyAbsSyn10  happy_var_4) `HappyStk`
	(HappyAbsSyn17  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn9
		 (Select True happy_var_3 happy_var_4
	) `HappyStk` happyRest

happyReduce_21 = happySpecReduce_3  10 happyReduction_21
happyReduction_21 (HappyAbsSyn11  happy_var_3)
	(HappyAbsSyn17  happy_var_2)
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

happyReduce_23 = happyReduce 8 11 happyReduction_23
happyReduction_23 ((HappyAbsSyn12  happy_var_8) `HappyStk`
	(HappyAbsSyn18  happy_var_7) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn18  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn37  happy_var_3) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn30  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn11
		 (Join happy_var_1 (map (\x -> Field x) happy_var_3) (Equal happy_var_5 happy_var_7) happy_var_8
	) `HappyStk` happyRest

happyReduce_24 = happySpecReduce_1  11 happyReduction_24
happyReduction_24 (HappyAbsSyn12  happy_var_1)
	 =  HappyAbsSyn11
		 (happy_var_1
	)
happyReduction_24 _  = notHappyAtAll 

happyReduce_25 = happySpecReduce_3  12 happyReduction_25
happyReduction_25 (HappyAbsSyn13  happy_var_3)
	(HappyAbsSyn22  happy_var_2)
	_
	 =  HappyAbsSyn12
		 (Where happy_var_2 happy_var_3
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
	(HappyAbsSyn17  happy_var_2)
	_
	 =  HappyAbsSyn13
		 (GroupBy happy_var_2 happy_var_3
	)
happyReduction_27 _ _ _  = notHappyAtAll 

happyReduce_28 = happySpecReduce_1  13 happyReduction_28
happyReduction_28 (HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn13
		 (happy_var_1
	)
happyReduction_28 _  = notHappyAtAll 

happyReduce_29 = happySpecReduce_3  14 happyReduction_29
happyReduction_29 (HappyAbsSyn15  happy_var_3)
	(HappyAbsSyn22  happy_var_2)
	_
	 =  HappyAbsSyn14
		 (Having happy_var_2 happy_var_3
	)
happyReduction_29 _ _ _  = notHappyAtAll 

happyReduce_30 = happySpecReduce_1  14 happyReduction_30
happyReduction_30 (HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn14
		 (happy_var_1
	)
happyReduction_30 _  = notHappyAtAll 

happyReduce_31 = happyReduce 4 15 happyReduction_31
happyReduction_31 ((HappyAbsSyn16  happy_var_4) `HappyStk`
	(HappyAbsSyn29  happy_var_3) `HappyStk`
	(HappyAbsSyn17  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn15
		 (OrderBy happy_var_2 happy_var_3 happy_var_4
	) `HappyStk` happyRest

happyReduce_32 = happySpecReduce_1  15 happyReduction_32
happyReduction_32 (HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn15
		 (happy_var_1
	)
happyReduction_32 _  = notHappyAtAll 

happyReduce_33 = happySpecReduce_2  16 happyReduction_33
happyReduction_33 (HappyTerminal (TNum happy_var_2))
	_
	 =  HappyAbsSyn16
		 (Limit happy_var_2 End
	)
happyReduction_33 _ _  = notHappyAtAll 

happyReduce_34 = happySpecReduce_0  16 happyReduction_34
happyReduction_34  =  HappyAbsSyn16
		 (End
	)

happyReduce_35 = happySpecReduce_3  17 happyReduction_35
happyReduction_35 (HappyAbsSyn17  happy_var_3)
	_
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn17
		 (happy_var_1 ++ happy_var_3
	)
happyReduction_35 _ _ _  = notHappyAtAll 

happyReduce_36 = happySpecReduce_1  17 happyReduction_36
happyReduction_36 (HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn17
		 ([happy_var_1]
	)
happyReduction_36 _  = notHappyAtAll 

happyReduce_37 = happySpecReduce_1  18 happyReduction_37
happyReduction_37 (HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn18
		 (Field happy_var_1
	)
happyReduction_37 _  = notHappyAtAll 

happyReduce_38 = happySpecReduce_1  18 happyReduction_38
happyReduction_38 (HappyAbsSyn28  happy_var_1)
	 =  HappyAbsSyn18
		 (A2 happy_var_1
	)
happyReduction_38 _  = notHappyAtAll 

happyReduce_39 = happySpecReduce_3  18 happyReduction_39
happyReduction_39 (HappyTerminal (TField happy_var_3))
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn18
		 (As happy_var_1 (Field happy_var_3)
	)
happyReduction_39 _ _ _  = notHappyAtAll 

happyReduce_40 = happyReduce 5 18 happyReduction_40
happyReduction_40 ((HappyTerminal (TField happy_var_5)) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn9  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn18
		 (As (Subquery happy_var_2) (Field happy_var_5)
	) `HappyStk` happyRest

happyReduce_41 = happySpecReduce_3  18 happyReduction_41
happyReduction_41 (HappyTerminal (TField happy_var_3))
	_
	(HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn18
		 (Dot happy_var_1 happy_var_3
	)
happyReduction_41 _ _ _  = notHappyAtAll 

happyReduce_42 = happySpecReduce_1  18 happyReduction_42
happyReduction_42 (HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn18
		 (happy_var_1
	)
happyReduction_42 _  = notHappyAtAll 

happyReduce_43 = happySpecReduce_1  18 happyReduction_43
happyReduction_43 _
	 =  HappyAbsSyn18
		 (All
	)

happyReduce_44 = happySpecReduce_3  19 happyReduction_44
happyReduction_44 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn18
		 (Plus happy_var_1 happy_var_3
	)
happyReduction_44 _ _ _  = notHappyAtAll 

happyReduce_45 = happySpecReduce_3  19 happyReduction_45
happyReduction_45 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn18
		 (Minus happy_var_1 happy_var_3
	)
happyReduction_45 _ _ _  = notHappyAtAll 

happyReduce_46 = happySpecReduce_3  19 happyReduction_46
happyReduction_46 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn18
		 (Times happy_var_1 happy_var_3
	)
happyReduction_46 _ _ _  = notHappyAtAll 

happyReduce_47 = happySpecReduce_3  19 happyReduction_47
happyReduction_47 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn18
		 (Div happy_var_1 happy_var_3
	)
happyReduction_47 _ _ _  = notHappyAtAll 

happyReduce_48 = happySpecReduce_3  19 happyReduction_48
happyReduction_48 _
	(HappyAbsSyn18  happy_var_2)
	_
	 =  HappyAbsSyn18
		 (Brack happy_var_2
	)
happyReduction_48 _ _ _  = notHappyAtAll 

happyReduce_49 = happySpecReduce_2  19 happyReduction_49
happyReduction_49 (HappyAbsSyn18  happy_var_2)
	_
	 =  HappyAbsSyn18
		 (Negate happy_var_2
	)
happyReduction_49 _ _  = notHappyAtAll 

happyReduce_50 = happySpecReduce_1  19 happyReduction_50
happyReduction_50 (HappyTerminal (TNum happy_var_1))
	 =  HappyAbsSyn18
		 (A3 happy_var_1
	)
happyReduction_50 _  = notHappyAtAll 

happyReduce_51 = happySpecReduce_1  20 happyReduction_51
happyReduction_51 (HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn17
		 ([Field happy_var_1]
	)
happyReduction_51 _  = notHappyAtAll 

happyReduce_52 = happySpecReduce_3  20 happyReduction_52
happyReduction_52 (HappyTerminal (TField happy_var_3))
	_
	(HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn17
		 ([As (Field happy_var_1) (Field happy_var_3)]
	)
happyReduction_52 _ _ _  = notHappyAtAll 

happyReduce_53 = happySpecReduce_3  20 happyReduction_53
happyReduction_53 (HappyAbsSyn17  happy_var_3)
	_
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn17
		 (happy_var_1 ++ happy_var_3
	)
happyReduction_53 _ _ _  = notHappyAtAll 

happyReduce_54 = happyReduce 5 20 happyReduction_54
happyReduction_54 ((HappyTerminal (TField happy_var_5)) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn6  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn17
		 ([As (Subquery happy_var_2) (Field happy_var_5)]
	) `HappyStk` happyRest

happyReduce_55 = happySpecReduce_1  21 happyReduction_55
happyReduction_55 (HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn17
		 ([Field happy_var_1]
	)
happyReduction_55 _  = notHappyAtAll 

happyReduce_56 = happySpecReduce_3  21 happyReduction_56
happyReduction_56 (HappyAbsSyn17  happy_var_3)
	_
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn17
		 (happy_var_1 ++ happy_var_3
	)
happyReduction_56 _ _ _  = notHappyAtAll 

happyReduce_57 = happySpecReduce_3  22 happyReduction_57
happyReduction_57 (HappyAbsSyn22  happy_var_3)
	_
	(HappyAbsSyn22  happy_var_1)
	 =  HappyAbsSyn22
		 (And happy_var_1 happy_var_3
	)
happyReduction_57 _ _ _  = notHappyAtAll 

happyReduce_58 = happySpecReduce_3  22 happyReduction_58
happyReduction_58 _
	(HappyAbsSyn22  happy_var_2)
	_
	 =  HappyAbsSyn22
		 (happy_var_2
	)
happyReduction_58 _ _ _  = notHappyAtAll 

happyReduce_59 = happySpecReduce_3  22 happyReduction_59
happyReduction_59 (HappyAbsSyn22  happy_var_3)
	_
	(HappyAbsSyn22  happy_var_1)
	 =  HappyAbsSyn22
		 (Or happy_var_1 happy_var_3
	)
happyReduction_59 _ _ _  = notHappyAtAll 

happyReduce_60 = happySpecReduce_3  22 happyReduction_60
happyReduction_60 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn22
		 (Equal happy_var_1 happy_var_3
	)
happyReduction_60 _ _ _  = notHappyAtAll 

happyReduce_61 = happySpecReduce_3  22 happyReduction_61
happyReduction_61 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn22
		 (Great happy_var_1 happy_var_3
	)
happyReduction_61 _ _ _  = notHappyAtAll 

happyReduce_62 = happySpecReduce_3  22 happyReduction_62
happyReduction_62 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn22
		 (Less happy_var_1 happy_var_3
	)
happyReduction_62 _ _ _  = notHappyAtAll 

happyReduce_63 = happySpecReduce_2  22 happyReduction_63
happyReduction_63 (HappyAbsSyn22  happy_var_2)
	_
	 =  HappyAbsSyn22
		 (Not happy_var_2
	)
happyReduction_63 _ _  = notHappyAtAll 

happyReduce_64 = happyReduce 4 22 happyReduction_64
happyReduction_64 (_ `HappyStk`
	(HappyAbsSyn6  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn22
		 (Exist happy_var_3
	) `HappyStk` happyRest

happyReduce_65 = happySpecReduce_3  22 happyReduction_65
happyReduction_65 (HappyTerminal (TStr happy_var_3))
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn22
		 (Like happy_var_1 happy_var_3
	)
happyReduction_65 _ _ _  = notHappyAtAll 

happyReduce_66 = happyReduce 5 22 happyReduction_66
happyReduction_66 (_ `HappyStk`
	(HappyAbsSyn6  happy_var_4) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn18  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn22
		 (InQuery happy_var_1 happy_var_4
	) `HappyStk` happyRest

happyReduce_67 = happyReduce 5 22 happyReduction_67
happyReduction_67 (_ `HappyStk`
	(HappyAbsSyn17  happy_var_4) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn18  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn22
		 (InVals happy_var_1 happy_var_4
	) `HappyStk` happyRest

happyReduce_68 = happySpecReduce_3  23 happyReduction_68
happyReduction_68 (HappyAbsSyn22  happy_var_3)
	_
	(HappyAbsSyn22  happy_var_1)
	 =  HappyAbsSyn22
		 (And happy_var_1 happy_var_3
	)
happyReduction_68 _ _ _  = notHappyAtAll 

happyReduce_69 = happySpecReduce_3  23 happyReduction_69
happyReduction_69 _
	(HappyAbsSyn22  happy_var_2)
	_
	 =  HappyAbsSyn22
		 (happy_var_2
	)
happyReduction_69 _ _ _  = notHappyAtAll 

happyReduce_70 = happySpecReduce_3  23 happyReduction_70
happyReduction_70 (HappyAbsSyn22  happy_var_3)
	_
	(HappyAbsSyn22  happy_var_1)
	 =  HappyAbsSyn22
		 (Or happy_var_1 happy_var_3
	)
happyReduction_70 _ _ _  = notHappyAtAll 

happyReduce_71 = happySpecReduce_3  23 happyReduction_71
happyReduction_71 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn22
		 (Equal happy_var_1 happy_var_3
	)
happyReduction_71 _ _ _  = notHappyAtAll 

happyReduce_72 = happySpecReduce_3  23 happyReduction_72
happyReduction_72 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn22
		 (Great happy_var_1 happy_var_3
	)
happyReduction_72 _ _ _  = notHappyAtAll 

happyReduce_73 = happySpecReduce_3  23 happyReduction_73
happyReduction_73 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn22
		 (Less happy_var_1 happy_var_3
	)
happyReduction_73 _ _ _  = notHappyAtAll 

happyReduce_74 = happySpecReduce_2  23 happyReduction_74
happyReduction_74 (HappyAbsSyn22  happy_var_2)
	_
	 =  HappyAbsSyn22
		 (Not happy_var_2
	)
happyReduction_74 _ _  = notHappyAtAll 

happyReduce_75 = happyReduce 4 23 happyReduction_75
happyReduction_75 (_ `HappyStk`
	(HappyAbsSyn6  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn22
		 (Exist happy_var_3
	) `HappyStk` happyRest

happyReduce_76 = happySpecReduce_3  23 happyReduction_76
happyReduction_76 (HappyTerminal (TStr happy_var_3))
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn22
		 (Like happy_var_1 happy_var_3
	)
happyReduction_76 _ _ _  = notHappyAtAll 

happyReduce_77 = happySpecReduce_1  24 happyReduction_77
happyReduction_77 (HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn18
		 (happy_var_1
	)
happyReduction_77 _  = notHappyAtAll 

happyReduce_78 = happySpecReduce_1  24 happyReduction_78
happyReduction_78 (HappyAbsSyn28  happy_var_1)
	 =  HappyAbsSyn18
		 (A2 happy_var_1
	)
happyReduction_78 _  = notHappyAtAll 

happyReduce_79 = happySpecReduce_1  25 happyReduction_79
happyReduction_79 (HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn18
		 (happy_var_1
	)
happyReduction_79 _  = notHappyAtAll 

happyReduce_80 = happySpecReduce_1  25 happyReduction_80
happyReduction_80 (HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn18
		 (happy_var_1
	)
happyReduction_80 _  = notHappyAtAll 

happyReduce_81 = happySpecReduce_1  26 happyReduction_81
happyReduction_81 (HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn18
		 (Field happy_var_1
	)
happyReduction_81 _  = notHappyAtAll 

happyReduce_82 = happySpecReduce_3  26 happyReduction_82
happyReduction_82 (HappyTerminal (TField happy_var_3))
	_
	(HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn18
		 (Dot happy_var_1 happy_var_3
	)
happyReduction_82 _ _ _  = notHappyAtAll 

happyReduce_83 = happySpecReduce_1  27 happyReduction_83
happyReduction_83 (HappyTerminal (TStr happy_var_1))
	 =  HappyAbsSyn18
		 (A1 happy_var_1
	)
happyReduction_83 _  = notHappyAtAll 

happyReduce_84 = happySpecReduce_1  27 happyReduction_84
happyReduction_84 (HappyTerminal (TDatTim happy_var_1))
	 =  HappyAbsSyn18
		 (A5 happy_var_1
	)
happyReduction_84 _  = notHappyAtAll 

happyReduce_85 = happySpecReduce_1  27 happyReduction_85
happyReduction_85 (HappyTerminal (TDat happy_var_1))
	 =  HappyAbsSyn18
		 (A6 happy_var_1
	)
happyReduction_85 _  = notHappyAtAll 

happyReduce_86 = happySpecReduce_1  27 happyReduction_86
happyReduction_86 (HappyTerminal (TTim happy_var_1))
	 =  HappyAbsSyn18
		 (A7 happy_var_1
	)
happyReduction_86 _  = notHappyAtAll 

happyReduce_87 = happySpecReduce_1  27 happyReduction_87
happyReduction_87 (HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn18
		 (happy_var_1
	)
happyReduction_87 _  = notHappyAtAll 

happyReduce_88 = happySpecReduce_1  27 happyReduction_88
happyReduction_88 _
	 =  HappyAbsSyn18
		 (Nulo
	)

happyReduce_89 = happyReduce 4 28 happyReduction_89
happyReduction_89 (_ `HappyStk`
	(HappyAbsSyn18  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn28
		 (Sum False happy_var_3
	) `HappyStk` happyRest

happyReduce_90 = happyReduce 5 28 happyReduction_90
happyReduction_90 (_ `HappyStk`
	(HappyAbsSyn18  happy_var_4) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn28
		 (Sum True happy_var_4
	) `HappyStk` happyRest

happyReduce_91 = happyReduce 4 28 happyReduction_91
happyReduction_91 (_ `HappyStk`
	(HappyAbsSyn18  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn28
		 (Count False happy_var_3
	) `HappyStk` happyRest

happyReduce_92 = happyReduce 5 28 happyReduction_92
happyReduction_92 (_ `HappyStk`
	(HappyAbsSyn18  happy_var_4) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn28
		 (Count True happy_var_4
	) `HappyStk` happyRest

happyReduce_93 = happyReduce 4 28 happyReduction_93
happyReduction_93 (_ `HappyStk`
	(HappyAbsSyn18  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn28
		 (Avg False happy_var_3
	) `HappyStk` happyRest

happyReduce_94 = happyReduce 5 28 happyReduction_94
happyReduction_94 (_ `HappyStk`
	(HappyAbsSyn18  happy_var_4) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn28
		 (Avg True happy_var_4
	) `HappyStk` happyRest

happyReduce_95 = happyReduce 4 28 happyReduction_95
happyReduction_95 (_ `HappyStk`
	(HappyAbsSyn18  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn28
		 (Min False happy_var_3
	) `HappyStk` happyRest

happyReduce_96 = happyReduce 5 28 happyReduction_96
happyReduction_96 (_ `HappyStk`
	(HappyAbsSyn18  happy_var_4) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn28
		 (Min True happy_var_4
	) `HappyStk` happyRest

happyReduce_97 = happyReduce 4 28 happyReduction_97
happyReduction_97 (_ `HappyStk`
	(HappyAbsSyn18  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn28
		 (Max False happy_var_3
	) `HappyStk` happyRest

happyReduce_98 = happyReduce 5 28 happyReduction_98
happyReduction_98 (_ `HappyStk`
	(HappyAbsSyn18  happy_var_4) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn28
		 (Max True happy_var_4
	) `HappyStk` happyRest

happyReduce_99 = happySpecReduce_1  29 happyReduction_99
happyReduction_99 _
	 =  HappyAbsSyn29
		 (A
	)

happyReduce_100 = happySpecReduce_1  29 happyReduction_100
happyReduction_100 _
	 =  HappyAbsSyn29
		 (D
	)

happyReduce_101 = happySpecReduce_1  30 happyReduction_101
happyReduction_101 _
	 =  HappyAbsSyn30
		 (Inner
	)

happyReduce_102 = happySpecReduce_1  30 happyReduction_102
happyReduction_102 _
	 =  HappyAbsSyn30
		 (JLeft
	)

happyReduce_103 = happySpecReduce_1  30 happyReduction_103
happyReduction_103 _
	 =  HappyAbsSyn30
		 (JRight
	)

happyReduce_104 = happySpecReduce_3  31 happyReduction_104
happyReduction_104 _
	(HappyAbsSyn17  happy_var_2)
	_
	 =  HappyAbsSyn31
		 (Avl.singletonT happy_var_2
	)
happyReduction_104 _ _ _  = notHappyAtAll 

happyReduce_105 = happySpecReduce_3  31 happyReduction_105
happyReduction_105 (HappyAbsSyn31  happy_var_3)
	_
	(HappyAbsSyn31  happy_var_1)
	 =  HappyAbsSyn31
		 (Avl.join happy_var_1  happy_var_3
	)
happyReduction_105 _ _ _  = notHappyAtAll 

happyReduce_106 = happySpecReduce_1  32 happyReduction_106
happyReduction_106 (HappyTerminal (TStr happy_var_1))
	 =  HappyAbsSyn17
		 ([A1 happy_var_1]
	)
happyReduction_106 _  = notHappyAtAll 

happyReduce_107 = happySpecReduce_1  32 happyReduction_107
happyReduction_107 (HappyTerminal (TNum happy_var_1))
	 =  HappyAbsSyn17
		 ([A3 happy_var_1]
	)
happyReduction_107 _  = notHappyAtAll 

happyReduce_108 = happySpecReduce_1  32 happyReduction_108
happyReduction_108 (HappyTerminal (TDatTim happy_var_1))
	 =  HappyAbsSyn17
		 ([A5 happy_var_1]
	)
happyReduction_108 _  = notHappyAtAll 

happyReduce_109 = happySpecReduce_1  32 happyReduction_109
happyReduction_109 (HappyTerminal (TDat happy_var_1))
	 =  HappyAbsSyn17
		 ([A6 happy_var_1]
	)
happyReduction_109 _  = notHappyAtAll 

happyReduce_110 = happySpecReduce_1  32 happyReduction_110
happyReduction_110 (HappyTerminal (TTim happy_var_1))
	 =  HappyAbsSyn17
		 ([A7 happy_var_1]
	)
happyReduction_110 _  = notHappyAtAll 

happyReduce_111 = happySpecReduce_1  32 happyReduction_111
happyReduction_111 _
	 =  HappyAbsSyn17
		 ([Nulo]
	)

happyReduce_112 = happySpecReduce_3  32 happyReduction_112
happyReduction_112 (HappyAbsSyn17  happy_var_3)
	_
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn17
		 (happy_var_1 ++ happy_var_3
	)
happyReduction_112 _ _ _  = notHappyAtAll 

happyReduce_113 = happySpecReduce_3  33 happyReduction_113
happyReduction_113 (HappyAbsSyn18  happy_var_3)
	_
	(HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn33
		 (([happy_var_1],[happy_var_3])
	)
happyReduction_113 _ _ _  = notHappyAtAll 

happyReduce_114 = happySpecReduce_3  33 happyReduction_114
happyReduction_114 (HappyAbsSyn33  happy_var_3)
	_
	(HappyAbsSyn33  happy_var_1)
	 =  HappyAbsSyn33
		 (let ((k1,m1),(k2,m2)) = (happy_var_1,happy_var_3)
                                  in (k1 ++ k2, m1 ++ m2)
	)
happyReduction_114 _ _ _  = notHappyAtAll 

happyReduce_115 = happyReduce 5 34 happyReduction_115
happyReduction_115 (_ `HappyStk`
	(HappyAbsSyn35  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TField happy_var_2)) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn34
		 (CTable happy_var_2 happy_var_4
	) `HappyStk` happyRest

happyReduce_116 = happySpecReduce_2  34 happyReduction_116
happyReduction_116 (HappyTerminal (TField happy_var_2))
	_
	 =  HappyAbsSyn34
		 (DTable happy_var_2
	)
happyReduction_116 _ _  = notHappyAtAll 

happyReduce_117 = happySpecReduce_2  34 happyReduction_117
happyReduction_117 (HappyTerminal (TField happy_var_2))
	_
	 =  HappyAbsSyn34
		 (CBase happy_var_2
	)
happyReduction_117 _ _  = notHappyAtAll 

happyReduce_118 = happySpecReduce_2  34 happyReduction_118
happyReduction_118 (HappyTerminal (TField happy_var_2))
	_
	 =  HappyAbsSyn34
		 (DBase happy_var_2
	)
happyReduction_118 _ _  = notHappyAtAll 

happyReduce_119 = happySpecReduce_2  34 happyReduction_119
happyReduction_119 (HappyTerminal (TField happy_var_2))
	_
	 =  HappyAbsSyn34
		 (Use happy_var_2
	)
happyReduction_119 _ _  = notHappyAtAll 

happyReduce_120 = happySpecReduce_1  34 happyReduction_120
happyReduction_120 _
	 =  HappyAbsSyn34
		 (ShowB
	)

happyReduce_121 = happySpecReduce_1  34 happyReduction_121
happyReduction_121 _
	 =  HappyAbsSyn34
		 (ShowT
	)

happyReduce_122 = happySpecReduce_1  35 happyReduction_122
happyReduction_122 (HappyAbsSyn36  happy_var_1)
	 =  HappyAbsSyn35
		 ([happy_var_1]
	)
happyReduction_122 _  = notHappyAtAll 

happyReduce_123 = happySpecReduce_3  35 happyReduction_123
happyReduction_123 (HappyAbsSyn35  happy_var_3)
	_
	(HappyAbsSyn35  happy_var_1)
	 =  HappyAbsSyn35
		 (happy_var_1 ++ happy_var_3
	)
happyReduction_123 _ _ _  = notHappyAtAll 

happyReduce_124 = happySpecReduce_3  36 happyReduction_124
happyReduction_124 _
	(HappyAbsSyn40  happy_var_2)
	(HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn36
		 (Col happy_var_1 happy_var_2 True
	)
happyReduction_124 _ _ _  = notHappyAtAll 

happyReduce_125 = happySpecReduce_2  36 happyReduction_125
happyReduction_125 (HappyAbsSyn40  happy_var_2)
	(HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn36
		 (Col happy_var_1 happy_var_2 False
	)
happyReduction_125 _ _  = notHappyAtAll 

happyReduce_126 = happyReduce 4 36 happyReduction_126
happyReduction_126 (_ `HappyStk`
	(HappyAbsSyn37  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn36
		 (PKey happy_var_3
	) `HappyStk` happyRest

happyReduce_127 = happyReduce 11 36 happyReduction_127
happyReduction_127 ((HappyAbsSyn38  happy_var_11) `HappyStk`
	(HappyAbsSyn38  happy_var_10) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn37  happy_var_8) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TField happy_var_6)) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn37  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn36
		 (FKey happy_var_3 happy_var_6 happy_var_8 happy_var_10 happy_var_11
	) `HappyStk` happyRest

happyReduce_128 = happySpecReduce_1  37 happyReduction_128
happyReduction_128 (HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn37
		 ([happy_var_1]
	)
happyReduction_128 _  = notHappyAtAll 

happyReduce_129 = happySpecReduce_3  37 happyReduction_129
happyReduction_129 (HappyAbsSyn37  happy_var_3)
	_
	(HappyAbsSyn37  happy_var_1)
	 =  HappyAbsSyn37
		 (happy_var_1 ++ happy_var_3
	)
happyReduction_129 _ _ _  = notHappyAtAll 

happyReduce_130 = happySpecReduce_0  38 happyReduction_130
happyReduction_130  =  HappyAbsSyn38
		 (Restricted
	)

happyReduce_131 = happySpecReduce_2  38 happyReduction_131
happyReduction_131 _
	_
	 =  HappyAbsSyn38
		 (Restricted
	)

happyReduce_132 = happySpecReduce_2  38 happyReduction_132
happyReduction_132 _
	_
	 =  HappyAbsSyn38
		 (Cascades
	)

happyReduce_133 = happySpecReduce_2  38 happyReduction_133
happyReduction_133 _
	_
	 =  HappyAbsSyn38
		 (Nullifies
	)

happyReduce_134 = happySpecReduce_0  39 happyReduction_134
happyReduction_134  =  HappyAbsSyn38
		 (Restricted
	)

happyReduce_135 = happySpecReduce_2  39 happyReduction_135
happyReduction_135 _
	_
	 =  HappyAbsSyn38
		 (Restricted
	)

happyReduce_136 = happySpecReduce_2  39 happyReduction_136
happyReduction_136 _
	_
	 =  HappyAbsSyn38
		 (Cascades
	)

happyReduce_137 = happySpecReduce_2  39 happyReduction_137
happyReduction_137 _
	_
	 =  HappyAbsSyn38
		 (Nullifies
	)

happyReduce_138 = happySpecReduce_1  40 happyReduction_138
happyReduction_138 _
	 =  HappyAbsSyn40
		 (Int
	)

happyReduce_139 = happySpecReduce_1  40 happyReduction_139
happyReduction_139 _
	 =  HappyAbsSyn40
		 (Float
	)

happyReduce_140 = happySpecReduce_1  40 happyReduction_140
happyReduction_140 _
	 =  HappyAbsSyn40
		 (Bool
	)

happyReduce_141 = happySpecReduce_1  40 happyReduction_141
happyReduction_141 _
	 =  HappyAbsSyn40
		 (String
	)

happyReduce_142 = happySpecReduce_1  40 happyReduction_142
happyReduction_142 _
	 =  HappyAbsSyn40
		 (Datetime
	)

happyReduce_143 = happySpecReduce_1  40 happyReduction_143
happyReduction_143 _
	 =  HappyAbsSyn40
		 (Dates
	)

happyReduce_144 = happySpecReduce_1  40 happyReduction_144
happyReduction_144 _
	 =  HappyAbsSyn40
		 (Tim
	)

happyNewToken action sts stk
	= lexer(\tk -> 
	let cont i = action i i tk (HappyState action) sts stk in
	case tk of {
	TEOF -> action 122 122 tk (HappyState action) sts stk;
	TInsert -> cont 41;
	TDelete -> cont 42;
	TUpdate -> cont 43;
	TSelect -> cont 44;
	TFrom -> cont 45;
	TSemiColon -> cont 46;
	TWhere -> cont 47;
	TGroupBy -> cont 48;
	THaving -> cont 49;
	TOrderBy -> cont 50;
	TUnion -> cont 51;
	TDiff -> cont 52;
	TIntersect -> cont 53;
	TAnd -> cont 54;
	TOr -> cont 55;
	TEqual -> cont 56;
	TGreat -> cont 57;
	TLess -> cont 58;
	TLike -> cont 59;
	TExist -> cont 60;
	TNot -> cont 61;
	TSum -> cont 62;
	TCount -> cont 63;
	TAvg -> cont 64;
	TMin -> cont 65;
	TMax -> cont 66;
	TLimit -> cont 67;
	TAsc -> cont 68;
	TDesc -> cont 69;
	TAll -> cont 70;
	TOpen -> cont 71;
	TClose -> cont 72;
	TComa -> cont 73;
	TAs -> cont 74;
	TSet -> cont 75;
	TField happy_dollar_dollar -> cont 76;
	TDistinct -> cont 77;
	TIn -> cont 78;
	TDot -> cont 79;
	TPlus -> cont 80;
	TMinus -> cont 81;
	TTimes -> cont 82;
	TDiv -> cont 83;
	TNeg -> cont 84;
	TCTable -> cont 85;
	TCBase -> cont 86;
	TDTable -> cont 87;
	TDBase -> cont 88;
	TPkey -> cont 89;
	TUse -> cont 90;
	TShowB -> cont 91;
	TShowT -> cont 92;
	TDatTim happy_dollar_dollar -> cont 93;
	TDat happy_dollar_dollar -> cont 94;
	TTim happy_dollar_dollar -> cont 95;
	TStr happy_dollar_dollar -> cont 96;
	TNum happy_dollar_dollar -> cont 97;
	TNull -> cont 98;
	TInt -> cont 99;
	TFloat -> cont 100;
	TString -> cont 101;
	TBool -> cont 102;
	TDateTime -> cont 103;
	TDate -> cont 104;
	TTime -> cont 105;
	TSrc -> cont 106;
	TCUser -> cont 107;
	TDUser -> cont 108;
	TSUser -> cont 109;
	TFKey -> cont 110;
	TRef -> cont 111;
	TDel -> cont 112;
	TUpd -> cont 113;
	TRestricted -> cont 114;
	TCascades -> cont 115;
	TNullifies -> cont 116;
	TOn -> cont 117;
	TJoin -> cont 118;
	TLeft -> cont 119;
	TRight -> cont 120;
	TInner -> cont 121;
	_ -> happyError' (tk, [])
	})

happyError_ explist 122 tk = happyError' (tk, explist)
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
             | TEqual
             | TGreat
             | TLess
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

         ('A':'N':'D':xs) -> \(s1,s2) ->  cont TAnd xs (s1,3 + s2)
         ('O':'R':xs) ->  \(s1,s2) ->  cont TOr xs (s1,2 + s2)
         ('N':'O':'T':xs) -> \(s1,s2) ->  cont TNot xs (s1,3 + s2)
         ('L':'I':'K':'E':xs) -> \(s1,s2) ->  cont TLike xs (s1,4 + s2)
         ('E':'X':'I':'S':'T':xs) -> \(s1,s2) ->  cont TExist xs (s1,5 + s2)
         ('I':'N':xs) -> \(s1,s2) ->  cont TIn xs (s1,2 + s2)
         ('G':'R':'O':'U':'P':' ':'B':'Y':xs) -> \(s1,s2) ->  cont TGroupBy xs (s1,8 + s2)
         ('=':xs) -> \(s1,s2) ->  cont TEqual xs (s1,1 + s2)
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


         ('A':'s':'c':xs) -> \(s1,s2) ->  cont TAsc xs (s1,3 + s2)
         ('D':'e':'s':'c':xs) -> \(s1,s2) ->  cont TDesc xs (s1,4 + s2)

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


         ('D':'E':'L':'E':'T':'E':xs) -> \(s1,s2) ->  cont TDelete xs (s1,6 + s2)
         ('U':'P':'D':'A':'T':'E':xs) -> \(s1,s2) ->  cont TUpdate xs (s1,6 + s2)
         ('S':'E':'T':xs) -> \(s1,s2) -> cont TSet xs (s1,3 + s2)
         ('S':'E':'L':'E':'C':'T':xs) -> \(s1,s2) -> cont TSelect xs (s1,6 + s2)
         ('F':'R':'O':'M':xs) -> \(s1,s2) -> cont TFrom xs (s1,4 + s2)
         ('W':'H':'E':'R':'E':xs) -> \(s1,s2) -> cont TWhere xs (s1,5 + s2)
         ('G':'R':'O':'U':'P':' ':'B':'Y':xs) -> \(s1,s2) -> cont TGroupBy xs (s1,8 + s2)
         ('H':'A':'V':'I':'N':'G':xs) -> \(s1,s2) -> cont THaving xs (s1,6 + s2)
         ('O':'R':'D':'E':'R':' ':'B':'Y':xs) -> \(s1,s2) -> cont TGroupBy xs (s1,8 + s2)
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







# 1 "/usr/include/stdc-predef.h" 1 3 4

# 17 "/usr/include/stdc-predef.h" 3 4











































{-# LINE 7 "<command-line>" #-}
{-# LINE 1 "/usr/lib/ghc/include/ghcversion.h" #-}















{-# LINE 7 "<command-line>" #-}
{-# LINE 1 "/tmp/ghc8336_0/ghc_2.h" #-}
































































































































































































{-# LINE 7 "<command-line>" #-}
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
