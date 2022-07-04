@ECHO OFF

REM ###########################################################
REM #
REM # Get path creation time in YYYYMMDDhhmmss.microseconds.
REM #
REM ###########################################################

SETLOCAL

@REM IF [%1]==[] ECHO Value Missing

:: Check given argument.
IF "%1%" == "" (
  SET dirPath=%CD%
) ELSE (
  SET dirPath=%~f1%
)
ECHO Recieved: %dirPath%

:: Check for last character separator.
IF "%dirPath:~-1%" == "\" (
  SET dirPath=%dirPath:~0,-1%
)

:: Format path correctly.
SET dirPath=%dirPath:\=\\%
ECHO Converted: %dirPath%

:: Get creationTime.
SET command=wmic fsdir where name="%dirPath%" get creationdate
ECHO Executing: %command%
%command% | findstr /brc:[0-9]
ENDLOCAL
