extends TextEdit

var motd = """
Welcome to Not An Illegal DOS (v{game_version})
Copyright (C) 2024 Arsalan "Aeri" Kazmi (AeriaVelocity)

Type `setup` to install Not An Illegal Game.""".format(
    {"game_version": ProjectSettings.get_setting("application/config/version")}
)

var prompt: String = "A:\\>"

func _ready():
    if Signals.already_been_in_setup:
        motd = """
Type `setup` to return to Setup."""
    text = motd + "\n\n%s" % get_prompt()
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

    print("%s, %s" % [command, args])

    match command:
        "setup":
            get_tree().change_scene_to_file("res://Scenes/preinstallation.tscn")
        "exit":
            get_tree().quit()
        "echo":
            command_output(" ".join(args))
        _:
            if ":" in command and command.length() == 2:
                set_prompt(command[0])
                text += get_prompt()
                reset_caret_position()
            else:
                command_output("Bad command or file name")

func command_output(output: String):
    text += output + "\n" + get_prompt()
    reset_caret_position()

func set_prompt(drive_letter: String):
    prompt = "%s:\\>" % drive_letter

func get_prompt() -> String:
    return prompt

func reset_caret_position():
    set_caret_line(get_line_count())
    set_caret_column(get_line(get_line_count() - 1).length())
