extends Label

signal enter_pressed

var version_strings = {
    "engine_version": Engine.get_version_info().string,
    "game_version": ProjectSettings.get_setting("application/config/version"),
}

var extra_info = ""

var HEADER = """GogetterBIOS v{engine_version}

Running power-on sequence...
(WAIT=1.5s)
{extra_info}Initialising Not An Illegal Game...
(WAIT=1s)
""".format(version_strings)

var WEB_TEXT = HEADER + """This game is not supported inside a web browser.

System halted."""

var ANTI_PIRACY_TEXT = """════════════ WARNING ════════════
It is a serious crime to copy video games according to copyright law.
If you downloaded this game illegally, power off your PC, sit in the corner
and think about what you've done.

Anyway, this game is made to resemble an old 90s operating system that can't
be named for copyright/trademark reasons. You know, the one out of Redmond.

Just letting you know now: EVERYTHING BEYOND THIS POINT is fictional, no matter
how similar to a real PC this may look like.

If you accept these terms, press the Enter key to proceed to NAI-DOS.
(You won't see this screen again next time you start the game.)

(USERWAIT)
(SCENE=Scenes/not_an_illegal_dos.tscn)"""

func animate_characters(line, speed):
    var index = line.find("(TYPED)")
    text += line.substr(0, index)
    var stripped_line = line.substr(index + 7)

    for character in stripped_line:
        text += character
        await get_tree().create_timer(speed).timeout

func delay_animation(line) -> String:
    var index_start = line.find("(WAIT=")
    var index_end = line.find("s)")

    assert(index_start > -1 and index_end > -1, "WAIT directive format is incorrect")

    var isolated_number = line.substr(index_start, index_end).replace("(WAIT=", "").replace("s)", "")

    var wait_amount = float(isolated_number)
    line = line.replace("(WAIT=" + str(wait_amount) + "s)", "")

    await get_tree().create_timer(wait_amount).timeout

    return line

## The delay between displaying each line.
@export var line_delay = 0.2

## The delay between displaying (typing) each character.
@export var char_delay = 0.05

func animate_text(input):
    """
    Possible directives:
    (TYPED)text - Will type text character by character until the end of the line
    (WAIT=xs) - Will wait x seconds before resuming animation (the closing `s` is necessary)
    (USERWAIT) - Will wait for the user to press the Enter key
    (SCENE=scene_name) - Will switch to the specified scene
    """

    for line in input.split("\n"):
        if "(SCENE=" in line:
            var scene_name = line.replace("(SCENE=", "").replace(")", "")
            get_tree().change_scene_to_file(scene_name)
            break

        if "(USERWAIT)" in line:
            text += "Press Enter to continue. . ."
            await enter_pressed
            text += "\n"
            continue

        if "(WAIT=" in line and "s)" in line:
            line = await delay_animation(line)

        if "(TYPED)" in line:
            await animate_characters(line, char_delay)
            text += "\n"
            continue

        if line == "":
            # This is to stop the font from displaying a newline character
            text += " \n"
        else:
            text += line + "\n"

        await get_tree().create_timer(line_delay).timeout

func controller_message() -> String:
    var message: String
    var controllers = len(Input.get_connected_joypads())

    if controllers == 0:
        return ""

    var controller_message_prefix = "This game will not work with your " + Input.get_joy_name(0)

    if controllers == 2:
        message = controller_message_prefix + " and " + Input.get_joy_name(1) + "."
    elif controllers >= 2:
        message = controller_message_prefix + " and " + String(controllers) + " other controller(s)."
    elif controllers == 1:
        message = controller_message_prefix + "."

    message += "\nPlease use a keyboard and mouse."

    return message

func add_extra_info(info):
    if info == "":
        return
    extra_info += info + "\n"

func get_extra_info() -> String:
    if extra_info == "":
        return ""
    return extra_info + "\n"

func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

    add_extra_info(controller_message())

    if OS.get_name() == "Android" or OS.get_name() == "iOS":
        add_extra_info("""Not An Illegal Game is not officially supported on {os_name}.
To play this game, you need a physical keyboard as the software keyboard will not work.
Please connect a real physical keyboard to continue.

(USERWAIT)""".format({ "os_name": OS.get_name() }))

    match OS.get_name():
        "Web":
            animate_text(HEADER.format({ "extra_info": get_extra_info() }) + WEB_TEXT)
        _:
            animate_text(HEADER.format({ "extra_info": get_extra_info() }) + ANTI_PIRACY_TEXT)

func _input(event):
    if event is InputEventKey and Input.is_action_just_pressed("ui_accept"):
        emit_signal("enter_pressed")
