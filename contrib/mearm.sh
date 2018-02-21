#! /usr/bin/env bash

set -u

# mearm.sh - Control a Mime Industries MeArm from bash, via servoblaster.
#            The intended versoin of servoblaster is that from
#            https://github.com/srcshelton/servoblaster

declare delay="${DELAY:-0.1}"
declare -i step=${STEP:-1}
declare -i debug=${DEBUG:-0}

function die() {
	echo >&2 "FATAL: ${*:-Unknown error}"
	exit 1
} # die

function main() {
	local -a args=( "${@}" )
	local -i pin start end position direction

	if [[ "${args[*]}" =~ -(h|-help) ]] || (( ${#args[@]} != 3 )); then
		echo "Usage: $( basename "${0}" ) <component> <start> <end>"
		echo "       component may be 'base', 'lower-arm', 'upper-arm',"
		echo "       or 'claw'."
		echo "       positions may be 'open', 'close', 'left', 'right',"
		echo "       'up', down', 'centre', 'middle' or a percentage."
		if [[ "${args[*]}" =~ -(h|-help) ]]; then
			exit 0
		else
			exit 1
		fi
	fi

	[[ -w /dev/servoblaster ]] || die "Cannot write to /dev/servoblaster"

	pin=9
	case "${args[0]}" in
		b|base)
			pin=0
			;;
		u|upper-arm|upperarm|upper)
			pin=1
			;;
		l|lower-arm|lowerarm|lower)
			pin=2
			;;
		c|claw|hand|gipper)
			pin=3
			;;
		*)
			die "Unknown component '${args[0]}'"
			;;
	esac
	(( debug )) && echo >&2 "DEBUG: pin is ${pin}"

	start=999
	case "${args[1]}" in
		open|opened)
			case "${pin}" in
				3)
					start=0
					;;
				*)
					die "'${args[1]}' is only valid for component 'claw'"
					;;
			esac
			;;
		right)
			case "${pin}" in
				0)
					start=0
					;;
				*)
					die "'${args[1]}' is only valid for component 'base'"
					;;
			esac
			;;
		up|top)
			case "${pin}" in
				1)
					start=75
					;;
				2)
					start=25
					;;
				*)
					die "'${args[1]}' is only valid for components 'upper-arm', 'lower-arm'"
					;;
			esac
			;;

		close|closed)
			case "${pin}" in
				3)
					start=100
					;;
				*)
					die "'${args[1]}' is only valid for component 'claw'"
					;;
			esac
			;;
		left)
			case "${pin}" in
				0)
					start=100
					;;
				*)
					die "'${args[1]}' is only valid for component 'base'"
					;;
			esac
			;;
		down|bottom)
			case "${pin}" in
				1)
					start=25
					;;
				2)
					start=75
					;;
				*)
					die "'${args[1]}' is only valid for components 'upper-arm', 'lower-arm'"
					;;
			esac
			;;

		centre|center|middle)
			start=50
			;;
		[0-9]*)
			(( start = ${args[1]} ))
			if (( 0 == start )) && ! [[ "0" == "${args[1]}" ]]; then
				die "Unrecognised starting percentage '${args[1]}'"
			fi
			;;
		*)
			die "Unrecognised starting percentage '${args[1]}'"
			;;
	esac
	(( debug )) && echo >&2 "DEBUG: start is ${start}"

	end=999
	case "${args[2]}" in
		open|opened)
			case "${pin}" in
				3)
					end=0
					;;
				*)
					die "'${args[1]}' is only valid for component 'claw'"
					;;
			esac
			;;
		right)
			case "${pin}" in
				0)
					end=0
					;;
				*)
					die "'${args[1]}' is only valid for component 'base'"
					;;
			esac
			;;
		up|top)
			case "${pin}" in
				1)
					end=75
					;;
				2)
					end=25
					;;
				*)
					die "'${args[1]}' is only valid for components 'upper-arm', 'lower-arm'"
					;;
			esac
			;;

		close|closed)
			case "${pin}" in
				3)
					end=100
					;;
				*)
					die "'${args[1]}' is only valid for component 'claw'"
					;;
			esac
			;;
		left)
			case "${pin}" in
				0)
					end=100
					;;
				*)
					die "'${args[1]}' is only valid for component 'base'"
					;;
			esac
			;;
		down|bottom)
			case "${pin}" in
				1)
					end=25
					;;
				2)
					end=75
					;;
				*)
					die "'${args[1]}' is only valid for components 'upper-arm', 'lower-arm'"
					;;
			esac
			;;

		centre|center|middle)
			end=50
			;;
		[0-9]*)
			(( end = ${args[2]} ))
			if (( 0 == end )) && ! [[ "0" == "${args[2]}" ]]; then
				die "Unrecognised ending percentage '${args[2]}'"
			fi
			;;
		*)
			die "Unrecognised ending percentage '${args[2]}'"
			;;
	esac
	(( debug )) && echo >&2 "DEBUG: end is ${end}"

	echo "${pin}=${start}%" > /dev/servoblaster

	if (( start == end )); then
		echo "Starting end ending places are the same - nothing to do"
		exit 0
	fi

	(( position = start ))
	sleep 1
	if (( position < end )); then
		direction=1
	else
		direction=0
	fi

	while true; do
		(( debug )) && echo >&2 "DEBUG: Step starts with direction ${direction}, position ${position}, end ${end}"

		if (( 0 == direction )) && (( position > end )); then
			(( position -= step ))
		elif (( 1 == direction )) && (( position < end )); then
			(( position += step ))
		else # position == end, or overshot
			echo "Done"
			exit 0
		fi
		echo "${pin}=${position}%" > /dev/servoblaster
		sleep "${delay}"
	done
} # main

main "${@:-}"

exit ${?}
