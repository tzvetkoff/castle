#!/bin/bash

stop_spotlight_for_volume() {
	if [[ -d "${1}" ]]; then
		mdutil -E -i off "${1}"
	fi
}

stop_spotlight_for_volume '/Volumes/Storage'
