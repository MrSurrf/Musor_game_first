extends Control

@onready var terminal: RichTextLabel = $Terminal
@onready var background: ColorRect = $Background
@onready var error_sound: AudioStreamPlayer = $ErrorSound


# Цвета для разных состояний
var color_black = Color(0.0, 0.0, 0.0, 1.0)
var color_blue = Color(0.0, 0.2, 0.6)
var color_green = Color(0.0, 0.3, 0.0)
var color_red = Color(0.3, 0.0, 0.0)

# Состояние терминала
var terminal_text = ""
var current_command = ""
var prompt = "root@rk3568-buildroot:~# "
var mc_mode = false
var shake_tween = null

# Словарь с командами
var commands = {
	"mc": "запускает Midnight Commander (меняет фон на синий)",
	"top": "показывает системные процессы",
	"ls": "показывает список файлов",
	"help": "показывает список доступных команд",
	"clear": "очищает терминал",
	"exit": "выход из системы"
}


func _ready():
	# Подключаем обработку ввода
	set_process_unhandled_input(true)
	
	# Инициализируем терминал
	terminal.bbcode_enabled = true
	terminal.scroll_following = true
	terminal.custom_minimum_size = Vector2(800, 600)
	
	# Выводим приветствие
	append_terminal("[color=green]Система запущена. Введите 'help' для списка команд.[/color]")
	append_terminal("")
	append_terminal(prompt)
	
	# Устанавливаем фокус на сцену
	grab_focus()

func _unhandled_input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		
		# Проверяем комбинацию Ctrl+L
		if event.ctrl_pressed and event.keycode == KEY_L:
			# Очищаем терминал (как в Linux Ctrl+L)
			terminal_text = ""
			terminal.clear()
			current_command = ""
			append_terminal(prompt)
			get_viewport().set_input_as_handled()
		
		match event.keycode:
			KEY_ESCAPE:
				if mc_mode:
					change_background_color(color_black)
					mc_mode = false
					append_terminal("[color=gray]Режим mc закрыт, фон черный.[/color]")
					append_terminal("")
					append_terminal(prompt)
					current_command = ""
					update_terminal_display()
				get_viewport().set_input_as_handled()
			
			KEY_ENTER:
				# Отправляем команду
				send_command()
				get_viewport().set_input_as_handled()
			
			KEY_BACKSPACE:
				# Удаляем последний символ из команды
				if current_command.length() > 0:
					current_command = current_command.substr(0, current_command.length() - 1)
					update_terminal_display()
				get_viewport().set_input_as_handled()
			
			KEY_DELETE:
				# Очищаем текущую команду полностью
				current_command = ""
				update_terminal_display()
				get_viewport().set_input_as_handled()
			
					
			_:
				# Если нажата обычная клавиша с символом
				if event.unicode > 0:
					var char = char(event.unicode)
					current_command += char
					update_terminal_display()
					get_viewport().set_input_as_handled()

func update_terminal_display():
	# Обновляем дисплей с текущей командой и курсором
	terminal.clear()
	terminal.append_text(terminal_text)
	
	# Выводим текущую строку ввода с курсором
	var display_line = current_command + "[color=cyan]_[/color]"
	terminal.append_text(display_line)
	
	# Прокручиваем вниз
	await get_tree().process_frame
	terminal.scroll_to_line(terminal.get_line_count())

func append_terminal(text: String):
	# Добавляем текст в буфер терминала
	if terminal_text != "":
		terminal_text += "\n"
	terminal_text += text
	
	# Обновляем дисплей
	terminal.clear()
	terminal.append_text(terminal_text)
	terminal.scroll_to_line(terminal.get_line_count())

func send_command():
	# Сохраняем введённую команду
	var command = current_command.strip_edges().to_lower()
	
	# Выводим команду (она уже видна, но полностью)
	terminal_text += "\n"
	
	if command == "":
		# Если команда пуста, просто выводим новое приглашение
		append_terminal(prompt)
		current_command = ""
		update_terminal_display()
		return
	
	# Обрабатываем команду
	process_command(command)
	
	# Выводим новое приглашение
	append_terminal(prompt)
	current_command = ""
	update_terminal_display()

func process_command(command: String):
	var words = command.split(" ", false)
	if words.size() == 0:
		return
	
	var main_command = words[0]
	
	match main_command:
		"mc":
			change_background_color(color_blue)
			mc_mode = true
			append_terminal("[color=cyan]Midnight Commander активирован![/color]")
			append_terminal("[color=cyan]╔════════════════════════════════════╗[/color]")
			append_terminal("[color=cyan]║   Файловый менеджер активен       ║[/color]")
			append_terminal("[color=cyan]╚════════════════════════════════════╝[/color]")
		
		"top":
			change_background_color(color_green)
			append_terminal("[color=lime]Список процессов:[/color]")
			append_terminal("PID  USER    CPU%  MEM%  COMMAND")
			append_terminal("1    root     0.1   0.5  /sbin/init")
			append_terminal("42   ai_core  15.3  23.1  neural_process")
			append_terminal("127  system   2.1   8.4   consciousness.exe")
		
		"ls":
			append_terminal("[color=white]Содержимое директории:[/color]")
			append_terminal("memories/    thoughts/    logs/")
			append_terminal("config.sys   neural.dat   soul.bin")
		
		"help":
			append_terminal("[color=yellow]Доступные команды:[/color]")
			for cmd in commands.keys():
				append_terminal("  [color=cyan]" + cmd + "[/color] - " + commands[cmd])
		
		"clear":
			terminal_text = ""
			terminal.clear()
			change_background_color(color_black)
			current_command = ""
			append_terminal(prompt)
			update_terminal_display()
		
		"exit":
			append_terminal("[color=red]Завершение работы...[/color]")
			await get_tree().create_timer(1.0).timeout
			get_tree().quit()
		
		_:
			# Неизвестная команда - эффект ошибки
			append_terminal("[color=red]Ошибка: команда '" + command + "' не найдена[/color]")
			append_terminal("[color=yellow]Введите 'help' для списка команд[/color]")
			play_error_feedback()

func play_error_feedback():
	# Запускаем звук ошибки
	if error_sound:
		error_sound.play()
	
	# Запускаем shake анимацию экрана
	shake_screen()

func shake_screen():
	if shake_tween != null and shake_tween.is_valid():
		return
	
	shake_tween = create_tween()
	var shake_amount = 8
	var shake_duration = 0.02
	var original_pos = self.position
	
	shake_tween.tween_property(self, "position", original_pos + Vector2(shake_amount, 0), shake_duration)
	shake_tween.tween_property(self, "position", original_pos + Vector2(-shake_amount, 0), shake_duration).set_delay(shake_duration)
	shake_tween.tween_property(self, "position", original_pos + Vector2(0, shake_amount), shake_duration).set_delay(shake_duration * 2)
	shake_tween.tween_property(self, "position", original_pos + Vector2(0, -shake_amount), shake_duration).set_delay(shake_duration * 3)
	shake_tween.tween_property(self, "position", original_pos, shake_duration).set_delay(shake_duration * 4)
	
	shake_tween.connect("finished", Callable(self, "_on_shake_finished"))

func _on_shake_finished():
	self.position = Vector2.ZERO

func change_background_color(new_color: Color):
	var tween = create_tween()
	tween.tween_property(background, "color", new_color, 0.5)
