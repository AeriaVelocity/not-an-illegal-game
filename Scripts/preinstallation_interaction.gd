extends ColorRect

var current_screen = 1
var previous_screen = 0

var current_node: Control
var previous_node: Control

var is_ready = false
var colour_removed = false

@onready var animations = $AnimationPlayer

func _ready():
    animations.play("appear")
    await animations.animation_finished
    is_ready = true

func _input(event):
    if not is_ready:
        return

    var key = event.as_text()

    if event is InputEventKey and event.is_pressed():
        if $ExitPrompt.visible:
            if key == "F3":
                get_tree().quit()
            if key == "Escape":
                $ExitPrompt.hide()
            return

        previous_screen = current_screen

        if key == "3" || key == "F3":
            $ExitPrompt.show()

        match current_screen:
            0:
                if key == "Escape":
                    current_screen = 1
            1:
                if key == "Enter":
                    current_screen = 2
                if key == "1" || key == "F1":
                    current_screen = 0
                if key == "5" || key == "F5":
                    colour_removed = true
            _:
                pass

func set_keys():
    var keys = $Keys/Label

    match current_screen:
        0:
            keys.text = "F3=Quit  Escape=Previous Screen"
        1:
            keys.text = "Enter=Continue  F1=Help  F3=Quit  F5=Remove Colour"
        _:
            keys.text = "???"

func set_screen():
    current_node = get_node("Screen " + str(current_screen))
    previous_node = get_node("Screen " + str(previous_screen))

    if previous_node:
        previous_node.hide()
    if current_node:
        current_node.show()

    set_keys()

func set_colours():
    var main = "#0000a8"
    var gray = "#a8a8a8"
    if colour_removed:
        main = Color.BLACK

    if current_screen == 0:
        color = gray
        $Keys.color = main
        current_node.get_node("Label").modulate = Color.BLACK
        $Keys/Label.modulate = Color.WHITE
    else:
        color = main
        $Keys.color = gray
        current_node.get_node("Label").modulate = Color.WHITE
        $Keys/Label.modulate = Color.BLACK

func _process(_delta):
    if not is_ready:
        return

    set_screen()
    set_colours()
