@Echo off
REM Hack because of an EPERM bug in gitbook: https://github.com/GitbookIO/gitbook/issues/1379
:Start
call gitbook serve
goto Start