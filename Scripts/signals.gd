extends Node

signal request_screen_change(screen: int)
signal request_exit

var current_screen = 0

var already_been_in_setup = false
