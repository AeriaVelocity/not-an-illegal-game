extends TextEdit

var motd = """To run Setup again, type `setup`.

%s""" % get_prompt()

func _ready():
    text = motd
    call_deferred("grab_focus")
    reset_caret_position()

func _input(event):
    if event is InputEventKey and event.is_pressed() and event.keycode == KEY_ENTER:
        get_viewport().set_input_as_handled()
        handle_enter_keypress()

func handle_enter_keypress():
    var caret_at_bottom = get_caret_line() == get_line_count() - 1
    if caret_at_bottom:
        process_command(get_line(get_line_count() - 1))
    else:
        var line = get_line(get_caret_line())
        reset_caret_position()
        process_command(line, false)

    reset_caret_position()

func process_command(input: String, linebreak: bool = true):
    if linebreak:
        text += "\n"

    input = input.replace(get_prompt(), "")
    var command = input.split(" ")[0]
    var args = input.split(" ").slice(1)

    match command:
        "setup":
            get_tree().change_scene_to_file("res://Scenes/preinstallation.tscn")
        "exit":
            get_tree().quit()
        "echo":
            command_output("".join(args))
        _:
            command_output("Bad command or file name")

func command_output(output: String):
    text += output + "\n" + get_prompt()
    reset_caret_position()

func get_prompt() -> String:
    return "A:\\>"

func reset_caret_position():
    set_caret_line(get_line_count())
    set_caret_column(get_line(get_line_count() - 1).length())
