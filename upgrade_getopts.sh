#! /bin/sh

# This is a simulation for upgrading firmware. 
# you can choose a partition for writing a firmware image. 
# And also decide to do reset-to-default or reboot system after upgrade procedure is complete or not.

part_no=''
is_do_r2d=0
is_do_reboot=0
image_name=''

show_usage() {
	cat <<EOF

Usage:
      $0 [-p PART_NO] [-d] [-r] [PATH_TO_IMAGE]

Params:
       -p PART_NO  # firmware partition { 1: firmware1; 2: firmware2: 3:both }
       -d          # reset to default (before reboot) after the upgrade is complete
       -r          # reboot after the upgrade is complete

EOF
}

do_getopts () {
	local OPTIND
	while getopts "drhp:": opt; do
		case "$opt" in
			p)
				p="$OPTARG"
				part_no=$p
				;;
			r)
				r="$OPTARG"
				is_do_reboot=1
				;;
			d)
				d="$OPTARG"
				is_do_r2d=1
				;;
			h)
				show_usage
				exit 0
				;;
			?)
				echo "Error: Invalid option" >&2
				show_usage
				exit 1
				;;
		esac
	done

	shift "$((OPTIND-1))"

	image_name="$1"
}

show_summary() {
	[ "$image_name" = "" ] && image_name="/tmp/firmware.img"
	[ "$part_no" = "" ] && part_no=1

	cat <<EOF

partition No:     `[ "$part_no" -gt "3" ] && echo "BOTH" || echo "firmware${part_no}"`
reset-to-default: `[ "$is_do_r2d" = "1" ] && echo "Yes" || echo "No"`
reboot:           `[ "$is_do_reboot" = "1" ] && echo "Yes" || echo ""No`
image name:       $image_name

EOF
}

do_main () {
	do_getopts "$@" && \
	show_summary
}

do_main "$@"

