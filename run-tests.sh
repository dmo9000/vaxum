TESTS="tests/test1.zil tests/test2.zil tests/test3.zil tests/test4.zil tests/test5.zil tests/test6.zil tests/test7.zil tests/test8.zil games/zork1/zork1.zil games/zork2/zork2.zil games/zork3/zork3.zil games/enchanter/enchanter.zil games/witness/witness.zil games/deadline/deadline.zil"

for ZIL in ${TESTS} ; do 
	echo -n "Compiling ${ZIL} ... "
	./vaxum.exe -d 0 ${ZIL} 1>/dev/null 2>&1
	STATUS=$?
	echo "${STATUS}"
done
