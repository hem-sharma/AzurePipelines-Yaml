@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
REM Arguments- %1: Root Directory, %2: Region, %3: Timestamp, %4: Environment, %5: Current head, %6: Global region
ECHO ==============================================================================
ECHO Initiating...
ls


cd %2
git checkout %1

git tag -a test1 6bc1dd0 -m 'added'
git push --follow-tags

ECHO completed against !tag!.
ECHO ==============================================================================
