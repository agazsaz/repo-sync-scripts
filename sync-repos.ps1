#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Скрипт для синхронизации двух репозиториев
.DESCRIPTION
    Выполняет pull из удаленного репозитория и копирует содержимое в другой локальный репозиторий
.NOTES
    Автор: Евгений
    Версия: 1.0
#>

# Настройка кодировки
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

# Функция для проверки пути
function Test-PathSafe {
    param([string]$Path)
    
    if (-not (Test-Path $Path)) {
        Write-Host "Ошибка: Путь '$Path' не существует!" -ForegroundColor Red
        return $false
    }
    
    if ($Path -match 'System32|Windows|Program Files') {
        Write-Host "Предупреждение: Путь содержит системную директорию!" -ForegroundColor Yellow
        $confirmation = Read-Host "Продолжить? (y/n)"
        if ($confirmation -ne 'y') { return $false }
    }
    
    return $true
}

# Функция для копирования
function Copy-RepositoryContent {
    param(
        [string]$SourcePath,
        [string]$DestinationPath
    )
    
    try {
        Get-ChildItem -Path $SourcePath -Exclude '.git' | ForEach-Object {
            $SourceItem = $_.FullName
            $DestItem = Join-Path $DestinationPath $_.Name
            
            if ($_.PSIsContainer) {
                Copy-Item -Path $SourceItem -Destination $DestItem -Recurse -Force
                Write-Host "Скопирована папка: $($_.Name)" -ForegroundColor Green
            } else {
                Copy-Item -Path $SourceItem -Destination $DestItem -Force
                Write-Host "Скопирован файл: $($_.Name)" -ForegroundColor Green
            }
        }
        return $true
    }
    catch {
        Write-Host "Ошибка при копировании: $_" -ForegroundColor Red
        return $false
    }
}

# Основная функция
function Start-Sync {
    Write-Host "=== Синхронизация репозиториев ===" -ForegroundColor Cyan
    
    $sourceRepo = "C:\Projects\source-repo"
    $destRepo = "C:\Projects\destination-repo"
    
    if (-not (Test-PathSafe $sourceRepo)) { return }
    if (-not (Test-PathSafe $destRepo)) { return }
    
    Write-Host "`n[1/4] Выполняем git pull в исходном репозитории..." -ForegroundColor Yellow
    Set-Location $sourceRepo
    
    $remoteExists = git remote -v
    if ($remoteExists) {
        git pull
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Ошибка при выполнении git pull!" -ForegroundColor Red
            return
        }
    } else {
        Write-Host "Нет удаленного репозитория, пропускаем pull" -ForegroundColor Yellow
    }
    
    Write-Host "`n[2/4] Копируем содержимое в целевой репозиторий..." -ForegroundColor Yellow
    $copyResult = Copy-RepositoryContent -SourcePath $sourceRepo -DestinationPath $destRepo
    
    if (-not $copyResult) {
        Write-Host "Ошибка при копировании!" -ForegroundColor Red
        return
    }
    
    Write-Host "`n[3/4] Хотите выполнить git push в целевом репозитории? (y/n)" -ForegroundColor Yellow
    $doPush = Read-Host
    
    if ($doPush -eq 'y') {
        Set-Location $destRepo
        $status = git status --porcelain
        if ($status) {
            git add .
            git commit -m "Auto-sync from source repository $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
            git push
            Write-Host "Git push выполнен успешно!" -ForegroundColor Green
        } else {
            Write-Host "Нет изменений для коммита" -ForegroundColor Yellow
        }
    }
    
    Write-Host "`n[4/4] Синхронизация завершена!" -ForegroundColor Green
    Write-Host "`nНажмите любую клавишу для выхода..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

Start-Sync