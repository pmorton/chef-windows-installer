#
# Author:: Paul Morton (<pmorton@biaprotect.com>)
# Copyright:: Copyright (c) 2011 Paul Morton
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

!define DevKitURL "http://cloud.github.com/downloads/oneclick/rubyinstaller/DevKit-tdm-32-4.5.1-20101214-1400-sfx.exe"
!define DevKitDownload "$Temp\DevKit.exe";
!define RubyURL "http://rubyforge.org/frs/download.php/74298/rubyinstaller-1.9.2-p180.exe";
!define RubyDownload "$Temp\Ruby.exe"


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



ReadRegStr $RubyDir HKLM "SOFTWARE\RubyInstaller\MRI\1.9.2" "InstallLocation"
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
nsExec::ExecToLog "$gemBin install knife-windows --no-ri --no-rdoc --verbose";

sectionEnd