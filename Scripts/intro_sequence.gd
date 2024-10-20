extends Label

signal enter_pressed

var version_strings = {
    "engine_version": Engine.get_version_info().string,
    "game_version": ProjectSettings.get_setting("application/config/version"),
}

var STARTUP_TEXT = """GogetterBIOS v{engine_version}

Welcome to Not An Illegal Game (v{game_version})

C:\\>(TYPED)naig

Starting Not An Illegal Game...""".format(version_strings)

var SETUP_TEXT = """GogetterBIOS v{engine_version}

Welcome to Not An Illegal Game (v{game_version})

C:\\>(TYPED)A:

Insert a diskette into device A: and press any key to continue
(WAIT=0.6s)
A:\\>(WAIT=0.3s)(TYPED)setup

Initialising Not An Illegal Game...

============ WARNING ============
It is a serious crime to copy video games according to copyright law.
If you downloaded this game illegally, power off your PC, sit in the corner and think about what you've done.
Anyway, this game is made to resemble an old 90s operating system that can't be named for copyright/trademark reasons. You know, the one out of Redmond.
Just letting you know now: EVERYTHING BEYOND THIS POINT is fictional, no matter how similar to a real PC this may look like.
If you accept these terms, press the Enter key to proceed to Setup.
(You won't see this screen again next time you start the game.)

(USERWAIT)""".format(version_strings)

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

        text += line + "\n"

        await get_tree().create_timer(line_delay).timeout

# Called when the node enters the scene tree for the first time.
func _ready():
    # For now, default to SETUP_TEXT since we're just starting out
    animate_text(SETUP_TEXT)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
    if event is InputEventKey and Input.is_action_just_pressed("ui_accept"):
        emit_signal("enter_pressed")
