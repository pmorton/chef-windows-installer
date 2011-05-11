!define DevKitURL "http://cloud.github.com/downloads/oneclick/rubyinstaller/DevKit-tdm-32-4.5.1-20101214-1400-sfx.exe"
!define DevKitDownload "$Temp\DevKit.exe";
!define RubyURL "http://rubyforge.org/frs/download.php/74293/rubyinstaller-1.8.7-p334.exe";
!define RubyDownload "$Temp\Ruby.exe"
#!define InstallDirectory "C:\ChefClient";
#!define RubyDir "${InstallDirectory}\Ruby";
#!define RubyBin "${RubyDir}\bin\ruby.exe"
#!define gemBin "${RubyDir}\bin\gem.bat"
#!define DevKitDir "${InstallDirectory}\DevKit"

OutFile "ChefInstaller.exe"

InstallDir "C:\ChefClient"

XPStyle On
ShowInstDetails show
Page directory
Page instfiles
section

Var /GLOBAL RubyDir
Var /GLOBAL RubyBin
Var /GLOBAL gemBin
Var /GLOBAL InstallRuby
Var /GLOBAL DevKitDir



ReadRegStr $RubyDir HKLM "SOFTWARE\RubyInstaller\MRI\1.8.7" "InstallLocation"
DetailPrint $RubyDir
IfErrors 0 RubyFound
	DetailPrint "No existing Ruby installation found"
	StrCpy $RubyDir "$INSTDIR\Ruby"
	StrCpy $InstallRuby 1
	Goto RubyInitalized
RubyFound:
	DetailPrint "Existing Ruby installation found ($RubyDir)"
	StrCpy $InstallRuby 0
	
RubyInitalized:
	StrCpy $RubyBin "$RubyDir\bin\ruby.exe"
	StrCpy $gemBin "$RubyDir\bin\gem.bat"

IntCmp $InstallRuby 0 RubyInstallDone
	DetailPrint "Downloading Ruby (${RubyURL})..."
	nsisdl::download "${RubyURL}" "${RubyDownload}"

	DetailPrint "Installing Ruby (${RubyDownload})"
	nsExec::ExecToLog "${RubyDownload} /tasks=assocfiles,modpath /verysilent /dir=$INSTDIR\Ruby"
RubyInstallDone:

StrCpy $DevKitDir "$RubyDir\DevKit"

IfFileExists "$DevKitDir\dk.rb" DevKitInstalled DevKitMissing
DevKitMissing:
	SetOutPath $DevKitDir
	DetailPrint "Downloading Ruby DevKit (${DevKitURL})..."
	nsisdl::download "${DevKitURL}" "${DevKitDownload}"

	DetailPrint "Installing RubyDevKit (${DevKitDownload})"
	Nsis7z::ExtractWithDetails "${DevKitDownload}" "Installing RubyDevKit..."
	Goto DevKitDone
DevKitInstalled:
	DetailPrint "Existing DevKit found ($DevKitDir)"
DevKitDone:

DetailPrint "Configuring Ruby DevKit...."
nsExec::ExecToLog "$RubyBin $DevKitDir\dk.rb init"
nsExec::ExecToLog "$RubyBin $DevKitDir\dk.rb install"
nsExec::ExecToLog "$gemBin install win32-open3 ruby-wmi windows-api windows-pr --no-rdoc --no-ri --verbose"

DetailPrint "Installing Chef..."
nsExec::ExecToLog "$gemBin install chef --no-ri --no-rdoc --verbose";

sectionEnd