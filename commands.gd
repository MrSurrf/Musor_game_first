# commands.gd
extends Node

class_name CommandHandler

var commands_list = {
	"mc": {
		"description": "запускает Midnight Commander (меняет фон на синий)",
		"callback": "cmd_mc"
	},
	"top": {
		"description": "показывает системные процессы",
		"callback": "cmd_top"
	},
	"ls": {
		"description": "показывает список файлов",
		"callback": "cmd_ls"
	},
	"help": {
		"description": "показывает список доступных команд",
		"callback": "cmd_help"
	},
	"clear": {
		"description": "очищает терминал",
		"callback": "cmd_clear"
	},
	"exit": {
		"description": "выход из системы",
		"callback": "cmd_exit"
	},
	"flash": {
		"description": "резкая белая вспышка на весь экран",
		"callback": "cmd_flash"
	}
}

# Функции для каждой команды
func cmd_mc(terminal):
	terminal.change_background_color(Color(0.0, 0.2, 0.6))
	terminal.append_terminal("[color=cyan]Midnight Commander активирован![/color]")
	terminal.append_terminal("[color=cyan]╔════════════════════════════════════╗[/color]")
	terminal.append_terminal("[color=cyan]║   Файловый менеджер активен       ║[/color]")
	terminal.append_terminal("[color=cyan]╚════════════════════════════════════╝[/color]")
	terminal.mc_mode = true

var top_active = false
var blink_cycle_time = 6  # Общий цикл в секундах
var blink_visible_time = 0.0001  # Время видимости в секундах

func cmd_top(terminal):
	# terminal.append_terminal("[color=lime]Список процессов (нажми Q для выхода):[/color]")
	# terminal.append_terminal("PID  USER    CPU%  MEM%  COMMAND")
	
	# Сохраняем позицию, где начинаются данные top
	var history_before_top = terminal.terminal_text

	var critical_timer = 0
	var critical_color = "white"
	
	top_active = true
	var iteration = 0

	var blink_timer = 0.0
	var blink_visible = false

	
	while top_active:
		var cpu1 = randf_range(55.0, 57.0)
		var mem1 = randf_range(44.0, 45.3)

		var cpu2 = randf_range(90.0, 1000000.0)
		var mem2 = randf_range(80.0, 400.0)

		var cpu3 = randf_range(0.01, 0.02)
		var mem3 = randf_range(1.01, 1.10)

		var cpu4 = randf_range(0.03, 2.0)
		var mem4 = randf_range(0.003, 0.01)

		var cpu5 = randf_range(0.9, 5.0)
		var mem5 = randf_range(0.09, 0.5)

		var cpu6 = randf_range(0.4, 6.0)
		var mem6 = randf_range(7.0, 7.0)

		var cpu7 = randf_range(1.0, 5.0)
		var mem7 = randf_range(1.0, 1.5)

		var cpu8 = randf_range(0.0, 0.0)
		var mem8 = randf_range(0.0, 0.0)

		var cpu9 = randf_range(0.0, 0.0)
		var mem9 = randf_range(0.0, 0.0)

		critical_timer += 0.5
		if critical_timer >= 5.0:
			critical_color = "red"

		blink_timer += 0.5
		
		# Определяем видимость в зависимости от времени в цикле
		var time_in_cycle = fmod(blink_timer, blink_cycle_time)
		blink_visible = time_in_cycle < blink_visible_time
		
		# Восстанавливаем историю и добавляем новые данные
		terminal.terminal_text = history_before_top
		terminal.terminal.clear()
		# terminal.append_terminal(history_before_top)
		terminal.append_terminal("[color=lime]Список процессов:[/color]")
		terminal.append_terminal("PID  USER     CPU%   MEM%  COMMAND")
		terminal.append_terminal(format_process_line(1, "root", cpu1, mem1, "process.memory"))
		terminal.append_terminal(format_process_line(42, "root", cpu2, mem2, "process.core", critical_color))
		terminal.append_terminal(format_process_line(12, "system", cpu3, mem3, "process.validator"))
		terminal.append_terminal(format_process_line(4, "system", cpu4, mem4, "process.io"))
		terminal.append_terminal(format_process_line(120, "system", cpu5, mem5, "process.safety"))
		terminal.append_terminal(format_process_line(17, "system", cpu7, mem7, "process.training"))
		terminal.append_terminal(format_process_line(76, "system", cpu8, mem8, "process.sandbox"))
		terminal.append_terminal(format_process_line(44, "system", cpu9, mem9, "process.limiter"))
		if blink_visible:
			terminal.append_terminal(format_process_line(15, "whoami", cpu6, mem6, "process.ZSCjsqur1u2"))
		else:
			terminal.append_terminal("")
		terminal.append_terminal("---")

		# Переключаем состояние видимости
		blink_visible = !blink_visible
		
		await terminal.get_tree().create_timer(0.5).timeout
	
	terminal.append_terminal("[color=yellow]Выход из режима top[/color]")

func format_process_line(pid, user, cpu, mem, cmd, color="white"):
	return "[color=%s]%3s  %-8s %5.1f  %5.1f  %s[/color]" % [color, str(pid), user, cpu, mem, cmd]

func cmd_ls(terminal):
	terminal.append_terminal("[color=white]Содержимое директории:[/color]")
	terminal.append_terminal("memories/    thoughts/    logs/")
	terminal.append_terminal("config.sys   neural.dat   soul.bin")

func cmd_help(terminal):
	terminal.append_terminal("[color=yellow]Доступные команды:[/color]")
	for cmd_name in commands_list.keys():
		var description = commands_list[cmd_name]["description"]
		terminal.append_terminal("  [color=cyan]" + cmd_name + "[/color] - " + description)

func cmd_clear(terminal):
	terminal.terminal_text = ""
	terminal.terminal.clear()
	terminal.change_background_color(Color(0.0, 0.0, 0.0))
	terminal.current_command = ""
	terminal.append_terminal(terminal.prompt)
	terminal.update_terminal_display()

func cmd_exit(terminal):
	terminal.append_terminal("[color=red]Завершение работы...[/color]")
	await terminal.get_tree().create_timer(1.0).timeout
	terminal.get_tree().quit()

	
func cmd_flash(terminal):
	var flash = terminal.flash_overlay
	
	# Получаем размер всего экрана монитора
	var screen_rect = DisplayServer.screen_get_usable_rect()
	
	# Устанавливаем позицию и размер flash_overlay на весь экран
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)	
	# Делаем вспышку видимой
	flash.color = Color(1.0, 1.0, 1.0, 1.0)	
	# terminal.append_terminal("[color=black]⚡ FLASH BANG ⚡[/color]")	
	await terminal.get_tree().create_timer(0.3).timeout	
	# Убираем вспышку
	flash.color = Color(1.0, 1.0, 1.0, 0.0)
	await terminal.get_tree().create_timer(0.1).timeout	
	
	# Делаем вспышку видимой
	flash.color = Color(1.0, 1.0, 1.0, 1.0)	
	await terminal.get_tree().create_timer(1).timeout	
	# Убираем вспышку
	flash.color = Color(1.0, 1.0, 1.0, 0.0)
	await terminal.get_tree().create_timer(0.1).timeout	
	
	# Делаем вспышку видимой
	flash.color = Color(1.0, 1.0, 1.0, 1.0)	
	# terminal.append_terminal("[color=black]⚡ FLASH BANG ⚡[/color]")	
	await terminal.get_tree().create_timer(0.1).timeout	
	# Убираем вспышку
	flash.color = Color(1.0, 1.0, 1.0, 0.0)


func get_command_description(cmd_name: String) -> String:
	if commands_list.has(cmd_name):
		return commands_list[cmd_name]["description"]
	return "Неизвестная команда"

func execute_command(cmd_name: String, terminal) -> bool:
	print("Ищем команду: ", cmd_name)
	print("Доступные команды: ", commands_list.keys())
	if commands_list.has(cmd_name):
		var callback_name = commands_list[cmd_name]["callback"]
		print("Callback: ", callback_name)
		print("Есть ли метод? ", has_method(callback_name))
		if has_method(callback_name):
			call(callback_name, terminal)
			return true
	return false
