;-------------------------------------
; Vokabel Trainer
; 
;-------------------------------------

Openlibrary    = -408
Closelibrary   = -414
Openscreen     = -198
Closescreen    = -066
Openwindow     = -204
Closewindow    = -072
Addmem         = -198
Freemem        = -210

Getmsg         = -372

Draw           = -246
Cmove          = -240
Point          = -324
Drawmode       = -354
Writeln        = -060
Setapen        = -342
Setbpen        = -348
FBOX           = -306

Execbase       = 4
Mousebot       = $bfe001

;-------------------------------------

Write:MACRO *\Text,%\l,%\x,%\y

       Crmove  \x,\y
       lea     \text,a0
       move.l  #\l,d0
       jsr     Writeln(a6)

       endm

OpenLib:MACRO *\Name,*\Base

       move.l  Execbase,a6
       lea     \Name,a1
       jsr     OpenLibrary(a6)
       move.l  d0,\Base

       endm

CloseLib:MACRO *\Base

       move.l  Execbase,a6
       move.l  \Base,a1
       jsr     CloseLibrary(a6)

       endm

OpenScr:MACRO  *\Devs,*\HD

       move.l  Intbase,a6
       lea     \Devs,a0
       jsr     OpenScreen(a6)
       move.l  d0,\HD

       endm

CloseScr:MACRO *\HD

       move.l  Intbase,a6
       move.l  \HD,a0
       jsr     Closescreen(a6)

       endm

OpenWind:MACRO *\Devs,*\HD

       move.l  Intbase,a6
       lea     \devs,a0
       jsr     Openwindow(a6)
       move.l  d0,\HD
       move.l  d0,a0
       move.l  50(a0),Rastport

       endm

CloseWind:MACRO *\HD

       move.l  Intbase,a6
       move.l  \HD,a0
       jsr     Closewindow(a6)

       endm

Crmove:MACRO %\x,%\y

       move.l  Grabase,a6
       move.l  Rastport,a1
       move.l  #\x,d0
       move.l  #\y,d1
       jsr     cmove(a6)

       endm

Line:MACRO %\x1,%\y1,%\x2,%\y2

       Crmove  \x1,\y1
       move.l  #\x2,d0
       move.l  #\y2,d1
       jsr     Draw(a6)

       endm

Drawmod:MACRO   %\m

       move.l  #\m,d0
       jsr     drawmode(a6)
       endm

Color:MACRO %\col

       move.l  grabase,a6
       move.l  rastport,a1
       move.l  #\col,d0
       jsr     Setapen(a6)
       Endm

BOX:MACRO %\x1,%\y1,%\x2,%\y2,%\col

       Color   \col
       move.l  #\x1,d0
       move.l  #\y1,d1
       move.l  #\x2,d2
       move.l  #\y2,d3
       jsr     Fbox(a6)
       COLOR   1
       endm

DBOX:MACRO %\x1,%\y1,%\x2,%\y2,%\c


       BOX     \x1+2,\y1+3,\x2+3,\y2+2,1
       BOX     \x1,\y1,\x2,\y2,1
       BOX     \x1+1,\y1+1,\x2-1,\y2-1,\c
       endm

Colorb:MACRO %\col

       move.l  grabase,a6
       move.l  rastport,a1
       move.l  #\col,d0
       jsr     setbpen(a6)
       endm


Memadd:MACRO %\by,*\adr

       move.l  Execbase,a6
       move.l  #\by,d0
       move.l  #$10002,d1
       jsr     addmem(a6)
       move.l  d0,\adr
       move.l  d0,dummy
       beq     Ende
       endm

Memfre:MACRO %\by,*\adr

       move.l  Execbase,a6
       move.l  #\by,d0
       move.l  \adr,a1
       jsr     freemem(a6)
       endm

Test:MACRO %\x1,%\y1,%\x2,%\y2,*\adr
       move.l  #\x1,d2
       move.l  #\y1,d3
       move.l  #\x2,d4
       move.l  #\y2,d5
       move.l  \adr,a1
       bsr     Testm
       endm

Bild:MACRO

       BOX     0,175,640,246,2
       DBOX    235,225,405,238,0
       Color   3
       Write   Autor,19,245,235
       Color   3
       Write   Dtext,8,450,15
       Write   Etext,8,110,15

       colorb  3
       DBOX    10,180,210,190,3
       Write   Load,6,90,188
       DBOX    10,195,210,205,3
       Write   Save,10,70,203
       DBOX    10,210,210,220,3
       Write   loes,12,60,218
       DBOX    10,225,210,235,3
       Write   sloe,16,45,233
      
       DBOX    220,180,420,190,3
       Write   Druk,8,290,188
       DBOX    220,195,420,205,3
       Write   uebe,4,300,203
       DBOX    220,210,420,220,3
       Write   info,4,300,218
      
       DBOX    430,180,630,190,3
       Write   nsei,14,485,188
       DBOX    430,195,630,205,3
       Write   lsei,12,490,203
       DBOX    430,210,630,220,3
       Write   anfa,6,510,218
       DBOX    430,225,630,235,3
       Write   enda,4,520,233
       Endm


Start:

       Openlib intname,intbase
       Openlib graname,grabase

       Openscr Devs,scrhd
       Openwind winddevs,windhd
       
       MEMADD  36000,Speicher
       
       Bild

loop:
       test    430,180,630,195,weiter
       test    430,195,630,205,Letzte
       move.l  execbase,a6
       move.l  windhd,a0
       move.l  86(a0),a0
       jsr     getmsg(a6)
       tst     d0
       beq     loop
       move.l  d0,a0
       move.l  20(a0),d0
       cmp     #$200,d0
       bne     loop


ende:
       MEMFRE 36000,Speicher
       Closewind windhd
       Closescr  scrhd

       Closelib  intbase
       Closelib  grabase
          
       rts

 align
Testm:

       btst    #6,mousebot
       bne     tend
       move.l  grabase,a6
       move.l  windhd,a0
       move    12(a0),d1
       move    14(a0),d0
       cmp     d3,d1
       blo     tend
       cmp     d5,d1
       bhi     tend

       cmp     d2,d0
       blo     tend
       cmp     d4,d0
       bhi     tend
       jsr     (a1)

tend:
       rts

Weiter:
       Move.l  Dummy,a1
       lea     strbuf1,a2
       move.l  #758,d4
cl1:   move.b  (a2),(a1)
       adda    #1,a1
       adda    #1,a2
       dbra    d4,cl1
       move.l  a1,dummy
       move.l  #758,d4
       lea     strbuf1,a2
cl2:   move.b  #0,(a2)
       adda    #1,a2
       dbra    d4,cl2
       closewind windhd
       openwind  winddevs,windhd
       Bild
       rts

Letzte:
       move.l  Dummy,a1
       lea     strbuf1,a2
       move.l  #758,d4
       suba    #760,a1
cl3:   move.b  (a1),(a2)
       adda    #1,a1
       adda    #1,a2
       dbra    d4,cl3
       move.l  a1,dummy
       closewind windhd
       openwind  winddevs,windhd
       bild
       rts

devs:

       dc.w    0,0,640,256,2
       dc.b    0,1
       dc.w    $8002,15
       dc.l    0,titel,0,0


winddevs:
       dc.w    0,10,640,245
       dc.b    1,0
       dc.l    $200,$1808,gadget1,0,0
scrhd: dc.l    0
       dc.l    0
       dc.w    500,200,640,256,15

windhd:        dc.l    0
Rastport:      dc.l    0
Intbase:       dc.l    0
Grabase:       dc.l    0



intname:       dc.b    "intuition.library",0
 align
graname:       dc.b    "graphics.library",0
 align
titel:         dc.b    "                       V O K A B E L  -  P A U K E R",0
 align


gadget1:
       dc.l    gadget2
       dc.w    3
       dc.w    20
       dc.w    310
       dc.w    10
       dc.w    0
       dc.w    2
       dc.w    4
       dc.l    border
       dc.l    0,0,0
       dc.l    string_info
       dc.w    0
       dc.l    0
 align
string_info:

       dc.l    strbuf1
       dc.l    undo
       dc.w    0
       dc.w    38
       dc.w    0,0,0,0,0,0
       dc.l    0,0,0
       align
gadget2:
       dc.l    gadget3
       dc.w    3
       dc.w    35
       dc.w    310
       dc.w    10
       dc.w    0
       dc.w    2
       dc.w    4
       dc.l    border
       dc.l    0,0,0
       dc.l    string_info2
       dc.w    0
       dc.l    0
 align
string_info2:

       dc.l    strbuf2
       dc.l    undo
       dc.w    0
       dc.w    38
       dc.w    0,0,0,0,0,0
       dc.l    0,0,0
       align
gadget3:
       dc.l    gadget4
       dc.w    3
       dc.w    50
       dc.w    310
       dc.w    10
       dc.w    0
       dc.w    2
       dc.w    4
       dc.l    border
       dc.l    0,0,0
       dc.l    string_info3
       dc.w    0
       dc.l    0
 align
string_info3:

       dc.l    strbuf3
       dc.l    undo
       dc.w    0
       dc.w    38
       dc.w    0,0,0,0,0,0
       dc.l    0,0,0
       align
gadget4:
       dc.l    gadget5
       dc.w    3
       dc.w    65
       dc.w    310
       dc.w    10
       dc.w    0
       dc.w    2
       dc.w    4
       dc.l    border
       dc.l    0,0,0
       dc.l    string_info4
       dc.w    0
       dc.l    0
 align
string_info4:

       dc.l    strbuf4
       dc.l    undo
       dc.w    0
       dc.w    38
       dc.w    0,0,0,0,0,0
       dc.l    0,0,0
       align

gadget5:
       dc.l    gadget6
       dc.w    3
       dc.w    80
       dc.w    310
       dc.w    10
       dc.w    0
       dc.w    2
       dc.w    4
       dc.l    border
       dc.l    0,0,0
       dc.l    string_info5
       dc.w    0
       dc.l    0
 align
string_info5:

       dc.l    strbuf5
       dc.l    undo
       dc.w    0
       dc.w    38
       dc.w    0,0,0,0,0,0
       dc.l    0,0,0
       align

gadget6:
       dc.l    gadget7
       dc.w    3
       dc.w    95
       dc.w    310
       dc.w    10
       dc.w    0
       dc.w    2
       dc.w    4
       dc.l    border
       dc.l    0,0,0
       dc.l    string_info6
       dc.w    0
       dc.l    0
 align
string_info6:

       dc.l    strbuf6
       dc.l    undo
       dc.w    0
       dc.w    38
       dc.w    0,0,0,0,0,0
       dc.l    0,0,0
       align
gadget7:
       dc.l    gadget8
       dc.w    3
       dc.w    110
       dc.w    310
       dc.w    10
       dc.w    0
       dc.w    2
       dc.w    4
       dc.l    border
       dc.l    0,0,0
       dc.l    string_info7
       dc.w    0
       dc.l    0
 align
string_info7:

       dc.l    strbuf7
       dc.l    undo
       dc.w    0
       dc.w    38
       dc.w    0,0,0,0,0,0
       dc.l    0,0,0
       align
gadget8:
       dc.l    gadget9
       dc.w    3
       dc.w    125
       dc.w    310
       dc.w    10
       dc.w    0
       dc.w    2
       dc.w    4
       dc.l    border
       dc.l    0,0,0
       dc.l    string_info8
       dc.w    0
       dc.l    0
 align
string_info8:

       dc.l    strbuf8
       dc.l    undo
       dc.w    0
       dc.w    38
       dc.w    0,0,0,0,0,0
       dc.l    0,0,0
       align
gadget9:
       dc.l    gadget10
       dc.w    3
       dc.w    140
       dc.w    310
       dc.w    10
       dc.w    0
       dc.w    2
       dc.w    4
       dc.l    border
       dc.l    0,0,0
       dc.l    string_info9
       dc.w    0
       dc.l    0
 align
string_info9:

       dc.l    strbuf9
       dc.l    undo
       dc.w    0
       dc.w    38
       dc.w    0,0,0,0,0,0
       dc.l    0,0,0
       align
gadget10:
       dc.l    gadgetd1
       dc.w    3
       dc.w    155
       dc.w    310
       dc.w    10
       dc.w    0
       dc.w    2
       dc.w    4
       dc.l    border
       dc.l    0,0,0
       dc.l    string_info10
       dc.w    0
       dc.l    0
 align
string_info10:

       dc.l    strbuf10
       dc.l    undo
       dc.w    0
       dc.w    38
       dc.w    0,0,0,0,0,0
       dc.l    0,0,0
       align

gadgetd1:
       dc.l    gadgetd2
       dc.w    323
       dc.w    20
       dc.w    310
       dc.w    10
       dc.w    0
       dc.w    2
       dc.w    4
       dc.l    border
       dc.l    0,0,0
       dc.l    string_infod
       dc.w    0
       dc.l    0
 align
string_infod:

       dc.l    strbufd1
       dc.l    undo
       dc.w    0
       dc.w    38
       dc.w    0,0,0,0,0,0
       dc.l    0,0,0
       align
gadgetd2:
       dc.l    gadgetd3
       dc.w    323
       dc.w    35
       dc.w    310
       dc.w    10
       dc.w    0
       dc.w    2
       dc.w    4
       dc.l    border
       dc.l    0,0,0
       dc.l    string_infod2
       dc.w    0
       dc.l    0
 align
string_infod2:

       dc.l    strbufd2
       dc.l    undo
       dc.w    0
       dc.w    38
       dc.w    0,0,0,0,0,0
       dc.l    0,0,0
       align
gadgetd3:
       dc.l    gadgetd4
       dc.w    323
       dc.w    50
       dc.w    310
       dc.w    10
       dc.w    0
       dc.w    2
       dc.w    4
       dc.l    border
       dc.l    0,0,0
       dc.l    string_infod3
       dc.w    0
       dc.l    0
 align
string_infod3:

       dc.l    strbufd3
       dc.l    undo
       dc.w    0
       dc.w    38
       dc.w    0,0,0,0,0,0
       dc.l    0,0,0
       align
gadgetd4:
       dc.l    gadgetd5
       dc.w    323
       dc.w    65
       dc.w    310
       dc.w    10
       dc.w    0
       dc.w    2
       dc.w    4
       dc.l    border
       dc.l    0,0,0
       dc.l    string_infod4
       dc.w    0
       dc.l    0
 align
string_infod4:

       dc.l    strbufd4
       dc.l    undo
       dc.w    0
       dc.w    38
       dc.w    0,0,0,0,0,0
       dc.l    0,0,0
       align

gadgetd5:
       dc.l    gadgetd6
       dc.w    323
       dc.w    80
       dc.w    310
       dc.w    10
       dc.w    0
       dc.w    2
       dc.w    4
       dc.l    border
       dc.l    0,0,0
       dc.l    string_infod5
       dc.w    0
       dc.l    0
 align
string_infod5:

       dc.l    strbufd5
       dc.l    undo
       dc.w    0
       dc.w    38
       dc.w    0,0,0,0,0,0
       dc.l    0,0,0
       align

gadgetd6:
       dc.l    gadgetd7
       dc.w    323
       dc.w    95
       dc.w    310
       dc.w    10
       dc.w    0
       dc.w    2
       dc.w    4
       dc.l    border
       dc.l    0,0,0
       dc.l    string_infod6
       dc.w    0
       dc.l    0
 align
string_infod6:

       dc.l    strbufd6
       dc.l    undo
       dc.w    0
       dc.w    38
       dc.w    0,0,0,0,0,0
       dc.l    0,0,0
       align
gadgetd7:
       dc.l    gadgetd8
       dc.w    323
       dc.w    110
       dc.w    310
       dc.w    10
       dc.w    0
       dc.w    2
       dc.w    4
       dc.l    border
       dc.l    0,0,0
       dc.l    string_infod7
       dc.w    0
       dc.l    0
 align
string_infod7:

       dc.l    strbufd7
       dc.l    undo
       dc.w    0
       dc.w    38
       dc.w    0,0,0,0,0,0
       dc.l    0,0,0
       align
gadgetd8:
       dc.l    gadgetd9
       dc.w    323
       dc.w    125
       dc.w    310
       dc.w    10
       dc.w    0
       dc.w    2
       dc.w    4
       dc.l    border
       dc.l    0,0,0
       dc.l    string_infod8
       dc.w    0
       dc.l    0
 align
string_infod8:

       dc.l    strbufd8
       dc.l    undo
       dc.w    0
       dc.w    38
       dc.w    0,0,0,0,0,0
       dc.l    0,0,0
       align
gadgetd9:
       dc.l    gadgetd10
       dc.w    323
       dc.w    140
       dc.w    310
       dc.w    10
       dc.w    0
       dc.w    2
       dc.w    4
       dc.l    border
       dc.l    0,0,0
       dc.l    string_infod9
       dc.w    0
       dc.l    0
 align
string_infod9:

       dc.l    strbufd9
       dc.l    undo
       dc.w    0
       dc.w    38
       dc.w    0,0,0,0,0,0
       dc.l    0,0,0
       align
gadgetd10:
       dc.l    0
       dc.w    323
       dc.w    155
       dc.w    310
       dc.w    10
       dc.w    0
       dc.w    2
       dc.w    4
       dc.l    border
       dc.l    0,0,0
       dc.l    string_infod10
       dc.w    0
       dc.l    0
 align
string_infod10:

       dc.l    strbufd10
       dc.l    undo
       dc.w    0
       dc.w    38
       dc.w    0,0,0,0,0,0
       dc.l    0,0,0
       align


border:
       dc.w    0,0
       dc.b    1,0
       dc.b    0
       dc.b    13
       dc.l    koord
       dc.l    0

koord:

       dc.w    -2,-2
       dc.w    310,-2
       dc.w    310,9
       dc.w    -2,9
       dc.w    -2,-2
       dc.w    310,-2
       dc.w    310,2
       dc.w    311,2
       dc.w    311,10
       dc.w    2,10
       dc.w    2,11
       dc.w    312,11
       dc.w    312,2
           
strbuf1:   ds.b   38,0
strbuf2:   ds.b   38,0
strbuf3:   ds.b   38,0
strbuf4:   ds.b   38,0
strbuf5:   ds.b   38,0
strbuf6:   ds.b   38,0
strbuf7:   ds.b   38,0
strbuf8:   ds.b   38,0
strbuf9:   ds.b   38,0
strbuf10:  ds.b   38,0
strbufd1:  ds.b   38,0
strbufd2:  ds.b   38,0
strbufd3:  ds.b   38,0
strbufd4:  ds.b   38,0
strbufd5:  ds.b   38,0
strbufd6:  ds.b   38,0
strbufd7:  ds.b   38,0
strbufd8:  ds.b   38,0
strbufd9:  ds.b   38,0
strbufd10: ds.b   38,0

undo:      ds.b   38,0

autor: dc.b    "Von Lutz Großhennig"

dtext: dc.b    "DEUTSCH "
ETEXT: dc.b    "ENGLISCH"
Load:  dc.b    "Laden "
Save:  dc.b    "Speichern "
druk:  dc.b    "Drucken "
info:  dc.b    "INFO"
loes:  dc.b    "File Löschen"
sloe:  dc.b    "Speicher Löschen"
uebe:  dc.b    "Üben"
nsei:  dc.b    "Nächste Seite "
lsei:  dc.b    "Letzte Seite"
anfa:  dc.b    "Anfang"
enda:  dc.b    "Ende"
mo:    dc.b    "MOIN"

 align.l

Speicher:      dc.l    0
dummy:         dc.l    0
 end

