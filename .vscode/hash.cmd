@ECHO OFF

REM ###########################################################
REM #
REM # Replicate VS Code approach to creating salted hash folder.
REM #
REM ###########################################################

SETLOCAL

SET _vsc=.\.vscode

:: Check given argument.
IF "%1%" == "" (
  SET dirPath=%CD%
) ELSE (
  SET dirPath=%~f1%
)
ECHO Recieved: %dirPath%

:: Get creation time of root folder.
FOR /F %%A IN ('%_vsc%\exec_creationTime.cmd %dirPath%') DO SET creationDate=%%A
ECHO creationDate: %creationDate%

:: Break creation time into two parts dateTime and us (microseconds).
FOR /F "tokens=1,2 delims=." %%A IN ("%creationDate%") DO SET dateTime=%%A & SET us=%%B
ECHO dateTime: %dateTime%
ECHO us: %us%

:: Format date and time correctly.
SET YYYY=%dateTime:~0,4%
SET MM=%dateTime:~4,2%
SET DD=%dateTime:~6,2%
SET hh=%dateTime:~8,2%
SET min=%dateTime:~10,2%
SET ss=%dateTime:~12,2%
SET formattedDateTime=%YYYY%/%MM%/%DD% %hh%:%min%:%ss%
ECHO formattedDateTime: %formattedDateTime%

:: Convert formattedDateTime to epoch milliseconds.
FOR /F %%A IN ('cscript /nologo %_vsc%\ms.js %formattedDateTime%') DO SET epoch=%%A
ECHO epoch: %epoch%

SET ms=%us:~0,3%
ECHO ms: %ms%
CALL SET fullEpoch=%%epoch:000=%ms%%%
ECHO fullEpoch: %fullEpoch%

:: Create hash.
:: Get current directory in vscode.Uri.fsPath format.
SET drive=%dirPath:~0,1%
CALL :toLower drive
SET fsPath=%drive%%dirPath:~1%
ECHO fsPath: %fsPath%

:: Create salt.
SET fsPathSalt=%fsPath%%fullEpoch%
ECHO %fsPathSalt%> %_vsc%\fsPathSalt.txt

:: Remove CRLF from file and generate hash digest.
FOR /F %%A IN ('type %_vsc%\fsPathSalt.txt') DO (>%_vsc%\fsPathSalt.txt <NUL SET /p unused=%%A)
certutil -hashfile %_vsc%\fsPathSalt.txt MD5 | find /v ":"> %_vsc%\md5-hex.digest
del /Q /A:A %_vsc%\fsPathSalt.txt
ENDLOCAL
GOTO :eof

REM #################################################################
REM # Convert the supplied environment variable (%1) to lowercase.
REM # This may be slow for very long strings.
REM #################################################################
:toLower
  FOR %%G IN (a b c d e f g h i j k l m n o p q r s t u v w x y z) DO CALL Set %1=%%%1:%%G=%%G%%
EXIT /B 0
