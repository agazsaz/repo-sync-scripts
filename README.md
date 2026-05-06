# repo-sync-scripts
# Скрипты синхронизации Git-репозиториев

## 📋 Описание
Скрипты для автоматической синхронизации между двумя Git-репозиториями.

## 🔗 Мои репозитории
- **source-repo** (исходный) → https://github.com/agazsaz/repo-sync-scripts/
- **destination-repo** (целевой) → https://github.com/agazsaz/MFUA.REP

## 📁 Файлы
| Файл | Назначение |
|------|------------|
| `sync-repos.ps1` | Скрипт для Windows PowerShell |
| `sync-repos.sh` | Скрипт для Linux/MacOS Bash |

## ⚙️ Функции скрипта
1. **git pull** в исходном репозитории
2. **Копирование** всех файлов (кроме `.git`) в целевой репозиторий
3. **Замена** существующих файлов
4. **Опционально git push** в целевой репозиторий

## 🚀 Запуск на Windows
```powershell
cd C:\users\agaszaz\projects
.\sync-repos.ps1
