

	.FUNCT	PARSER,PTR=P-LEXSTART,WRD,VAL=0,VERB=0,LEN,DIR=0,NW=0,LW=0,NUM,SCNT,CNT=-1
?PRG1:	IGRTR?	'CNT,P-ITBLLEN \?ELS5
	JUMP	?REP2
?ELS5:	PUT	P-ITBL,CNT,0
	JUMP	?PRG1
?REP2:	SET	'P-ADVERB,FALSE-VALUE
	SET	'P-MERGED,FALSE-VALUE
	PUT	P-PRSO,P-MATCHLEN,0
	PUT	P-PRSI,P-MATCHLEN,0
	PUT	P-BUTS,P-MATCHLEN,0
	ZERO?	QUOTE-FLAG \?CND8
	EQUAL?	WINNER,PLAYER /?CND8
	SET	'WINNER,PLAYER
	LOC	WINNER
	FSET?	STACK,VEHBIT /?CND8
	LOC	WINNER >HERE
?CND8:	ZERO?	P-CONT /?ELS18
	SET	'PTR,P-CONT
	ZERO?	SUPER-BRIEF \?CND20
	EQUAL?	PLAYER,WINNER \?CND20
	CRLF	
?CND20:	SET	'P-CONT,FALSE-VALUE
	JUMP	?CND16
?ELS18:	SET	'WINNER,PLAYER
	SET	'QUOTE-FLAG,FALSE-VALUE
	LOC	WINNER
	FSET?	STACK,VEHBIT /?CND27
	LOC	WINNER >HERE
?CND27:	ZERO?	SUPER-BRIEF \?CND30
	CRLF	
?CND30:	PRINTI	">"
	READ	P-INBUF,P-LEXV
?CND16:	GETB	P-LEXV,P-LEXWORDS >P-LEN
	ZERO?	P-LEN \?CND35
	PRINTI	"I beg your pardon?"
	CRLF	
	RFALSE	
?CND35:	SET	'LEN,P-LEN
	SET	'P-DIR,FALSE-VALUE
	SET	'P-NCN,0
	SET	'P-GETFLAGS,0
?PRG40:	DLESS?	'P-LEN,0 \?ELS44
	SET	'QUOTE-FLAG,FALSE-VALUE
	JUMP	?REP41
?ELS44:	GET	P-LEXV,PTR >WRD
	ZERO?	WRD \?THN47
	CALL	NUMBER?,PTR >WRD
	ZERO?	WRD /?ELS46
?THN47:	EQUAL?	WRD,W?TO \?ELS51
	EQUAL?	VERB,ACT?TELL \?ELS51
	SET	'WRD,W?QUOTE
	JUMP	?CND49
?ELS51:	EQUAL?	WRD,W?THEN \?CND49
	ZERO?	VERB \?CND49
	PUT	P-ITBL,P-VERB,ACT?TELL
	PUT	P-ITBL,P-VERBN,0
	SET	'WRD,W?QUOTE
?CND49:	EQUAL?	WRD,W?THEN,W?PERIOD /?THN61
	EQUAL?	WRD,W?QUOTE \?ELS60
?THN61:	EQUAL?	WRD,W?QUOTE \?CND63
	ZERO?	QUOTE-FLAG /?ELS68
	SET	'QUOTE-FLAG,FALSE-VALUE
	JUMP	?CND63
?ELS68:	SET	'QUOTE-FLAG,TRUE-VALUE
?CND63:	ZERO?	P-LEN /?THN72
	ADD	PTR,P-LEXELEN >P-CONT
?THN72:	PUTB	P-LEXV,P-LEXWORDS,P-LEN
	JUMP	?REP41
?ELS60:	CALL	WT?,WRD,PS?DIRECTION,P1?DIRECTION >VAL
	ZERO?	VAL /?ELS75
	EQUAL?	VERB,FALSE-VALUE,ACT?WALK \?ELS75
	EQUAL?	LEN,1 /?THN78
	EQUAL?	LEN,2 \?ELS81
	EQUAL?	VERB,ACT?WALK /?THN78
?ELS81:	ADD	PTR,P-LEXELEN
	GET	P-LEXV,STACK >NW
	EQUAL?	NW,W?THEN,W?PERIOD,W?QUOTE \?ELS83
	LESS?	LEN,2 \?THN78
?ELS83:	ZERO?	QUOTE-FLAG /?ELS85
	EQUAL?	LEN,2 \?ELS85
	EQUAL?	NW,W?QUOTE /?THN78
?ELS85:	GRTR?	LEN,2 \?ELS75
	EQUAL?	NW,W?COMMA,W?AND \?ELS75
?THN78:	SET	'DIR,VAL
	EQUAL?	NW,W?COMMA,W?AND \?CND88
	ADD	PTR,P-LEXELEN
	PUT	P-LEXV,STACK,W?THEN
?CND88:	GRTR?	LEN,2 /?CND42
	SET	'QUOTE-FLAG,FALSE-VALUE
	JUMP	?REP41
?ELS75:	CALL	WT?,WRD,PS?VERB,P1?VERB >VAL
	ZERO?	VAL /?ELS95
	ZERO?	VERB \?ELS95
	SET	'VERB,VAL
	PUT	P-ITBL,P-VERB,VAL
	PUT	P-ITBL,P-VERBN,P-VTBL
	PUT	P-VTBL,0,WRD
	MUL	PTR,2
	ADD	STACK,2 >NUM
	GETB	P-LEXV,NUM
	PUTB	P-VTBL,2,STACK
	ADD	NUM,1
	GETB	P-LEXV,STACK
	PUTB	P-VTBL,3,STACK
	JUMP	?CND42
?ELS95:	CALL	WT?,WRD,PS?PREPOSITION,0 >VAL
	ZERO?	VAL \?THN100
	EQUAL?	WRD,W?ALL,W?ONE,W?A /?THN104
	CALL	WT?,WRD,PS?ADJECTIVE
	ZERO?	STACK \?THN104
	CALL	WT?,WRD,PS?OBJECT
	ZERO?	STACK /?ELS99
?THN104:	SET	'VAL,0
?THN100:	GRTR?	P-LEN,0 \?ELS108
	ADD	PTR,P-LEXELEN
	GET	P-LEXV,STACK
	EQUAL?	STACK,W?OF \?ELS108
	ZERO?	VAL \?ELS108
	EQUAL?	WRD,W?ALL,W?ONE,W?A /?ELS108
	JUMP	?CND42
?ELS108:	ZERO?	VAL /?ELS112
	ZERO?	P-LEN /?THN115
	ADD	PTR,2
	GET	P-LEXV,STACK
	EQUAL?	STACK,W?THEN,W?PERIOD \?ELS112
?THN115:	LESS?	P-NCN,2 \?CND42
	PUT	P-ITBL,P-PREP1,VAL
	PUT	P-ITBL,P-PREP1N,WRD
	JUMP	?CND42
?ELS112:	EQUAL?	P-NCN,2 \?ELS121
	PRINTI	"There were too many nouns in that sentence."
	CRLF	
	RFALSE	
?ELS121:	INC	'P-NCN
	CALL	CLAUSE,PTR,VAL,WRD >PTR
	ZERO?	PTR /FALSE
	LESS?	PTR,0 \?CND42
	SET	'QUOTE-FLAG,FALSE-VALUE
	JUMP	?REP41
?ELS99:	CALL	WT?,WRD,PS?BUZZ-WORD
	ZERO?	STACK /?ELS132
	JUMP	?CND42
?ELS132:	CALL	CANT-USE,PTR
	RFALSE	
?ELS46:	CALL	UNKNOWN-WORD,PTR
	RFALSE	
?CND42:	SET	'LW,WRD
	ADD	PTR,P-LEXELEN >PTR
	JUMP	?PRG40
?REP41:	ZERO?	DIR /?CND137
	SET	'PRSA,V?WALK
	SET	'PRSO,DIR
	SET	'P-WALK-DIR,DIR
	RETURN	TRUE-VALUE
?CND137:	SET	'P-WALK-DIR,FALSE-VALUE
	ZERO?	P-OFLAG /?CND141
	CALL	ORPHAN-MERGE
?CND141:	CALL	SYNTAX-CHECK
	ZERO?	STACK /FALSE
	CALL	SNARF-OBJECTS
	ZERO?	STACK /FALSE
	CALL	TAKE-CHECK
	ZERO?	STACK /FALSE
	CALL	MANY-CHECK
	ZERO?	STACK /FALSE
	RTRUE


	.FUNCT	WT?,PTR,BIT,B1=5,OFFS=P-P1OFF,TYP
	GETB	PTR,P-PSOFF >TYP
	BTST	TYP,BIT \FALSE
	GRTR?	B1,4 /TRUE
	BAND	TYP,P-P1BITS >TYP
	EQUAL?	TYP,B1 /?CND13
	INC	'OFFS
?CND13:	GETB	PTR,OFFS
	RSTACK	


	.FUNCT	CLAUSE,PTR,VAL,WRD,OFF,NUM,ANDFLG=0,FIRST??=1,NW,LW=0,?TMP1
	SUB	P-NCN,1
	MUL	STACK,2 >OFF
	ZERO?	VAL /?ELS3
	ADD	P-PREP1,OFF >NUM
	PUT	P-ITBL,NUM,VAL
	ADD	NUM,1
	PUT	P-ITBL,STACK,WRD
	ADD	PTR,P-LEXELEN >PTR
	JUMP	?CND1
?ELS3:	INC	'P-LEN
?CND1:	ZERO?	P-LEN \?CND6
	DEC	'P-NCN
	RETURN	-1
?CND6:	ADD	P-NC1,OFF >NUM
	MUL	PTR,2
	ADD	P-LEXV,STACK
	PUT	P-ITBL,NUM,STACK
	GET	P-LEXV,PTR
	EQUAL?	STACK,W?THE,W?A,W?AN \?CND9
	GET	P-ITBL,NUM
	ADD	STACK,4
	PUT	P-ITBL,NUM,STACK
?CND9:	
?PRG12:	DLESS?	'P-LEN,0 \?CND14
	ADD	NUM,1 >?TMP1
	MUL	PTR,2
	ADD	P-LEXV,STACK
	PUT	P-ITBL,?TMP1,STACK
	RETURN	-1
?CND14:	GET	P-LEXV,PTR >WRD
	ZERO?	WRD \?THN20
	CALL	NUMBER?,PTR >WRD
	ZERO?	WRD /?ELS19
?THN20:	ZERO?	P-LEN \?ELS24
	SET	'NW,0
	JUMP	?CND22
?ELS24:	ADD	PTR,P-LEXELEN
	GET	P-LEXV,STACK >NW
?CND22:	EQUAL?	WRD,W?AND,W?COMMA \?ELS29
	SET	'ANDFLG,TRUE-VALUE
	JUMP	?CND17
?ELS29:	EQUAL?	WRD,W?ALL,W?ONE \?ELS31
	EQUAL?	NW,W?OF \?CND17
	DEC	'P-LEN
	ADD	PTR,P-LEXELEN >PTR
	JUMP	?CND17
?ELS31:	EQUAL?	WRD,W?THEN,W?PERIOD /?THN37
	CALL	WT?,WRD,PS?PREPOSITION
	ZERO?	STACK /?ELS36
	ZERO?	FIRST?? \?ELS36
?THN37:	INC	'P-LEN
	ADD	NUM,1 >?TMP1
	MUL	PTR,2
	ADD	P-LEXV,STACK
	PUT	P-ITBL,?TMP1,STACK
	SUB	PTR,P-LEXELEN
	RETURN	STACK
?ELS36:	CALL	WT?,WRD,PS?OBJECT
	ZERO?	STACK /?ELS42
	CALL	WT?,WRD,PS?ADJECTIVE,P1?ADJECTIVE
	ZERO?	STACK /?ELS45
	ZERO?	NW /?ELS45
	CALL	WT?,NW,PS?OBJECT
	ZERO?	STACK /?ELS45
	JUMP	?CND17
?ELS45:	ZERO?	ANDFLG \?ELS49
	EQUAL?	NW,W?BUT,W?EXCEPT /?ELS49
	EQUAL?	NW,W?AND,W?COMMA /?ELS49
	ADD	NUM,1 >?TMP1
	ADD	PTR,2
	MUL	STACK,2
	ADD	P-LEXV,STACK
	PUT	P-ITBL,?TMP1,STACK
	RETURN	PTR
?ELS49:	SET	'ANDFLG,FALSE-VALUE
	JUMP	?CND17
?ELS42:	CALL	WT?,WRD,PS?ADJECTIVE
	ZERO?	STACK \?CND17
	CALL	WT?,WRD,PS?BUZZ-WORD
	ZERO?	STACK /?ELS55
	JUMP	?CND17
?ELS55:	ZERO?	ANDFLG /?ELS59
	CALL	WT?,WRD,PS?DIRECTION
	ZERO?	STACK \?THN62
	CALL	WT?,WRD,PS?VERB
	ZERO?	STACK /?ELS59
?THN62:	SUB	PTR,4 >PTR
	ADD	PTR,2
	PUT	P-LEXV,STACK,W?THEN
	ADD	P-LEN,2 >P-LEN
	JUMP	?CND17
?ELS59:	CALL	WT?,WRD,PS?PREPOSITION
	ZERO?	STACK /?ELS65
	JUMP	?CND17
?ELS65:	CALL	CANT-USE,PTR
	RFALSE	
?ELS19:	CALL	UNKNOWN-WORD,PTR
	RFALSE	
?CND17:	SET	'LW,WRD
	SET	'FIRST??,FALSE-VALUE
	ADD	PTR,P-LEXELEN >PTR
	JUMP	?PRG12


	.FUNCT	NUMBER?,PTR,CNT,BPTR,CHR,SUM=0,TIM=0,?TMP1
	MUL	PTR,2
	ADD	P-LEXV,STACK
	GETB	STACK,2 >CNT
	MUL	PTR,2
	ADD	P-LEXV,STACK
	GETB	STACK,3 >BPTR
?PRG1:	DLESS?	'CNT,0 \?ELS5
	JUMP	?REP2
?ELS5:	GETB	P-INBUF,BPTR >CHR
	EQUAL?	CHR,58 \?ELS10
	SET	'TIM,SUM
	SET	'SUM,0
	JUMP	?CND8
?ELS10:	GRTR?	SUM,10000 /FALSE
	LESS?	CHR,58 \FALSE
	GRTR?	CHR,47 \FALSE
	MUL	SUM,10 >?TMP1
	SUB	CHR,48
	ADD	?TMP1,STACK >SUM
?CND8:	INC	'BPTR
	JUMP	?PRG1
?REP2:	PUT	P-LEXV,PTR,W?INTNUM
	GRTR?	SUM,1000 /FALSE
	ZERO?	TIM /?CND19
	LESS?	TIM,8 \?ELS27
	ADD	TIM,12 >TIM
	JUMP	?CND25
?ELS27:	GRTR?	TIM,23 /FALSE
?CND25:	MUL	TIM,60
	ADD	SUM,STACK >SUM
?CND19:	SET	'P-NUMBER,SUM
	RETURN	W?INTNUM


	.FUNCT	ORPHAN-MERGE,CNT=-1,TEMP,VERB,BEG,END,ADJ=0,WRD,?TMP1
	SET	'P-OFLAG,FALSE-VALUE
	GET	P-ITBL,P-VERB >VERB
	ZERO?	VERB /?ELS3
	GET	P-OTBL,P-VERB
	EQUAL?	VERB,STACK \FALSE
?ELS3:	EQUAL?	P-NCN,2 /FALSE
	GET	P-OTBL,P-NC1
	EQUAL?	STACK,1 \?ELS9
	GET	P-ITBL,P-PREP1 >TEMP
	GET	P-OTBL,P-PREP1
	EQUAL?	TEMP,STACK /?THN13
	ZERO?	TEMP \FALSE
?THN13:	GET	P-ITBL,P-NC1
	PUT	P-OTBL,P-NC1,STACK
	GET	P-ITBL,P-NC1L
	PUT	P-OTBL,P-NC1L,STACK
	JUMP	?CND1
?ELS9:	GET	P-OTBL,P-NC2
	EQUAL?	STACK,1 \?ELS18
	GET	P-ITBL,P-PREP1 >TEMP
	GET	P-OTBL,P-PREP2
	EQUAL?	TEMP,STACK /?THN22
	ZERO?	TEMP \FALSE
?THN22:	GET	P-ITBL,P-NC1
	PUT	P-OTBL,P-NC2,STACK
	GET	P-ITBL,P-NC1L
	PUT	P-OTBL,P-NC2L,STACK
	SET	'P-NCN,2
	JUMP	?CND1
?ELS18:	ZERO?	P-ACLAUSE /?CND1
	EQUAL?	P-NCN,1 /?ELS31
	SET	'P-ACLAUSE,FALSE-VALUE
	RFALSE	
?ELS31:	GET	P-ITBL,P-NC1 >BEG
	GET	P-ITBL,P-NC1L >END
?PRG34:	EQUAL?	BEG,END \?ELS38
	ZERO?	ADJ /?ELS41
	CALL	ACLAUSE-WIN,ADJ
	JUMP	?CND29
?ELS41:	SET	'P-ACLAUSE,FALSE-VALUE
	RFALSE	
?ELS38:	ZERO?	ADJ \?ELS46
	GET	BEG,0 >WRD
	GETB	WRD,P-PSOFF
	BTST	STACK,PS?ADJECTIVE \?ELS46
	SET	'ADJ,WRD
	JUMP	?CND36
?ELS46:	GETB	WRD,P-PSOFF
	BTST	STACK,PS?OBJECT /?THN51
	EQUAL?	WRD,W?ONE \?CND36
?THN51:	EQUAL?	WRD,P-ANAM,W?ONE \FALSE
	CALL	ACLAUSE-WIN,ADJ
	JUMP	?CND29
?CND36:	ADD	BEG,P-WORDLEN >BEG
	JUMP	?PRG34
?CND29:	
?CND1:	
?PRG58:	IGRTR?	'CNT,P-ITBLLEN \?ELS62
	SET	'P-MERGED,TRUE-VALUE
	RTRUE	
?ELS62:	GET	P-OTBL,CNT
	PUT	P-ITBL,CNT,STACK
	JUMP	?PRG58


	.FUNCT	ACLAUSE-WIN,ADJ
	SET	'P-CCSRC,P-OTBL
	ADD	P-ACLAUSE,1
	CALL	CLAUSE-COPY,P-ACLAUSE,STACK,ADJ
	GET	P-OTBL,P-NC2
	ZERO?	STACK /?ELS2
	SET	'P-NCN,2
?ELS2:	SET	'P-ACLAUSE,FALSE-VALUE
	RTRUE	


	.FUNCT	WORD-PRINT,CNT,BUF
?PRG1:	DLESS?	'CNT,0 /TRUE
	GETB	P-INBUF,BUF
	PRINTC	STACK
	INC	'BUF
	JUMP	?PRG1


	.FUNCT	UNKNOWN-WORD,PTR,BUF,?TMP1
	EQUAL?	PRSA,V?SAY \?CND1
	PRINTI	"Nothing happens."
	CRLF	
	RFALSE	
?CND1:	PRINTI	"I don't know the word """
	MUL	PTR,2 >BUF
	ADD	P-LEXV,BUF
	GETB	STACK,2 >?TMP1
	ADD	P-LEXV,BUF
	GETB	STACK,3
	CALL	WORD-PRINT,?TMP1,STACK
	PRINTI	"""."
	CRLF	
	SET	'QUOTE-FLAG,FALSE-VALUE
	SET	'P-OFLAG,FALSE-VALUE
	RETURN	P-OFLAG


	.FUNCT	CANT-USE,PTR,BUF,?TMP1
	EQUAL?	PRSA,V?SAY \?CND1
	PRINTI	"Nothing happens."
	CRLF	
	RFALSE	
?CND1:	PRINTI	"You used the word """
	MUL	PTR,2 >BUF
	ADD	P-LEXV,BUF
	GETB	STACK,2 >?TMP1
	ADD	P-LEXV,BUF
	GETB	STACK,3
	CALL	WORD-PRINT,?TMP1,STACK
	PRINTI	""" in a way that I don't understand."
	CRLF	
	SET	'QUOTE-FLAG,FALSE-VALUE
	SET	'P-OFLAG,FALSE-VALUE
	RETURN	P-OFLAG


	.FUNCT	SYNTAX-CHECK,SYN,LEN,NUM,OBJ,DRIVE1=0,DRIVE2=0,PREP,VERB,TMP,?TMP2,?TMP1
	GET	P-ITBL,P-VERB >VERB
	ZERO?	VERB \?CND1
	PRINTI	"There was no verb in that sentence!"
	CRLF	
	RFALSE	
?CND1:	SUB	255,VERB
	GET	VERBS,STACK >SYN
	GETB	SYN,0 >LEN
	ADD	1,SYN >SYN
?PRG6:	GETB	SYN,P-SBITS
	BAND	STACK,P-SONUMS >NUM
	LESS?	NUM,1 /?ELS10
	ZERO?	P-NCN \?ELS10
	GET	P-ITBL,P-PREP1 >PREP
	ZERO?	PREP /?THN13
	GETB	SYN,P-SPREP1
	EQUAL?	PREP,STACK \?ELS10
?THN13:	SET	'DRIVE1,SYN
	JUMP	?CND8
?ELS10:	GETB	SYN,P-SPREP1 >?TMP1
	GET	P-ITBL,P-PREP1
	EQUAL?	?TMP1,STACK \?CND8
	EQUAL?	NUM,2 \?ELS19
	EQUAL?	P-NCN,1 \?ELS19
	SET	'DRIVE2,SYN
	JUMP	?CND8
?ELS19:	GETB	SYN,P-SPREP2 >?TMP1
	GET	P-ITBL,P-PREP2
	EQUAL?	?TMP1,STACK \?CND8
	CALL	SYNTAX-FOUND,SYN
	RTRUE	
?CND8:	DLESS?	'LEN,1 \?ELS26
	ZERO?	DRIVE1 \?REP7
	ZERO?	DRIVE2 /?ELS29
	JUMP	?REP7
?ELS29:	PRINTI	"That sentence isn't one I recognize."
	CRLF	
	RFALSE	
?ELS26:	ADD	SYN,P-SYNLEN >SYN
	JUMP	?PRG6
?REP7:	ZERO?	DRIVE1 /?ELS42
	GETB	DRIVE1,P-SFWIM1 >?TMP2
	GETB	DRIVE1,P-SLOC1 >?TMP1
	GETB	DRIVE1,P-SPREP1
	CALL	GWIM,?TMP2,?TMP1,STACK >OBJ
	ZERO?	OBJ /?ELS42
	PUT	P-PRSO,P-MATCHLEN,1
	PUT	P-PRSO,1,OBJ
	CALL	SYNTAX-FOUND,DRIVE1
	RSTACK	
?ELS42:	ZERO?	DRIVE2 /?ELS46
	GETB	DRIVE2,P-SFWIM2 >?TMP2
	GETB	DRIVE2,P-SLOC2 >?TMP1
	GETB	DRIVE2,P-SPREP2
	CALL	GWIM,?TMP2,?TMP1,STACK >OBJ
	ZERO?	OBJ /?ELS46
	PUT	P-PRSI,P-MATCHLEN,1
	PUT	P-PRSI,1,OBJ
	CALL	SYNTAX-FOUND,DRIVE2
	RSTACK	
?ELS46:	EQUAL?	VERB,ACT?FIND \?ELS50
	PRINTI	"That question can't be answered."
	CRLF	
	RFALSE	
?ELS50:	CALL	ORPHAN,DRIVE1,DRIVE2
	PRINTI	"What do you want to "
	GET	P-OTBL,P-VERBN >TMP
	ZERO?	TMP \?ELS59
	PRINTI	"tell"
	JUMP	?CND57
?ELS59:	GETB	P-VTBL,2
	ZERO?	STACK \?ELS63
	GET	TMP,0
	PRINTB	STACK
	JUMP	?CND57
?ELS63:	GETB	TMP,2 >?TMP1
	GETB	TMP,3
	CALL	WORD-PRINT,?TMP1,STACK
	PUTB	P-VTBL,2,0
?CND57:	ZERO?	DRIVE2 /?CND66
	CALL	CLAUSE-PRINT,P-NC1,P-NC1L
?CND66:	SET	'P-OFLAG,TRUE-VALUE
	ZERO?	DRIVE1 /?ELS74
	GETB	DRIVE1,P-SPREP1
	JUMP	?CND70
?ELS74:	GETB	DRIVE2,P-SPREP2
?CND70:	CALL	PREP-PRINT,STACK
	PRINTI	"?"
	CRLF	
	RFALSE	


	.FUNCT	ORPHAN,D1,D2,CNT=-1
	PUT	P-OCLAUSE,P-MATCHLEN,0
	SET	'P-CCSRC,P-ITBL
?PRG1:	IGRTR?	'CNT,P-ITBLLEN \?ELS5
	JUMP	?REP2
?ELS5:	GET	P-ITBL,CNT
	PUT	P-OTBL,CNT,STACK
	JUMP	?PRG1
?REP2:	EQUAL?	P-NCN,2 \?CND8
	CALL	CLAUSE-COPY,P-NC2,P-NC2L
?CND8:	LESS?	P-NCN,1 /?CND11
	CALL	CLAUSE-COPY,P-NC1,P-NC1L
?CND11:	ZERO?	D1 /?ELS18
	GETB	D1,P-SPREP1
	PUT	P-OTBL,P-PREP1,STACK
	PUT	P-OTBL,P-NC1,1
	RTRUE	
?ELS18:	ZERO?	D2 /FALSE
	GETB	D2,P-SPREP2
	PUT	P-OTBL,P-PREP2,STACK
	PUT	P-OTBL,P-NC2,1
	RTRUE	


	.FUNCT	CLAUSE-PRINT,BPTR,EPTR,?TMP1
	GET	P-ITBL,BPTR >?TMP1
	GET	P-ITBL,EPTR
	CALL	BUFFER-PRINT,?TMP1,STACK,TRUE-VALUE
	RSTACK	


	.FUNCT	BUFFER-PRINT,BEG,END,CP,NOSP=0,WRD,FIRST??=1,PN=0,?TMP1
?PRG1:	EQUAL?	BEG,END /TRUE
	ZERO?	NOSP /?ELS10
	SET	'NOSP,FALSE-VALUE
	JUMP	?CND8
?ELS10:	PRINTI	" "
?CND8:	GET	BEG,0 >WRD
	EQUAL?	WRD,W?PERIOD \?ELS18
	SET	'NOSP,TRUE-VALUE
	JUMP	?CND3
?ELS18:	ZERO?	FIRST?? /?CND21
	ZERO?	PN \?CND21
	ZERO?	CP /?CND21
	PRINTI	"the "
?CND21:	ZERO?	P-OFLAG /?ELS30
	PRINTB	WRD
	JUMP	?CND28
?ELS30:	EQUAL?	WRD,W?IT \?ELS33
	EQUAL?	P-IT-LOC,HERE \?ELS33
	PRINTD	P-IT-OBJECT
	JUMP	?CND28
?ELS33:	GETB	BEG,2 >?TMP1
	GETB	BEG,3
	CALL	WORD-PRINT,?TMP1,STACK
?CND28:	SET	'FIRST??,FALSE-VALUE
?CND3:	ADD	BEG,P-WORDLEN >BEG
	JUMP	?PRG1


	.FUNCT	CAPITALIZE,PTR,?TMP1
	GETB	PTR,3
	GETB	P-INBUF,STACK
	SUB	STACK,32
	PRINTC	STACK
	GETB	PTR,2
	SUB	STACK,1 >?TMP1
	GETB	PTR,3
	ADD	STACK,1
	CALL	WORD-PRINT,?TMP1,STACK
	RSTACK	


	.FUNCT	PREP-PRINT,PREP,WRD
	ZERO?	PREP /FALSE
	PRINTI	" "
	CALL	PREP-FIND,PREP >WRD
	PRINTB	WRD
	RTRUE	


	.FUNCT	CLAUSE-COPY,BPTR,EPTR,INSRT=0,BEG,END
	GET	P-CCSRC,BPTR >BEG
	GET	P-CCSRC,EPTR >END
	GET	P-OCLAUSE,P-MATCHLEN
	MUL	STACK,P-LEXELEN
	ADD	STACK,2
	ADD	P-OCLAUSE,STACK
	PUT	P-OTBL,BPTR,STACK
?PRG1:	EQUAL?	BEG,END \?ELS5
	GET	P-OCLAUSE,P-MATCHLEN
	MUL	STACK,P-LEXELEN
	ADD	STACK,2
	ADD	P-OCLAUSE,STACK
	PUT	P-OTBL,EPTR,STACK
	RTRUE	
?ELS5:	ZERO?	INSRT /?CND8
	GET	BEG,0
	EQUAL?	P-ANAM,STACK \?CND8
	CALL	CLAUSE-ADD,INSRT
?CND8:	GET	BEG,0
	CALL	CLAUSE-ADD,STACK
?CND3:	ADD	BEG,P-WORDLEN >BEG
	JUMP	?PRG1


	.FUNCT	CLAUSE-ADD,WRD,PTR
	GET	P-OCLAUSE,P-MATCHLEN
	ADD	STACK,2 >PTR
	SUB	PTR,1
	PUT	P-OCLAUSE,STACK,WRD
	PUT	P-OCLAUSE,PTR,0
	PUT	P-OCLAUSE,P-MATCHLEN,PTR
	RTRUE	


	.FUNCT	PREP-FIND,PREP,CNT=0,SIZE
	GET	PREPOSITIONS,0
	MUL	STACK,2 >SIZE
?PRG1:	IGRTR?	'CNT,SIZE /FALSE
	GET	PREPOSITIONS,CNT
	EQUAL?	STACK,PREP \?PRG1
	SUB	CNT,1
	GET	PREPOSITIONS,STACK
	RETURN	STACK


	.FUNCT	SYNTAX-FOUND,SYN
	SET	'P-SYNTAX,SYN
	GETB	SYN,P-SACTION >PRSA
	RETURN	PRSA


	.FUNCT	GWIM,GBIT,LBIT,PREP,OBJ
	EQUAL?	GBIT,RMUNGBIT \?CND1
	RETURN	ROOMS
?CND1:	SET	'P-GWIMBIT,GBIT
	SET	'P-SLOCBITS,LBIT
	PUT	P-MERGE,P-MATCHLEN,0
	CALL	GET-OBJECT,P-MERGE,FALSE-VALUE
	ZERO?	STACK /?ELS8
	SET	'P-GWIMBIT,0
	GET	P-MERGE,P-MATCHLEN
	EQUAL?	STACK,1 \FALSE
	GET	P-MERGE,1 >OBJ
	PRINTI	"("
	ZERO?	PREP /?CND16
	CALL	PREP-FIND,PREP
	PRINTB	STACK
	PRINTI	" the "
?CND16:	PRINTD	OBJ
	PRINTI	")"
	CRLF	
	RETURN	OBJ
?ELS8:	SET	'P-GWIMBIT,0
	RFALSE	


	.FUNCT	SNARF-OBJECTS,PTR
	GET	P-ITBL,P-NC1 >PTR
	ZERO?	PTR /?CND1
	GETB	P-SYNTAX,P-SLOC1 >P-SLOCBITS
	GET	P-ITBL,P-NC1L
	CALL	SNARFEM,PTR,STACK,P-PRSO
	ZERO?	STACK /FALSE
	GET	P-BUTS,P-MATCHLEN
	ZERO?	STACK /?CND1
	CALL	BUT-MERGE,P-PRSO >P-PRSO
?CND1:	GET	P-ITBL,P-NC2 >PTR
	ZERO?	PTR /TRUE
	GETB	P-SYNTAX,P-SLOC2 >P-SLOCBITS
	GET	P-ITBL,P-NC2L
	CALL	SNARFEM,PTR,STACK,P-PRSI
	ZERO?	STACK /FALSE
	GET	P-BUTS,P-MATCHLEN
	ZERO?	STACK /TRUE
	GET	P-PRSI,P-MATCHLEN
	EQUAL?	STACK,1 \?ELS18
	CALL	BUT-MERGE,P-PRSO >P-PRSO
	RTRUE	
?ELS18:	CALL	BUT-MERGE,P-PRSI >P-PRSI
	RTRUE	


	.FUNCT	BUT-MERGE,TBL,LEN,BUTLEN,CNT=1,MATCHES=0,OBJ,NTBL
	GET	TBL,P-MATCHLEN >LEN
	PUT	P-MERGE,P-MATCHLEN,0
?PRG1:	DLESS?	'LEN,0 \?ELS5
	JUMP	?REP2
?ELS5:	GET	TBL,CNT >OBJ
	CALL	ZMEMQ,OBJ,P-BUTS
	ZERO?	STACK /?ELS7
	JUMP	?CND3
?ELS7:	ADD	MATCHES,1
	PUT	P-MERGE,STACK,OBJ
	INC	'MATCHES
?CND3:	INC	'CNT
	JUMP	?PRG1
?REP2:	PUT	P-MERGE,P-MATCHLEN,MATCHES
	SET	'NTBL,P-MERGE
	SET	'P-MERGE,TBL
	RETURN	NTBL


	.FUNCT	SNARFEM,PTR,EPTR,TBL,BUT=0,LEN,WV,WRD,NW
	SET	'P-GETFLAGS,0
	SET	'P-CSPTR,PTR
	SET	'P-CEPTR,EPTR
	PUT	P-BUTS,P-MATCHLEN,0
	PUT	TBL,P-MATCHLEN,0
	GET	PTR,0 >WRD
?PRG1:	EQUAL?	PTR,EPTR \?ELS5
	ZERO?	BUT /?ORP9
	PUSH	BUT
	JUMP	?THN6
?ORP9:	PUSH	TBL
?THN6:	CALL	GET-OBJECT,STACK
	RETURN	STACK
?ELS5:	GET	PTR,P-LEXELEN >NW
	EQUAL?	WRD,W?ALL \?ELS14
	SET	'P-GETFLAGS,P-ALL
	EQUAL?	NW,W?OF \?CND12
	ADD	PTR,P-WORDLEN >PTR
	JUMP	?CND12
?ELS14:	EQUAL?	WRD,W?BUT,W?EXCEPT \?ELS19
	ZERO?	BUT /?ORP25
	PUSH	BUT
	JUMP	?THN22
?ORP25:	PUSH	TBL
?THN22:	CALL	GET-OBJECT,STACK
	ZERO?	STACK /FALSE
	SET	'BUT,P-BUTS
	PUT	BUT,P-MATCHLEN,0
	JUMP	?CND3
?ELS19:	EQUAL?	WRD,W?A,W?ONE \?ELS27
	ZERO?	P-ADJ \?ELS30
	SET	'P-GETFLAGS,P-ONE
	EQUAL?	NW,W?OF \?CND3
	ADD	PTR,P-WORDLEN >PTR
	JUMP	?CND3
?ELS30:	SET	'P-NAM,P-ONEOBJ
	ZERO?	BUT /?ORP41
	PUSH	BUT
	JUMP	?THN38
?ORP41:	PUSH	TBL
?THN38:	CALL	GET-OBJECT,STACK
	ZERO?	STACK /FALSE
	ZERO?	NW /TRUE
	JUMP	?CND3
?ELS27:	EQUAL?	WRD,W?AND,W?COMMA \?ELS45
	EQUAL?	NW,W?AND,W?COMMA /?ELS45
	ZERO?	BUT /?ORP53
	PUSH	BUT
	JUMP	?THN50
?ORP53:	PUSH	TBL
?THN50:	CALL	GET-OBJECT,STACK
	ZERO?	STACK \?CND12
	RFALSE	
?ELS45:	CALL	WT?,WRD,PS?BUZZ-WORD
	ZERO?	STACK /?ELS55
	JUMP	?CND3
?ELS55:	EQUAL?	WRD,W?AND,W?COMMA \?ELS57
	JUMP	?CND3
?ELS57:	EQUAL?	WRD,W?OF \?ELS59
	ZERO?	P-GETFLAGS \?CND12
	SET	'P-GETFLAGS,P-INHIBIT
	JUMP	?CND12
?ELS59:	CALL	WT?,WRD,PS?ADJECTIVE,P1?ADJECTIVE >WV
	ZERO?	WV /?ELS64
	ZERO?	P-ADJ \?ELS64
	SET	'P-ADJ,WV
	SET	'P-ADJN,WRD
	JUMP	?CND3
?ELS64:	CALL	WT?,WRD,PS?OBJECT,P1?OBJECT
	ZERO?	STACK /?CND3
	SET	'P-NAM,WRD
	SET	'P-ONEOBJ,WRD
?CND12:	
?CND3:	EQUAL?	PTR,EPTR /?PRG1
	ADD	PTR,P-WORDLEN >PTR
	SET	'WRD,NW
	JUMP	?PRG1


	.FUNCT	GET-OBJECT,TBL,VRB=1,BTS,LEN,XBITS,TLEN,GCHECK=0,OLEN=0
	SET	'XBITS,P-SLOCBITS
	GET	TBL,P-MATCHLEN >TLEN
	BTST	P-GETFLAGS,P-INHIBIT /TRUE
	ZERO?	P-NAM \?CND4
	ZERO?	P-ADJ /?CND4
	CALL	WT?,P-ADJN,PS?OBJECT,P1?OBJECT
	ZERO?	STACK /?ELS11
	SET	'P-NAM,P-ADJN
	SET	'P-ADJ,FALSE-VALUE
	JUMP	?CND4
?ELS11:	CALL	WT?,P-ADJN,PS?DIRECTION,P1?DIRECTION >BTS
	ZERO?	BTS /?CND4
	SET	'P-ADJ,FALSE-VALUE
	PUT	TBL,P-MATCHLEN,1
	PUT	TBL,1,INTDIR
	SET	'P-DIRECTION,BTS
	RTRUE	
?CND4:	ZERO?	P-NAM \?CND14
	ZERO?	P-ADJ \?CND14
	EQUAL?	P-GETFLAGS,P-ALL /?CND14
	ZERO?	P-GWIMBIT \?CND14
	ZERO?	VRB /FALSE
	PRINTI	"There seems to be a noun missing in that sentence!"
	CRLF	
	RFALSE	
?CND14:	EQUAL?	P-GETFLAGS,P-ALL \?THN28
	ZERO?	P-SLOCBITS \?CND25
?THN28:	SET	'P-SLOCBITS,-1
?CND25:	SET	'P-TABLE,TBL
?PRG30:	ZERO?	GCHECK /?ELS34
	CALL	GLOBAL-CHECK,TBL
	JUMP	?CND32
?ELS34:	ZERO?	LIT /?CND38
	CALL	DO-SL,HERE,SOG,SIR
?CND38:	CALL	DO-SL,WINNER,SH,SC
	EQUAL?	WINNER,PLAYER /?CND32
	CALL	DO-SL,PLAYER,SH,SC
?CND32:	GET	TBL,P-MATCHLEN
	SUB	STACK,TLEN >LEN
	BTST	P-GETFLAGS,P-ALL \?ELS47
	JUMP	?CND45
?ELS47:	BTST	P-GETFLAGS,P-ONE \?ELS49
	ZERO?	LEN /?ELS49
	EQUAL?	LEN,1 /?CND52
	RANDOM	LEN
	GET	TBL,STACK
	PUT	TBL,1,STACK
	PRINTI	"(How about the "
	GET	TBL,1
	PRINTD	STACK
	PRINTI	"?)"
	CRLF	
?CND52:	PUT	TBL,P-MATCHLEN,1
	JUMP	?CND45
?ELS49:	GRTR?	LEN,1 /?THN61
	ZERO?	LEN \?ELS60
	EQUAL?	P-SLOCBITS,-1 /?ELS60
?THN61:	EQUAL?	P-SLOCBITS,-1 \?ELS67
	SET	'P-SLOCBITS,XBITS
	SET	'OLEN,LEN
	GET	TBL,P-MATCHLEN
	SUB	STACK,LEN
	PUT	TBL,P-MATCHLEN,STACK
	JUMP	?PRG30
?ELS67:	ZERO?	LEN \?CND70
	SET	'LEN,OLEN
?CND70:	ZERO?	VRB /?ELS75
	ZERO?	P-NAM /?ELS75
	CALL	WHICH-PRINT,TLEN,LEN,TBL
	EQUAL?	TBL,P-PRSO \?ELS82
	PUSH	P-NC1
	JUMP	?CND78
?ELS82:	PUSH	P-NC2
?CND78:	SET	'P-ACLAUSE,STACK
	SET	'P-AADJ,P-ADJ
	SET	'P-ANAM,P-NAM
	CALL	ORPHAN,FALSE-VALUE,FALSE-VALUE
	SET	'P-OFLAG,TRUE-VALUE
	JUMP	?CND73
?ELS75:	ZERO?	VRB /?CND73
	PRINTI	"There seems to be a noun missing in that sentence!"
	CRLF	
?CND73:	SET	'P-NAM,FALSE-VALUE
	SET	'P-ADJ,FALSE-VALUE
	RFALSE	
?ELS60:	ZERO?	LEN \?ELS91
	ZERO?	GCHECK /?ELS91
	ZERO?	VRB /?CND94
	EQUAL?	WINNER,PLAYER /?ELS100
	PRINTI	"""I can't see that here!"""
	CRLF	
	JUMP	?CND94
?ELS100:	ZERO?	LIT /?ELS104
	PRINTI	"You can't see any"
	ZERO?	P-OFLAG /?ELS110
	ZERO?	P-ADJ /?CND112
	PRINTI	" "
	PRINTB	P-ADJN
?CND112:	ZERO?	P-NAM /?CND108
	PRINTI	" "
	PRINTB	P-NAM
	JUMP	?CND108
?ELS110:	CALL	BUFFER-PRINT,P-CSPTR,P-CEPTR,FALSE-VALUE
?CND108:	PRINTI	" here."
	CRLF	
	JUMP	?CND94
?ELS104:	PRINTI	"It's too dark to see."
	CRLF	
?CND94:	SET	'P-NAM,FALSE-VALUE
	SET	'P-ADJ,FALSE-VALUE
	RFALSE	
?ELS91:	ZERO?	LEN \?CND45
	SET	'GCHECK,TRUE-VALUE
	JUMP	?PRG30
?CND45:	SET	'P-ADJ,FALSE-VALUE
	SET	'P-NAM,FALSE-VALUE
	SET	'P-SLOCBITS,XBITS
	RTRUE	


	.FUNCT	WHICH-PRINT,TLEN,LEN,TBL,OBJ,RLEN
	SET	'RLEN,LEN
	PRINTI	"Which "
	PRINTB	P-NAM
	PRINTI	" do you mean, "
?PRG5:	INC	'TLEN
	GET	TBL,TLEN >OBJ
	PRINTI	"the "
	PRINTD	OBJ
	EQUAL?	LEN,2 \?ELS11
	EQUAL?	RLEN,2 /?CND12
	PRINTI	","
?CND12:	PRINTI	" or "
	JUMP	?CND9
?ELS11:	GRTR?	LEN,2 \?CND9
	PRINTI	", "
?CND9:	DLESS?	'LEN,1 \?PRG5
	PRINTR	"?"


	.FUNCT	GLOBAL-CHECK,TBL,LEN,RMG,RMGL,CNT=0,OBJ,OBITS,FOO
	GET	TBL,P-MATCHLEN >LEN
	SET	'OBITS,P-SLOCBITS
	GETPT	HERE,P?GLOBAL >RMG
	ZERO?	RMG /?CND1
	PTSIZE	RMG
	SUB	STACK,1 >RMGL
?PRG4:	GETB	RMG,CNT >OBJ
	CALL	THIS-IT?,OBJ,TBL
	ZERO?	STACK /?CND6
	CALL	OBJ-FOUND,OBJ,TBL
?CND6:	IGRTR?	'CNT,RMGL \?PRG4
?CND1:	GETPT	HERE,P?PSEUDO >RMG
	ZERO?	RMG /?CND12
	PTSIZE	RMG
	DIV	STACK,4
	SUB	STACK,1 >RMGL
	SET	'CNT,0
?PRG15:	MUL	CNT,2
	GET	RMG,STACK
	EQUAL?	P-NAM,STACK \?ELS19
	MUL	CNT,2
	ADD	STACK,1
	GET	RMG,STACK
	PUTP	PSEUDO-OBJECT,P?ACTION,STACK
	GETPT	PSEUDO-OBJECT,P?ACTION
	SUB	STACK,5 >FOO
	GET	P-NAM,0
	PUT	FOO,0,STACK
	GET	P-NAM,1
	PUT	FOO,1,STACK
	CALL	OBJ-FOUND,PSEUDO-OBJECT,TBL
	JUMP	?CND12
?ELS19:	IGRTR?	'CNT,RMGL \?PRG15
?CND12:	GET	TBL,P-MATCHLEN
	EQUAL?	STACK,LEN \FALSE
	SET	'P-SLOCBITS,-1
	SET	'P-TABLE,TBL
	CALL	DO-SL,GLOBAL-OBJECTS,1,1
	SET	'P-SLOCBITS,OBITS
	GET	TBL,P-MATCHLEN
	ZERO?	STACK \FALSE
	EQUAL?	PRSA,V?LOOK-INSIDE,V?SEARCH,V?EXAMINE \FALSE
	CALL	DO-SL,ROOMS,1,1
	RSTACK	


	.FUNCT	DO-SL,OBJ,BIT1,BIT2,BTS
	ADD	BIT1,BIT2
	BTST	P-SLOCBITS,STACK \?ELS5
	CALL	SEARCH-LIST,OBJ,P-TABLE,P-SRCALL
	RSTACK	
?ELS5:	BTST	P-SLOCBITS,BIT1 \?ELS12
	CALL	SEARCH-LIST,OBJ,P-TABLE,P-SRCTOP
	RSTACK	
?ELS12:	BTST	P-SLOCBITS,BIT2 \TRUE
	CALL	SEARCH-LIST,OBJ,P-TABLE,P-SRCBOT
	RSTACK	


	.FUNCT	SEARCH-LIST,OBJ,TBL,LVL,FLS,NOBJ
	FIRST?	OBJ >OBJ \FALSE
?PRG6:	EQUAL?	LVL,P-SRCBOT /?CND8
	GETPT	OBJ,P?SYNONYM
	ZERO?	STACK /?CND8
	CALL	THIS-IT?,OBJ,TBL
	ZERO?	STACK /?CND8
	CALL	OBJ-FOUND,OBJ,TBL
?CND8:	EQUAL?	LVL,P-SRCTOP \?THN18
	FSET?	OBJ,SEARCHBIT /?THN18
	FSET?	OBJ,SURFACEBIT \?CND13
?THN18:	FIRST?	OBJ >NOBJ \?CND13
	FSET?	OBJ,OPENBIT /?THN20
	FSET?	OBJ,TRANSBIT \?CND13
?THN20:	FSET?	OBJ,SURFACEBIT \?ELS26
	PUSH	P-SRCALL
	JUMP	?CND22
?ELS26:	FSET?	OBJ,SEARCHBIT \?ELS28
	PUSH	P-SRCALL
	JUMP	?CND22
?ELS28:	PUSH	P-SRCTOP
?CND22:	CALL	SEARCH-LIST,OBJ,TBL,STACK >FLS
?CND13:	NEXT?	OBJ >OBJ /?PRG6
	RTRUE	


	.FUNCT	OBJ-FOUND,OBJ,TBL,PTR
	GET	TBL,P-MATCHLEN >PTR
	ADD	PTR,1
	PUT	TBL,STACK,OBJ
	ADD	PTR,1
	PUT	TBL,P-MATCHLEN,STACK
	RTRUE	


	.FUNCT	TAKE-CHECK
	GETB	P-SYNTAX,P-SLOC1
	CALL	ITAKE-CHECK,P-PRSO,STACK
	ZERO?	STACK /FALSE
	GETB	P-SYNTAX,P-SLOC2
	CALL	ITAKE-CHECK,P-PRSI,STACK
	RSTACK	


	.FUNCT	ITAKE-CHECK,TBL,BTS,PTR,OBJ,TAKEN
	GET	TBL,P-MATCHLEN >PTR
	ZERO?	PTR /TRUE
	BTST	BTS,STAKE \TRUE
?PRG8:	DLESS?	'PTR,0 /TRUE
	ADD	PTR,1
	GET	TBL,STACK >OBJ
	EQUAL?	OBJ,IT \?CND15
	SET	'OBJ,P-IT-OBJECT
?CND15:	IN?	OBJ,WINNER /?PRG8
	SET	'PRSO,OBJ
	FSET?	OBJ,TRYTAKEBIT \?ELS23
	SET	'TAKEN,TRUE-VALUE
	JUMP	?CND21
?ELS23:	CALL	ITAKE,FALSE-VALUE
	EQUAL?	STACK,TRUE-VALUE \?ELS25
	SET	'TAKEN,FALSE-VALUE
	JUMP	?CND21
?ELS25:	SET	'TAKEN,TRUE-VALUE
?CND21:	ZERO?	TAKEN /?ELS30
	BTST	BTS,SHAVE \?ELS30
	PRINTI	"You don't have the "
	PRINTD	OBJ
	PRINTI	"."
	CRLF	
	RFALSE	
?ELS30:	ZERO?	TAKEN \?PRG8
	PRINTI	"(Taken)"
	CRLF	
	JUMP	?PRG8


	.FUNCT	MANY-CHECK,LOSS=0,TMP,?TMP1
	GET	P-PRSO,P-MATCHLEN
	GRTR?	STACK,1 \?ELS3
	GETB	P-SYNTAX,P-SLOC1
	BTST	STACK,SMANY /?ELS3
	SET	'LOSS,1
	JUMP	?CND1
?ELS3:	GET	P-PRSI,P-MATCHLEN
	GRTR?	STACK,1 \?CND1
	GETB	P-SYNTAX,P-SLOC2
	BTST	STACK,SMANY /?CND1
	SET	'LOSS,2
?CND1:	ZERO?	LOSS /TRUE
	PRINTI	"You can't use multiple "
	EQUAL?	LOSS,2 \?CND18
	PRINTI	"in"
?CND18:	PRINTI	"direct objects with """
	GET	P-ITBL,P-VERBN >TMP
	ZERO?	TMP \?ELS27
	PRINTI	"tell"
	JUMP	?CND25
?ELS27:	ZERO?	P-OFLAG \?THN32
	ZERO?	P-MERGED /?ELS31
?THN32:	GET	TMP,0
	PRINTB	STACK
	JUMP	?CND25
?ELS31:	GETB	TMP,2 >?TMP1
	GETB	TMP,3
	CALL	WORD-PRINT,?TMP1,STACK
?CND25:	PRINTI	"""."
	CRLF	
	RFALSE	


	.FUNCT	ZMEMQ,ITM,TBL,SIZE=-1,CNT=1
	ZERO?	TBL /FALSE
	LESS?	SIZE,0 /?ELS6
	SET	'CNT,0
	JUMP	?CND4
?ELS6:	GET	TBL,0 >SIZE
?CND4:	
?PRG9:	GET	TBL,CNT
	EQUAL?	ITM,STACK /TRUE
	IGRTR?	'CNT,SIZE \?PRG9
	RFALSE	


	.FUNCT	ZMEMQB,ITM,TBL,SIZE,CNT=0
?PRG1:	GETB	TBL,CNT
	EQUAL?	ITM,STACK /TRUE
	IGRTR?	'CNT,SIZE \?PRG1
	RFALSE	


	.FUNCT	LIT?,RM,OHERE,LIT=0
	SET	'P-GWIMBIT,ONBIT
	SET	'OHERE,HERE
	SET	'HERE,RM
	FSET?	RM,ONBIT \?ELS3
	SET	'LIT,TRUE-VALUE
	JUMP	?CND1
?ELS3:	PUT	P-MERGE,P-MATCHLEN,0
	SET	'P-TABLE,P-MERGE
	SET	'P-SLOCBITS,-1
	EQUAL?	OHERE,RM \?CND6
	CALL	DO-SL,WINNER,1,1
?CND6:	CALL	DO-SL,RM,1,1
	GET	P-TABLE,P-MATCHLEN
	GRTR?	STACK,0 \?CND1
	SET	'LIT,TRUE-VALUE
?CND1:	SET	'HERE,OHERE
	SET	'P-GWIMBIT,0
	RETURN	LIT


	.FUNCT	PRSO-PRINT,PTR
	ZERO?	P-MERGED \?THN6
	GET	P-ITBL,P-NC1 >PTR
	GET	PTR,0
	EQUAL?	STACK,W?IT \?ELS5
?THN6:	PRINTI	" "
	PRINTD	PRSO
	RTRUE	
?ELS5:	GET	P-ITBL,P-NC1L
	CALL	BUFFER-PRINT,PTR,STACK,FALSE-VALUE
	RSTACK	


	.FUNCT	PRSI-PRINT,PTR
	ZERO?	P-MERGED \?THN6
	GET	P-ITBL,P-NC2 >PTR
	GET	PTR,0
	EQUAL?	STACK,W?IT \?ELS5
?THN6:	PRINTI	" "
	PRINTD	PRSO
	RTRUE	
?ELS5:	GET	P-ITBL,P-NC2L
	CALL	BUFFER-PRINT,PTR,STACK,FALSE-VALUE
	RSTACK	


	.FUNCT	THIS-IT?,OBJ,TBL,SYNS,?TMP1
	FSET?	OBJ,INVISIBLE /FALSE
	ZERO?	P-NAM /?ELS5
	GETPT	OBJ,P?SYNONYM >SYNS
	PTSIZE	SYNS
	DIV	STACK,2
	SUB	STACK,1
	CALL	ZMEMQ,P-NAM,SYNS,STACK
	ZERO?	STACK /FALSE
?ELS5:	ZERO?	P-ADJ /?ELS9
	GETPT	OBJ,P?ADJECTIVE >SYNS
	ZERO?	SYNS /FALSE
	PTSIZE	SYNS
	SUB	STACK,1
	CALL	ZMEMQB,P-ADJ,SYNS,STACK
	ZERO?	STACK /FALSE
?ELS9:	ZERO?	P-GWIMBIT /TRUE
	FSET?	OBJ,P-GWIMBIT /TRUE
	RFALSE	

	.ENDI
