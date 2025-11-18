extends Control

# Ссылки на узлы
@onready var background: ColorRect = $Background
@onready var terminal_output: RichTextLabel = $TerminalOutput
@onready var command_input: LineEdit = $HBoxContainer/CommandInput
@onready var root_control = self  # Корневой Control, который двигаем для тряски
@onready var error_sound: AudioStreamPlayer = $ErrorSound

# Цвета для разных состояний
var color_black = Color(0.0, 0.0, 0.0)  # Черный
var color_blue = Color(0.0, 0.2, 0.6)   # Темно-синий (как в mc)
var color_green = Color(0.0, 0.3, 0.0)  # Темно-зеленый
var color_red = Color(0.3, 0.0, 0.0)    # Темно-красный

var mc_mode = false
var shake_tween = null
# Словарь с командами и их описаниями
var commands = {
	"mc": "запускает Midnight Commander (меняет фон на синий)",
	"top": "показывает системные процессы",
	"ls": "показывает список файлов",
	"help": "показывает список доступных команд",
	"clear": "очищает терминал",
	"exit": "выход из системы"
}

func _ready():
	var no_border = StyleBoxFlat.new()
	no_border.border_width_left = 0
	no_border.border_width_top = 0
	no_border.border_width_right = 0
	no_border.border_width_bottom = 0
	no_border.bg_color = Color(0, 0, 0, 0)  # полностью прозрачный фон, при необходимости замени
	
	command_input.add_theme_stylebox_override("normal", no_border)
	command_input.add_theme_stylebox_override("focus", no_border)
	command_input.add_theme_stylebox_override("hover", no_border)


	# Background.color = Color(0, 0, 0)  # Чёрный фон
	# Подключаем сигнал на Enter в LineEdit
	command_input.text_submitted.connect(_on_command_submitted)
	command_input.grab_focus()
	
	# Приветственное сообщение
	print_terminal("[color=green]_[/color]")


	# Мерцающий курсор
	var cursor_timer = Timer.new()
	add_child(cursor_timer)
	cursor_timer.wait_time = 0.5
	cursor_timer.timeout.connect(_on_cursor_blink)
	cursor_timer.start()

func _on_cursor_blink():
	command_input.caret_blink = !command_input.caret_blink

func _on_command_submitted(command_text: String):
	# Очищаем пробелы и приводим к нижнему регистру
	var command = command_text.strip_edges().to_lower()
	
	# Выводим введенную команду
	print_terminal("[color=gray]$ " + command_text + "[/color]")
	
	# Обрабатываем команду
	process_command(command)
	
	# Очищаем поле ввода и возвращаем фокус
	command_input.clear()
	command_input.grab_focus()

func process_command(command: String):
	# Разбиваем команду на слова
	var words = command.split(" ", false)
	if words.size() == 0:
		return
	
	var main_command = words[0]
	
	# Обрабатываем команды
	match main_command:
		"mc":			
			change_background_color(color_blue)
			mc_mode = true
			print_terminal("[color=cyan]____Мне кажется стало лучше____[/color]")
			print_terminal("[color=cyan]╔════════════════════════════════════╗[/color]")
			print_terminal("[color=cyan]║   Файловый менеджер активен       ║[/color]")
			print_terminal("[color=cyan]╚════════════════════════════════════╝[/color]")
		
		"top":
			# change_background_color(color_green)
			print_terminal("[color=lime]Список процессов:[/color]")
			print_terminal("PID  USER    CPU%  MEM%  COMMAND")
			print_terminal("1    root     0.1   0.5  /sbin/init")
			print_terminal("42   ai_core  15.3  23.1  neural_process")
			print_terminal("127  system   2.1   8.4   consciousness.exe")
		
		"ls":
			print_terminal("[color=white]Содержимое директории:[/color]")
			print_terminal("memories/    thoughts/    logs/")
			print_terminal("config.sys   neural.dat   soul.bin")
		
		"help":
			print_terminal("[color=yellow]Доступные команды:[/color]")
			for cmd in commands.keys():
				print_terminal("  [color=cyan]" + cmd + "[/color] - " + commands[cmd])
		
		"clear":
			terminal_output.clear()
			change_background_color(color_black)
		
		"exit":
			#print_terminal("[color=red]возвращайся[/color]")
			print_terminal("[color=white]
			⠣⡑⡕⡱⡸⡀⡢⡂⢨⠀⡌⠀⠀⠀⠀⠀⠀ 
⠀⠀⠀⠀⠀⠀⠀⡕⢅⠕⢘⢜⠰⣱⢱⢱⢕⢵⠰⡱⡱⢘⡄⡎⠌⡀⠀⠀⠀⠀ 
⠀⠀⠀⠀⠀⠀⠱⡸⡸⡨⢸⢸⢈⢮⡪⣣⣣⡣⡇⣫⡺⡸⡜⡎⡢⠀⠀⠀⠀⠀ 
⠀⠀⠀⠀⠀⠀⢱⢱⠵⢹⢸⢼⡐⡵⣝⢮⢖⢯⡪⡲⡝⠕⣝⢮⢪⢀⠀⠀⠀⠀ 
⠀⠀⠀⠀⢀⠂⡮⠁⠐⠀⡀⡀⠑⢝⢮⣳⣫⢳⡙⠐⠀⡠⡀⠀⠑⠀⠀⠀⠀⠀ 
⠀⠀⠀⠀⢠⠣⠐⠀       [color=red]возвращайся[/color]⡀   .⠈⡈⠀⡀⠀⠀ 
⠀⠀⠀⠀⠐⡝⣕⢄⡀⠑⢙⠉⠁⡠⡣⢯⡪⣇⢇⢀⠀⠡⠁⠁⡠⡢⠡⠀⠀⠀ 
⠀⠀⠀⠀⠀⢑⢕⢧⣣⢐⡄⣄⡍⡎⡮⣳⢽⡸⡸⡊⣧⣢⠀⣕⠜⡌⠌⠀⠀⠀ 
⠀⠀⠀⠀⠀⠀⠌⡪⡪⠳⣝⢞⡆⡇⡣⡯⣞⢜⡜⡄⡧⡗⡇⠣⡃⡂⠀⠀⠀⠀ 
⠀⠀⠀⠀⠀⠀⠀⠨⢊⢜⢜⣝⣪⢪⠌⢩⢪⢃⢱⣱⢹⢪⢪⠊⠀⠀⠀⠀⠀⠀ 
⠀⠀⠀⠀⠀⠀⠀⠀⠐⠡⡑⠜⢎⢗⢕⢘⢜⢜⢜⠜⠕⠡⠡⡈⠀⠀⠀⠀⠀⠀ 
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⡢⢀⠈⠨⣂⡐⢅⢕⢐⠁⠡⠡⢁⠀⠀⠀⠀⠀⠀⠀ 
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢈⠢⠀⡀⡐⡍⢪⢘⠀⠀⠡⡑⡀⠀⠀⠀⠀⠀⠀⠀ 
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠨⢂⠀⠌⠘⢜⠘⠀⢌⠰⡈⠀⠀⠀⠀⠀⠀⠀⠀ 
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢑⢸⢌⢖⢠⢀⠪⡂[/color]")
			await get_tree().create_timer(0.7).timeout
			get_tree().quit()
		
		_:
			print_terminal("[color=red]Мне кажется команда '" + command + "' мне не известна[/color]")
			print_terminal("[color=yellow]Поробуй еще раз, пожалуйста[/color]")
			
			play_error_feedback()


func play_error_feedback():
	# Запускаем звук ошибки
	if error_sound:
		error_sound.play()

	# Запускаем shake анимацию экрана
	shake_screen()

func shake_screen():
	if shake_tween != null and shake_tween.is_active():
		return  # Анимация уже идёт, не запускаем новую
	var shake_tween = create_tween()
	var shake_amount = 5  # амплитуда тряски в пикселях
	var shake_duration = 0.02

	# Сохраняем исходную позицию
	var original_pos = root_control.position

	# Последовательность небольших смещений

	shake_tween.tween_property(root_control, "position", original_pos + Vector2(shake_amount, 0), shake_duration)
	shake_tween.tween_property(root_control, "position", original_pos + Vector2(-shake_amount, 0), shake_duration).set_delay(shake_duration)
	shake_tween.tween_property(root_control, "position", original_pos + Vector2(0, shake_amount), shake_duration).set_delay(shake_duration * 2)
	shake_tween.tween_property(root_control, "position", original_pos + Vector2(0, -shake_amount), shake_duration).set_delay(shake_duration * 3)
	shake_tween.tween_property(root_control, "position", original_pos, shake_duration).set_delay(shake_duration * 4)

	 # Обязательно сбросить позицию после завершения
	shake_tween.connect("finished", Callable(self, "_on_shake_finished"))

func _on_shake_finished():
	root_control.position = Vector2.ZERO


func _unhandled_input(event):
	if mc_mode and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		change_background_color(color_black)
		mc_mode = false
		print_terminal("[color=gray]....и снова в темноту...[/color]")

func print_terminal(text: String):
	# Добавляем текст в терминал с новой строки
	terminal_output.append_text(text + "\n")
	# Прокручиваем вниз
	terminal_output.scroll_to_line(terminal_output.get_line_count())

func change_background_color(new_color: Color):
	# Плавная смена цвета фона
	var tween = create_tween()
	tween.tween_property(background, "color", new_color, 0.5)
