1 REM   +----------------------------------------------------------------------+
2 REM   | MBConv v0.1 * Modbus register number/address converter utility       |
3 REM   | Copyright (C) 2023-2024 Pozsar Zsolt <pozsarzs@gmail.com>            |
4 REM   | mbconv.bas                                                           |
5 REM   | GW-Basic version of the original mbconv ModShell script              |
6 REM   +----------------------------------------------------------------------+
7 REM
8 REM   This program is free software: you can redistribute it and/or modify it
9 REM   under the terms of the European Union Public License 1.2 version.
10 REM
11 REM  This program is distributed in the hope that it will be useful, but
12 REM  WITHOUT ANY WARRANTY; without even the implied warranty of
13 REM  MERCHANTABILITY or FITNESS A PARTICULAR PURPOSE.
14 REM
20 REM *** CONSTANTS / MESSAGES ***
21 DIM MSG$(16)
22 FOR I%=0 TO 16
23 READ MSG$(I%)
24 NEXT I%
25 DATA "MBConv v0.1 * Modbus register number/address converter utility"
26 DATA "(C) 2024 Pozsar Zsolt <http://www.pozsarzs.hu>"
27 DATA "Please enter your input data, or hit <ENTER> exit:"
28 DATA "  register_number or type [c|d|i|h]:"
29 DATA "  address [0-9998]:"
30 DATA " discrete output coils"
31 DATA " discrete input contacts"
32 DATA "ERROR:"
33 DATA " analog input registers"
34 DATA " analog output holding registers"
35 DATA "  register number:  "
36 DATA "  register type:    "
37 DATA "  register address: "
38 DATA " The register type can be c, d, i and h."
39 DATA " The address can be 0-9998."
40 DATA " The register number can be 1-9999, 10001-19999, 30001-39999 and 40001-49999."
41 DATA "  ---------------------------------------------------------"
50 REM *** CONSTANTS / REGISTER TYPES ***
51 LET OFFSET%=10000
52 DIM REGTYPE$(4)
53 FOR I%=0 TO 4
54 READ REGTYPE$(I%)
55 NEXT I%
56 DATA "c","d","_","i","h"
60 REM *** MAIN ***
61 REM ** PRINT HEADER, INPUT VALUES AND SELECT OPERATION MODE ** 
70 LET VALID%=255
80 PRINT MSG$(0)
90 PRINT MSG$(1)
91 PRINT ""
100 PRINT MSG$(2)
110 PRINT MSG$(3)
120 INPUT ARG1$
130 IF LEN(ARG1$)=0 THEN END ELSE GOSUB 2000
140 IF VALID%=255 THEN GOTO 200
150 PRINT MSG$(4)
160 INPUT ARG2$
170 IF LEN(ARG2$)=0 THEN END
180 GOTO 500
200 REM * CONVERT REGISTER NUMBER TO ADDRESS *
210 PRINT ""
220 GOSUB 2200
230 IF VALID%=255 THEN GOTO 370
240 LET RTYPE%=VALID%+5 
250 LET RNUMBER!=VAL(ARG1$)
260 IF RNUMBER!=0 THEN RNUMBER!=1
270 REM PRINT REGISTER NUMBER
280 PRINT MSG$(10) RNUMBER!
290 REM PRINT SPLITTER
300 PRINT MSG$(16)
310 REM PRINT REGISTER TYPE 
320 PRINT MSG$(11) MSG$(RTYPE%)
330 REM PRINT REGISTER ADDRESS
340 LET RADDRESS% = RNUMBER! - ((OFFSET% * VALID%) + 1)
350 PRINT MSG$(12) RADDRESS% "(" HEX$(RADDRESS%) "h)"
360 END
370 REM ERROR: BAD REGISTER NUMBER
380 PRINT MSG$(7) MSG$(15)
390 END
500 REM ** CONVERT ADDRESS TO REGISTER NUMBER **
510 PRINT ""
520 REM CHECK REGISTER TYPE
530 GOSUB 2000
540 IF VALID%=255 THEN GOTO 700
550 LET RTYPE%=VALID%
560 REM CHECK REGISTER ADDRESS
570 GOSUB 2100
580 IF VALID%=255 THEN GOTO 730
590 LET RADDRESS%=VAL(ARG2$)
600 REM PRINT REGISTER ADDRESS
610 PRINT MSG$(12) RADDRESS% "(" HEX$(RADDRESS%) "h)"
620 REM PRINT REGISTER TYPE 
630 PRINT MSG$(11) MSG$(RTYPE%+5)
640 REM PRINT SPLITTER
650 PRINT MSG$(16)
660 REM PRINT REGISTER NUMBER
670 LET RNUMBER!=(OFFSET%*RTYPE%)+RADDRESS%+1
680 PRINT MSG$(10) RNUMBER!
690 END
700 REM ERROR: BAD TYPE
710 PRINT MSG$(7) MSG$(13)
720 END
730 REM ERROR: BAD ADDRESS
740 PRINT MSG$(7) MSG$(14)
750 END
2000 REM *** CHECK REGISTER TYPE ***
2010 REM RESULT IN VALID% VARIABLE: 0,1,3,4 OR 255
2020 LET VALID%=255
2030 FOR I%=0 TO 4
2040 IF ARG1$=REGTYPE$(I%) THEN LET VALID%=I%
2050 NEXT I%
2060 IF VALID%=2 THEN LET VALID%=255
2070 RETURN
2100 REM *** CHECK REGISTER ADDRESS ***
2110 REM RESULT IN VALID% VARIABLE: 0 OR 255
2120 LET VALID%=255
2130 IF (VAL(ARG2$)>=0) AND (VAL(ARG2$)<=9998) THEN LET VALID%=0
2140 RETURN
2200 REM *** CHECK REGISTER NUMBER ***
2210 REM RESULT IN VALID% VARIABLE: 0,1,3,4 OR 255
2220 LET VALID%=255
2230 IF (VAL(ARG1$)>=1) AND (VAL(ARG1$)<=9999) THEN LET VALID%=0
2240 IF (VAL(ARG1$)>=10001) AND (VAL(ARG1$)<=19999) THEN LET VALID%=1
2250 IF (VAL(ARG1$)>=30001) AND (VAL(ARG1$)<=39999) THEN LET VALID%=3
2260 IF (VAL(ARG1$)>=40001) AND (VAL(ARG1$)<=49999) THEN LET VALID%=4
2270 RETURN
