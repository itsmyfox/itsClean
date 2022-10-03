# itsClean
ItsClean PowerShell
* Данный скрипт прошел многочисленные тесты, очистил и продиагностировал уже свыше 1000 компьютеров в компании.
* Удаляет скачанные обновления Windows, очищает от дампов, логов, лишних файлов в системе.
* Скрипты подписаны сертификатом. Полностью открытый исходный код.

# При появлении заявки о нехватке места на ОС Windows : 

1. Скопировать целиком папку PSScriptMenuGui в любое место на компьютер. Все скрипты взаимосвязаны между друг другом и не будут работать полноценно, если будете использовать скрипты отдельно.
2. Убедитесь, что у Вас имеются права администратора на Вашей учетной записи Windows.
* 2.1 Первый способ: Параметры - Учетные записи - Ваши данные.
* 2.2 Второй способ: кликните по значку Windows - потом кликнуть по аватарке вашего профиля - изменить параметры учетной записи. Вас перебросит в параметры - Ваши данные.
3. Перейти в папку C:\***\***\PSScriptMenuGui\start\
4. Правой клавишей мыши по "START_Scripts.ps1" - Выполнить с помощью PowerShell. 
Тем самым Вы запустите GUI меню для простого взаимодействия со скриптами.
5. При первом запуске Вас попросят подтвердить запуск скрипта - введите на клавиатуре букву "А" и нажмите Enter.

Теперь подробнее о функционале скриптов:

# ItsDiagnostics:

1. Обновление групповых политик с помощью команды : 
gpupdate /force 
 
2. Восстановить поврежденное хранилище компонентов Windows с помощью команды: 
DISM /Online /Cleanup-Image /RestoreHealth 
 
3. Диагностика и восстановление системных файлов с помощью команды: 
sfc /scannow 

# ItsCleanable:

Очистка диска по строго фиксированным директориям. Эти директории указаны в текстовых файлах и можно менять самостоятельно. 
PSScriptMenuGui\start\file-check.txt - Директории дампов, логов и мусора в папках Windows, ProgramData и корня диска С.
PSScriptMenuGui\start\users-directory.txt - Директории в папке пользователей. По реестру идет сканирование всех ваших пользователей и очистка дампов, логов.

Что такое удаление индексной базы?
Это все что Вы ищите по поиску Windows. Любые поиски по папкам логируются по умолчанию (если это включено при установке Windows). Со временем данный фаил растет и его нужно очищать и создавать новый. В данном случае скрипт останавливает службу Windows Search, удаляет Windows.edb и создает новый фаил. 

Список фиксированных директорий в папке Windows, ProgramData и корня диска С (PSScriptMenuGui\start\file-check.txt):

C:\Logs\
C:\Windows\Logs\
C:\Windows\Temp\
C:\Windows\SoftwareDistribution\
C:\Windows\Installer\$PatchCache$\
C:\Windows\assembly\NativeImages_v2.0.50727_32\temp\
C:\Windows\assembly\NativeImages_v4.0.30319_64\temp\
C:\Windows\assembly\NativeImages_v2.0.50727_64\temp\
C:\Windows\assembly\NativeImages_v4.0.30319_32\temp\
C:\Windows\assembly\temp\
C:\Windows\assembly\tmp\
C:\Windows\System32\WDI\BootPerformanceDiagnostics_SystemData.bin
C:\Windows\System32\WDI\ShutdownPerformanceDiagnostics_SystemData.bin
C:\Windows\System32\catroot2\dberr.txt
C:\Windows\System32\LogFiles\WMI\RtBackup\
C:\Windows\BitLockerDiscoveryVolumeContents\
C:\Windows\LastGood.Tmp\
C:\Windows\msdownld.tmp\
C:\Windows\Minidump\
C:\Windows\'Downloaded Program Files'\
C:\Windows\'Downloaded Installations'\
C:\Windows\tracing\
C:\Windows\rescache\
C:\Windows\ModemLogs\
C:\Windows\CbsTemp\
C:\Windows\LiveKernelReports\
C:\Windows\DeliveryOptimization\
C:\Windows\RemotePackages\
C:\Windows\bcastdvr\
C:\Windows\SchCache\
C:\Windows\Speech\Engines\Lexicon\
C:\Windows\Speech\Engines\SR\
C:\Windows\Speech_OneCore\Engines\Lexicon\
C:\Windows\Speech_OneCore\Engines\SR\
C:\Windows\System32\wbem\Logs\
C:\Windows\SysWOW64\wbem\Logs\
C:\Windows\assembly\temp\
C:\Windows\Minidump\
C:\Windows\ServiceProfiles\NetworkService\AppData\Local\Temp\
C:\Windows\System32\DriverStore\Temp\
C:\Windows\System32\config\systemprofile\AppData\LocalLow\Microsoft\CryptnetUrlCache\Content\
C:\Windows\System32\config\systemprofile\AppData\LocalLow\Microsoft\CryptnetUrlCache\MetaData\
C:\Windows\ServiceProfiles\LocalService\AppData\LocalLow\Microsoft\CryptnetUrlCache\Content\
C:\Windows\ServiceProfiles\LocalService\AppData\LocalLow\Microsoft\CryptnetUrlCache\MetaData\
C:\Windows\System32\LogFiles\Scm\
C:\Windows\System32\sysprep\Panther\IE\
C:\Windows\System32\WDI\LogFiles\
C:\'Program Files (x86)'\LANDesk\LDClient\sdmcache\
C:\'Program Files'\NVIDIA Corporation\Installer2\
C:\'Program Files'\Uninstall Information\
C:\'Program Files'\WindowsUpdate\
C:\'Program Files (x86)'\Uninstall Information\
C:\'Program Files (x86)'\WindowsUpdate\
C:\ProgramData\'Aktiv Co'\
C:\ProgramData\USOShared\Logs\
C:\ProgramData\VMware\VDM\logs\
C:\ProgramData\VMware\VDM\Dumps\
C:\ProgramData\Microsoft\Diagnosis\
C:\ProgramData\'Kaspersky Lab'\KES\Temp\
C:\ProgramData\'Kaspersky Lab'\KES\Cache\
C:\ProgramData\KasperskyLab\adminkit\1103\$FTCITmp\
C:\ProgramData\Intel\Logs\
C:\ProgramData\Intel\'Package Cache'\
C:\ProgramData\Veeam\Setup\Temp\
C:\ProgramData\'Crypto Pro'\'Installer Cache'\
C:\ProgramData\'Package Cache'\
C:\ProgramData\Oracle\Java\installcache_x64\
C:\ProgramData\LANDesk\Log\
C:\ProgramData\Intel\Logs\
C:\ProgramData\LANDesk\Temp\
C:\ProgramData\Microsoft\Windows\RetailDemo\OfflineContent\
C:\ProgramData\Microsoft\Windows\WER\ReportArchive\
C:\ProgramData\Microsoft\Windows\WER\ReportQueue\
C:\ProgramData\Microsoft\Windows\'Power Efficiency Diagnostics'\
C:\ProgramData\Microsoft\SmsRouter\MessageStore\
C:\ProgramData\Microsoft\Windows\WER\
C:\ProgramData\Microsoft\Network\Downloader\
C:\ProgramData\Microsoft\'Windows Security Health'\Logs\
C:\ProgramData\Microsoft\'Windows Defender'\Support\
C:\ProgramData\Microsoft\'Windows Defender'\Scans\History\Results\Resource\
C:\ProgramData\'Windows Defender'\'Definition Updates'\
C:\ProgramData\'Windows Defender'\Scans\
C:\Intel\
C:\SWSetup\
C:\AMD\
C:\$WINDOWS.~BT\
C:\$WINDOWS.~WS\
C:\$Windows.~BT\
C:\$Windows.~WS\
C:\Windows10Upgrade\
C:\MSOCache\
C:\Tracing\
C:\NVIDIA\
C:\Config.Msi\
C:\PerfLogs\

Список фиксированных директорий в папке пользователи (PSScriptMenuGui\start\users-directory.txt):

\AppData\Local\Temp\
\'Local Settings'\Temp\
\'Local Settings'\'Temporary Internet Files'\
\AppData\Local\Microsoft\Windows\'Temporary Internet Files'\
\AppData\Local\Yandex\YandexBrowser\Application\browser.7z
\AppData\Local\Yandex\YandexBrowser\Application\brand-package.cab
\AppData\Local\Yandex\YandexBrowser\Application\setup.exe
\AppData\Local\Comms\
\AppData\Local\Microsoft\Windows\PowerShell\
\AppData\Local\Microsoft\Windows\Notifications\
\AppData\Local\Microsoft\Windows\PRICache\
\AppData\Local\Microsoft\Windows\Caches\
\AppData\Local\Microsoft\Windows\WebCache\
\AppData\Local\Microsoft\Windows\WebCache.old\
\AppData\LocalLow\Microsoft\CryptnetUrlCache\
\AppData\LocalLow\Microsoft\Windows\AppCache\
\AppData\LocalLow\Temp\
\AppData\Roaming\Microsoft\Windows\Recent\CustomDestinations\
\AppData\Macromedia\'Flash Player'\AssetCache\
\AppData\Macromedia\'Flash Player'\NativeCache\
\AppData\Adobe\'Flash Player'\AssetCache\
\AppData\Adobe\'Flash Player'\NativeCache\
\AppData\ElevatedDiagnostics\
\AppData\Local\*.auc
\AppData\Local\Microsoft\'Terminal Server Client'\Cache\*
\AppData\Local\Microsoft\Windows\'Temporary Internet Files'\*
\AppData\Local\Microsoft\Windows\WER\ReportQueue\*
\AppData\Local\Microsoft\Windows\Explorer\*
