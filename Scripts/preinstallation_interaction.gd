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

    var signals = get_node("/root/Signals")

    signals.request_screen_change.connect(Callable(self, "change_screen"))
    signals.request_exit.connect(Callable(self, "show_exit_prompt"))

func _input(event):
    if not is_ready:
        return

    var key = event.as_text()

    if event is InputEventKey and event.is_pressed():
        if $ExitPrompt.visible:
            if key == "F3":
                exit_to_dos()
            if key == "Escape":
                hide_exit_prompt()
            return

        if key == "F1" and current_screen != 0:
            change_screen(0)
        if key == "F3":
            show_exit_prompt()

        match current_screen:
            0:
                if key == "Escape":
                    change_screen(previous_screen)
            1:
                if key == "Enter":
                    change_screen(2)
                if key == "F5":
                    colour_removed = true
            _:
                pass

func change_screen(screen):
    previous_screen = current_screen
    current_screen = screen
    Signals.current_screen = current_screen

func show_exit_prompt():
    $ExitPrompt.show()

func hide_exit_prompt():
    $ExitPrompt.hide()

func exit_to_dos():
    Signals.already_been_in_setup = true
    get_tree().change_scene_to_file("res://Scenes/not_an_illegal_dos.tscn")

func set_keys():
    var keys = $Keys/Label

    match current_screen:
        0:
            keys.text = "F3=Quit  Escape=Previous Screen"
        1:
            keys.text = "Enter=Continue  F1=Help  F3=Quit  F5=Remove Colour"
        2:
            keys.text = "Enter=Continue  F1=Help  F3=Quit"
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

    var exit_prompt_title_label = load("res://Resources/exit-prompt-title-label.tres")
    var exit_prompt_title_style = load("res://Resources/exit-prompt-title-style.tres")
    var exit_prompt_outline_style = load("res://Resources/exit-prompt-outline.tres")

    if colour_removed:
        main = Color.BLACK

    if current_screen == 0:
        color = gray
        $Keys.color = main
        current_node.get_node("Label").modulate = Color.BLACK
        $Keys/Label.modulate = Color.WHITE
        $ExitPrompt.color = Color.BLACK
        exit_prompt_title_style.bg_color = Color.BLACK
        exit_prompt_outline_style.border_color = gray
        exit_prompt_title_label.font_color = gray
    else:
        color = main
        $Keys.color = gray
        current_node.get_node("Label").modulate = Color.WHITE
        $Keys/Label.modulate = Color.BLACK
        $ExitPrompt.color = gray
        exit_prompt_title_style.bg_color = gray
        exit_prompt_outline_style.border_color = Color.BLACK
        exit_prompt_title_label.font_color = Color.BLACK

func _process(_delta):
    if not is_ready:
        return

    set_screen()
    set_colours()
