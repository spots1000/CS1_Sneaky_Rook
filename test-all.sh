#!/bin/bash


# Sean Szumlanski
# COP 3502, Fall 2018

# ========================
# SneakyRooks: test-all.sh
# ========================
# You can run this script at the command line like so:
#
#   bash test-all.sh
#
# For more details, see the assignment PDF.


################################################################################
# Shell check.
################################################################################

# Running this script with sh instead of bash can lead to false positives on the
# test cases. Yikes! These checks ensure the script is not being run through the
# Bourne shell (or any shell other than bash).

if [ "$BASH" != "/bin/bash" ]; then
  echo ""
  echo " Bloop! Please use bash to run this script, like so: bash test-all.sh"
  echo ""
  exit
fi

if [ -z "$BASH_VERSION" ]; then
  echo ""
  echo " Bloop! Please use bash to run this script, like so: bash test-all.sh"
  echo ""
  exit
fi


################################################################################
# Initialization.
################################################################################

PASS_CNT=0
NUM_TEST_CASES=4
TOTAL_TEST_CNT=8  # Each test case is run twice: standard test and valgrind.


################################################################################
# Magical incantations.
################################################################################

# Ensure that obnoxious glibc errors are piped to stderr.
export LIBC_FATAL_STDERR_=1

# Now redirect all local error messages to /dev/null (like "process aborted").
exec 2> /dev/null


################################################################################
# Check that all required files are present.
################################################################################

if [ ! -f SneakyRooks.c ]; then
	echo ""
	echo " Error: You must place SneakyRooks.c in this directory before"
	echo "        we can proceed. Aborting test script."
	echo ""
	exit
elif [ ! -f SneakyRooks.h ]; then
	echo ""
	echo " Error: You must place SneakyRooks.h in this directory before"
	echo "        we can proceed. Aborting test script."
	echo ""
	exit
elif [ ! -d sample_output ]; then
	echo ""
	echo " Error: You must place the sample_output folder in this directory"
	echo "        before we can proceed. Aborting test script."
	echo ""
	exit
fi

for i in `seq -f "%02g" 1 $NUM_TEST_CASES`;
do
	if [ ! -f testcase$i.c ]; then
		echo ""
		echo " Error: You must place testcase$i.c in this directory before we"
		echo "        can proceed. Aborting test script."
		echo ""
		exit
	fi
done

for i in `seq -f "%02g" 1 $NUM_TEST_CASES`;
do
	if [ ! -f sample_output/output$i.txt ]; then
		echo ""
		echo " Error: You must place output$i.txt in the sample_output directory"
		echo "        before we can proceed. Aborting test script."
		echo ""
		exit
	fi
done


################################################################################
# Run test cases.
################################################################################

echo ""
echo "================================================================"
echo "Running test cases..."
echo "================================================================"
echo ""

for i in `seq -f "%02g" 1 $NUM_TEST_CASES`;
do
	echo -n "  [Test Case] Checking testcase$i.c .... "

	# Attempt to compile.
	gcc SneakyRooks.c testcase$i.c 2> /dev/null
	compile_val=$?
	if [[ $compile_val != 0 ]]; then
		echo "fail (failed to compile)"
		continue
	fi

	# Run program. Capture return value to check whether it crashes.
	./a.out > myoutput.txt 2> /dev/null
	execution_val=$?
	if [[ $execution_val != 0 ]]; then
		echo "fail (program crashed)"
		continue
	fi

	# Run diff and capture its return value.
	diff myoutput.txt sample_output/output$i.txt > /dev/null
	diff_val=$?
	
	# Output results based on diff's return value.
	if  [[ $diff_val != 0 ]]; then
		echo "fail (output does not match)"
	else
		echo "PASS!"
		PASS_CNT=`expr $PASS_CNT + 1`
	fi
done


################################################################################
# Check for memory leaks: run test cases through valgrind.
################################################################################

echo ""
echo "================================================================"
echo "Checking for memory leaks with valgrind..."
echo "================================================================"
echo ""

for i in `seq -f "%02g" 1 $NUM_TEST_CASES`;
do
	echo -n "  [Memory Leak Check] $testcase_file ... "

	# Attempt to compile.
	gcc SneakyRooks.c testcase$i.c -g 2> /dev/null
	compile_val=$?
	if [[ $compile_val != 0 ]]; then
		echo "fail (failed to compile)"
		continue
	fi

	# Run program through valgrind. Check whether program crashes.
	valgrind --leak-check=yes ./a.out > myoutput.txt 2> err.log
	execution_val=$?
	if [[ $execution_val != 0 ]]; then
		echo "fail (program crashed)"
		continue
	fi

	# Check output for indication of memory leaks.
	grep --silent "no leaks are possible" err.log
	valgrindfail=$?
	if [[ $valgrindfail != 0 ]]; then
		echo "fail (memory leak detected)"
		continue
	fi

	# Run diff and capture its return value.
	diff myoutput.txt sample_output/output$i.txt > /dev/null
	diff_val=$?
	
	# Output results based on diff's return value.
	if  [[ $diff_val != 0 ]]; then
		echo "fail (output mismatch)"
	else
		echo "PASS!"
		PASS_CNT=`expr $PASS_CNT + 1`
	fi
done


############################################################################
# Check for warnings.
############################################################################

echo ""
echo "================================================================"
echo "Checking for compiler warnings..."
echo "================================================================"
echo ""

gcc SneakyRooks.c -c &> ./err.log
compile_flag=$?

if [[ $compile_flag != 0 ]]; then
	echo "  Failed to compile."
else
	grep --silent "warning" err.log
	warnings_flag=$?

	if [[ $warnings_flag == 0 ]]; then
		echo "  Warnings detected. :("
	else
		echo "  No warnings detected. Hooray!"
	fi
fi


################################################################################
# Cleanup phase.
################################################################################

# Clean up the executable file.
rm -f a.out

# Clean up the output file generated by this script.
rm -f myoutput.txt

# Remove error log generated by warning check.
rm -f err.log


################################################################################
# Final thoughts.
################################################################################

echo ""
echo "================================================================"
echo "Final Report"
echo "================================================================"

if [ $PASS_CNT -eq $TOTAL_TEST_CNT ]; then
	echo ""
	echo "              ,)))))))),,,"
	echo "            ,(((((((((((((((,"
	echo "            )\\\`\\)))))))))))))),"
	echo "     *--===///\`_    \`\`\`((((((((("
	echo "           \\\\\\ b\\  \\    \`\`)))))))"
	echo "            ))\\    |     ((((((((               ,,,,"
	echo "           (   \\   |\`.    ))))))))       ____ ,)))))),"
	echo "                \\, /  )  ((((((((-.___.-\"    \`\"((((((("
	echo "                 \`\"  /    )))))))               \\\`)))))"
	echo "                    /    ((((\`\`                  \\((((("
	echo "              _____|      \`))         /          |)))))"
	echo "             /     \\                 |          / ((((("
	echo "            /  --.__)      /        _\\         /   )))))"
	echo "           /  /    /     /'\`\"~----~\`  \`.       \\   (((("
	echo "          /  /    /     /\`              \`-._    \`-. \`)))"
	echo "         /_ (    /    /\`                    \`-._   \\ (("
	echo "        /__|\`   /   /\`                        \`\\\`-. \\ ')"
	echo "               /  /\`                            \`\\ \\ \\"
	echo "              /  /                                \\ \\ \\"
	echo "             /_ (                                 /_()_("
	echo "            /__|\`                                /__/__|"
	echo ""
	echo "                             Legendary."
	echo ""
	echo "                10/10 would run this program again."
	echo ""
	echo "  CONGRATULATIONS! You appear to be passing all required test"
	echo "  cases! (Now, don't forget to create some extra test cases of"
	echo "  your own. These test cases are not necessarily comprehensive.)"
	echo ""
else
	echo "                           ."
	echo "                          \":\""
	echo "                        ___:____     |\"\\/\"|"
	echo "                      ,'        \`.    \\  /"
	echo "                      |  o        \\___/  |"
	echo "                    ~^~^~^~^~^~^~^~^~^~^~^~^~"
	echo ""
	echo "                           (fail whale)"
	echo ""
	echo "  The fail whale is friendly and adorable! He is not here to"
	echo "  demoralize you, but rather, to bring you comfort and joy"
	echo "  in your time of need. \"Keep plugging away,\" he says! \"You"
	echo "  can do this!\""
	echo ""
	echo "  For instructions on how to run these test cases individually"
	echo "  and inspect how your output differs from the expected output,"
	echo "  be sure to consult the assignment PDF."
	echo ""
fi
