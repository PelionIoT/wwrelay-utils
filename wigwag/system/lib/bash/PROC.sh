#!/bin/bash

LOCKDIR=/var/lock

PROC_block(){
	local lock="$1"
	log debug	"lockfile-create -r 0 $LOCKDIR/$lock"
	lockfile-check "$LOCKDIR/$lock"
	if [[ $? -eq 0 ]]; then
		echo 2
	else
		lockfile-create -r 0 "$LOCKDIR/$lock"
		if [[ $? -eq 0 ]]; then
			log info "Lockfile: locked"
			echo 1
		else
			echo 0
		fi
	fi
}

PROC_unblock(){
	local lock="$1"
	lockfile-remove "$LOCKDIR/$lock"
	if [[ $? -eq 0 ]]; then
		log info "Lockfile: unlocked"
		return 0
	else
		return 1
	fi
}

PROC_updateblock(){
	local lock="$1"
	lockfile-touch -o "$LOCKDIR/$lock"
	if [[ $? -eq 0 ]]; then
		log info "Lockfile: updated lock"
		return 0
	else
		return 1
	fi
}