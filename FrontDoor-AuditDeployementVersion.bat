@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
REM Arguments- %1: Root Directory, %2: Region, %3: Timestamp, %4: Environment, %5: Current head, %6: Global region
ECHO ==============================================================================
ECHO Initiating...

SET rootDirectory=%1
SET strAccountName=wmarstor%6%4
SET deploymenthistorytableName=msdeploymentversioninfo
SET partitionKey=WM.Launchpad.%2

(SET MicroserviceVersion=)
(SET DIVersion=)
(SET StorageVersion=)
(SET UtilitiesVersion=)
(SET DataFoundationVersion=)
(SET OperationFoundationVersion=)
(SET DataVersion=)
(SET AFFoundationVersion=)
(SET EventVersion=)
(SET OperationVersion=)
(SET NotificationVersion=)
(SET CommonModelVersion=)
(SET SchedulerVersion=)
(SET OperationTestVersion=)
FOR /F "tokens=*" %%a IN (%rootDirectory%\SolutionInfo.props) DO (
    Set val=%%a
    
    SET msCheck=!val:~1,7!
    IF !mscheck!==Version SET MicroserviceVersion=!val:~9,5!

    SET dCheck=!val:~1,31!
    IF !dCheck!==WM_AF_DependencyInjectorVersion SET DIVersion=!val:~33,5!

    SET strCheck=!val:~1,17!
    IF !strCheck!==WM_StorageVersion SET StorageVersion=!val:~19,5!

    SET utilCheck=!val:~1,19!
    IF !utilCheck!==WM_UtilitiesVersion SET UtilitiesVersion=!val:~21,5!

    SET dfCheck=!val:~1,25!
    IF !dfCheck!==WM_Data_FoundationVersion SET DataFoundationVersion=!val:~27,5!

    SET ofCheck=!val:~1,30!
    IF !ofCheck!==WM_Operation_FoundationVersion SET OperationFoundationVersion=!val:~32,5!

    SET dataCheck=!val:~1,14!
    IF !dataCheck!==WM_DataVersion SET DataVersion=!val:~16,5!

    SET afCheck=!val:~1,23!
    IF !afCheck!==WM_AF_FoundationVersion SET AFFoundationVersion=!val:~25,5!

    SET eventCheck=!val:~1,15!
    IF !eventCheck!==WM_EventVersion SET EventVersion=!val:~17,5!

    SET operationCheck=!val:~1,19!
    IF !operationCheck!==WM_OperationVersion SET OperationVersion=!val:~21,5!

    SET notificationCheck=!val:~1,22!
    IF !notificationCheck!==WM_NotificationVersion SET NotificationVersion=!val:~24,5!

    SET commonModelCheck=!val:~1,15!
    IF !commonModelCheck!==WM_Common_Model SET CommonModelVersion=!val:~17,5!

    SET schedulerCheck=!val:~1,19!
    IF !schedulerCheck!==WM_SchedulerVersion SET SchedulerVersion=!val:~21,5!

    SET operationTestCheck=!val:~1,17!
    IF !operationTestCheck!==WM_Operation_Test SET OperationTestVersion=!val:~19,5!
)

ECHO Microservice version: !MicroserviceVersion!
ECHO DI version: !DIVersion!
ECHO Storage version: !StorageVersion!
ECHO Utilities version: !UtilitiesVersion!
ECHO Data Foundation version: !DataFoundationVersion!
ECHO Operation Foundation version: !OperationFoundationVersion!
ECHO Data version: !DataVersion!
ECHO AF Foundation version: !AFFoundationVersion!
ECHO Event version: !EventVersion!
ECHO Operation version: !OperationVersion!
ECHO Notification version: !NotificationVersion!
ECHO Common Model version: !CommonModelVersion!
ECHO Scheduler version: !SchedulerVersion!
ECHO Operation Test version: !OperationTestVersion!

SET tag=%5_%4
ECHO Tagging current release as: !tag!
git tag -a !tag! %5 -m 'Auto added.'
git push --follow-tags

ECHO. && ECHO Creating %deploymenthistorytableName% table if not exists...
CALL az storage table create --name %deploymenthistorytableName% --account-name !strAccountName!

ECHO. && ECHO Upserting WM.Launchpad current version...
CALL az storage entity insert --table-name %deploymenthistorytableName% --account-name !strAccountName! --if-exists replace --entity PartitionKey=%partitionKey% RowKey=Current MicroserviceVersion=!MicroserviceVersion! DependencyInjectionVersion=!DIVersion! StorageVersion=!StorageVersion! UtilitiesVersion=!UtilitiesVersion! DataFoundationVersion=!DataFoundationVersion! OperationFoundationVersion=!OperationFoundationVersion! DataVersion=!DataVersion! AFFoundationVersion=!AFFoundationVersion! EventVersion=!EventVersion! OperationVersion=!OperationVersion! NotificationVersion=!NotificationVersion! CommonModelVersion=!CommonModelVersion! SchedulerVersion=!SchedulerVersion! OperationTestVersion=!OperationTestVersion! ReleaseTag=!tag!

ECHO. && ECHO Inserting WM.Launchpad current deployment log...
CALL az storage entity insert --table-name %deploymenthistorytableName% --account-name !strAccountName! --entity PartitionKey=%partitionKey% RowKey=%3 MicroserviceVersion=!MicroserviceVersion! DependencyInjectionVersion=!DIVersion! StorageVersion=!StorageVersion! UtilitiesVersion=!UtilitiesVersion! DataFoundationVersion=!DataFoundationVersion! OperationFoundationVersion=!OperationFoundationVersion! DataVersion=!DataVersion! AFFoundationVersion=!AFFoundationVersion! EventVersion=!EventVersion! OperationVersion=!OperationVersion! NotificationVersion=!NotificationVersion! CommonModelVersion=!CommonModelVersion! SchedulerVersion=!SchedulerVersion! OperationTestVersion=!OperationTestVersion! ReleaseTag=!tag!

ECHO completed against !tag!.
ECHO ==============================================================================