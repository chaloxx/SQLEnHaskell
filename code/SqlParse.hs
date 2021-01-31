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
happyExpList = Happy_Data_Array.listArray (0,837) ([0,0,3840,0,512,61312,57344,1,0,0,960,0,128,0,0,0,0,0,0,0,0,0,0,0,0,0,28672,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,1,0,0,0,0,0,0,16384,0,0,0,0,0,0,49152,12487,2,4,0,0,0,128,0,0,0,0,0,0,0,128,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,1,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,128,0,0,0,0,0,0,1,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,64,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32,0,0,0,0,0,60,0,8,958,1920,0,0,0,0,0,4,0,0,0,0,0,244,2048,2,0,0,7,0,0,0,0,961,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,128,0,0,0,0,0,0,0,32,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,2,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,0,0,0,0,0,0,8192,0,3196,33,64,0,0,0,0,0,0,2,0,0,0,0,0,49152,4295,2,4,0,0,0,0,61440,33841,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,32,0,0,0,0,0,16,0,0,0,0,0,0,0,0,8192,0,0,0,0,0,8192,0,2048,0,0,0,0,0,2048,0,512,0,0,0,0,0,512,0,128,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,1008,0,0,0,0,0,3199,33,252,0,0,0,0,0,16384,0,0,0,0,0,0,0,0,0,0,0,0,0,15616,0,130,0,0,448,0,0,0,0,256,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,3845,0,0,0,0,0,0,0,12,0,0,0,0,0,0,0,3,0,0,0,0,0,0,49152,0,0,0,0,0,0,0,12288,0,0,0,0,0,0,0,3072,0,0,0,0,0,0,0,256,0,0,0,0,0,0,7936,2115,4096,0,0,0,0,0,51136,528,1024,0,0,0,0,0,12784,132,256,0,0,0,0,0,3196,33,64,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,0,0,16896,0,0,0,0,0,0,61440,4295,49154,15,0,0,0,0,0,1056,0,0,0,0,0,0,32512,8460,64512,0,0,0,0,0,0,66,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,12784,132,256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,64,16,512,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3072,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,508,0,0,0,0,0,8,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9088,0,0,0,0,0,2048,0,512,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,49408,3,0,0,0,0,0,0,0,0,0,0,0,0,25088,8192,0,0,0,0,0,0,0,7,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,128,0,0,0,0,0,0,64512,33841,61440,3,0,0,0,32,32512,8460,64512,0,0,0,0,0,0,512,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,12288,0,130,0,0,0,0,0,36352,32769,0,0,0,0,0,0,32768,31,0,0,0,0,0,0,0,8,64,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,0,0,0,0,49152,17183,8,63,0,0,0,512,61440,4295,49154,15,0,0,0,15360,0,130,0,0,448,0,0,0,0,256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,768,0,0,0,0,0,0,0,192,0,0,0,0,0,0,0,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,16,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,64,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16384,0,2048,0,0,0,0,0,0,256,0,0,0,0,0,0,0,6,0,0,0,0,0,0,0,0,48,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32,0,0,0,0,0,0,0,32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4032,0,0,0,0,0,12796,132,1008,0,0,0,0,0,3199,33,252,0,0,0,0,0,17183,8,63,0,0,0,0,61440,4295,49154,15,0,0,0,0,0,1024,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,64,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8192,0,0,1024,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1056,0,0,0,0,0,32768,1,16,0,0,0,0,0,24576,0,0,0,0,0,0,0,2,32768,0,0,0,0,0,0,0,0,0,128,0,0,0,0,0,2048,0,0,0,0,0,0,0,17183,8,63,0,0,0,0,49152,4295,49154,15,0,0,0,0,61440,33841,61440,3,0,0,0,0,31744,8460,64512,0,0,0,0,0,7936,2115,16128,0,0,0,0,0,51136,528,4032,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16384,0,0,0,0,0,0,24,256,0,0,0,0,0,0,6,0,0,0,0,0,0,32,0,8,0,0,0,0,0,0,0,0,2048,0,0,0,0,0,51136,528,4032,0,0,0,0,0,12784,132,1008,0,0,0,0,0,3196,33,252,0,0,0,0,0,0,0,0,0,0,0,0,61440,4295,49154,15,0,0,0,0,64512,33841,61440,3,0,0,0,0,0,256,0,0,0,0,0,7168,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,512,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,64,16,512,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,12288,0,0,0,0,0,0,0,3072,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,49152,1,64,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,2,16128,0,0,0,0,0,0,0,0,0,0,0,0,448,16384,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,128,0,0,0,0,0,32768,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,512,0,0,0,0,0,0,0,0,0,0,0,0,0,28672,0,16,0,0,0,0,0,0,0,12,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16,0,0,0,0,0,60,512,0,0,0,0,0,0,0,2048,0,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,192,0,0,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,14336,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,14,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	])

{-# NOINLINE happyExpListPerState #-}
happyExpListPerState st =
    token_strs_expected
  where token_strs = ["error","%dummy","%start_sql","SQL","MANUSERS","DML","Query","Query0","Query1","Query2","Query3","Query4","Query5","Query6","Query7","Query8","ArgS","Exp","IntExp","ArgF","Fields","BoolExpW","BoolExpH","ValueH","ValueW","Var","Value","Aggregate","Order","SomeJoin","TreeListArgs","ListArgs","ToUpdate","DDL","LCArgs","CArgs","FieldList","DelReferenceOption","UpdReferenceOption","TYPE","INSERT","DELETE","UPDATE","SELECT","FROM","';'","WHERE","GROUPBY","HAVING","ORDERBY","UNION","DIFF","INTERSECT","AND","OR","NE","GE","LE","'='","'>'","'<'","LIKE","EXIST","NOT","Sum","Count","Avg","Min","Max","LIMIT","Asc","Desc","ALL","'('","')'","','","AS","SET","FIELD","DISTINCT","IN","'.'","'+'","'-'","'*'","'/'","NEG","CTABLE","CBASE","DTABLE","DALLTABLE","DBASE","PKEY","USE","SHOWB","SHOWT","DATTIM","DAT","TIM","STR","NUM","NULL","INT","FLOAT","STRING","BOOL","DATETIME","DATE","TIME","SRC","CUSER","DUSER","SUSER","FKEY","REFERENCE","DEL","UPD","RESTRICTED","CASCADES","NULLIFIES","ON","JOIN","LEFT","RIGHT","INNER","%eof"]
        bit_start = st * 126
        bit_end = (st + 1) * 126
        read_bit = readArrayBit happyExpList
        bits = map read_bit [bit_start..bit_end - 1]
        bits_indexed = zip bits [0..125]
        token_strs_expected = concatMap f bits_indexed
        f (False, _) = []
        f (True, nr) = [token_strs !! nr]

action_0 (41) = happyShift action_6
action_0 (42) = happyShift action_7
action_0 (43) = happyShift action_8
action_0 (44) = happyShift action_9
action_0 (74) = happyShift action_10
action_0 (88) = happyShift action_14
action_0 (89) = happyShift action_15
action_0 (90) = happyShift action_16
action_0 (91) = happyShift action_17
action_0 (92) = happyShift action_18
action_0 (94) = happyShift action_19
action_0 (95) = happyShift action_20
action_0 (96) = happyShift action_21
action_0 (110) = happyShift action_22
action_0 (111) = happyShift action_23
action_0 (112) = happyShift action_24
action_0 (113) = happyShift action_25
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
action_1 (74) = happyShift action_10
action_1 (6) = happyGoto action_2
action_1 (7) = happyGoto action_3
action_1 (8) = happyGoto action_4
action_1 (9) = happyGoto action_5
action_1 _ = happyFail (happyExpListPerState 1)

action_2 _ = happyReduce_1

action_3 (51) = happyShift action_55
action_3 (52) = happyShift action_56
action_3 (53) = happyShift action_57
action_3 _ = happyReduce_13

action_4 _ = happyReduce_17

action_5 _ = happyReduce_18

action_6 (79) = happyShift action_54
action_6 _ = happyFail (happyExpListPerState 6)

action_7 (79) = happyShift action_53
action_7 _ = happyFail (happyExpListPerState 7)

action_8 (79) = happyShift action_52
action_8 _ = happyFail (happyExpListPerState 8)

action_9 (65) = happyShift action_41
action_9 (66) = happyShift action_42
action_9 (67) = happyShift action_43
action_9 (68) = happyShift action_44
action_9 (69) = happyShift action_45
action_9 (73) = happyShift action_46
action_9 (74) = happyShift action_47
action_9 (79) = happyShift action_48
action_9 (80) = happyShift action_49
action_9 (84) = happyShift action_50
action_9 (101) = happyShift action_51
action_9 (17) = happyGoto action_37
action_9 (18) = happyGoto action_38
action_9 (19) = happyGoto action_39
action_9 (28) = happyGoto action_40
action_9 _ = happyFail (happyExpListPerState 9)

action_10 (44) = happyShift action_9
action_10 (9) = happyGoto action_36
action_10 _ = happyFail (happyExpListPerState 10)

action_11 (46) = happyShift action_35
action_11 (126) = happyAccept
action_11 _ = happyFail (happyExpListPerState 11)

action_12 _ = happyReduce_3

action_13 _ = happyReduce_2

action_14 (79) = happyShift action_34
action_14 _ = happyFail (happyExpListPerState 14)

action_15 (79) = happyShift action_33
action_15 _ = happyFail (happyExpListPerState 15)

action_16 (79) = happyShift action_32
action_16 _ = happyFail (happyExpListPerState 16)

action_17 _ = happyReduce_122

action_18 (79) = happyShift action_31
action_18 _ = happyFail (happyExpListPerState 18)

action_19 (79) = happyShift action_30
action_19 _ = happyFail (happyExpListPerState 19)

action_20 _ = happyReduce_126

action_21 _ = happyReduce_127

action_22 (100) = happyShift action_29
action_22 _ = happyFail (happyExpListPerState 22)

action_23 (79) = happyShift action_28
action_23 _ = happyFail (happyExpListPerState 23)

action_24 (79) = happyShift action_27
action_24 _ = happyFail (happyExpListPerState 24)

action_25 (79) = happyShift action_26
action_25 _ = happyFail (happyExpListPerState 25)

action_26 (79) = happyShift action_103
action_26 _ = happyFail (happyExpListPerState 26)

action_27 (79) = happyShift action_102
action_27 _ = happyFail (happyExpListPerState 27)

action_28 (79) = happyShift action_101
action_28 _ = happyFail (happyExpListPerState 28)

action_29 _ = happyReduce_6

action_30 _ = happyReduce_125

action_31 _ = happyReduce_124

action_32 _ = happyReduce_121

action_33 _ = happyReduce_123

action_34 (74) = happyShift action_100
action_34 _ = happyFail (happyExpListPerState 34)

action_35 (41) = happyShift action_6
action_35 (42) = happyShift action_7
action_35 (43) = happyShift action_8
action_35 (44) = happyShift action_9
action_35 (74) = happyShift action_10
action_35 (88) = happyShift action_14
action_35 (89) = happyShift action_15
action_35 (90) = happyShift action_16
action_35 (91) = happyShift action_17
action_35 (92) = happyShift action_18
action_35 (94) = happyShift action_19
action_35 (95) = happyShift action_20
action_35 (96) = happyShift action_21
action_35 (110) = happyShift action_22
action_35 (111) = happyShift action_23
action_35 (112) = happyShift action_24
action_35 (113) = happyShift action_25
action_35 (4) = happyGoto action_99
action_35 (5) = happyGoto action_12
action_35 (6) = happyGoto action_2
action_35 (7) = happyGoto action_3
action_35 (8) = happyGoto action_4
action_35 (9) = happyGoto action_5
action_35 (34) = happyGoto action_13
action_35 _ = happyReduce_4

action_36 (75) = happyShift action_98
action_36 _ = happyFail (happyExpListPerState 36)

action_37 (45) = happyShift action_88
action_37 (47) = happyShift action_89
action_37 (48) = happyShift action_90
action_37 (49) = happyShift action_91
action_37 (50) = happyShift action_92
action_37 (70) = happyShift action_93
action_37 (76) = happyShift action_94
action_37 (123) = happyShift action_95
action_37 (124) = happyShift action_96
action_37 (125) = happyShift action_97
action_37 (10) = happyGoto action_80
action_37 (11) = happyGoto action_81
action_37 (12) = happyGoto action_82
action_37 (13) = happyGoto action_83
action_37 (14) = happyGoto action_84
action_37 (15) = happyGoto action_85
action_37 (16) = happyGoto action_86
action_37 (30) = happyGoto action_87
action_37 _ = happyReduce_36

action_38 (77) = happyShift action_75
action_38 (83) = happyShift action_76
action_38 (84) = happyShift action_77
action_38 (85) = happyShift action_78
action_38 (86) = happyShift action_79
action_38 _ = happyReduce_38

action_39 _ = happyReduce_44

action_40 _ = happyReduce_40

action_41 (74) = happyShift action_74
action_41 _ = happyFail (happyExpListPerState 41)

action_42 (74) = happyShift action_73
action_42 _ = happyFail (happyExpListPerState 42)

action_43 (74) = happyShift action_72
action_43 _ = happyFail (happyExpListPerState 43)

action_44 (74) = happyShift action_71
action_44 _ = happyFail (happyExpListPerState 44)

action_45 (74) = happyShift action_70
action_45 _ = happyFail (happyExpListPerState 45)

action_46 _ = happyReduce_45

action_47 (44) = happyShift action_9
action_47 (65) = happyShift action_41
action_47 (66) = happyShift action_42
action_47 (67) = happyShift action_43
action_47 (68) = happyShift action_44
action_47 (69) = happyShift action_45
action_47 (73) = happyShift action_46
action_47 (74) = happyShift action_47
action_47 (79) = happyShift action_48
action_47 (84) = happyShift action_50
action_47 (101) = happyShift action_51
action_47 (9) = happyGoto action_68
action_47 (18) = happyGoto action_69
action_47 (19) = happyGoto action_39
action_47 (28) = happyGoto action_40
action_47 _ = happyFail (happyExpListPerState 47)

action_48 (82) = happyShift action_67
action_48 _ = happyReduce_39

action_49 (65) = happyShift action_41
action_49 (66) = happyShift action_42
action_49 (67) = happyShift action_43
action_49 (68) = happyShift action_44
action_49 (69) = happyShift action_45
action_49 (73) = happyShift action_46
action_49 (74) = happyShift action_47
action_49 (79) = happyShift action_48
action_49 (84) = happyShift action_50
action_49 (101) = happyShift action_51
action_49 (17) = happyGoto action_66
action_49 (18) = happyGoto action_38
action_49 (19) = happyGoto action_39
action_49 (28) = happyGoto action_40
action_49 _ = happyFail (happyExpListPerState 49)

action_50 (65) = happyShift action_41
action_50 (66) = happyShift action_42
action_50 (67) = happyShift action_43
action_50 (68) = happyShift action_44
action_50 (69) = happyShift action_45
action_50 (73) = happyShift action_46
action_50 (74) = happyShift action_47
action_50 (79) = happyShift action_48
action_50 (84) = happyShift action_50
action_50 (101) = happyShift action_51
action_50 (18) = happyGoto action_65
action_50 (19) = happyGoto action_39
action_50 (28) = happyGoto action_40
action_50 _ = happyFail (happyExpListPerState 50)

action_51 _ = happyReduce_52

action_52 (78) = happyShift action_64
action_52 _ = happyFail (happyExpListPerState 52)

action_53 (47) = happyShift action_63
action_53 _ = happyFail (happyExpListPerState 53)

action_54 (74) = happyShift action_62
action_54 (31) = happyGoto action_61
action_54 _ = happyFail (happyExpListPerState 54)

action_55 (44) = happyShift action_9
action_55 (74) = happyShift action_10
action_55 (7) = happyGoto action_60
action_55 (8) = happyGoto action_4
action_55 (9) = happyGoto action_5
action_55 _ = happyFail (happyExpListPerState 55)

action_56 (44) = happyShift action_9
action_56 (74) = happyShift action_10
action_56 (7) = happyGoto action_59
action_56 (8) = happyGoto action_4
action_56 (9) = happyGoto action_5
action_56 _ = happyFail (happyExpListPerState 56)

action_57 (44) = happyShift action_9
action_57 (74) = happyShift action_10
action_57 (7) = happyGoto action_58
action_57 (8) = happyGoto action_4
action_57 (9) = happyGoto action_5
action_57 _ = happyFail (happyExpListPerState 57)

action_58 (51) = happyShift action_55
action_58 (52) = happyShift action_56
action_58 (53) = happyShift action_57
action_58 _ = happyReduce_16

action_59 (51) = happyShift action_55
action_59 (52) = happyShift action_56
action_59 (53) = happyShift action_57
action_59 _ = happyReduce_15

action_60 (51) = happyShift action_55
action_60 (52) = happyShift action_56
action_60 (53) = happyShift action_57
action_60 _ = happyReduce_14

action_61 (76) = happyShift action_170
action_61 _ = happyReduce_10

action_62 (97) = happyShift action_164
action_62 (98) = happyShift action_165
action_62 (99) = happyShift action_166
action_62 (100) = happyShift action_167
action_62 (101) = happyShift action_168
action_62 (102) = happyShift action_169
action_62 (32) = happyGoto action_163
action_62 _ = happyFail (happyExpListPerState 62)

action_63 (63) = happyShift action_135
action_63 (64) = happyShift action_136
action_63 (65) = happyShift action_41
action_63 (66) = happyShift action_42
action_63 (67) = happyShift action_43
action_63 (68) = happyShift action_44
action_63 (69) = happyShift action_45
action_63 (73) = happyShift action_46
action_63 (74) = happyShift action_137
action_63 (79) = happyShift action_124
action_63 (84) = happyShift action_50
action_63 (97) = happyShift action_125
action_63 (98) = happyShift action_126
action_63 (99) = happyShift action_127
action_63 (100) = happyShift action_128
action_63 (101) = happyShift action_51
action_63 (102) = happyShift action_129
action_63 (18) = happyGoto action_114
action_63 (19) = happyGoto action_115
action_63 (22) = happyGoto action_162
action_63 (25) = happyGoto action_132
action_63 (26) = happyGoto action_133
action_63 (27) = happyGoto action_134
action_63 (28) = happyGoto action_40
action_63 _ = happyFail (happyExpListPerState 63)

action_64 (79) = happyShift action_161
action_64 (33) = happyGoto action_160
action_64 _ = happyFail (happyExpListPerState 64)

action_65 _ = happyReduce_51

action_66 (45) = happyShift action_88
action_66 (47) = happyShift action_89
action_66 (48) = happyShift action_90
action_66 (49) = happyShift action_91
action_66 (50) = happyShift action_92
action_66 (70) = happyShift action_93
action_66 (76) = happyShift action_94
action_66 (123) = happyShift action_95
action_66 (124) = happyShift action_96
action_66 (125) = happyShift action_97
action_66 (10) = happyGoto action_159
action_66 (11) = happyGoto action_81
action_66 (12) = happyGoto action_82
action_66 (13) = happyGoto action_83
action_66 (14) = happyGoto action_84
action_66 (15) = happyGoto action_85
action_66 (16) = happyGoto action_86
action_66 (30) = happyGoto action_87
action_66 _ = happyReduce_36

action_67 (79) = happyShift action_158
action_67 _ = happyFail (happyExpListPerState 67)

action_68 (75) = happyShift action_157
action_68 _ = happyFail (happyExpListPerState 68)

action_69 (75) = happyShift action_156
action_69 (77) = happyShift action_75
action_69 (83) = happyShift action_76
action_69 (84) = happyShift action_77
action_69 (85) = happyShift action_78
action_69 (86) = happyShift action_79
action_69 _ = happyFail (happyExpListPerState 69)

action_70 (79) = happyShift action_146
action_70 (80) = happyShift action_155
action_70 (26) = happyGoto action_154
action_70 _ = happyFail (happyExpListPerState 70)

action_71 (79) = happyShift action_146
action_71 (80) = happyShift action_153
action_71 (26) = happyGoto action_152
action_71 _ = happyFail (happyExpListPerState 71)

action_72 (79) = happyShift action_146
action_72 (80) = happyShift action_151
action_72 (26) = happyGoto action_150
action_72 _ = happyFail (happyExpListPerState 72)

action_73 (79) = happyShift action_146
action_73 (80) = happyShift action_149
action_73 (26) = happyGoto action_148
action_73 _ = happyFail (happyExpListPerState 73)

action_74 (79) = happyShift action_146
action_74 (80) = happyShift action_147
action_74 (26) = happyGoto action_145
action_74 _ = happyFail (happyExpListPerState 74)

action_75 (79) = happyShift action_144
action_75 _ = happyFail (happyExpListPerState 75)

action_76 (65) = happyShift action_41
action_76 (66) = happyShift action_42
action_76 (67) = happyShift action_43
action_76 (68) = happyShift action_44
action_76 (69) = happyShift action_45
action_76 (73) = happyShift action_46
action_76 (74) = happyShift action_47
action_76 (79) = happyShift action_48
action_76 (84) = happyShift action_50
action_76 (101) = happyShift action_51
action_76 (18) = happyGoto action_143
action_76 (19) = happyGoto action_39
action_76 (28) = happyGoto action_40
action_76 _ = happyFail (happyExpListPerState 76)

action_77 (65) = happyShift action_41
action_77 (66) = happyShift action_42
action_77 (67) = happyShift action_43
action_77 (68) = happyShift action_44
action_77 (69) = happyShift action_45
action_77 (73) = happyShift action_46
action_77 (74) = happyShift action_47
action_77 (79) = happyShift action_48
action_77 (84) = happyShift action_50
action_77 (101) = happyShift action_51
action_77 (18) = happyGoto action_142
action_77 (19) = happyGoto action_39
action_77 (28) = happyGoto action_40
action_77 _ = happyFail (happyExpListPerState 77)

action_78 (65) = happyShift action_41
action_78 (66) = happyShift action_42
action_78 (67) = happyShift action_43
action_78 (68) = happyShift action_44
action_78 (69) = happyShift action_45
action_78 (73) = happyShift action_46
action_78 (74) = happyShift action_47
action_78 (79) = happyShift action_48
action_78 (84) = happyShift action_50
action_78 (101) = happyShift action_51
action_78 (18) = happyGoto action_141
action_78 (19) = happyGoto action_39
action_78 (28) = happyGoto action_40
action_78 _ = happyFail (happyExpListPerState 78)

action_79 (65) = happyShift action_41
action_79 (66) = happyShift action_42
action_79 (67) = happyShift action_43
action_79 (68) = happyShift action_44
action_79 (69) = happyShift action_45
action_79 (73) = happyShift action_46
action_79 (74) = happyShift action_47
action_79 (79) = happyShift action_48
action_79 (84) = happyShift action_50
action_79 (101) = happyShift action_51
action_79 (18) = happyGoto action_140
action_79 (19) = happyGoto action_39
action_79 (28) = happyGoto action_40
action_79 _ = happyFail (happyExpListPerState 79)

action_80 _ = happyReduce_20

action_81 _ = happyReduce_23

action_82 _ = happyReduce_25

action_83 _ = happyReduce_27

action_84 _ = happyReduce_29

action_85 _ = happyReduce_31

action_86 _ = happyReduce_34

action_87 (122) = happyShift action_139
action_87 _ = happyFail (happyExpListPerState 87)

action_88 (74) = happyShift action_112
action_88 (79) = happyShift action_113
action_88 (20) = happyGoto action_138
action_88 _ = happyFail (happyExpListPerState 88)

action_89 (63) = happyShift action_135
action_89 (64) = happyShift action_136
action_89 (65) = happyShift action_41
action_89 (66) = happyShift action_42
action_89 (67) = happyShift action_43
action_89 (68) = happyShift action_44
action_89 (69) = happyShift action_45
action_89 (73) = happyShift action_46
action_89 (74) = happyShift action_137
action_89 (79) = happyShift action_124
action_89 (84) = happyShift action_50
action_89 (97) = happyShift action_125
action_89 (98) = happyShift action_126
action_89 (99) = happyShift action_127
action_89 (100) = happyShift action_128
action_89 (101) = happyShift action_51
action_89 (102) = happyShift action_129
action_89 (18) = happyGoto action_114
action_89 (19) = happyGoto action_115
action_89 (22) = happyGoto action_131
action_89 (25) = happyGoto action_132
action_89 (26) = happyGoto action_133
action_89 (27) = happyGoto action_134
action_89 (28) = happyGoto action_40
action_89 _ = happyFail (happyExpListPerState 89)

action_90 (74) = happyShift action_112
action_90 (79) = happyShift action_113
action_90 (20) = happyGoto action_130
action_90 _ = happyFail (happyExpListPerState 90)

action_91 (63) = happyShift action_121
action_91 (64) = happyShift action_122
action_91 (65) = happyShift action_41
action_91 (66) = happyShift action_42
action_91 (67) = happyShift action_43
action_91 (68) = happyShift action_44
action_91 (69) = happyShift action_45
action_91 (73) = happyShift action_46
action_91 (74) = happyShift action_123
action_91 (79) = happyShift action_124
action_91 (84) = happyShift action_50
action_91 (97) = happyShift action_125
action_91 (98) = happyShift action_126
action_91 (99) = happyShift action_127
action_91 (100) = happyShift action_128
action_91 (101) = happyShift action_51
action_91 (102) = happyShift action_129
action_91 (18) = happyGoto action_114
action_91 (19) = happyGoto action_115
action_91 (23) = happyGoto action_116
action_91 (24) = happyGoto action_117
action_91 (26) = happyGoto action_118
action_91 (27) = happyGoto action_119
action_91 (28) = happyGoto action_120
action_91 _ = happyFail (happyExpListPerState 91)

action_92 (74) = happyShift action_112
action_92 (79) = happyShift action_113
action_92 (20) = happyGoto action_111
action_92 _ = happyFail (happyExpListPerState 92)

action_93 (101) = happyShift action_110
action_93 _ = happyFail (happyExpListPerState 93)

action_94 (65) = happyShift action_41
action_94 (66) = happyShift action_42
action_94 (67) = happyShift action_43
action_94 (68) = happyShift action_44
action_94 (69) = happyShift action_45
action_94 (73) = happyShift action_46
action_94 (74) = happyShift action_47
action_94 (79) = happyShift action_48
action_94 (84) = happyShift action_50
action_94 (101) = happyShift action_51
action_94 (17) = happyGoto action_109
action_94 (18) = happyGoto action_38
action_94 (19) = happyGoto action_39
action_94 (28) = happyGoto action_40
action_94 _ = happyFail (happyExpListPerState 94)

action_95 _ = happyReduce_107

action_96 _ = happyReduce_108

action_97 _ = happyReduce_106

action_98 _ = happyReduce_19

action_99 (46) = happyShift action_35
action_99 _ = happyReduce_5

action_100 (79) = happyShift action_106
action_100 (93) = happyShift action_107
action_100 (114) = happyShift action_108
action_100 (35) = happyGoto action_104
action_100 (36) = happyGoto action_105
action_100 _ = happyFail (happyExpListPerState 100)

action_101 _ = happyReduce_7

action_102 _ = happyReduce_8

action_103 _ = happyReduce_9

action_104 (75) = happyShift action_235
action_104 (76) = happyShift action_236
action_104 _ = happyFail (happyExpListPerState 104)

action_105 _ = happyReduce_128

action_106 (103) = happyShift action_228
action_106 (104) = happyShift action_229
action_106 (105) = happyShift action_230
action_106 (106) = happyShift action_231
action_106 (107) = happyShift action_232
action_106 (108) = happyShift action_233
action_106 (109) = happyShift action_234
action_106 (40) = happyGoto action_227
action_106 _ = happyFail (happyExpListPerState 106)

action_107 (74) = happyShift action_226
action_107 _ = happyFail (happyExpListPerState 107)

action_108 (74) = happyShift action_225
action_108 _ = happyFail (happyExpListPerState 108)

action_109 (76) = happyShift action_94
action_109 _ = happyReduce_37

action_110 _ = happyReduce_35

action_111 (70) = happyShift action_93
action_111 (71) = happyShift action_223
action_111 (72) = happyShift action_224
action_111 (76) = happyShift action_194
action_111 (16) = happyGoto action_221
action_111 (29) = happyGoto action_222
action_111 _ = happyReduce_36

action_112 (44) = happyShift action_9
action_112 (74) = happyShift action_10
action_112 (7) = happyGoto action_220
action_112 (8) = happyGoto action_4
action_112 (9) = happyGoto action_5
action_112 _ = happyFail (happyExpListPerState 112)

action_113 (77) = happyShift action_219
action_113 _ = happyReduce_53

action_114 (77) = happyShift action_75
action_114 (83) = happyShift action_76
action_114 (84) = happyShift action_77
action_114 (85) = happyShift action_78
action_114 (86) = happyShift action_79
action_114 _ = happyFail (happyExpListPerState 114)

action_115 (75) = happyReduce_92
action_115 (77) = happyReduce_44
action_115 (83) = happyReduce_44
action_115 (84) = happyReduce_44
action_115 (85) = happyReduce_44
action_115 (86) = happyReduce_44
action_115 _ = happyReduce_92

action_116 (50) = happyShift action_92
action_116 (54) = happyShift action_217
action_116 (55) = happyShift action_218
action_116 (70) = happyShift action_93
action_116 (15) = happyGoto action_216
action_116 (16) = happyGoto action_86
action_116 _ = happyReduce_36

action_117 (59) = happyShift action_213
action_117 (60) = happyShift action_214
action_117 (61) = happyShift action_215
action_117 _ = happyFail (happyExpListPerState 117)

action_118 (62) = happyShift action_212
action_118 _ = happyFail (happyExpListPerState 118)

action_119 _ = happyReduce_82

action_120 (75) = happyReduce_83
action_120 (77) = happyReduce_40
action_120 (83) = happyReduce_40
action_120 (84) = happyReduce_40
action_120 (85) = happyReduce_40
action_120 (86) = happyReduce_40
action_120 _ = happyReduce_83

action_121 (74) = happyShift action_211
action_121 _ = happyFail (happyExpListPerState 121)

action_122 (63) = happyShift action_121
action_122 (64) = happyShift action_122
action_122 (65) = happyShift action_41
action_122 (66) = happyShift action_42
action_122 (67) = happyShift action_43
action_122 (68) = happyShift action_44
action_122 (69) = happyShift action_45
action_122 (73) = happyShift action_46
action_122 (74) = happyShift action_123
action_122 (79) = happyShift action_124
action_122 (84) = happyShift action_50
action_122 (97) = happyShift action_125
action_122 (98) = happyShift action_126
action_122 (99) = happyShift action_127
action_122 (100) = happyShift action_128
action_122 (101) = happyShift action_51
action_122 (102) = happyShift action_129
action_122 (18) = happyGoto action_114
action_122 (19) = happyGoto action_115
action_122 (23) = happyGoto action_210
action_122 (24) = happyGoto action_117
action_122 (26) = happyGoto action_118
action_122 (27) = happyGoto action_119
action_122 (28) = happyGoto action_120
action_122 _ = happyFail (happyExpListPerState 122)

action_123 (44) = happyShift action_9
action_123 (63) = happyShift action_121
action_123 (64) = happyShift action_122
action_123 (65) = happyShift action_41
action_123 (66) = happyShift action_42
action_123 (67) = happyShift action_43
action_123 (68) = happyShift action_44
action_123 (69) = happyShift action_45
action_123 (73) = happyShift action_46
action_123 (74) = happyShift action_123
action_123 (79) = happyShift action_124
action_123 (84) = happyShift action_50
action_123 (97) = happyShift action_125
action_123 (98) = happyShift action_126
action_123 (99) = happyShift action_127
action_123 (100) = happyShift action_128
action_123 (101) = happyShift action_51
action_123 (102) = happyShift action_129
action_123 (9) = happyGoto action_68
action_123 (18) = happyGoto action_69
action_123 (19) = happyGoto action_115
action_123 (23) = happyGoto action_209
action_123 (24) = happyGoto action_117
action_123 (26) = happyGoto action_118
action_123 (27) = happyGoto action_119
action_123 (28) = happyGoto action_120
action_123 _ = happyFail (happyExpListPerState 123)

action_124 (75) = happyReduce_86
action_124 (77) = happyReduce_39
action_124 (82) = happyShift action_208
action_124 (83) = happyReduce_39
action_124 (84) = happyReduce_39
action_124 (85) = happyReduce_39
action_124 (86) = happyReduce_39
action_124 _ = happyReduce_86

action_125 _ = happyReduce_89

action_126 _ = happyReduce_90

action_127 _ = happyReduce_91

action_128 _ = happyReduce_88

action_129 _ = happyReduce_93

action_130 (49) = happyShift action_91
action_130 (50) = happyShift action_92
action_130 (70) = happyShift action_93
action_130 (76) = happyShift action_194
action_130 (14) = happyGoto action_207
action_130 (15) = happyGoto action_85
action_130 (16) = happyGoto action_86
action_130 _ = happyReduce_36

action_131 (48) = happyShift action_90
action_131 (49) = happyShift action_91
action_131 (50) = happyShift action_92
action_131 (54) = happyShift action_174
action_131 (55) = happyShift action_175
action_131 (70) = happyShift action_93
action_131 (13) = happyGoto action_206
action_131 (14) = happyGoto action_84
action_131 (15) = happyGoto action_85
action_131 (16) = happyGoto action_86
action_131 _ = happyReduce_36

action_132 (56) = happyShift action_200
action_132 (57) = happyShift action_201
action_132 (58) = happyShift action_202
action_132 (59) = happyShift action_203
action_132 (60) = happyShift action_204
action_132 (61) = happyShift action_205
action_132 _ = happyFail (happyExpListPerState 132)

action_133 (62) = happyShift action_198
action_133 (81) = happyShift action_199
action_133 _ = happyReduce_84

action_134 _ = happyReduce_85

action_135 (74) = happyShift action_197
action_135 _ = happyFail (happyExpListPerState 135)

action_136 (63) = happyShift action_135
action_136 (64) = happyShift action_136
action_136 (65) = happyShift action_41
action_136 (66) = happyShift action_42
action_136 (67) = happyShift action_43
action_136 (68) = happyShift action_44
action_136 (69) = happyShift action_45
action_136 (73) = happyShift action_46
action_136 (74) = happyShift action_137
action_136 (79) = happyShift action_124
action_136 (84) = happyShift action_50
action_136 (97) = happyShift action_125
action_136 (98) = happyShift action_126
action_136 (99) = happyShift action_127
action_136 (100) = happyShift action_128
action_136 (101) = happyShift action_51
action_136 (102) = happyShift action_129
action_136 (18) = happyGoto action_114
action_136 (19) = happyGoto action_115
action_136 (22) = happyGoto action_196
action_136 (25) = happyGoto action_132
action_136 (26) = happyGoto action_133
action_136 (27) = happyGoto action_134
action_136 (28) = happyGoto action_40
action_136 _ = happyFail (happyExpListPerState 136)

action_137 (44) = happyShift action_9
action_137 (63) = happyShift action_135
action_137 (64) = happyShift action_136
action_137 (65) = happyShift action_41
action_137 (66) = happyShift action_42
action_137 (67) = happyShift action_43
action_137 (68) = happyShift action_44
action_137 (69) = happyShift action_45
action_137 (73) = happyShift action_46
action_137 (74) = happyShift action_137
action_137 (79) = happyShift action_124
action_137 (84) = happyShift action_50
action_137 (97) = happyShift action_125
action_137 (98) = happyShift action_126
action_137 (99) = happyShift action_127
action_137 (100) = happyShift action_128
action_137 (101) = happyShift action_51
action_137 (102) = happyShift action_129
action_137 (9) = happyGoto action_68
action_137 (18) = happyGoto action_69
action_137 (19) = happyGoto action_115
action_137 (22) = happyGoto action_195
action_137 (25) = happyGoto action_132
action_137 (26) = happyGoto action_133
action_137 (27) = happyGoto action_134
action_137 (28) = happyGoto action_40
action_137 _ = happyFail (happyExpListPerState 137)

action_138 (47) = happyShift action_89
action_138 (48) = happyShift action_90
action_138 (49) = happyShift action_91
action_138 (50) = happyShift action_92
action_138 (70) = happyShift action_93
action_138 (76) = happyShift action_194
action_138 (123) = happyShift action_95
action_138 (124) = happyShift action_96
action_138 (125) = happyShift action_97
action_138 (11) = happyGoto action_193
action_138 (12) = happyGoto action_82
action_138 (13) = happyGoto action_83
action_138 (14) = happyGoto action_84
action_138 (15) = happyGoto action_85
action_138 (16) = happyGoto action_86
action_138 (30) = happyGoto action_87
action_138 _ = happyReduce_36

action_139 (79) = happyShift action_192
action_139 (37) = happyGoto action_191
action_139 _ = happyFail (happyExpListPerState 139)

action_140 _ = happyReduce_49

action_141 _ = happyReduce_48

action_142 (85) = happyShift action_78
action_142 (86) = happyShift action_79
action_142 _ = happyReduce_47

action_143 (85) = happyShift action_78
action_143 (86) = happyShift action_79
action_143 _ = happyReduce_46

action_144 _ = happyReduce_41

action_145 (75) = happyShift action_190
action_145 _ = happyFail (happyExpListPerState 145)

action_146 (82) = happyShift action_189
action_146 _ = happyReduce_86

action_147 (79) = happyShift action_146
action_147 (26) = happyGoto action_188
action_147 _ = happyFail (happyExpListPerState 147)

action_148 (75) = happyShift action_187
action_148 _ = happyFail (happyExpListPerState 148)

action_149 (79) = happyShift action_146
action_149 (26) = happyGoto action_186
action_149 _ = happyFail (happyExpListPerState 149)

action_150 (75) = happyShift action_185
action_150 _ = happyFail (happyExpListPerState 150)

action_151 (79) = happyShift action_146
action_151 (26) = happyGoto action_184
action_151 _ = happyFail (happyExpListPerState 151)

action_152 (75) = happyShift action_183
action_152 _ = happyFail (happyExpListPerState 152)

action_153 (79) = happyShift action_146
action_153 (26) = happyGoto action_182
action_153 _ = happyFail (happyExpListPerState 153)

action_154 (75) = happyShift action_181
action_154 _ = happyFail (happyExpListPerState 154)

action_155 (79) = happyShift action_146
action_155 (26) = happyGoto action_180
action_155 _ = happyFail (happyExpListPerState 155)

action_156 _ = happyReduce_50

action_157 (77) = happyShift action_179
action_157 _ = happyFail (happyExpListPerState 157)

action_158 _ = happyReduce_43

action_159 _ = happyReduce_21

action_160 (47) = happyShift action_177
action_160 (76) = happyShift action_178
action_160 _ = happyFail (happyExpListPerState 160)

action_161 (59) = happyShift action_176
action_161 _ = happyFail (happyExpListPerState 161)

action_162 (54) = happyShift action_174
action_162 (55) = happyShift action_175
action_162 _ = happyReduce_11

action_163 (75) = happyShift action_172
action_163 (76) = happyShift action_173
action_163 _ = happyFail (happyExpListPerState 163)

action_164 _ = happyReduce_113

action_165 _ = happyReduce_114

action_166 _ = happyReduce_115

action_167 _ = happyReduce_111

action_168 _ = happyReduce_112

action_169 _ = happyReduce_116

action_170 (74) = happyShift action_62
action_170 (31) = happyGoto action_171
action_170 _ = happyFail (happyExpListPerState 170)

action_171 (76) = happyShift action_170
action_171 _ = happyReduce_110

action_172 _ = happyReduce_109

action_173 (97) = happyShift action_164
action_173 (98) = happyShift action_165
action_173 (99) = happyShift action_166
action_173 (100) = happyShift action_167
action_173 (101) = happyShift action_168
action_173 (102) = happyShift action_169
action_173 (32) = happyGoto action_279
action_173 _ = happyFail (happyExpListPerState 173)

action_174 (63) = happyShift action_135
action_174 (64) = happyShift action_136
action_174 (65) = happyShift action_41
action_174 (66) = happyShift action_42
action_174 (67) = happyShift action_43
action_174 (68) = happyShift action_44
action_174 (69) = happyShift action_45
action_174 (73) = happyShift action_46
action_174 (74) = happyShift action_137
action_174 (79) = happyShift action_124
action_174 (84) = happyShift action_50
action_174 (97) = happyShift action_125
action_174 (98) = happyShift action_126
action_174 (99) = happyShift action_127
action_174 (100) = happyShift action_128
action_174 (101) = happyShift action_51
action_174 (102) = happyShift action_129
action_174 (18) = happyGoto action_114
action_174 (19) = happyGoto action_115
action_174 (22) = happyGoto action_278
action_174 (25) = happyGoto action_132
action_174 (26) = happyGoto action_133
action_174 (27) = happyGoto action_134
action_174 (28) = happyGoto action_40
action_174 _ = happyFail (happyExpListPerState 174)

action_175 (63) = happyShift action_135
action_175 (64) = happyShift action_136
action_175 (65) = happyShift action_41
action_175 (66) = happyShift action_42
action_175 (67) = happyShift action_43
action_175 (68) = happyShift action_44
action_175 (69) = happyShift action_45
action_175 (73) = happyShift action_46
action_175 (74) = happyShift action_137
action_175 (79) = happyShift action_124
action_175 (84) = happyShift action_50
action_175 (97) = happyShift action_125
action_175 (98) = happyShift action_126
action_175 (99) = happyShift action_127
action_175 (100) = happyShift action_128
action_175 (101) = happyShift action_51
action_175 (102) = happyShift action_129
action_175 (18) = happyGoto action_114
action_175 (19) = happyGoto action_115
action_175 (22) = happyGoto action_277
action_175 (25) = happyGoto action_132
action_175 (26) = happyGoto action_133
action_175 (27) = happyGoto action_134
action_175 (28) = happyGoto action_40
action_175 _ = happyFail (happyExpListPerState 175)

action_176 (65) = happyShift action_41
action_176 (66) = happyShift action_42
action_176 (67) = happyShift action_43
action_176 (68) = happyShift action_44
action_176 (69) = happyShift action_45
action_176 (73) = happyShift action_46
action_176 (74) = happyShift action_47
action_176 (79) = happyShift action_48
action_176 (84) = happyShift action_50
action_176 (97) = happyShift action_125
action_176 (98) = happyShift action_126
action_176 (99) = happyShift action_127
action_176 (100) = happyShift action_128
action_176 (101) = happyShift action_51
action_176 (102) = happyShift action_129
action_176 (18) = happyGoto action_114
action_176 (19) = happyGoto action_115
action_176 (27) = happyGoto action_276
action_176 (28) = happyGoto action_40
action_176 _ = happyFail (happyExpListPerState 176)

action_177 (63) = happyShift action_135
action_177 (64) = happyShift action_136
action_177 (65) = happyShift action_41
action_177 (66) = happyShift action_42
action_177 (67) = happyShift action_43
action_177 (68) = happyShift action_44
action_177 (69) = happyShift action_45
action_177 (73) = happyShift action_46
action_177 (74) = happyShift action_137
action_177 (79) = happyShift action_124
action_177 (84) = happyShift action_50
action_177 (97) = happyShift action_125
action_177 (98) = happyShift action_126
action_177 (99) = happyShift action_127
action_177 (100) = happyShift action_128
action_177 (101) = happyShift action_51
action_177 (102) = happyShift action_129
action_177 (18) = happyGoto action_114
action_177 (19) = happyGoto action_115
action_177 (22) = happyGoto action_275
action_177 (25) = happyGoto action_132
action_177 (26) = happyGoto action_133
action_177 (27) = happyGoto action_134
action_177 (28) = happyGoto action_40
action_177 _ = happyFail (happyExpListPerState 177)

action_178 (79) = happyShift action_161
action_178 (33) = happyGoto action_274
action_178 _ = happyFail (happyExpListPerState 178)

action_179 (79) = happyShift action_273
action_179 _ = happyFail (happyExpListPerState 179)

action_180 (75) = happyShift action_272
action_180 _ = happyFail (happyExpListPerState 180)

action_181 _ = happyReduce_102

action_182 (75) = happyShift action_271
action_182 _ = happyFail (happyExpListPerState 182)

action_183 _ = happyReduce_100

action_184 (75) = happyShift action_270
action_184 _ = happyFail (happyExpListPerState 184)

action_185 _ = happyReduce_98

action_186 (75) = happyShift action_269
action_186 _ = happyFail (happyExpListPerState 186)

action_187 _ = happyReduce_96

action_188 (75) = happyShift action_268
action_188 _ = happyFail (happyExpListPerState 188)

action_189 (79) = happyShift action_267
action_189 _ = happyFail (happyExpListPerState 189)

action_190 _ = happyReduce_94

action_191 (76) = happyShift action_265
action_191 (121) = happyShift action_266
action_191 _ = happyFail (happyExpListPerState 191)

action_192 _ = happyReduce_134

action_193 _ = happyReduce_22

action_194 (74) = happyShift action_112
action_194 (79) = happyShift action_113
action_194 (20) = happyGoto action_264
action_194 _ = happyFail (happyExpListPerState 194)

action_195 (54) = happyShift action_174
action_195 (55) = happyShift action_175
action_195 (75) = happyShift action_263
action_195 _ = happyFail (happyExpListPerState 195)

action_196 (54) = happyShift action_174
action_196 (55) = happyShift action_175
action_196 _ = happyReduce_68

action_197 (44) = happyShift action_9
action_197 (74) = happyShift action_10
action_197 (7) = happyGoto action_262
action_197 (8) = happyGoto action_4
action_197 (9) = happyGoto action_5
action_197 _ = happyFail (happyExpListPerState 197)

action_198 (100) = happyShift action_261
action_198 _ = happyFail (happyExpListPerState 198)

action_199 (74) = happyShift action_260
action_199 _ = happyFail (happyExpListPerState 199)

action_200 (65) = happyShift action_41
action_200 (66) = happyShift action_42
action_200 (67) = happyShift action_43
action_200 (68) = happyShift action_44
action_200 (69) = happyShift action_45
action_200 (73) = happyShift action_46
action_200 (74) = happyShift action_47
action_200 (79) = happyShift action_124
action_200 (84) = happyShift action_50
action_200 (97) = happyShift action_125
action_200 (98) = happyShift action_126
action_200 (99) = happyShift action_127
action_200 (100) = happyShift action_128
action_200 (101) = happyShift action_51
action_200 (102) = happyShift action_129
action_200 (18) = happyGoto action_114
action_200 (19) = happyGoto action_115
action_200 (25) = happyGoto action_259
action_200 (26) = happyGoto action_254
action_200 (27) = happyGoto action_134
action_200 (28) = happyGoto action_40
action_200 _ = happyFail (happyExpListPerState 200)

action_201 (65) = happyShift action_41
action_201 (66) = happyShift action_42
action_201 (67) = happyShift action_43
action_201 (68) = happyShift action_44
action_201 (69) = happyShift action_45
action_201 (73) = happyShift action_46
action_201 (74) = happyShift action_47
action_201 (79) = happyShift action_124
action_201 (84) = happyShift action_50
action_201 (97) = happyShift action_125
action_201 (98) = happyShift action_126
action_201 (99) = happyShift action_127
action_201 (100) = happyShift action_128
action_201 (101) = happyShift action_51
action_201 (102) = happyShift action_129
action_201 (18) = happyGoto action_114
action_201 (19) = happyGoto action_115
action_201 (25) = happyGoto action_258
action_201 (26) = happyGoto action_254
action_201 (27) = happyGoto action_134
action_201 (28) = happyGoto action_40
action_201 _ = happyFail (happyExpListPerState 201)

action_202 (65) = happyShift action_41
action_202 (66) = happyShift action_42
action_202 (67) = happyShift action_43
action_202 (68) = happyShift action_44
action_202 (69) = happyShift action_45
action_202 (73) = happyShift action_46
action_202 (74) = happyShift action_47
action_202 (79) = happyShift action_124
action_202 (84) = happyShift action_50
action_202 (97) = happyShift action_125
action_202 (98) = happyShift action_126
action_202 (99) = happyShift action_127
action_202 (100) = happyShift action_128
action_202 (101) = happyShift action_51
action_202 (102) = happyShift action_129
action_202 (18) = happyGoto action_114
action_202 (19) = happyGoto action_115
action_202 (25) = happyGoto action_257
action_202 (26) = happyGoto action_254
action_202 (27) = happyGoto action_134
action_202 (28) = happyGoto action_40
action_202 _ = happyFail (happyExpListPerState 202)

action_203 (65) = happyShift action_41
action_203 (66) = happyShift action_42
action_203 (67) = happyShift action_43
action_203 (68) = happyShift action_44
action_203 (69) = happyShift action_45
action_203 (73) = happyShift action_46
action_203 (74) = happyShift action_47
action_203 (79) = happyShift action_124
action_203 (84) = happyShift action_50
action_203 (97) = happyShift action_125
action_203 (98) = happyShift action_126
action_203 (99) = happyShift action_127
action_203 (100) = happyShift action_128
action_203 (101) = happyShift action_51
action_203 (102) = happyShift action_129
action_203 (18) = happyGoto action_114
action_203 (19) = happyGoto action_115
action_203 (25) = happyGoto action_256
action_203 (26) = happyGoto action_254
action_203 (27) = happyGoto action_134
action_203 (28) = happyGoto action_40
action_203 _ = happyFail (happyExpListPerState 203)

action_204 (65) = happyShift action_41
action_204 (66) = happyShift action_42
action_204 (67) = happyShift action_43
action_204 (68) = happyShift action_44
action_204 (69) = happyShift action_45
action_204 (73) = happyShift action_46
action_204 (74) = happyShift action_47
action_204 (79) = happyShift action_124
action_204 (84) = happyShift action_50
action_204 (97) = happyShift action_125
action_204 (98) = happyShift action_126
action_204 (99) = happyShift action_127
action_204 (100) = happyShift action_128
action_204 (101) = happyShift action_51
action_204 (102) = happyShift action_129
action_204 (18) = happyGoto action_114
action_204 (19) = happyGoto action_115
action_204 (25) = happyGoto action_255
action_204 (26) = happyGoto action_254
action_204 (27) = happyGoto action_134
action_204 (28) = happyGoto action_40
action_204 _ = happyFail (happyExpListPerState 204)

action_205 (65) = happyShift action_41
action_205 (66) = happyShift action_42
action_205 (67) = happyShift action_43
action_205 (68) = happyShift action_44
action_205 (69) = happyShift action_45
action_205 (73) = happyShift action_46
action_205 (74) = happyShift action_47
action_205 (79) = happyShift action_124
action_205 (84) = happyShift action_50
action_205 (97) = happyShift action_125
action_205 (98) = happyShift action_126
action_205 (99) = happyShift action_127
action_205 (100) = happyShift action_128
action_205 (101) = happyShift action_51
action_205 (102) = happyShift action_129
action_205 (18) = happyGoto action_114
action_205 (19) = happyGoto action_115
action_205 (25) = happyGoto action_253
action_205 (26) = happyGoto action_254
action_205 (27) = happyGoto action_134
action_205 (28) = happyGoto action_40
action_205 _ = happyFail (happyExpListPerState 205)

action_206 _ = happyReduce_26

action_207 _ = happyReduce_28

action_208 (79) = happyShift action_252
action_208 _ = happyFail (happyExpListPerState 208)

action_209 (54) = happyShift action_217
action_209 (55) = happyShift action_218
action_209 (75) = happyShift action_251
action_209 _ = happyFail (happyExpListPerState 209)

action_210 (54) = happyShift action_217
action_210 (55) = happyShift action_218
action_210 _ = happyReduce_79

action_211 (44) = happyShift action_9
action_211 (74) = happyShift action_10
action_211 (7) = happyGoto action_250
action_211 (8) = happyGoto action_4
action_211 (9) = happyGoto action_5
action_211 _ = happyFail (happyExpListPerState 211)

action_212 (100) = happyShift action_249
action_212 _ = happyFail (happyExpListPerState 212)

action_213 (65) = happyShift action_41
action_213 (66) = happyShift action_42
action_213 (67) = happyShift action_43
action_213 (68) = happyShift action_44
action_213 (69) = happyShift action_45
action_213 (73) = happyShift action_46
action_213 (74) = happyShift action_47
action_213 (79) = happyShift action_48
action_213 (84) = happyShift action_50
action_213 (97) = happyShift action_125
action_213 (98) = happyShift action_126
action_213 (99) = happyShift action_127
action_213 (100) = happyShift action_128
action_213 (101) = happyShift action_51
action_213 (102) = happyShift action_129
action_213 (18) = happyGoto action_114
action_213 (19) = happyGoto action_115
action_213 (24) = happyGoto action_248
action_213 (27) = happyGoto action_119
action_213 (28) = happyGoto action_120
action_213 _ = happyFail (happyExpListPerState 213)

action_214 (65) = happyShift action_41
action_214 (66) = happyShift action_42
action_214 (67) = happyShift action_43
action_214 (68) = happyShift action_44
action_214 (69) = happyShift action_45
action_214 (73) = happyShift action_46
action_214 (74) = happyShift action_47
action_214 (79) = happyShift action_48
action_214 (84) = happyShift action_50
action_214 (97) = happyShift action_125
action_214 (98) = happyShift action_126
action_214 (99) = happyShift action_127
action_214 (100) = happyShift action_128
action_214 (101) = happyShift action_51
action_214 (102) = happyShift action_129
action_214 (18) = happyGoto action_114
action_214 (19) = happyGoto action_115
action_214 (24) = happyGoto action_247
action_214 (27) = happyGoto action_119
action_214 (28) = happyGoto action_120
action_214 _ = happyFail (happyExpListPerState 214)

action_215 (65) = happyShift action_41
action_215 (66) = happyShift action_42
action_215 (67) = happyShift action_43
action_215 (68) = happyShift action_44
action_215 (69) = happyShift action_45
action_215 (73) = happyShift action_46
action_215 (74) = happyShift action_47
action_215 (79) = happyShift action_48
action_215 (84) = happyShift action_50
action_215 (97) = happyShift action_125
action_215 (98) = happyShift action_126
action_215 (99) = happyShift action_127
action_215 (100) = happyShift action_128
action_215 (101) = happyShift action_51
action_215 (102) = happyShift action_129
action_215 (18) = happyGoto action_114
action_215 (19) = happyGoto action_115
action_215 (24) = happyGoto action_246
action_215 (27) = happyGoto action_119
action_215 (28) = happyGoto action_120
action_215 _ = happyFail (happyExpListPerState 215)

action_216 _ = happyReduce_30

action_217 (63) = happyShift action_121
action_217 (64) = happyShift action_122
action_217 (65) = happyShift action_41
action_217 (66) = happyShift action_42
action_217 (67) = happyShift action_43
action_217 (68) = happyShift action_44
action_217 (69) = happyShift action_45
action_217 (73) = happyShift action_46
action_217 (74) = happyShift action_123
action_217 (79) = happyShift action_124
action_217 (84) = happyShift action_50
action_217 (97) = happyShift action_125
action_217 (98) = happyShift action_126
action_217 (99) = happyShift action_127
action_217 (100) = happyShift action_128
action_217 (101) = happyShift action_51
action_217 (102) = happyShift action_129
action_217 (18) = happyGoto action_114
action_217 (19) = happyGoto action_115
action_217 (23) = happyGoto action_245
action_217 (24) = happyGoto action_117
action_217 (26) = happyGoto action_118
action_217 (27) = happyGoto action_119
action_217 (28) = happyGoto action_120
action_217 _ = happyFail (happyExpListPerState 217)

action_218 (63) = happyShift action_121
action_218 (64) = happyShift action_122
action_218 (65) = happyShift action_41
action_218 (66) = happyShift action_42
action_218 (67) = happyShift action_43
action_218 (68) = happyShift action_44
action_218 (69) = happyShift action_45
action_218 (73) = happyShift action_46
action_218 (74) = happyShift action_123
action_218 (79) = happyShift action_124
action_218 (84) = happyShift action_50
action_218 (97) = happyShift action_125
action_218 (98) = happyShift action_126
action_218 (99) = happyShift action_127
action_218 (100) = happyShift action_128
action_218 (101) = happyShift action_51
action_218 (102) = happyShift action_129
action_218 (18) = happyGoto action_114
action_218 (19) = happyGoto action_115
action_218 (23) = happyGoto action_244
action_218 (24) = happyGoto action_117
action_218 (26) = happyGoto action_118
action_218 (27) = happyGoto action_119
action_218 (28) = happyGoto action_120
action_218 _ = happyFail (happyExpListPerState 218)

action_219 (79) = happyShift action_243
action_219 _ = happyFail (happyExpListPerState 219)

action_220 (51) = happyShift action_55
action_220 (52) = happyShift action_56
action_220 (53) = happyShift action_57
action_220 (75) = happyShift action_242
action_220 _ = happyFail (happyExpListPerState 220)

action_221 _ = happyReduce_33

action_222 (70) = happyShift action_93
action_222 (16) = happyGoto action_241
action_222 _ = happyReduce_36

action_223 _ = happyReduce_104

action_224 _ = happyReduce_105

action_225 (79) = happyShift action_192
action_225 (37) = happyGoto action_240
action_225 _ = happyFail (happyExpListPerState 225)

action_226 (79) = happyShift action_192
action_226 (37) = happyGoto action_239
action_226 _ = happyFail (happyExpListPerState 226)

action_227 (102) = happyShift action_238
action_227 _ = happyReduce_131

action_228 _ = happyReduce_144

action_229 _ = happyReduce_145

action_230 _ = happyReduce_147

action_231 _ = happyReduce_146

action_232 _ = happyReduce_148

action_233 _ = happyReduce_149

action_234 _ = happyReduce_150

action_235 _ = happyReduce_120

action_236 (79) = happyShift action_106
action_236 (93) = happyShift action_107
action_236 (114) = happyShift action_108
action_236 (35) = happyGoto action_237
action_236 (36) = happyGoto action_105
action_236 _ = happyFail (happyExpListPerState 236)

action_237 (76) = happyShift action_236
action_237 _ = happyReduce_129

action_238 _ = happyReduce_130

action_239 (75) = happyShift action_288
action_239 (76) = happyShift action_265
action_239 _ = happyFail (happyExpListPerState 239)

action_240 (75) = happyShift action_287
action_240 (76) = happyShift action_265
action_240 _ = happyFail (happyExpListPerState 240)

action_241 _ = happyReduce_32

action_242 (77) = happyShift action_286
action_242 _ = happyFail (happyExpListPerState 242)

action_243 _ = happyReduce_54

action_244 _ = happyReduce_75

action_245 _ = happyReduce_73

action_246 _ = happyReduce_78

action_247 _ = happyReduce_77

action_248 _ = happyReduce_76

action_249 _ = happyReduce_81

action_250 (51) = happyShift action_55
action_250 (52) = happyShift action_56
action_250 (53) = happyShift action_57
action_250 (75) = happyShift action_285
action_250 _ = happyFail (happyExpListPerState 250)

action_251 _ = happyReduce_74

action_252 (75) = happyReduce_87
action_252 (77) = happyReduce_43
action_252 (83) = happyReduce_43
action_252 (84) = happyReduce_43
action_252 (85) = happyReduce_43
action_252 (86) = happyReduce_43
action_252 _ = happyReduce_87

action_253 _ = happyReduce_67

action_254 _ = happyReduce_84

action_255 _ = happyReduce_66

action_256 _ = happyReduce_64

action_257 _ = happyReduce_63

action_258 _ = happyReduce_62

action_259 _ = happyReduce_65

action_260 (44) = happyShift action_9
action_260 (74) = happyShift action_10
action_260 (97) = happyShift action_164
action_260 (98) = happyShift action_165
action_260 (99) = happyShift action_166
action_260 (100) = happyShift action_167
action_260 (101) = happyShift action_168
action_260 (102) = happyShift action_169
action_260 (7) = happyGoto action_283
action_260 (8) = happyGoto action_4
action_260 (9) = happyGoto action_5
action_260 (32) = happyGoto action_284
action_260 _ = happyFail (happyExpListPerState 260)

action_261 _ = happyReduce_70

action_262 (51) = happyShift action_55
action_262 (52) = happyShift action_56
action_262 (53) = happyShift action_57
action_262 (75) = happyShift action_282
action_262 _ = happyFail (happyExpListPerState 262)

action_263 _ = happyReduce_60

action_264 (76) = happyShift action_194
action_264 _ = happyReduce_55

action_265 (79) = happyShift action_192
action_265 (37) = happyGoto action_281
action_265 _ = happyFail (happyExpListPerState 265)

action_266 (79) = happyShift action_146
action_266 (26) = happyGoto action_280
action_266 _ = happyFail (happyExpListPerState 266)

action_267 _ = happyReduce_87

action_268 _ = happyReduce_95

action_269 _ = happyReduce_97

action_270 _ = happyReduce_99

action_271 _ = happyReduce_101

action_272 _ = happyReduce_103

action_273 _ = happyReduce_42

action_274 (76) = happyShift action_178
action_274 _ = happyReduce_119

action_275 (54) = happyShift action_174
action_275 (55) = happyShift action_175
action_275 _ = happyReduce_12

action_276 _ = happyReduce_118

action_277 _ = happyReduce_61

action_278 _ = happyReduce_59

action_279 (76) = happyShift action_173
action_279 _ = happyReduce_117

action_280 (59) = happyShift action_293
action_280 _ = happyFail (happyExpListPerState 280)

action_281 (76) = happyShift action_265
action_281 _ = happyReduce_135

action_282 _ = happyReduce_69

action_283 (51) = happyShift action_55
action_283 (52) = happyShift action_56
action_283 (53) = happyShift action_57
action_283 (75) = happyShift action_292
action_283 _ = happyFail (happyExpListPerState 283)

action_284 (75) = happyShift action_291
action_284 (76) = happyShift action_173
action_284 _ = happyFail (happyExpListPerState 284)

action_285 _ = happyReduce_80

action_286 (79) = happyShift action_290
action_286 _ = happyFail (happyExpListPerState 286)

action_287 (115) = happyShift action_289
action_287 _ = happyFail (happyExpListPerState 287)

action_288 _ = happyReduce_132

action_289 (79) = happyShift action_295
action_289 _ = happyFail (happyExpListPerState 289)

action_290 _ = happyReduce_56

action_291 _ = happyReduce_72

action_292 _ = happyReduce_71

action_293 (79) = happyShift action_146
action_293 (26) = happyGoto action_294
action_293 _ = happyFail (happyExpListPerState 293)

action_294 (47) = happyShift action_89
action_294 (48) = happyShift action_90
action_294 (49) = happyShift action_91
action_294 (50) = happyShift action_92
action_294 (70) = happyShift action_93
action_294 (12) = happyGoto action_297
action_294 (13) = happyGoto action_83
action_294 (14) = happyGoto action_84
action_294 (15) = happyGoto action_85
action_294 (16) = happyGoto action_86
action_294 _ = happyReduce_36

action_295 (74) = happyShift action_296
action_295 _ = happyFail (happyExpListPerState 295)

action_296 (79) = happyShift action_192
action_296 (37) = happyGoto action_298
action_296 _ = happyFail (happyExpListPerState 296)

action_297 _ = happyReduce_24

action_298 (75) = happyShift action_299
action_298 (76) = happyShift action_265
action_298 _ = happyFail (happyExpListPerState 298)

action_299 (116) = happyShift action_301
action_299 (38) = happyGoto action_300
action_299 _ = happyReduce_136

action_300 (117) = happyShift action_306
action_300 (39) = happyGoto action_305
action_300 _ = happyReduce_140

action_301 (118) = happyShift action_302
action_301 (119) = happyShift action_303
action_301 (120) = happyShift action_304
action_301 _ = happyFail (happyExpListPerState 301)

action_302 _ = happyReduce_137

action_303 _ = happyReduce_138

action_304 _ = happyReduce_139

action_305 _ = happyReduce_133

action_306 (118) = happyShift action_307
action_306 (119) = happyShift action_308
action_306 (120) = happyShift action_309
action_306 _ = happyFail (happyExpListPerState 306)

action_307 _ = happyReduce_141

action_308 _ = happyReduce_142

action_309 _ = happyReduce_143

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

happyReduce_4 = happySpecReduce_2  4 happyReduction_4
happyReduction_4 _
	(HappyAbsSyn4  happy_var_1)
	 =  HappyAbsSyn4
		 (happy_var_1
	)
happyReduction_4 _ _  = notHappyAtAll 

happyReduce_5 = happySpecReduce_3  4 happyReduction_5
happyReduction_5 (HappyAbsSyn4  happy_var_3)
	_
	(HappyAbsSyn4  happy_var_1)
	 =  HappyAbsSyn4
		 (Seq happy_var_1 happy_var_3
	)
happyReduction_5 _ _ _  = notHappyAtAll 

happyReduce_6 = happySpecReduce_2  4 happyReduction_6
happyReduction_6 (HappyTerminal (TStr happy_var_2))
	_
	 =  HappyAbsSyn4
		 (Source happy_var_2
	)
happyReduction_6 _ _  = notHappyAtAll 

happyReduce_7 = happySpecReduce_3  5 happyReduction_7
happyReduction_7 (HappyTerminal (TField happy_var_3))
	(HappyTerminal (TField happy_var_2))
	_
	 =  HappyAbsSyn5
		 (CUser happy_var_2 happy_var_3
	)
happyReduction_7 _ _ _  = notHappyAtAll 

happyReduce_8 = happySpecReduce_3  5 happyReduction_8
happyReduction_8 (HappyTerminal (TField happy_var_3))
	(HappyTerminal (TField happy_var_2))
	_
	 =  HappyAbsSyn5
		 (DUser happy_var_2 happy_var_3
	)
happyReduction_8 _ _ _  = notHappyAtAll 

happyReduce_9 = happySpecReduce_3  5 happyReduction_9
happyReduction_9 (HappyTerminal (TField happy_var_3))
	(HappyTerminal (TField happy_var_2))
	_
	 =  HappyAbsSyn5
		 (SUser happy_var_2 happy_var_3
	)
happyReduction_9 _ _ _  = notHappyAtAll 

happyReduce_10 = happySpecReduce_3  6 happyReduction_10
happyReduction_10 (HappyAbsSyn31  happy_var_3)
	(HappyTerminal (TField happy_var_2))
	_
	 =  HappyAbsSyn6
		 (Insert happy_var_2 happy_var_3
	)
happyReduction_10 _ _ _  = notHappyAtAll 

happyReduce_11 = happyReduce 4 6 happyReduction_11
happyReduction_11 ((HappyAbsSyn22  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TField happy_var_2)) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn6
		 (Delete happy_var_2 happy_var_4
	) `HappyStk` happyRest

happyReduce_12 = happyReduce 6 6 happyReduction_12
happyReduction_12 ((HappyAbsSyn22  happy_var_6) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn33  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TField happy_var_2)) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn6
		 (Update happy_var_2 happy_var_4 happy_var_6
	) `HappyStk` happyRest

happyReduce_13 = happySpecReduce_1  6 happyReduction_13
happyReduction_13 (HappyAbsSyn6  happy_var_1)
	 =  HappyAbsSyn6
		 (happy_var_1
	)
happyReduction_13 _  = notHappyAtAll 

happyReduce_14 = happySpecReduce_3  7 happyReduction_14
happyReduction_14 (HappyAbsSyn6  happy_var_3)
	_
	(HappyAbsSyn6  happy_var_1)
	 =  HappyAbsSyn6
		 (Union happy_var_1 happy_var_3
	)
happyReduction_14 _ _ _  = notHappyAtAll 

happyReduce_15 = happySpecReduce_3  7 happyReduction_15
happyReduction_15 (HappyAbsSyn6  happy_var_3)
	_
	(HappyAbsSyn6  happy_var_1)
	 =  HappyAbsSyn6
		 (Diff happy_var_1 happy_var_3
	)
happyReduction_15 _ _ _  = notHappyAtAll 

happyReduce_16 = happySpecReduce_3  7 happyReduction_16
happyReduction_16 (HappyAbsSyn6  happy_var_3)
	_
	(HappyAbsSyn6  happy_var_1)
	 =  HappyAbsSyn6
		 (Intersect happy_var_1 happy_var_3
	)
happyReduction_16 _ _ _  = notHappyAtAll 

happyReduce_17 = happySpecReduce_1  7 happyReduction_17
happyReduction_17 (HappyAbsSyn6  happy_var_1)
	 =  HappyAbsSyn6
		 (happy_var_1
	)
happyReduction_17 _  = notHappyAtAll 

happyReduce_18 = happySpecReduce_1  8 happyReduction_18
happyReduction_18 (HappyAbsSyn9  happy_var_1)
	 =  HappyAbsSyn6
		 (happy_var_1
	)
happyReduction_18 _  = notHappyAtAll 

happyReduce_19 = happySpecReduce_3  8 happyReduction_19
happyReduction_19 _
	(HappyAbsSyn9  happy_var_2)
	_
	 =  HappyAbsSyn6
		 (happy_var_2
	)
happyReduction_19 _ _ _  = notHappyAtAll 

happyReduce_20 = happySpecReduce_3  9 happyReduction_20
happyReduction_20 (HappyAbsSyn10  happy_var_3)
	(HappyAbsSyn17  happy_var_2)
	_
	 =  HappyAbsSyn9
		 (Select False happy_var_2 happy_var_3
	)
happyReduction_20 _ _ _  = notHappyAtAll 

happyReduce_21 = happyReduce 4 9 happyReduction_21
happyReduction_21 ((HappyAbsSyn10  happy_var_4) `HappyStk`
	(HappyAbsSyn17  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn9
		 (Select True happy_var_3 happy_var_4
	) `HappyStk` happyRest

happyReduce_22 = happySpecReduce_3  10 happyReduction_22
happyReduction_22 (HappyAbsSyn11  happy_var_3)
	(HappyAbsSyn17  happy_var_2)
	_
	 =  HappyAbsSyn10
		 (From happy_var_2 happy_var_3
	)
happyReduction_22 _ _ _  = notHappyAtAll 

happyReduce_23 = happySpecReduce_1  10 happyReduction_23
happyReduction_23 (HappyAbsSyn11  happy_var_1)
	 =  HappyAbsSyn10
		 (happy_var_1
	)
happyReduction_23 _  = notHappyAtAll 

happyReduce_24 = happyReduce 8 11 happyReduction_24
happyReduction_24 ((HappyAbsSyn12  happy_var_8) `HappyStk`
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

happyReduce_25 = happySpecReduce_1  11 happyReduction_25
happyReduction_25 (HappyAbsSyn12  happy_var_1)
	 =  HappyAbsSyn11
		 (happy_var_1
	)
happyReduction_25 _  = notHappyAtAll 

happyReduce_26 = happySpecReduce_3  12 happyReduction_26
happyReduction_26 (HappyAbsSyn13  happy_var_3)
	(HappyAbsSyn22  happy_var_2)
	_
	 =  HappyAbsSyn12
		 (Where happy_var_2 happy_var_3
	)
happyReduction_26 _ _ _  = notHappyAtAll 

happyReduce_27 = happySpecReduce_1  12 happyReduction_27
happyReduction_27 (HappyAbsSyn13  happy_var_1)
	 =  HappyAbsSyn12
		 (happy_var_1
	)
happyReduction_27 _  = notHappyAtAll 

happyReduce_28 = happySpecReduce_3  13 happyReduction_28
happyReduction_28 (HappyAbsSyn14  happy_var_3)
	(HappyAbsSyn17  happy_var_2)
	_
	 =  HappyAbsSyn13
		 (GroupBy happy_var_2 happy_var_3
	)
happyReduction_28 _ _ _  = notHappyAtAll 

happyReduce_29 = happySpecReduce_1  13 happyReduction_29
happyReduction_29 (HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn13
		 (happy_var_1
	)
happyReduction_29 _  = notHappyAtAll 

happyReduce_30 = happySpecReduce_3  14 happyReduction_30
happyReduction_30 (HappyAbsSyn15  happy_var_3)
	(HappyAbsSyn22  happy_var_2)
	_
	 =  HappyAbsSyn14
		 (Having happy_var_2 happy_var_3
	)
happyReduction_30 _ _ _  = notHappyAtAll 

happyReduce_31 = happySpecReduce_1  14 happyReduction_31
happyReduction_31 (HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn14
		 (happy_var_1
	)
happyReduction_31 _  = notHappyAtAll 

happyReduce_32 = happyReduce 4 15 happyReduction_32
happyReduction_32 ((HappyAbsSyn16  happy_var_4) `HappyStk`
	(HappyAbsSyn29  happy_var_3) `HappyStk`
	(HappyAbsSyn17  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn15
		 (OrderBy happy_var_2 happy_var_3 happy_var_4
	) `HappyStk` happyRest

happyReduce_33 = happySpecReduce_3  15 happyReduction_33
happyReduction_33 (HappyAbsSyn16  happy_var_3)
	(HappyAbsSyn17  happy_var_2)
	_
	 =  HappyAbsSyn15
		 (OrderBy happy_var_2 A happy_var_3
	)
happyReduction_33 _ _ _  = notHappyAtAll 

happyReduce_34 = happySpecReduce_1  15 happyReduction_34
happyReduction_34 (HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn15
		 (happy_var_1
	)
happyReduction_34 _  = notHappyAtAll 

happyReduce_35 = happySpecReduce_2  16 happyReduction_35
happyReduction_35 (HappyTerminal (TNum happy_var_2))
	_
	 =  HappyAbsSyn16
		 (Limit happy_var_2 End
	)
happyReduction_35 _ _  = notHappyAtAll 

happyReduce_36 = happySpecReduce_0  16 happyReduction_36
happyReduction_36  =  HappyAbsSyn16
		 (End
	)

happyReduce_37 = happySpecReduce_3  17 happyReduction_37
happyReduction_37 (HappyAbsSyn17  happy_var_3)
	_
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn17
		 (happy_var_1 ++ happy_var_3
	)
happyReduction_37 _ _ _  = notHappyAtAll 

happyReduce_38 = happySpecReduce_1  17 happyReduction_38
happyReduction_38 (HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn17
		 ([happy_var_1]
	)
happyReduction_38 _  = notHappyAtAll 

happyReduce_39 = happySpecReduce_1  18 happyReduction_39
happyReduction_39 (HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn18
		 (Field happy_var_1
	)
happyReduction_39 _  = notHappyAtAll 

happyReduce_40 = happySpecReduce_1  18 happyReduction_40
happyReduction_40 (HappyAbsSyn28  happy_var_1)
	 =  HappyAbsSyn18
		 (A2 happy_var_1
	)
happyReduction_40 _  = notHappyAtAll 

happyReduce_41 = happySpecReduce_3  18 happyReduction_41
happyReduction_41 (HappyTerminal (TField happy_var_3))
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn18
		 (As happy_var_1 (Field happy_var_3)
	)
happyReduction_41 _ _ _  = notHappyAtAll 

happyReduce_42 = happyReduce 5 18 happyReduction_42
happyReduction_42 ((HappyTerminal (TField happy_var_5)) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn9  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn18
		 (As (Subquery happy_var_2) (Field happy_var_5)
	) `HappyStk` happyRest

happyReduce_43 = happySpecReduce_3  18 happyReduction_43
happyReduction_43 (HappyTerminal (TField happy_var_3))
	_
	(HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn18
		 (Dot happy_var_1 happy_var_3
	)
happyReduction_43 _ _ _  = notHappyAtAll 

happyReduce_44 = happySpecReduce_1  18 happyReduction_44
happyReduction_44 (HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn18
		 (happy_var_1
	)
happyReduction_44 _  = notHappyAtAll 

happyReduce_45 = happySpecReduce_1  18 happyReduction_45
happyReduction_45 _
	 =  HappyAbsSyn18
		 (All
	)

happyReduce_46 = happySpecReduce_3  19 happyReduction_46
happyReduction_46 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn18
		 (Plus happy_var_1 happy_var_3
	)
happyReduction_46 _ _ _  = notHappyAtAll 

happyReduce_47 = happySpecReduce_3  19 happyReduction_47
happyReduction_47 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn18
		 (Minus happy_var_1 happy_var_3
	)
happyReduction_47 _ _ _  = notHappyAtAll 

happyReduce_48 = happySpecReduce_3  19 happyReduction_48
happyReduction_48 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn18
		 (Times happy_var_1 happy_var_3
	)
happyReduction_48 _ _ _  = notHappyAtAll 

happyReduce_49 = happySpecReduce_3  19 happyReduction_49
happyReduction_49 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn18
		 (Div happy_var_1 happy_var_3
	)
happyReduction_49 _ _ _  = notHappyAtAll 

happyReduce_50 = happySpecReduce_3  19 happyReduction_50
happyReduction_50 _
	(HappyAbsSyn18  happy_var_2)
	_
	 =  HappyAbsSyn18
		 (Brack happy_var_2
	)
happyReduction_50 _ _ _  = notHappyAtAll 

happyReduce_51 = happySpecReduce_2  19 happyReduction_51
happyReduction_51 (HappyAbsSyn18  happy_var_2)
	_
	 =  HappyAbsSyn18
		 (Negate happy_var_2
	)
happyReduction_51 _ _  = notHappyAtAll 

happyReduce_52 = happySpecReduce_1  19 happyReduction_52
happyReduction_52 (HappyTerminal (TNum happy_var_1))
	 =  HappyAbsSyn18
		 (A3 happy_var_1
	)
happyReduction_52 _  = notHappyAtAll 

happyReduce_53 = happySpecReduce_1  20 happyReduction_53
happyReduction_53 (HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn17
		 ([Field happy_var_1]
	)
happyReduction_53 _  = notHappyAtAll 

happyReduce_54 = happySpecReduce_3  20 happyReduction_54
happyReduction_54 (HappyTerminal (TField happy_var_3))
	_
	(HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn17
		 ([As (Field happy_var_1) (Field happy_var_3)]
	)
happyReduction_54 _ _ _  = notHappyAtAll 

happyReduce_55 = happySpecReduce_3  20 happyReduction_55
happyReduction_55 (HappyAbsSyn17  happy_var_3)
	_
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn17
		 (happy_var_1 ++ happy_var_3
	)
happyReduction_55 _ _ _  = notHappyAtAll 

happyReduce_56 = happyReduce 5 20 happyReduction_56
happyReduction_56 ((HappyTerminal (TField happy_var_5)) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn6  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn17
		 ([As (Subquery happy_var_2) (Field happy_var_5)]
	) `HappyStk` happyRest

happyReduce_57 = happySpecReduce_1  21 happyReduction_57
happyReduction_57 (HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn17
		 ([Field happy_var_1]
	)
happyReduction_57 _  = notHappyAtAll 

happyReduce_58 = happySpecReduce_3  21 happyReduction_58
happyReduction_58 (HappyAbsSyn17  happy_var_3)
	_
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn17
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
happyReduction_62 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn22
		 (GEqual happy_var_1 happy_var_3
	)
happyReduction_62 _ _ _  = notHappyAtAll 

happyReduce_63 = happySpecReduce_3  22 happyReduction_63
happyReduction_63 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn22
		 (LEqual happy_var_1 happy_var_3
	)
happyReduction_63 _ _ _  = notHappyAtAll 

happyReduce_64 = happySpecReduce_3  22 happyReduction_64
happyReduction_64 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn22
		 (Equal happy_var_1 happy_var_3
	)
happyReduction_64 _ _ _  = notHappyAtAll 

happyReduce_65 = happySpecReduce_3  22 happyReduction_65
happyReduction_65 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn22
		 (NEqual happy_var_1 happy_var_3
	)
happyReduction_65 _ _ _  = notHappyAtAll 

happyReduce_66 = happySpecReduce_3  22 happyReduction_66
happyReduction_66 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn22
		 (Great happy_var_1 happy_var_3
	)
happyReduction_66 _ _ _  = notHappyAtAll 

happyReduce_67 = happySpecReduce_3  22 happyReduction_67
happyReduction_67 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn22
		 (Less happy_var_1 happy_var_3
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
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn22
		 (Like happy_var_1 happy_var_3
	)
happyReduction_70 _ _ _  = notHappyAtAll 

happyReduce_71 = happyReduce 5 22 happyReduction_71
happyReduction_71 (_ `HappyStk`
	(HappyAbsSyn6  happy_var_4) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn18  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn22
		 (InQuery happy_var_1 happy_var_4
	) `HappyStk` happyRest

happyReduce_72 = happyReduce 5 22 happyReduction_72
happyReduction_72 (_ `HappyStk`
	(HappyAbsSyn17  happy_var_4) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn18  happy_var_1) `HappyStk`
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
happyReduction_76 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn22
		 (Equal happy_var_1 happy_var_3
	)
happyReduction_76 _ _ _  = notHappyAtAll 

happyReduce_77 = happySpecReduce_3  23 happyReduction_77
happyReduction_77 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn22
		 (Great happy_var_1 happy_var_3
	)
happyReduction_77 _ _ _  = notHappyAtAll 

happyReduce_78 = happySpecReduce_3  23 happyReduction_78
happyReduction_78 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn22
		 (Less happy_var_1 happy_var_3
	)
happyReduction_78 _ _ _  = notHappyAtAll 

happyReduce_79 = happySpecReduce_2  23 happyReduction_79
happyReduction_79 (HappyAbsSyn22  happy_var_2)
	_
	 =  HappyAbsSyn22
		 (Not happy_var_2
	)
happyReduction_79 _ _  = notHappyAtAll 

happyReduce_80 = happyReduce 4 23 happyReduction_80
happyReduction_80 (_ `HappyStk`
	(HappyAbsSyn6  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn22
		 (Exist happy_var_3
	) `HappyStk` happyRest

happyReduce_81 = happySpecReduce_3  23 happyReduction_81
happyReduction_81 (HappyTerminal (TStr happy_var_3))
	_
	(HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn22
		 (Like happy_var_1 happy_var_3
	)
happyReduction_81 _ _ _  = notHappyAtAll 

happyReduce_82 = happySpecReduce_1  24 happyReduction_82
happyReduction_82 (HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn18
		 (happy_var_1
	)
happyReduction_82 _  = notHappyAtAll 

happyReduce_83 = happySpecReduce_1  24 happyReduction_83
happyReduction_83 (HappyAbsSyn28  happy_var_1)
	 =  HappyAbsSyn18
		 (A2 happy_var_1
	)
happyReduction_83 _  = notHappyAtAll 

happyReduce_84 = happySpecReduce_1  25 happyReduction_84
happyReduction_84 (HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn18
		 (happy_var_1
	)
happyReduction_84 _  = notHappyAtAll 

happyReduce_85 = happySpecReduce_1  25 happyReduction_85
happyReduction_85 (HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn18
		 (happy_var_1
	)
happyReduction_85 _  = notHappyAtAll 

happyReduce_86 = happySpecReduce_1  26 happyReduction_86
happyReduction_86 (HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn18
		 (Field happy_var_1
	)
happyReduction_86 _  = notHappyAtAll 

happyReduce_87 = happySpecReduce_3  26 happyReduction_87
happyReduction_87 (HappyTerminal (TField happy_var_3))
	_
	(HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn18
		 (Dot happy_var_1 happy_var_3
	)
happyReduction_87 _ _ _  = notHappyAtAll 

happyReduce_88 = happySpecReduce_1  27 happyReduction_88
happyReduction_88 (HappyTerminal (TStr happy_var_1))
	 =  HappyAbsSyn18
		 (A1 happy_var_1
	)
happyReduction_88 _  = notHappyAtAll 

happyReduce_89 = happySpecReduce_1  27 happyReduction_89
happyReduction_89 (HappyTerminal (TDatTim happy_var_1))
	 =  HappyAbsSyn18
		 (A5 happy_var_1
	)
happyReduction_89 _  = notHappyAtAll 

happyReduce_90 = happySpecReduce_1  27 happyReduction_90
happyReduction_90 (HappyTerminal (TDat happy_var_1))
	 =  HappyAbsSyn18
		 (A6 happy_var_1
	)
happyReduction_90 _  = notHappyAtAll 

happyReduce_91 = happySpecReduce_1  27 happyReduction_91
happyReduction_91 (HappyTerminal (TTim happy_var_1))
	 =  HappyAbsSyn18
		 (A7 happy_var_1
	)
happyReduction_91 _  = notHappyAtAll 

happyReduce_92 = happySpecReduce_1  27 happyReduction_92
happyReduction_92 (HappyAbsSyn18  happy_var_1)
	 =  HappyAbsSyn18
		 (happy_var_1
	)
happyReduction_92 _  = notHappyAtAll 

happyReduce_93 = happySpecReduce_1  27 happyReduction_93
happyReduction_93 _
	 =  HappyAbsSyn18
		 (Nulo
	)

happyReduce_94 = happyReduce 4 28 happyReduction_94
happyReduction_94 (_ `HappyStk`
	(HappyAbsSyn18  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn28
		 (Sum False happy_var_3
	) `HappyStk` happyRest

happyReduce_95 = happyReduce 5 28 happyReduction_95
happyReduction_95 (_ `HappyStk`
	(HappyAbsSyn18  happy_var_4) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn28
		 (Sum True happy_var_4
	) `HappyStk` happyRest

happyReduce_96 = happyReduce 4 28 happyReduction_96
happyReduction_96 (_ `HappyStk`
	(HappyAbsSyn18  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn28
		 (Count False happy_var_3
	) `HappyStk` happyRest

happyReduce_97 = happyReduce 5 28 happyReduction_97
happyReduction_97 (_ `HappyStk`
	(HappyAbsSyn18  happy_var_4) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn28
		 (Count True happy_var_4
	) `HappyStk` happyRest

happyReduce_98 = happyReduce 4 28 happyReduction_98
happyReduction_98 (_ `HappyStk`
	(HappyAbsSyn18  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn28
		 (Avg False happy_var_3
	) `HappyStk` happyRest

happyReduce_99 = happyReduce 5 28 happyReduction_99
happyReduction_99 (_ `HappyStk`
	(HappyAbsSyn18  happy_var_4) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn28
		 (Avg True happy_var_4
	) `HappyStk` happyRest

happyReduce_100 = happyReduce 4 28 happyReduction_100
happyReduction_100 (_ `HappyStk`
	(HappyAbsSyn18  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn28
		 (Min False happy_var_3
	) `HappyStk` happyRest

happyReduce_101 = happyReduce 5 28 happyReduction_101
happyReduction_101 (_ `HappyStk`
	(HappyAbsSyn18  happy_var_4) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn28
		 (Min True happy_var_4
	) `HappyStk` happyRest

happyReduce_102 = happyReduce 4 28 happyReduction_102
happyReduction_102 (_ `HappyStk`
	(HappyAbsSyn18  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn28
		 (Max False happy_var_3
	) `HappyStk` happyRest

happyReduce_103 = happyReduce 5 28 happyReduction_103
happyReduction_103 (_ `HappyStk`
	(HappyAbsSyn18  happy_var_4) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn28
		 (Max True happy_var_4
	) `HappyStk` happyRest

happyReduce_104 = happySpecReduce_1  29 happyReduction_104
happyReduction_104 _
	 =  HappyAbsSyn29
		 (A
	)

happyReduce_105 = happySpecReduce_1  29 happyReduction_105
happyReduction_105 _
	 =  HappyAbsSyn29
		 (D
	)

happyReduce_106 = happySpecReduce_1  30 happyReduction_106
happyReduction_106 _
	 =  HappyAbsSyn30
		 (Inner
	)

happyReduce_107 = happySpecReduce_1  30 happyReduction_107
happyReduction_107 _
	 =  HappyAbsSyn30
		 (JLeft
	)

happyReduce_108 = happySpecReduce_1  30 happyReduction_108
happyReduction_108 _
	 =  HappyAbsSyn30
		 (JRight
	)

happyReduce_109 = happySpecReduce_3  31 happyReduction_109
happyReduction_109 _
	(HappyAbsSyn17  happy_var_2)
	_
	 =  HappyAbsSyn31
		 (Avl.singletonT happy_var_2
	)
happyReduction_109 _ _ _  = notHappyAtAll 

happyReduce_110 = happySpecReduce_3  31 happyReduction_110
happyReduction_110 (HappyAbsSyn31  happy_var_3)
	_
	(HappyAbsSyn31  happy_var_1)
	 =  HappyAbsSyn31
		 (Avl.join happy_var_1  happy_var_3
	)
happyReduction_110 _ _ _  = notHappyAtAll 

happyReduce_111 = happySpecReduce_1  32 happyReduction_111
happyReduction_111 (HappyTerminal (TStr happy_var_1))
	 =  HappyAbsSyn17
		 ([A1 happy_var_1]
	)
happyReduction_111 _  = notHappyAtAll 

happyReduce_112 = happySpecReduce_1  32 happyReduction_112
happyReduction_112 (HappyTerminal (TNum happy_var_1))
	 =  HappyAbsSyn17
		 ([A3 happy_var_1]
	)
happyReduction_112 _  = notHappyAtAll 

happyReduce_113 = happySpecReduce_1  32 happyReduction_113
happyReduction_113 (HappyTerminal (TDatTim happy_var_1))
	 =  HappyAbsSyn17
		 ([A5 happy_var_1]
	)
happyReduction_113 _  = notHappyAtAll 

happyReduce_114 = happySpecReduce_1  32 happyReduction_114
happyReduction_114 (HappyTerminal (TDat happy_var_1))
	 =  HappyAbsSyn17
		 ([A6 happy_var_1]
	)
happyReduction_114 _  = notHappyAtAll 

happyReduce_115 = happySpecReduce_1  32 happyReduction_115
happyReduction_115 (HappyTerminal (TTim happy_var_1))
	 =  HappyAbsSyn17
		 ([A7 happy_var_1]
	)
happyReduction_115 _  = notHappyAtAll 

happyReduce_116 = happySpecReduce_1  32 happyReduction_116
happyReduction_116 _
	 =  HappyAbsSyn17
		 ([Nulo]
	)

happyReduce_117 = happySpecReduce_3  32 happyReduction_117
happyReduction_117 (HappyAbsSyn17  happy_var_3)
	_
	(HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn17
		 (happy_var_1 ++ happy_var_3
	)
happyReduction_117 _ _ _  = notHappyAtAll 

happyReduce_118 = happySpecReduce_3  33 happyReduction_118
happyReduction_118 (HappyAbsSyn18  happy_var_3)
	_
	(HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn33
		 (([happy_var_1],[happy_var_3])
	)
happyReduction_118 _ _ _  = notHappyAtAll 

happyReduce_119 = happySpecReduce_3  33 happyReduction_119
happyReduction_119 (HappyAbsSyn33  happy_var_3)
	_
	(HappyAbsSyn33  happy_var_1)
	 =  HappyAbsSyn33
		 (let ((k1,m1),(k2,m2)) = (happy_var_1,happy_var_3)
                                  in (k1 ++ k2, m1 ++ m2)
	)
happyReduction_119 _ _ _  = notHappyAtAll 

happyReduce_120 = happyReduce 5 34 happyReduction_120
happyReduction_120 (_ `HappyStk`
	(HappyAbsSyn35  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyTerminal (TField happy_var_2)) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn34
		 (CTable happy_var_2 happy_var_4
	) `HappyStk` happyRest

happyReduce_121 = happySpecReduce_2  34 happyReduction_121
happyReduction_121 (HappyTerminal (TField happy_var_2))
	_
	 =  HappyAbsSyn34
		 (DTable happy_var_2
	)
happyReduction_121 _ _  = notHappyAtAll 

happyReduce_122 = happySpecReduce_1  34 happyReduction_122
happyReduction_122 _
	 =  HappyAbsSyn34
		 (DAllTable
	)

happyReduce_123 = happySpecReduce_2  34 happyReduction_123
happyReduction_123 (HappyTerminal (TField happy_var_2))
	_
	 =  HappyAbsSyn34
		 (CBase happy_var_2
	)
happyReduction_123 _ _  = notHappyAtAll 

happyReduce_124 = happySpecReduce_2  34 happyReduction_124
happyReduction_124 (HappyTerminal (TField happy_var_2))
	_
	 =  HappyAbsSyn34
		 (DBase happy_var_2
	)
happyReduction_124 _ _  = notHappyAtAll 

happyReduce_125 = happySpecReduce_2  34 happyReduction_125
happyReduction_125 (HappyTerminal (TField happy_var_2))
	_
	 =  HappyAbsSyn34
		 (Use happy_var_2
	)
happyReduction_125 _ _  = notHappyAtAll 

happyReduce_126 = happySpecReduce_1  34 happyReduction_126
happyReduction_126 _
	 =  HappyAbsSyn34
		 (ShowB
	)

happyReduce_127 = happySpecReduce_1  34 happyReduction_127
happyReduction_127 _
	 =  HappyAbsSyn34
		 (ShowT
	)

happyReduce_128 = happySpecReduce_1  35 happyReduction_128
happyReduction_128 (HappyAbsSyn36  happy_var_1)
	 =  HappyAbsSyn35
		 ([happy_var_1]
	)
happyReduction_128 _  = notHappyAtAll 

happyReduce_129 = happySpecReduce_3  35 happyReduction_129
happyReduction_129 (HappyAbsSyn35  happy_var_3)
	_
	(HappyAbsSyn35  happy_var_1)
	 =  HappyAbsSyn35
		 (happy_var_1 ++ happy_var_3
	)
happyReduction_129 _ _ _  = notHappyAtAll 

happyReduce_130 = happySpecReduce_3  36 happyReduction_130
happyReduction_130 _
	(HappyAbsSyn40  happy_var_2)
	(HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn36
		 (Col happy_var_1 happy_var_2 True
	)
happyReduction_130 _ _ _  = notHappyAtAll 

happyReduce_131 = happySpecReduce_2  36 happyReduction_131
happyReduction_131 (HappyAbsSyn40  happy_var_2)
	(HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn36
		 (Col happy_var_1 happy_var_2 False
	)
happyReduction_131 _ _  = notHappyAtAll 

happyReduce_132 = happyReduce 4 36 happyReduction_132
happyReduction_132 (_ `HappyStk`
	(HappyAbsSyn37  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn36
		 (PKey happy_var_3
	) `HappyStk` happyRest

happyReduce_133 = happyReduce 11 36 happyReduction_133
happyReduction_133 ((HappyAbsSyn38  happy_var_11) `HappyStk`
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

happyReduce_134 = happySpecReduce_1  37 happyReduction_134
happyReduction_134 (HappyTerminal (TField happy_var_1))
	 =  HappyAbsSyn37
		 ([happy_var_1]
	)
happyReduction_134 _  = notHappyAtAll 

happyReduce_135 = happySpecReduce_3  37 happyReduction_135
happyReduction_135 (HappyAbsSyn37  happy_var_3)
	_
	(HappyAbsSyn37  happy_var_1)
	 =  HappyAbsSyn37
		 (happy_var_1 ++ happy_var_3
	)
happyReduction_135 _ _ _  = notHappyAtAll 

happyReduce_136 = happySpecReduce_0  38 happyReduction_136
happyReduction_136  =  HappyAbsSyn38
		 (Restricted
	)

happyReduce_137 = happySpecReduce_2  38 happyReduction_137
happyReduction_137 _
	_
	 =  HappyAbsSyn38
		 (Restricted
	)

happyReduce_138 = happySpecReduce_2  38 happyReduction_138
happyReduction_138 _
	_
	 =  HappyAbsSyn38
		 (Cascades
	)

happyReduce_139 = happySpecReduce_2  38 happyReduction_139
happyReduction_139 _
	_
	 =  HappyAbsSyn38
		 (Nullifies
	)

happyReduce_140 = happySpecReduce_0  39 happyReduction_140
happyReduction_140  =  HappyAbsSyn38
		 (Restricted
	)

happyReduce_141 = happySpecReduce_2  39 happyReduction_141
happyReduction_141 _
	_
	 =  HappyAbsSyn38
		 (Restricted
	)

happyReduce_142 = happySpecReduce_2  39 happyReduction_142
happyReduction_142 _
	_
	 =  HappyAbsSyn38
		 (Cascades
	)

happyReduce_143 = happySpecReduce_2  39 happyReduction_143
happyReduction_143 _
	_
	 =  HappyAbsSyn38
		 (Nullifies
	)

happyReduce_144 = happySpecReduce_1  40 happyReduction_144
happyReduction_144 _
	 =  HappyAbsSyn40
		 (Int
	)

happyReduce_145 = happySpecReduce_1  40 happyReduction_145
happyReduction_145 _
	 =  HappyAbsSyn40
		 (Float
	)

happyReduce_146 = happySpecReduce_1  40 happyReduction_146
happyReduction_146 _
	 =  HappyAbsSyn40
		 (Bool
	)

happyReduce_147 = happySpecReduce_1  40 happyReduction_147
happyReduction_147 _
	 =  HappyAbsSyn40
		 (String
	)

happyReduce_148 = happySpecReduce_1  40 happyReduction_148
happyReduction_148 _
	 =  HappyAbsSyn40
		 (Datetime
	)

happyReduce_149 = happySpecReduce_1  40 happyReduction_149
happyReduction_149 _
	 =  HappyAbsSyn40
		 (Dates
	)

happyReduce_150 = happySpecReduce_1  40 happyReduction_150
happyReduction_150 _
	 =  HappyAbsSyn40
		 (Tim
	)

happyNewToken action sts stk
	= lexer(\tk -> 
	let cont i = action i i tk (HappyState action) sts stk in
	case tk of {
	TEOF -> action 126 126 tk (HappyState action) sts stk;
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
	TNEqual -> cont 56;
	TGEqual -> cont 57;
	TLEqual -> cont 58;
	TEqual -> cont 59;
	TGreat -> cont 60;
	TLess -> cont 61;
	TLike -> cont 62;
	TExist -> cont 63;
	TNot -> cont 64;
	TSum -> cont 65;
	TCount -> cont 66;
	TAvg -> cont 67;
	TMin -> cont 68;
	TMax -> cont 69;
	TLimit -> cont 70;
	TAsc -> cont 71;
	TDesc -> cont 72;
	TAll -> cont 73;
	TOpen -> cont 74;
	TClose -> cont 75;
	TComa -> cont 76;
	TAs -> cont 77;
	TSet -> cont 78;
	TField happy_dollar_dollar -> cont 79;
	TDistinct -> cont 80;
	TIn -> cont 81;
	TDot -> cont 82;
	TPlus -> cont 83;
	TMinus -> cont 84;
	TTimes -> cont 85;
	TDiv -> cont 86;
	TNeg -> cont 87;
	TCTable -> cont 88;
	TCBase -> cont 89;
	TDTable -> cont 90;
	TDAllTable -> cont 91;
	TDBase -> cont 92;
	TPkey -> cont 93;
	TUse -> cont 94;
	TShowB -> cont 95;
	TShowT -> cont 96;
	TDatTim happy_dollar_dollar -> cont 97;
	TDat happy_dollar_dollar -> cont 98;
	TTim happy_dollar_dollar -> cont 99;
	TStr happy_dollar_dollar -> cont 100;
	TNum happy_dollar_dollar -> cont 101;
	TNull -> cont 102;
	TInt -> cont 103;
	TFloat -> cont 104;
	TString -> cont 105;
	TBool -> cont 106;
	TDateTime -> cont 107;
	TDate -> cont 108;
	TTime -> cont 109;
	TSrc -> cont 110;
	TCUser -> cont 111;
	TDUser -> cont 112;
	TSUser -> cont 113;
	TFKey -> cont 114;
	TRef -> cont 115;
	TDel -> cont 116;
	TUpd -> cont 117;
	TRestricted -> cont 118;
	TCascades -> cont 119;
	TNullifies -> cont 120;
	TOn -> cont 121;
	TJoin -> cont 122;
	TLeft -> cont 123;
	TRight -> cont 124;
	TInner -> cont 125;
	_ -> happyError' (tk, [])
	})

happyError_ explist 126 tk = happyError' (tk, explist)
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
