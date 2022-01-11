SendMode "Input"
Persistent
#SingleInstance force
SetTitleMatchMode(2)     ; All #If statements match anywhere in title
OnExit(SaveData)

skillCount := 5

#HotIf WinActive("Last Epoch")
HotIfWinActive("Last Epoch")

MyGui := Gui("", "Options", )

hotkeys := Array()
checkboxes := Array()
hotkeyDown := Map()

Loop skillCount {
	MyGui.Add("Text", "xm+0", "Skill " A_index " hotkey")

	control := MyGui.Add("Hotkey", "", "vHotkey" A_index)
	control.OnEvent("Change", updateHotkeys)
	hotkeys.Push(control)

	control := MyGui.Add("Checkbox", "x+20", "Enabled")
	control.OnEvent("Click", updateHotkeys)
	checkboxes.Push(control)

	if A_index < skillCount {
		MyGui.Add("Text", "xm+0 y+20 w250 0x10") ; separator line
	}
}

SaveData(*)
{
	loop skillCount {
		RegWrite(hotkeys[A_index].Value, "REG_SZ", "HKEY_CURRENT_USER\Software\LEAutocastScript", "Hotkey" A_index)
		RegWrite(checkboxes[A_index].Value, "REG_DWORD", "HKEY_CURRENT_USER\Software\LEAutocastScript", "HotkeyEnabled" A_index)
	}
}

LoadData(*)
{
	loop skillCount {
		hotkeys[A_index].Value := RegRead("HKEY_CURRENT_USER\Software\LEAutocastScript", "Hotkey" A_index, "")
		checkboxes[A_index].Value := RegRead("HKEY_CURRENT_USER\Software\LEAutocastScript", "HotkeyEnabled" A_index, 0)
	}
}

hotkeyPressed(hk)
{
	if hotkeyDown[hk] {
		SendInput("{" hk " up}")
		hotkeyDown[hk] := false
	}
	else {
		SendInput("{" hk " down}")
		hotkeyDown[hk] := true
	}
}

updateHotkeys(*)
{
	for k, v in hotkeyDown {
		try {
			Hotkey(k, "Off")
		}
	}
	hotkeyDown.Clear()
	loop skillCount {
		try {
			if checkboxes[A_index].Value = 1 {
				hotkeyDown[hotkeys[A_index].Value] := false
				Hotkey(hotkeys[A_index].Value, hotkeyPressed)
				Hotkey(hotkeys[A_index].Value, "On")
			}
		}
	}
}

LoadData()
updateHotkeys()

MyGui.OnEvent("Close", SaveData)

MyGui.Show
A_TrayMenu.Delete()
A_TrayMenu.Add("Options", (*) => MyGui.Show())
A_TrayMenu.Add("Exit", (*) => ExitApp())
A_TrayMenu.Default := "Options"
A_TrayMenu.ClickCount := 1