#!/bin/bash

frida-ps -Uia | grep "$1"
