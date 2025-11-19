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

func cmd_top(terminal):
	# terminal.append_terminal("[color=lime]Список процессов (нажми Q для выхода):[/color]")
	# terminal.append_terminal("PID  USER    CPU%  MEM%  COMMAND")
	
	# Сохраняем позицию, где начинаются данные top
	var history_before_top = terminal.terminal_text
	
	top_active = true
	var iteration = 0
	
	while top_active:
		var cpu1 = randf_range(0.1, 5.0)
		var mem1 = randf_range(0.3, 2.0)
		var cpu2 = randf_range(10.0, 25.0)
		var mem2 = randf_range(15.0, 30.0)
		var cpu3 = randf_range(1.0, 5.0)
		var mem3 = randf_range(5.0, 12.0)
		
		# Восстанавливаем историю и добавляем новые данные
		terminal.terminal_text = history_before_top
		terminal.terminal.clear()
		# terminal.append_terminal(history_before_top)
		terminal.append_terminal("[color=lime]Список процессов:[/color]")
		terminal.append_terminal("PID  USER    CPU%  MEM%  COMMAND")
		terminal.append_terminal("1    root     %.1f   %.1f  /sbin/init" % [cpu1, mem1])
		terminal.append_terminal("42   ai_core  %.1f   %.1f  neural_process" % [cpu2, mem2])
		terminal.append_terminal("127  system   %.1f   %.1f  consciousness.exe" % [cpu3, mem3])
		terminal.append_terminal("---")
		
		iteration += 1
		await terminal.get_tree().create_timer(0.5).timeout
	
	terminal.append_terminal("[color=yellow]Выход из режима top[/color]")
	terminal.current_command = ""
	terminal.append_terminal(terminal.prompt)
	terminal.update_terminal_display()


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
