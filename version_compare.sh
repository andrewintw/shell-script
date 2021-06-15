#! /bin/sh


get_ver_digit() {
	local ver="$1"
	local pos="$2"
	local digit=`echo $ver | cut -d '.' -f $pos`

	if [ "$digit" = "" ]; then
		digit=0
	fi

	digit=`expr $digit + 0`

	printf "%d" "$digit"
}

version_compare() {
	# <version core> ::= <major> "." <minor> "." <patch>
	local v1="$1"
	local v2="$2"

	v1_major=`get_ver_digit $v1 1`
	v1_minor=`get_ver_digit $v1 2`
	v1_patch=`get_ver_digit $v1 3`

	v2_major=`get_ver_digit $v2 1`
	v2_minor=`get_ver_digit $v2 2`
	v2_patch=`get_ver_digit $v2 3`

	#echo "v1:[$v1_major].[$v1_minor].[$v1_patch]"
	#echo "v2:[$v2_major].[$v2_minor].[$v2_patch]"

	if [ "${v1_major}.${v1_minor}.${v1_patch}" = "${v2_major}.${v2_minor}.${v2_patch}" ]; then
		return 0
	fi

	diff_major="$(( $v2_major - $v1_major ))"
	diff_minor="$(( $v2_minor - $v1_minor ))"
	diff_patch="$(( $v2_patch - $v1_patch ))"

	if [ $diff_major -gt 0 ]; then
		return 2
	elif [ $diff_major -lt 0 ]; then
		return 1
	fi

	if [ $diff_minor -gt 0 ]; then
		return 2
	elif [ $diff_minor -lt 0 ]; then
		return 1
	fi
	
	if [ $diff_patch -gt 0 ]; then
		return 2
	elif [ $diff_patch -lt 0 ]; then
		return 1
	fi
}

test_version_compare() {
	local v1="$1"
	local v2="$2"
	local exp="$3"
	local op=''

	version_compare "$v1" "$v2"
	case $? in
		0) op='=';;
		1) op='>';;
		2) op='<';;
	esac

	if [ "$op" = "$exp" ]; then
		echo "PASS> $v1 $op $v2"
	else
		echo "FAIL> $v1 is NOT $exp $v2"
	fi
}

do_test() {

cat << EOF
-------------------------------
The following tests should pass
-------------------------------

EOF

	while read -r test_list; do
		test_version_compare $test_list
	done << EOF
5.6.7        5.6.7        =
1.01.1       1.1.1        =
1.1.1        1.01.1       =
1.0.0        1.0.         =
1..0         1.0          =
1.0          1..0         =
0.1.0        .1.          =
4.08.0       4.08.01      <
16.00.09     16.00.08     >
16.00.08     16.00.09     <
2.2.0        2.10.0       <
3.0.10       3.0.2        >
3.2.8144     3.2.0        >
3.2.0        3.2.8144     <
1.2.0        2.1.0        <
2.1.0        1.2.0        >
8.9.10       9.8.2        <
9.8.2        8.9.10       >
7.8.9        7.9.8        <
7.9.8        7.8.9        >
EOF

cat << EOF
------------------------------
The following test should fail
------------------------------

EOF
	test_version_compare 1 1 '>'
	test_version_compare "0.2.0" "0.10.0" '>'
}

do_main() {
	do_test
}

do_main
