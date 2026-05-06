#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

check_path() {
    local path="$1"
    if [ ! -d "$path" ]; then
        echo -e "${RED}Ошибка: Путь '$path' не существует!${NC}"
        return 1
    fi
    return 0
}

copy_repository() {
    local source="$1"
    local dest="$2"
    
    if command -v rsync &> /dev/null; then
        rsync -av --delete --exclude='.git' "$source/" "$dest/"
        return $?
    else
        cp -rf "$source"/* "$dest/" 2>/dev/null
        cp -rf "$source"/.[!.]* "$dest/" 2>/dev/null
        return $?
    fi
}

main() {
    echo -e "${CYAN}=== Синхронизация репозиториев ===${NC}"
    
    SOURCE_REPO="/c/Projects/source-repo"
    DEST_REPO="/c/Projects/destination-repo"
    
    if ! check_path "$SOURCE_REPO"; then exit 1; fi
    if ! check_path "$DEST_REPO"; then exit 1; fi
    
    echo -e "\n${YELLOW}[1/4] Выполняем git pull в исходном репозитории...${NC}"
    cd "$SOURCE_REPO" || exit
    
    if git remote -v | grep -q .; then
        git pull
        if [ $? -ne 0 ]; then
            echo -e "${RED}Ошибка при выполнении git pull!${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}Нет удаленного репозитория, пропускаем pull${NC}"
    fi
    
    echo -e "\n${YELLOW}[2/4] Копируем содержимое в целевой репозиторий...${NC}"
    if ! copy_repository "$SOURCE_REPO" "$DEST_REPO"; then
        echo -e "${RED}Ошибка при копировании!${NC}"
        exit 1
    fi
    
    echo -e "\n${YELLOW}[3/4] Хотите выполнить git push в целевом репозитории? (y/n)${NC}"
    read -r do_push
    
    if [[ "$do_push" == "y" ]]; then
        cd "$DEST_REPO" || exit
        if [ -n "$(git status --porcelain)" ]; then
            git add .
            git commit -m "Auto-sync from source repository $(date '+%Y-%m-%d %H:%M:%S')"
            git push
            echo -e "${GREEN}Git push выполнен успешно!${NC}"
        else
            echo -e "${YELLOW}Нет изменений для коммита${NC}"
        fi
    fi
    
    echo -e "\n${GREEN}[4/4] Синхронизация завершена!${NC}"
}

main
read -p "Нажмите Enter для выхода..."