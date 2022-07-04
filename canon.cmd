@ECHO OFF

REM ###########################################################
REM #
REM # Canon script to launch local VS Code version with codio.
REM #
REM ###########################################################

SETLOCAL ENABLEEXTENSIONS

cls

SET _vsc=.\.vscode

IF "%1%" == "clean" (
  CALL :clean
)

REM ###########################################################
REM # Check if extension install is needed.
REM ###########################################################
CALL :isDir %_vsc%\extensions\*codio*
IF %ERRORLEVEL% NEQ 0 (
  CALL :install
)

CALL :open
GOTO :eof

REM ###########################################################
REM # Delete codio extension and user-data folders.
REM ###########################################################
:clean
  :: Possible 'File Not Found'.
  FOR /F %%A IN ('dir /B /S /A:D *codio-*') DO SET codioExtFolder=%%A
  rmdir /S /Q %codioExtFolder% > NUL 2>&1
  FOR /F %%A IN ('dir /B /S /A:D user-data') DO SET userDataFolder=%%A
  rmdir /S /Q %userDataFolder% > NUL 2>&1
EXIT /B 0

REM ###########################################################
REM # Check if argument is a directory.
REM ###########################################################
:isDir
  SETLOCAL
  :: Get file attributes.
  SET _attr=%~a1
  :: Get first character.
  SET _isdir=%_attr:~0,1%
  :: Insensitive case check.
  IF /I "%_isdir%" == "d" (
    ENDLOCAL
    EXIT /B 0
  )
  ENDLOCAL
EXIT /B 2

REM ###########################################################
REM # Install extensions needed for Canon.
REM ###########################################################
:install
  SETLOCAL
  :: Create install folder.
  mkdir %_vsc%\extensions 2>NUL

  :: Get new extension to install.
  FOR /f %%A IN ('dir /B /S /A:A codio-*.vsix') DO SET extension=%%A

  cmd /c code --extensions-dir %_vsc%\extensions ^
  --install-extension %extension% --force
  ENDLOCAL
EXIT /B 0

REM ###########################################################
REM # Open VS Code with workspace extensions.
REM ###########################################################
:open
  SETLOCAL
  :: Get hash value.
  IF NOT EXIST %_vsc%\md5-hex.digest (
    CALL %_vsc%\hash.cmd %CD%
  )
  SET /P hash=<%_vsc%\md5-hex.digest

  :: Create VS Code state.
  mkdir %_vsc%\user-data\User\workspaceStorage\%hash% 2>NUL
  if %ERRORLEVEL% EQU 0 (
    ECHO Created workspaceStorage folder: %hash%
  )
  copy /Y %_vsc%\workspaceStorage.vscdb %_vsc%\user-data\User\workspaceStorage\%hash%\state.vscdb > NUL

  :: Ensure clean start.
  mkdir %_vsc%\user-data\User\globalStorage 2>NUL
  copy /Y %_vsc%\globalStorage.vscdb %_vsc%\user-data\User\globalStorage\state.vscdb > NUL
  copy /Y %_vsc%\1024x768.json %_vsc%\user-data\User\globalStorage\storage.json > NUL

  CALL code --disable-workspace-trust --user-data-dir %_vsc%\user-data --extensions-dir %_vsc%\extensions .
  ENDLOCAL
EXIT /B 0
