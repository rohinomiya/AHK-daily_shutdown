; daily_shutdown.ahk --- 毎日決まった時間にシャットダウン
;
; Author::    Rohinomiya(Toru Fukuda) <mailto:rohinomiya@gmail.com>
; Copyright:: Copyright (c) 2011 Rohinomiya
; License::   GPL
; Last Change        : 2010/06/29 21:35:28.

; 使い方
;
; 1.以下のサイトから「蛍の光」の.mp3ファイルをダウンロードする
;   http://kya.art-studio.cc/
;   http://kya.art-studio.cc/48mp3/PYK00002_48kbps.mp3
;
; 2.ダウンロードしたファイルを daily_shutdown.exe と同じ場所に置く
;
; 3.daily_shutdown.ini をメモ帳で開き、時間になったら鳴らしたいファイル名や、時刻を書いて保存する

#Persistent
#SingleInstance
#NoEnv

#include %A_ScriptDir%
SetWorkingDir, %A_ScriptDir%

ExchangeFileExtension(Path, Ext)  ; パスの拡張子を置き換える
{
  SplitPath, Path, FileName, Dir, Extension, NameNoExt, OutDrive
  IfEqual, Dir,
    NewPath = %NameNoExt%%Ext%
  else
    NewPath = %Dir%\%NameNoExt%%Ext%
  
  return NewPath
}

MyIniFilePath()  ; 各スクリプトに対応するiniファイルのパスを取得する
{
  return ExchangeFileExtension(A_ScriptFullPath,".ini")
}

IniReadName(IniFilePath, Section, Key, Default)  ; Iniファイルから名を読み込む(存在チェックなし)
{
  IniRead, Dir, %IniFilePath%, %Section%, %Key%, %Default% 
  ifEqual, Dir, ERROR
  {
    Message = IniReadName(): Iniファイルに以下のエントリがありません。記述してください`n`r
    Message = %Message%%IniFilePath%`n`r
    Message = %Message%[%Section%] %Key%=?
    msgbox, %Message%
    exitApp
  }
  return Dir
}

zero_surpress(number, digit)
{
  len = StrLen(number) 
  while(len < digit)
  {
    number = 0%number%

    len = StrLen(number) 
  }

  return number
}

get_now_hhmm(OriginTime)
{
  HHMM = %A_HOUR%%A_MIN%

  IFLess,HHMM, %OriginTime%
  {
    T_HOUR := A_HOUR + 24
    T_HOUR := zero_surpress(T_HOUR, 2)
  }

  HHMM = %T_HOUR%%A_MIN%

	return HHMM
}

reset_flags()
{
  global SoundTimePassed
  global ShutdownPassed

  SoundTimePassed = false
  ShutdownPassed = false
}

ShowAlert(Command)
{
  global SoundTimePassed
  global ShutdownTime

  ifEqual, SoundTimePassed ,true
    return

  SoundTimePassed = true

  run, %Command%
  MsgBox, 48, そろそろ寝る準備をしましょう。,%ShutdownTime% に電源を切りますので、そろそろ片付けてください, 180
}

do_shutdown()
{
  global ShutdownPassed

  ifEqual, ShutdownPassed ,true
    return

  ShutdownPassed = true
  MsgBox, 49, もう寝る時間です。,まもなくパソコンの電源を切ります。`n(まだ使う場合は、3分以内にキャンセルを押してください),180

  IfMsgBox Cancel
    return

  shutdown, 5	; 1(Shutdown) * +4(Force)
}

; initialize
SoundTimePassed = false
ShutdownPassed = false

; .ini file read
IniFilePath := MyIniFilePath()

Section = PATH
Command := inireadname( IniFilePath, Section , "COMMAND" , "" )

Section = TIME
OriginTime := inireadname( IniFilePath, Section , "ORIGIN" , "0600" )
SoundTime := inireadname( IniFilePath, Section , "SOUND" , "2330" )
ShutdownTime := inireadname( IniFilePath, Section , "SHUTDOWN" , "2400" )

; set timer
SetTimer,OnTimer,20000 ; miliseccond
return

OnTimer:
  Now := get_now_hhmm(OriginTime)

;  msgbox, %Now% %SoundTime%

  ifEqual, Now, %OriginTime%
  	reset_flags()
	else ifEqual, Now, %SoundTime%
		ShowAlert(Command)
	else ifEqual, Now, %ShutdownTime%
		do_shutdown()
	return 
