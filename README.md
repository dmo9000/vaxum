# vaxum ZIL compiler 

An experimental Infocom ZIL compiler, intended to one day have multiple backends, in order of descending importance: 

	Generic C++
	Inform6/Inform7 
	Z-Machine Zcode
	Generic C
	C (using VBCC which has it's own Z-Machine backend)

Example games can be found in the games/ subdirectory. 

The .record files appear to the output of the original compiler (ie. logs). 
The toplevel file fed to the compiler should be listed in the compile log for each game.
eg. for ZORK1, the file is games/zork1/zork1.zil

# vaxum ZIL compiler
