@echo off
mode con lines=22 cols=86
echo>list.txt
echo>list.txt list disk
@echo on
diskpart -s list.txt
@echo off
set /p disco="Entre com o disco: "
echo:
echo>move.txt
echo>move.txt list disk
echo>>move.txt select disk %disco%
echo>>move.txt clean
echo>>move.txt create partition primary
echo>>move.txt format fs=ntfs quick
echo>>move.txt active
echo>>move.txt assign
@echo off
diskpart -s move.txt
echo:
del /f list.txt
del /f move.txt
pause
del C:\Windows\System32\*hd.bat
exit /b






