extends Control
## Pilot only: this scene reproduces the Guild UI with static demonstration values.
## Server simulation, saved game state and other screens are not connected here.

const MOBILE_BREAKPOINT: float = 780.0
const METRIC_COLUMNS_BREAKPOINT: float = 940.0
const SECTION_COLUMNS_BREAKPOINT: float = 1160.0
const SIDEBAR_WIDTH: float = 238.0

@onready var sidebar: PanelContainer = %Sidebar
@onready var shade: ColorRect = %MobileShade
@onready var screen: VBoxContainer = %ContentScreen
@onready var menu_button: Button = %MenuButton
@onready var metrics: GridContainer = %MetricsGrid
@onready var sections: GridContainer = %ContentGrid
@onready var body_margin: MarginContainer = %BodyMargin
@onready var pending_dialog: AcceptDialog = %PendingDialog

var drawer_open: bool = false

func _ready() -> void:
    menu_button.pressed.connect(_toggle_drawer)
    shade.gui_input.connect(_on_shade_input)
    %GuildNav.pressed.connect(_close_drawer)
    %Autosell.toggled.connect(_on_policy_changed.bind("Автоматичний продаж надлишків"))
    %Autobuy.toggled.connect(_on_policy_changed.bind("Автоматична закупівля"))

    var pending_buttons: Dictionary = {
        "CityNav": "Місто",
        "ForestNav": "Лісові стежки",
        "RidgeNav": "Кам'яний кряж",
        "DarkNav": "Чорні хащі",
        "QuickWarehouse": "Склад",
        "QuickProduction": "Виробництво",
        "QuickTrade": "Торгівля",
        "QuickOrders": "Накази",
        "QuickQuests": "Завдання",
        "QuickReports": "Звіти",
        "ManageHeroes": "Управління героями",
        "OpenProduction": "Виробництво",
        "HeroToren": "Накази Торена",
        "HeroElira": "Накази Еліри",
        "HeroBran": "Накази Брана"
    }
    for node_name in pending_buttons:
        var button: Button = get_node("%" + str(node_name)) as Button
        button.pressed.connect(_show_pending.bind(str(pending_buttons[node_name])))

    get_viewport().size_changed.connect(_adapt_layout)
    _adapt_layout()


func _adapt_layout() -> void:
    var width: float = get_viewport_rect().size.x
    var compact: bool = width < MOBILE_BREAKPOINT
    if not compact:
        drawer_open = false

    screen.offset_left = 0.0 if compact else SIDEBAR_WIDTH
    sidebar.visible = not compact or drawer_open
    shade.visible = compact and drawer_open
    menu_button.visible = compact
    %HeroCount.visible = not compact

    metrics.columns = 2 if width < METRIC_COLUMNS_BREAKPOINT else 4
    sections.columns = 1 if width < SECTION_COLUMNS_BREAKPOINT else 2
    body_margin.add_theme_constant_override("margin_left", 12 if compact else 22)
    body_margin.add_theme_constant_override("margin_right", 12 if compact else 22)


func _toggle_drawer() -> void:
    drawer_open = not drawer_open
    _adapt_layout()


func _close_drawer() -> void:
    drawer_open = false
    _adapt_layout()


func _on_shade_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed:
        _close_drawer()
    elif event is InputEventScreenTouch and event.pressed:
        _close_drawer()


func _show_pending(section: String) -> void:
    _close_drawer()
    pending_dialog.dialog_text = "«%s» ще не перенесено в Godot. Чинна Web-версія залишається доступною." % section
    var available_width: int = maxi(240, int(get_viewport_rect().size.x) - 24)
    pending_dialog.popup_centered(Vector2i(mini(380, available_width), 150))


func _on_policy_changed(_enabled: bool, _policy_name: String) -> void:
    %PolicyNote.text = "Налаштування змінено лише в тестовому інтерфейсі. Угоди не виконуються, значення не зберігається."


func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE and drawer_open:
        _close_drawer()
        get_viewport().set_input_as_handled()
