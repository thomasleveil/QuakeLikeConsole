; AutoHotKey that shows/hides a program window by pressing the F1 key.
; If the program is not running, it will start it.
;
; Great to make any program behave like the Quake console (toggle show/hide
; with a hotkey)
; 
; Uses AutoHotKey: https://github.com/AutoHotkey/AutoHotkey/releases
;
;
; Console programs:
;
; - Babun            https://github.com/babun/babun
; - Git Bash         https://git-scm.com/download/win
; - Console²         http://sourceforge.net/projects/console/
; - ConsoleZ         https://github.com/cbucher/console
; - Cygwin           https://www.cygwin.com/
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
version := "1.1"
website := "https://goo.gl/uo0CRZ"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#NoEnv
#SingleInstance

; Load a few environment variables
EnvGet, userprofile, USERPROFILE

; read config file
configFile = %userprofile%\.QuakeLikeConsole.ini
LoadConfig()

; Tray icon customization
Menu, Tray, Tip, % "Quake Like Console (key: " . key . ")"
Menu, Tray, NoStandard ; remove standard Menu items
Menu, Tray, Add, Quake Like Console v%version%, Dummy
Menu, Tray, Add, ; separator
Menu, Tray, Add, &Suspend, ToggleSuspend
Menu, Tray, Add, &Open config file, OpenConfig
Menu, Tray, Add, ; separator
Menu, tray, add, &About, Link
Menu, Tray, Add, E&xit, ButtonExit
Return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Handle Hotkey events
ToggleConsole:
	DetectHiddenWindows, On
	IfWinExist, %windowMatcher% ; see http://ahkscript.org/docs/misc/WinTitle.htm and use the AutoHotKey Window Spy
	{
		DetectHiddenWindows, Off
		IfWinActive
		{
			WinHide
		}
		else
		{
			WinShow
			WinActivate
		}	
	}
	else
	{
		Try Run, %command%, %workingDir%, Max  ; see http://ahkscript.org/docs/commands/Run.htm
		Catch, e
		{
			TrayTip, Could not execute command, %command%, 30, 3
			Throw, e
		}
	}
Return


LoadConfig() {
	global key, configFile, command, workingDir, windowMatcher, userprofile

	; if key already binded
	HotKey, %key%, , UseErrorLevel
	; disable the current Hotkey*
	if (ErrorLevel <> 5) {
		HotKey, %key%, Off
	}

	IniRead, command, %configFile%, Settings, command, %A_Space%
	if (command = "") {
		command := % userprofile . "\.babun\cygwin\bin\mintty.exe -"
		IniWrite, %command%, %configFile%, Settings, command
	}

	IniRead, workingDir, %configFile%, Settings, workingDir, %A_Space%
	if (workingDir = "") {
		workingDir := % userprofile
		IniWrite, %workingDir%, %configFile%, Settings, workingDir
	}

	IniRead, windowMatcher, %configFile%, Settings, windowMatcher, %A_Space%
	if (windowMatcher = "") {
		windowMatcher := "ahk_class mintty"
		IniWrite, %windowMatcher%, %configFile%, Settings, windowMatcher
	}

	IniRead, key, %configFile%, Settings, key, %A_Space%
	if (key = "") {
		key := "F1"
		IniWrite, F1, %configFile%, Settings, key
	}

	IniWrite, https://goo.gl/uo0CRZ, %configFile%, Help, website
	IniWrite, see https://www.autohotkey.com/docs/Hotkeys.htm, %configFile%, Help, key
	IniWrite, % "see " . %website%, %configFile%, Help, windowMatcher

	; keyboard key (or key-combination) to toggle the console
	HotKey, %key%, ToggleConsole, UseErrorLevel  ; see https://www.autohotkey.com/docs/Hotkeys.htm
	If ErrorLevel in 1,2,3,4
	{
		TrayTip, Invalid key, using default: F1, 30, 3
		key := "F1"
		IniWrite, F1, %configFile%, Settings, key
		HotKey, %key%, ToggleConsole
	}
}


Link:
	Run %website%
Return


ButtonExit:
	ExitApp
Return


ToggleSuspend:
	Suspend, Toggle
	Menu, Tray, ToggleCheck, &Suspend
Return


OpenConfig:
	RunWait, %configFile%
	LoadConfig()
	Reload
Return


Dummy:
Return