#!/bin/bash

infocmp xterm-256color | sed 's/clear=[^,]*,/clear=\\E[H\\E[2J\\E[3J,/' | tic -
