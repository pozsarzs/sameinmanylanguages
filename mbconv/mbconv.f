C +--------------------------------------------------------------------+
C | MBConv v0.1 * Modbus register number/address converter utility     |
C | Copyright (C) 2023-2024 Pozsar Zsolt <pozsarzs@gmail.com>          |
C | mbconv.f                                                           |
C | FORTRAN IV version of the original mbconv ModShell script          |
C +--------------------------------------------------------------------+
C
C This program is free software: you can redistribute it and/or modify
C it under the terms of the European Union Public License 1.2 version.
C
C This program is distributed in the hope that it will be useful, but
C WITHOUT ANY WARRANTY; without even the implied warranty of
C MERCHANTABILITY or FITNESS A PARTICULAR PURPOSE.

C *** MAIN SEGMENT ***
      PROGRAM MBCONV
C ** VARIABLES AND CONSTANTS **
      COMMON/GLBVAR/IMITEM(4),IREGTS(10)
      INTEGER I,IINPUT,IMODE,IOFFST,IRADDR,IRNUM,IRTYPE,IVALID
      INTEGER*4 ITEXT(5)
      DOUBLE PRECISION DERROR
      REAL RINPUT
      DATA IOFFST,IVALID/10000,255/
      DATA ITEXT /4H  re,4Hgist,4Her t,4Hype:,2H  /
      DATA DERROR/6HERROR: /
C ** MESSAGES **
 1000 FORMAT(62HMBConv v0.1 * Modbus register number/address converter u
     1tility)
 1001 FORMAT(46H(C) 2024 Pozsar Zsolt <http://www.pozsarzs.hu>)
 1002 FORMAT(14HPlease select:)
 1003 FORMAT(52H Convert register number to register type/address: 1)
 1004 FORMAT(52H Convert register type/address to register number: 2)
 1005 FORMAT(52H Exit to OS:                                       q)
 1006 FORMAT(24HPlease enter input data:)
 1007 FORMAT(17H-register number:)
 1008 FORMAT(25H-register type [c|d|i|h]:)
 1009 FORMAT(27H-register address [0-9998]:)
 1010 FORMAT(5A4,22H discrete output coils)
 1011 FORMAT(5A4,24H discrete input contacts)
 1012 FORMAT(5A4,23H analog input registers)
 1013 FORMAT(5A4,32H analog output holding registers)
 1014 FORMAT(21H  register number:   ,I5)
 1015 FORMAT(21H  register address:   ,I4)
 1016 FORMAT(A7,17HWrong input data!)
 1017 FORMAT(A7,39HThe register type can be c, d, i and h.)
 1018 FORMAT(A7,35HThe register address can be 0-9998.)
 1019 FORMAT(A7,72HThe register number can be 1-9999 10001-19999, 30001-
     139999, 40001-49999.)
C ** PRINT HEADER, INPUT VALUES AND SELECT OPERATION MODE ** 
      WRITE(6,1000)
      WRITE(6,1001)
      WRITE(6,*)
C GET ARGUMENTS FROM STDIN
   10 WRITE(6,1002)
      WRITE(6,1003)
      WRITE(6,1004)
      WRITE(6,1005)
      READ(5,20) IMODE
   20 FORMAT(A1)
      GOTO (30,70,240,240,10) IMENU(IMODE)
C * CONVERT REGISTER NUMBER TO ADDRESS *
   30 WRITE(6,*)
C GET ARGUMENT FROM STDIN
      WRITE(6,1006)
      WRITE(6,1007)
      READ(5,40,ERR=230) RINPUT
   40 FORMAT(F5)
      IINPUT=RINPUT
      IF (IINPUT.EQ.0) GOTO 230
C CHECK REGISTER NUMBER
      IVALID=ICREGN(IINPUT)
      IF (IVALID.EQ.255) GOTO 200
      IRNUM=IINPUT
      IRTYPE=IVALID
C PRIMARY MISSION
      IF (IRNUM.EQ.0) IRNUM=1
      IRADDR = IRNUM - ((IOFFST * IVALID) + 1)
      WRITE(6,*)
C PRINT REGISTER NUMBER
      WRITE(6,1014) IRNUM
C PRINT SPLITTER
      CALL SPLIT
C PRINT REGISTER TYPE
      GOTO (51,52,53,54,55) IRTYPE+1
   51 WRITE(6,1010) ITEXT
      GOTO 60
   52 WRITE(6,1011) ITEXT
      GOTO 60
   53 GOTO 60
   54 WRITE(6,1012) ITEXT
      GOTO 60
   55 WRITE(6,1013) ITEXT
      GOTO 60
C PRINT REGISTER ADDRESS
   60 WRITE(6,1015) IRADDR
      GOTO 240
C * CONVERT ADDRESS TO REGISTER NUMBER *
   70 WRITE(6,*)
C GET ARGUMENTS FROM STDIN
      WRITE(6,1006)
      WRITE(6,1008)
      READ(5,80) IINPUT
   80 FORMAT(A1)
      IVALID=ICREGT(IINPUT)
C CHECK REGISTER TYPE
      IF (IVALID.EQ.255) GOTO 200
      IRTYPE=IVALID
      WRITE(6,1006)
      WRITE(6,1009)
      READ(5,90,ERR=230) RINPUT
   90 FORMAT(F4)
      IINPUT=RINPUT
      IF (IINPUT.EQ.0) GOTO 230
C CHECK REGISTER ADDRESS
      IVALID=ICREGA(IINPUT)
      IF (IVALID.EQ.255) GOTO 200
      IRADDR=IINPUT
C PRIMARY MISSION
C PRINT REGISTER ADDRESS
      WRITE(6,1015) IRADDR
C PRINT REGISTER TYPE
      GOTO (101,102,103,104,105) IRTYPE+1
  101 WRITE(6,1010) ITEXT
      GOTO 110
  102 WRITE(6,1011) ITEXT
      GOTO 110
  103 GOTO 110
  104 WRITE(6,1012) ITEXT
      GOTO 110
  105 WRITE(6,1013) ITEXT
      GOTO 110
C PRINT SPLITTER
  110 CALL SPLIT
C PRINT REGISTER NUMBER
      IRNUM=(IOFFST*IRTYPE)+IRADDR+1
      WRITE(6,1014) IRNUM
      GOTO 240
C ERROR: BAD REGISTER TYPE
  200 WRITE(6,1017) DERROR
      GOTO 240
C ERROR: BAD REGISTER ADDRESS
  210 WRITE(6,1018) DERROR
      GOTO 240
C ERROR: BAD REGISTER NUMBER
  220 WRITE(6,1019) DERROR
      GOTO 240
C ERROR: DATA INPUT ERROR
  230 WRITE(6,1016) DERROR
      GOTO 240
C END OF PROGRAM
  240 WRITE(6,*)
      STOP
      END
C *** SEGMENT BLOCK DATA ***
      BLOCK DATA
      COMMON/GLBVAR/IMITEM(4),IREGTS(10)
      DATA IMITEM(1),IMITEM(2),IMITEM(3),IMITEM(4)/1H1,1H2,1HQ,1Hq/
      DATA IREGTS(1),IREGTS(2),IREGTS(3),IREGTS(4),IREGTS(5),
     1IREGTS(6),IREGTS(7),IREGTS(8),IREGTS(9),IREGTS(10)/
     21Hc,1Hd,1H_,1Hi,1Hh,1HC,1HD,1H_,1HI,1HH/
      END
C *** SEGMENT SPLIT ***
C PRINT SPLITTER TO CONSOLE
      SUBROUTINE SPLIT
      WRITE(*,300)
  300 FORMAT(2H  ,50(1H-))
      RETURN
      END
C *** SEGMENT IMENU ***
C GET SELECTED MENUITEM, RESULT: 1,2,3,4 OR 5
      INTEGER FUNCTION IMENU(ISLCT)
      COMMON/GLBVAR/IMITEM(4),IREGTS(10)
      INTEGER I, IVALID
      DATA IVALID/5/
      DO 400 I=1,4
      IF (ISLCT.EQ.IMITEM(I)) IVALID=I
  400 CONTINUE
      IMENU=IVALID
      RETURN
      END
C *** SEGMENT ICREGT ***
C CHECK REGISTER TYPE, RESULT: 0,1,3,4 OR 255
      INTEGER FUNCTION ICREGT(IREGT)
      COMMON/GLBVAR/IMITEM(4),IREGTS(10)
      INTEGER I, IVALID
      DATA IVALID/255/
      DO 500 I=0,4
      IF (IREGT.EQ.IREGTS(I+1)) IVALID=I
      IF (IREGT.EQ.IREGTS(I+6)) IVALID=I
  500 CONTINUE
      IF (IVALID.EQ.2) IVALID=255
      ICREGT=IVALID
      RETURN
      END
C *** SEGMENT ICREGA ***
C CHECK REGISTER ADDRESS, RESULT: 0 OR 255
      INTEGER FUNCTION ICREGA(IREGA)
      INTEGER IVALID
      DATA IVALID/255/
      IF ((IREGA.GE.0).AND.(IREGA.LE.9998)) IVALID=0
      ICREGA=IVALID
      RETURN
      END      
C *** SEGMENT ICREGN ***
C CHECK REGISTER NUMBER, RESULT: 0,1,3,4 OR 255
      INTEGER FUNCTION ICREGN(IREGN)
      INTEGER IVALID
      DATA IVALID/255/
      IF ((IREGN.GE.1).AND.(IREGN.LE.9999)) IVALID=0
      IF ((IREGN.GE.10001).AND.(IREGN.LE.19999)) IVALID=1
      IF ((IREGN.GE.30001).AND.(IREGN.LE.39999)) IVALID=3
      IF ((IREGN.GE.40001).AND.(IREGN.LE.49999)) IVALID=4
      ICREGN=IVALID
      RETURN
      END
