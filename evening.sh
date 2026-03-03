#!/bin/bash
# ============================================================
# evening.sh — Закат. Завершение беседы и сохранение памяти
# Запуск: ./scripts/evening.sh
# Запускать ПОСЛЕ того как Аристотель произнёс слова прощания
# ============================================================

# --- НАСТРОЙКИ (измени под свои пути) ---
PROJECT_DIR="$HOME/code/projects/Aristotel"
TODAY_SCROLL="$PROJECT_DIR/today_scroll.md"
MEMORY_FILE="$PROJECT_DIR/MEMORY.md"
PROGRESS_FILE="$PROJECT_DIR/PROGRESS.md"
CLAUDE_MD="$PROJECT_DIR/CLAUDE.md"
# -----------------------------------------

set -e
cd "$PROJECT_DIR"

echo ""
echo "🌇 Солнце садится над Ликеем..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. Определить номер дня
if [ -f "$MEMORY_FILE" ]; then
    LAST_DAY=$(grep -oP '(?<=### День )\d+' "$MEMORY_FILE" | tail -1)
    TODAY_DAY=$((LAST_DAY + 1))
else
    TODAY_DAY=1
fi
echo "📅 Завершается День $TODAY_DAY"

# 2. Считать тему из today_scroll.md
if [ -f "$TODAY_SCROLL" ]; then
    SCROLL_TOPIC=$(grep "## Тема:" "$TODAY_SCROLL" | sed 's/## Тема: //')
    echo "📜 Свиток: $SCROLL_TOPIC"
else
    SCROLL_TOPIC="без свитка"
    echo "📜 Свиток: не использовался"
fi

echo ""
echo "🤖 Агент закрывает беседу и обновляет память..."
echo ""

# 3. Агент обновляет все файлы
claude --dangerously-skip-permissions --print \
"Ты — агент завершения философской беседы. Выполни строго по шагам:

КОНТЕКСТ:
- Сегодня День $TODAY_DAY
- Свиток: '$SCROLL_TOPIC'
- Файл today_scroll.md содержит тему и ключевые понятия сегодняшней беседы

ЗАДАЧА 1 — Обнови MEMORY.md:
Прочитай today_scroll.md. Добавь в конец MEMORY.md новую запись строго по шаблону
(не более 6 строк, никакого пересказа):

### День $TODAY_DAY — [тема из today_scroll.md одной фразой]
- Свиток: $SCROLL_TOPIC
- Разобрали: [2–3 концепции из сегодняшнего свитка]
- Применял сам: нет
- Затруднения: нет
- Завтра: [следующая логичная тема по Метафизике]

ЗАДАЧА 2 — Обнови PROGRESS.md:
Прочитай today_scroll.md и найди ключевые понятия.
Если файл PROGRESS.md не существует — создай его с заголовком:
'# PROGRESS.md — Тематический прогресс по учению Аристотеля'

Для каждого понятия из today_scroll.md:
- Если понятие уже есть в PROGRESS.md — обнови статус на ✅ и добавь строку 'Разобрали День $TODAY_DAY'
- Если понятия нет — добавь новый блок:
  ## [Название понятия]
  - Введено: День $TODAY_DAY
  - Статус: 👁 упоминалось
  - Открытые вопросы: —

ЗАДАЧА 3 — Обнови оглавление в CLAUDE.md:
Прочитай CLAUDE.md. Найди таблицу свитков.
Если '$SCROLL_TOPIC' там ещё нет — добавь строку в конец таблицы.
Если уже есть — ничего не делай.

После выполнения всех задач выведи только:
'✓ MEMORY.md обновлён
✓ PROGRESS.md обновлён
✓ CLAUDE.md проверен'"

# 4. Удалить today_scroll.md
if [ -f "$TODAY_SCROLL" ]; then
    rm "$TODAY_SCROLL"
    echo "🗑  today_scroll.md удалён"
fi

# 5. Git commit и push
echo ""
echo "📤 Сохраняю в GitHub..."
git add -A
git commit -m "День $TODAY_DAY — $(date +%d.%m.%Y) | $SCROLL_TOPIC"
git push origin main --quiet
echo "   ✓ Запись о Дне $TODAY_DAY сохранена в GitHub"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌙 Ликей закрыт. До завтра, друг мой."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
