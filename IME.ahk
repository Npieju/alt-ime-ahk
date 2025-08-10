#Requires AutoHotkey v2.0
/***************************************************************************
  IME制御用 関数群 (IME.ahk)
  AutoHotkey v2 port
***************************************************************************/

IME_GET(WinTitle := "A") {
    hwnd := _imeGetDefaultWindow(WinTitle)
    return DllCall("SendMessage", "ptr", hwnd, "uint", 0x0283, "int", 0x0005, "int", 0)
}

IME_SET(SetSts, WinTitle := "A") {
    hwnd := _imeGetDefaultWindow(WinTitle)
    return DllCall("SendMessage", "ptr", hwnd, "uint", 0x0283, "int", 0x006, "int", SetSts)
}

IME_GetConvMode(WinTitle := "A") {
    hwnd := _imeGetDefaultWindow(WinTitle)
    return DllCall("SendMessage", "ptr", hwnd, "uint", 0x0283, "int", 0x001, "int", 0)
}

IME_SetConvMode(ConvMode, WinTitle := "A") {
    hwnd := _imeGetDefaultWindow(WinTitle)
    return DllCall("SendMessage", "ptr", hwnd, "uint", 0x0283, "int", 0x002, "int", ConvMode)
}

IME_GetSentenceMode(WinTitle := "A") {
    hwnd := _imeGetDefaultWindow(WinTitle)
    return DllCall("SendMessage", "ptr", hwnd, "uint", 0x0283, "int", 0x003, "int", 0)
}

IME_SetSentenceMode(SentenceMode, WinTitle := "A") {
    hwnd := _imeGetDefaultWindow(WinTitle)
    return DllCall("SendMessage", "ptr", hwnd, "uint", 0x0283, "int", 0x004, "int", SentenceMode)
}

IME_GetConverting(WinTitle := "A", ConvCls := "", CandCls := "") {
    focus := ControlGetFocus(WinTitle)
    hwnd := ControlGetHwnd(focus, WinTitle)
    if WinActive(WinTitle) {
        ptrSize := A_PtrSize
        cbSize := 4 + 4 + (ptrSize * 6) + 16
        stGTI := Buffer(cbSize, 0)
        NumPut("UInt", cbSize, stGTI, 0)
        if DllCall("GetGUIThreadInfo", "uint", 0, "ptr", stGTI)
            hwnd := NumGet(stGTI, 8 + ptrSize, "ptr")
    }
    pid := WinGetPID("ahk_id " hwnd)
    tmm := A_TitleMatchMode
    SetTitleMatchMode("RegEx")
    ConvCls := (ConvCls ? ConvCls "|" : "") "ATOK\d+CompStr|imejpstcnv\d+|WXGIMEConv|SKKIME\d+\.*\d+UCompStr|MSCTFIME Composition"
    CandCls := (CandCls ? CandCls "|" : "") "ATOK\d+Cand|imejpstCandList\d+|imejpstcand\d+|mscandui\d+\.candidate|WXGIMECand|SKKIME\d+\.*\d+UCand"
    CandGCls := "GoogleJapaneseInputCandidateWindow"
    ret := WinExist("ahk_class " CandCls " ahk_pid " pid) ? 2
        : WinExist("ahk_class " CandGCls) ? 2
        : WinExist("ahk_class " ConvCls " ahk_pid " pid) ? 1
        : 0
    SetTitleMatchMode(tmm)
    return ret
}

_imeGetDefaultWindow(WinTitle) {
    focus := ControlGetFocus(WinTitle)
    hwnd := ControlGetHwnd(focus, WinTitle)
    if WinActive(WinTitle) {
        ptrSize := A_PtrSize
        cbSize := 4 + 4 + (ptrSize * 6) + 16
        stGTI := Buffer(cbSize, 0)
        NumPut("UInt", cbSize, stGTI, 0)
        if DllCall("GetGUIThreadInfo", "uint", 0, "ptr", stGTI)
            hwnd := NumGet(stGTI, 8 + ptrSize, "ptr")
    }
    return DllCall("imm32\\ImmGetDefaultIMEWnd", "ptr", hwnd, "ptr")
}
