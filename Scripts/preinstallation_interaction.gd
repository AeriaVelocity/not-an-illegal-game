extends Control

var current_screen = 1
var previous_screen = 0

var is_ready = false

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
        previous_screen = current_screen

        match current_screen:
            0:
                if key == "1":
                    current_screen = 1
            1:
                if key == "Enter":
                    current_screen = 2
                if key == "1":
                    current_screen = 0
                if key == "3":
                    get_tree().quit()

func _process(_delta):
    if not is_ready:
        return

    var current_node = get_node("Screen " + str(current_screen))
    var previous_node = get_node("Screen " + str(previous_screen))

    if previous_node:
        previous_node.hide()
    if current_node:
        current_node.show()
