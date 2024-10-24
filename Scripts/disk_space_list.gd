extends VBoxContainer

var selected_option = 0
var current_screen = 0

var selected: StyleBoxFlat = StyleBoxFlat.new()
var deselected: StyleBoxFlat = StyleBoxFlat.new()

func _ready():
    var item_padding = 20

    selected.bg_color = "#a8a8a8ff"
    selected.border_color = selected.bg_color
    selected.border_width_left = item_padding
    selected.border_width_right = item_padding

    deselected.bg_color = "#00000000"
    deselected.border_color = deselected.bg_color
    deselected.border_width_left = item_padding
    deselected.border_width_right = item_padding

func activate_option():
    match selected_option:
        0:
            Signals.request_screen_change.emit(3)
        1:
            Signals.request_exit.emit()

func _process(_delta):
    current_screen = Signals.current_screen

    if current_screen != 2:
        return

    var default_font = load("res://Resources/default_font.tres")
    var selected_font = load("res://Resources/selected_font.tres")

    for i in range(get_child_count()):
        var option = get_child(i)

        if i == selected_option:
            option.add_theme_stylebox_override("normal", selected)
            option.label_settings = selected_font
        else:
            option.add_theme_stylebox_override("normal", deselected)
            option.label_settings = default_font

func _input(event):
    if current_screen != 2:
        return

    if event is InputEventKey and event.is_pressed():
        if event.as_text() == "Up":
            selected_option = max(selected_option - 1, 0)
        if event.as_text() == "Down":
            selected_option = min(selected_option + 1, get_child_count() - 1)
        if event.as_text() == "Enter":
            activate_option()
