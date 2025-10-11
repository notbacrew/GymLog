# 🏋️ GymLog - Полное техническое описание проекта

## 📋 Обзор проекта

**GymLog** — это современное iOS приложение для отслеживания тренировок, разработанное на SwiftUI с использованием Core Data для хранения данных. Приложение предоставляет полный функционал для ведения дневника тренировок, управления упражнениями, отслеживания прогресса и достижений.

## 🏗 Архитектура приложения

### Основные компоненты:
- **SwiftUI** - UI фреймворк
- **Core Data** - локальная база данных
- **Combine** - реактивное программирование
- **CryptoKit** - шифрование паролей
- **CloudKit** - синхронизация данных (опционально)

### Паттерн архитектуры:
- **MVVM** (Model-View-ViewModel)
- **ObservableObject** для управления состоянием
- **@Published** для реактивных обновлений UI

## 📁 Структура проекта

```
GymLog/
├── GymLogApp.swift                 # Точка входа приложения
├── ContentView.swift               # Главный TabView с навигацией
├── Info.plist                     # Конфигурация приложения
├── GymLog.entitlements            # Права доступа
├── Assets.xcassets/               # Ресурсы (иконки, цвета)
├── GymLog.xcdatamodeld/           # Core Data модель
│   └── GymLog.xcdatamodel/
│       └── contents               # XML схема базы данных
├── Models/
│   └── Constants.swift            # Константы и расширения
├── Services/
│   ├── AuthManager.swift          # Управление аутентификацией
│   ├── DataManager.swift          # Управление данными
│   ├── DataExportManager.swift    # Экспорт данных
│   ├── Persistence.swift          # Core Data стек
│   └── ThemeManager.swift         # Управление темами
├── Managers/
│   └── (пустая папка для будущих менеджеров)
├── Utils/
│   └── RestTimerView.swift        # Таймер отдыха
└── Views/
    ├── Auth/
    │   ├── WelcomeView.swift      # Экран приветствия
    │   └── RegisterView.swift     # Регистрация пользователя
    ├── Home/
    │   └── HomeView.swift         # Главная страница
    ├── Workout/
    │   ├── WorkoutListView.swift  # Список тренировок
    │   ├── AddWorkoutView.swift   # Добавление тренировки
    │   ├── AddWorkoutDetailView.swift # Детали тренировки
    │   ├── EditWorkoutView.swift  # Редактирование тренировки
    │   ├── WorkoutDetailView.swift # Просмотр тренировки
    │   └── WorkoutFiltersView.swift # Фильтры тренировок
    ├── Exercise/
    │   ├── ExerciseListView.swift # Список упражнений
    │   ├── AddExerciseView.swift  # Добавление упражнения
    │   ├── EditExerciseView.swift # Редактирование упражнения
    │   └── ExerciseDetailView.swift # Детали упражнения
    ├── Progress/
    │   ├── ProgressView.swift     # Статистика прогресса
    │   └── AchievementsView.swift # Достижения
    ├── Profile/
    │   └── ProfileView.swift      # Профиль пользователя
    └── Settings/
        └── SettingsView.swift     # Настройки приложения
```

## 🗄 Модель данных (Core Data)

### Сущности:

#### 1. **User** (Пользователь)
```swift
- id: UUID (уникальный идентификатор)
- username: String (имя пользователя)
- email: String (email)
- passwordHash: String (хеш пароля)
- avatar: Data? (аватар пользователя)
- createdAt: Date (дата создания)
- workouts: [Workout] (связь с тренировками)
- exercises: [Exercise] (связь с упражнениями)
```

#### 2. **Workout** (Тренировка)
```swift
- id: UUID (уникальный идентификатор)
- date: Date (дата тренировки)
- notes: String? (заметки)
- user: User (связь с пользователем)
- details: [WorkoutDetail] (связь с деталями)
```

#### 3. **Exercise** (Упражнение)
```swift
- id: UUID (уникальный идентификатор)
- name: String (название упражнения)
- category: String (категория: "Грудь", "Спина", "Ноги", "Плечи", "Руки", "Пресс", "Кардио")
- image: Data? (изображение упражнения)
- timestamp: Date (дата создания)
- user: User (связь с пользователем)
- details: [WorkoutDetail] (связь с деталями тренировок)
```

#### 4. **WorkoutDetail** (Детали тренировки)
```swift
- id: UUID (уникальный идентификатор)
- sets: Int16 (количество подходов)
- reps: Int16 (количество повторений)
- weight: Double (вес)
- comment: String? (комментарий)
- exercise: Exercise (связь с упражнением)
- workout: Workout (связь с тренировкой)
```

## 🎨 Система тем

### ThemeManager
```swift
class ThemeManager: ObservableObject {
    @Published var colorScheme: ColorScheme?
    
    // Поддерживаемые темы:
    enum AppTheme: String, CaseIterable {
        case system = "system"    // Системная тема
        case light = "light"      // Светлая тема
        case dark = "dark"        // Темная тема
    }
}
```

### Цветовая схема (Constants.swift)
```swift
struct Colors {
    static let primary = Color.blue
    static let secondary = Color.gray
    static let success = Color.green
    static let warning = Color.orange
    static let danger = Color.red
    
    // Цвета категорий упражнений:
    static let chest = Color.red
    static let back = Color.blue
    static let legs = Color.green
    static let shoulders = Color.orange
    static let arms = Color.purple
    static let abs = Color.yellow
    static let cardio = Color.pink
}
```

## 🔐 Система аутентификации

### AuthManager
```swift
class AuthManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    // Основные методы:
    func register(username: String, email: String, password: String)
    func login(email: String, password: String)
    func logout()
    func updateProfile(username: String, email: String, avatar: Data?)
    func changePassword(currentPassword: String, newPassword: String)
    func getUserStatistics() -> UserStatistics
}
```

### Безопасность:
- Пароли хешируются с помощью **CryptoKit**
- Используется **SHA256** для хеширования
- Данные пользователя хранятся в **Core Data**
- Текущий пользователь сохраняется в **UserDefaults**

## 📱 Навигация и UI

### Главная навигация (ContentView.swift)
```swift
TabView {
    HomeView(authManager: authManager)           // Главная
    WorkoutListView(authManager: authManager)    // Тренировки
    ExerciseListView(authManager: authManager)   // Упражнения
    ProgressStatsView(authManager: authManager)  // Прогресс
    AchievementsView(authManager: authManager)   // Достижения
    RestTimerView()                              // Таймер
    ProfileView(authManager: authManager)        // Профиль
}
```

### Основные экраны:

#### 1. **HomeView** - Главная страница
- Приветствие пользователя
- Быстрые действия (новая тренировка, новое упражнение)
- Статистика недели (тренировки, подходы, вес)
- Сегодняшние тренировки
- Последние тренировки
- Карточка достижений

#### 2. **WorkoutListView** - Список тренировок
- Список всех тренировок пользователя
- Фильтрация по периоду (все, сегодня, неделя, месяц, год)
- Сортировка по дате
- Поиск по названию
- Pull-to-refresh
- Swipe-to-delete

#### 3. **ExerciseListView** - Список упражнений
- Список всех упражнений пользователя
- Фильтрация по категориям
- Поиск по названию
- Добавление/редактирование упражнений
- Загрузка изображений

#### 4. **ProgressStatsView** - Статистика прогресса
- Общая статистика (тренировки, подходы, вес, кардио)
- Распределение по категориям
- Топ упражнений по максимальному весу
- Простой график прогресса
- Список личных рекордов (1RM)
- Тепловая карта активности

#### 5. **AchievementsView** - Достижения
- Список всех достижений
- Прогресс выполнения
- Описание требований
- Награды за выполнение

#### 6. **ProfileView** - Профиль пользователя
- Информация о пользователе
- Статистика (тренировки, упражнения, подходы, вес)
- Редактирование профиля
- Настройки темы
- Выход из аккаунта

## 🎯 Функциональность

### Управление тренировками:
- **Создание тренировки**: выбор даты, добавление упражнений
- **Добавление упражнений**: выбор из списка, указание подходов/повторений/веса
- **Редактирование**: изменение всех параметров тренировки
- **Удаление**: с подтверждением и откатом изменений
- **Заметки**: добавление комментариев к тренировкам

### Управление упражнениями:
- **Создание упражнения**: название, категория, изображение
- **Категории**: Грудь, Спина, Ноги, Плечи, Руки, Пресс, Кардио
- **Изображения**: загрузка и отображение фото упражнений
- **Редактирование**: изменение всех параметров
- **Удаление**: с проверкой использования в тренировках

### Статистика и аналитика:
- **Общая статистика**: количество тренировок, подходов, общий вес
- **Временные периоды**: неделя, месяц, год
- **Категории**: распределение нагрузки по группам мышц
- **Личные рекорды**: расчет 1RM (одноповторного максимума)
- **Тепловая карта**: визуализация активности по дням
- **Прогресс**: сравнение с предыдущими периодами

### Достижения:
- **Автоматическое отслеживание**: выполнение условий
- **Типы достижений**: количество тренировок, стрики, веса
- **Прогресс**: визуальные индикаторы выполнения
- **Награды**: система поощрений

#### Каталог достижений (полный перечень)

Ниже приведен расширенный список достижений с чёткими условиями, идентификаторами, рекомендуемыми иконками (SF Symbols), цветами и типом метрики. Этот перечень можно использовать как источник истины при обновлении UI или добавлении логики подсчёта.

Примечания по обозначениям:
- `metric` — на основе какой метрики считаем прогресс (например, totalWorkouts, totalSets, totalWeightKg, cardioMinutes, max1RM, streakDays)
- `target` — целевое числовое значение для разблокировки
- `scope` — период/область подсчёта (lifetime/weekly/monthly/perWorkout)
- `icon` — SF Symbol
- `color` — базовый цвет бейджа (рекомендация)

1) Общее количество тренировок (lifetime)
- id: ach.workouts.1 • title: «Первый шаг» • target: 1 • metric: totalWorkouts • scope: lifetime • icon: figure.walk • color: gray
- id: ach.workouts.10 • title: «Десятка» • target: 10 • metric: totalWorkouts • scope: lifetime • icon: dumbbell.fill • color: blue
- id: ach.workouts.50 • title: «Полсотни» • target: 50 • metric: totalWorkouts • scope: lifetime • icon: dumbbell.fill • color: indigo
- id: ach.workouts.100 • title: «Сотня» • target: 100 • metric: totalWorkouts • scope: lifetime • icon: trophy.fill • color: yellow
- id: ach.workouts.250 • title: «Железный» • target: 250 • metric: totalWorkouts • scope: lifetime • icon: medal.fill • color: orange
- id: ach.workouts.500 • title: «Легенда зала» • target: 500 • metric: totalWorkouts • scope: lifetime • icon: star.fill • color: purple

2) Стрики (подряд идущие дни тренировок)
- id: ach.streak.3 • title: «3 дня подряд» • target: 3 • metric: streakDays • scope: consecutive • icon: flame.fill • color: orange
- id: ach.streak.7 • title: «Неделя без перерыва» • target: 7 • metric: streakDays • scope: consecutive • icon: flame.fill • color: red
- id: ach.streak.14 • title: «Две недели силы» • target: 14 • metric: streakDays • scope: consecutive • icon: flame.fill • color: pink
- id: ach.streak.30 • title: «Месяц дисциплины» • target: 30 • metric: streakDays • scope: consecutive • icon: calendar • color: blue

3) Объём за неделю (суммарный «вес» для силовых + минуты для кардио)
- id: ach.volume.week.10k • title: «10k за неделю» • target: 10000 • metric: weeklyVolume • scope: weekly • icon: chart.bar.fill • color: teal
- id: ach.volume.week.25k • title: «25k за неделю» • target: 25000 • metric: weeklyVolume • scope: weekly • icon: chart.bar.fill • color: green
- id: ach.volume.week.50k • title: «50k за неделю» • target: 50000 • metric: weeklyVolume • scope: weekly • icon: chart.bar.fill • color: mint

4) Кардио-минуты (lifetime)
- id: ach.cardio.150 • title: «Кардио-стартер» • target: 150 • metric: cardioMinutes • scope: lifetime • icon: heart.fill • color: red
- id: ach.cardio.1000 • title: «Кардио-тысяча» • target: 1000 • metric: cardioMinutes • scope: lifetime • icon: heart.circle.fill • color: pink
- id: ach.cardio.5000 • title: «Кардио-мастер» • target: 5000 • metric: cardioMinutes • scope: lifetime • icon: bolt.heart • color: purple

5) Личные рекорды (1RM/максимальный вес)
- id: ach.pr.bench.100 • title: «Жим 100 кг» • target: 100 • metric: max1RM(«Жим лежа») • scope: lifetime • icon: scalemass • color: blue
- id: ach.pr.deadlift.180 • title: «Тяга 180 кг» • target: 180 • metric: max1RM(«Становая тяга») • scope: lifetime • icon: scalemass • color: orange
- id: ach.pr.squat.160 • title: «Присед 160 кг» • target: 160 • metric: max1RM(«Приседания») • scope: lifetime • icon: figure.strengthtraining.traditional • color: green
- id: ach.pr.pullups.20 • title: «20 подтягиваний» • target: 20 • metric: maxReps(«Подтягивания») • scope: lifetime • icon: figure.pullup • color: indigo

6) Категорийные достижения (распределение по группам мышц)
- id: ach.cat.chest.10k • title: «Грудь 10k» • target: 10000 • metric: volumeByCategory("Грудь") • scope: lifetime • icon: bolt.fill • color: red
- id: ach.cat.back.10k • title: «Спина 10k» • target: 10000 • metric: volumeByCategory("Спина") • scope: lifetime • icon: bolt.fill • color: blue
- id: ach.cat.legs.10k • title: «Ноги 10k» • target: 10000 • metric: volumeByCategory("Ноги") • scope: lifetime • icon: bolt.fill • color: green
- id: ach.cat.shoulders.10k • title: «Плечи 10k» • target: 10000 • metric: volumeByCategory("Плечи") • scope: lifetime • icon: bolt.fill • color: orange
- id: ach.cat.arms.10k • title: «Руки 10k» • target: 10000 • metric: volumeByCategory("Руки") • scope: lifetime • icon: bolt.fill • color: purple
- id: ach.cat.abs.5k • title: «Пресс 5k» • target: 5000 • metric: volumeByCategory("Пресс") • scope: lifetime • icon: bolt.fill • color: yellow

7) Частота тренировок в месяц
- id: ach.month.8 • title: «8 тренировок в месяц» • target: 8 • metric: workoutsInMonth • scope: monthly • icon: calendar.badge.clock • color: blue
- id: ach.month.12 • title: «12 тренировок в месяц» • target: 12 • metric: workoutsInMonth • scope: monthly • icon: calendar.badge.clock • color: green
- id: ach.month.20 • title: «20 тренировок в месяц» • target: 20 • metric: workoutsInMonth • scope: monthly • icon: calendar.badge.clock • color: orange

8) Количество подходов и повторений (lifetime)
- id: ach.sets.1000 • title: «1000 подходов» • target: 1000 • metric: totalSets • scope: lifetime • icon: repeat • color: orange
- id: ach.reps.10000 • title: «10 000 повторений» • target: 10000 • metric: totalReps • scope: lifetime • icon: arrow.triangle.2.circlepath • color: teal

9) Консистентность недель (сколько недель подряд ≥ N тренировок)
- id: ach.weeks.4x3 • title: «4 недели по 3 тренировки» • target: 4 • metric: weeksWithAtLeast(3) • scope: consecutiveWeeks • icon: calendar.circle • color: mint
- id: ach.weeks.8x3 • title: «8 недель по 3 тренировки» • target: 8 • metric: weeksWithAtLeast(3) • scope: consecutiveWeeks • icon: calendar.circle • color: cyan

10) Экспорт и дисциплина ведения дневника
- id: ach.journal.first • title: «Первый экспорт» • target: 1 • metric: exportsCount • scope: lifetime • icon: square.and.arrow.up • color: gray
- id: ach.journal.notes.100 • title: «100 заметок» • target: 100 • metric: notesCount • scope: lifetime • icon: note.text • color: brown

#### Расчёт метрик и источники данных
- totalWorkouts, workoutsInMonth, streakDays — считаются по сущности `Workout` (Core Data)
- weeklyVolume, volumeByCategory — агрегируются по `WorkoutDetail` с учётом категории упражнения
- totalSets, totalReps, totalWeightKg — суммирование по `WorkoutDetail`
- cardioMinutes — интерпретируются как `reps * sets` для упражнений с категорией «Кардио»
- max1RM, maxReps — вычисляются по лучшим результатам в рамках одной `Exercise`
- exportsCount, notesCount — события экспорта и заметок из `DataExportManager`/полей заметок

#### Рекомендации по UI бейджей
- Бронза (начальный уровень): gray/orange
- Серебро (средний уровень): blue/indigo
- Золото (высший уровень): yellow
- Специальные PR/кардио: red/purple/pink

#### Псевдокод проверки достижения
```swift
struct AchievementRule {
    let id: String
    let title: String
    let target: Double
    let metric: Metric
    let scope: Scope
}

enum Metric { case totalWorkouts, streakDays, weeklyVolume, cardioMinutes, totalSets, totalReps, totalWeightKg, max1RM(String), maxReps(String), volumeByCategory(String), workoutsInMonth, weeksWithAtLeast(Int), exportsCount, notesCount }
enum Scope { case lifetime, weekly, monthly, consecutive, consecutiveWeeks }

func isUnlocked(_ rule: AchievementRule, with stats: UserStatisticsExtended) -> Bool {
    let value = stats.value(for: rule.metric, scope: rule.scope)
    return value >= rule.target
}
```

Это позволит безопасно масштабировать перечень достижений, изменяя только конфигурацию правил.

## 🛠 Технические детали

### Core Data:
- **PersistenceController**: синглтон для управления стеком
- **CloudKit**: опциональная синхронизация между устройствами
- **Миграции**: автоматические обновления схемы
- **Контексты**: main и background для производительности

### Обработка ошибок:
- **Graceful degradation**: приложение продолжает работать при ошибках
- **Rollback**: откат изменений при неудачных операциях
- **Логирование**: вывод ошибок в консоль для отладки
- **Пользовательские уведомления**: понятные сообщения об ошибках

### Производительность:
- **@FetchRequest**: автоматические обновления UI при изменении данных
- **LazyVStack**: ленивая загрузка для больших списков
- **Фильтрация**: эффективные запросы к Core Data
- **Кэширование**: сохранение настроек в UserDefaults

### Безопасность:
- **Хеширование паролей**: SHA256 с солью
- **Валидация данных**: проверка входных параметров
- **Изоляция данных**: каждый пользователь видит только свои данные
- **Безопасное хранение**: Core Data с шифрованием

## 🎨 Дизайн-система

### Цвета:
- **Primary**: синий (#007AFF)
- **Secondary**: серый (#8E8E93)
- **Success**: зеленый (#34C759)
- **Warning**: оранжевый (#FF9500)
- **Danger**: красный (#FF3B30)

### Типографика:
- **Заголовки**: SF Pro, жирный, 24-32pt
- **Подзаголовки**: SF Pro, средний, 18-20pt
- **Основной текст**: SF Pro, обычный, 16-17pt
- **Вторичный текст**: SF Pro, обычный, 14-15pt
- **Мелкий текст**: SF Pro, обычный, 12-13pt

### Компоненты:
- **Карточки**: скругленные углы 12pt, тень
- **Кнопки**: скругленные углы 8pt, высота 44pt
- **Поля ввода**: скругленные углы 8pt, границы
- **Иконки**: SF Symbols, размеры 16-24pt
- **Отступы**: 16pt основной, 8pt малый

### Анимации:
- **Переходы**: плавные, 0.3 секунды
- **Загрузка**: индикаторы прогресса
- **Взаимодействие**: тактильная обратная связь
- **Навигация**: стандартные переходы iOS

## 📊 Константы и ограничения

### Лимиты (Constants.swift):
```swift
struct Limits {
    static let maxSets = 20           // Максимум подходов
    static let maxReps = 100          // Максимум повторений
    static let maxWeight: Double = 500.0  // Максимальный вес
    static let minWeight: Double = 0.0    // Минимальный вес
    static let maxNotesLength = 500   // Максимум символов в заметках
    static let maxExerciseNameLength = 100 // Максимум символов в названии
}
```

### Форматы дат:
```swift
struct DateFormats {
    static let full = "EEEE, d MMMM yyyy 'в' HH:mm"    // Полный формат
    static let medium = "d MMMM yyyy"                   // Средний формат
    static let short = "dd.MM.yyyy"                     // Короткий формат
    static let time = "HH:mm"                           // Время
    static let chart = "dd.MM"                          // Для графиков
}
```

## 🔧 Настройка и развертывание

### Требования:
- **iOS**: 15.0+
- **Xcode**: 13.0+
- **Swift**: 5.5+
- **Deployment Target**: iOS 15.0

### Зависимости:
- **SwiftUI**: встроенный фреймворк
- **Core Data**: встроенный фреймворк
- **Combine**: встроенный фреймворк
- **CryptoKit**: встроенный фреймворк
- **CloudKit**: встроенный фреймворк (опционально)

### Конфигурация:
1. **Info.plist**: настройки приложения
2. **GymLog.entitlements**: права доступа
3. **Core Data**: схема базы данных
4. **Assets**: иконки и ресурсы

## 🚀 Будущие улучшения

### Планируемые функции:
- **HealthKit интеграция**: синхронизация с Apple Health
- **Виджеты**: быстрый доступ к статистике
- **Apple Watch**: приложение для часов
- **Социальные функции**: друзья и соревнования
- **Планы тренировок**: готовые программы
- **Питание**: трекинг калорий и макросов
- **Аналитика**: продвинутые графики
- **Экспорт данных**: резервные копии
- **Офлайн режим**: работа без интернета

### Технические улучшения:
- **Unit тесты**: покрытие тестами
- **UI тесты**: автоматизированное тестирование
- **CI/CD**: автоматическая сборка
- **Локализация**: поддержка других языков
- **Accessibility**: доступность для всех пользователей

## 📝 Инструкции по разработке

### Добавление нового экрана:
1. Создать файл в соответствующей папке Views/
2. Реализовать View с @ObservedObject для AuthManager
3. Добавить навигацию в ContentView или родительский экран
4. Обновить Constants.swift при необходимости

### Добавление нового поля в Core Data:
1. Открыть .xcdatamodeld файл
2. Добавить атрибут к нужной сущности
3. Создать миграцию (если нужно)
4. Обновить код для работы с новым полем

### Изменение темы:
1. Обновить ThemeManager.swift
2. Добавить новые цвета в Constants.swift
3. Обновить ThemePickerView при необходимости
4. Протестировать на всех экранах

### Добавление нового типа упражнения:
1. Обновить exerciseCategories в Constants.swift
2. Добавить цвет в Colors структуру
3. Обновить categoryColor функцию
4. Протестировать фильтрацию

## ⚠️ Важные замечания

### При обновлении дизайна:
- **НЕ изменять** структуру Core Data без миграций
- **НЕ удалять** обязательные поля из моделей
- **НЕ изменять** логику AuthManager без тестирования
- **НЕ нарушать** связи между сущностями
- **СОХРАНЯТЬ** обратную совместимость

### При добавлении функций:
- **Использовать** существующие константы из Constants.swift
- **Следовать** паттерну MVVM
- **Добавлять** обработку ошибок
- **Тестировать** на разных устройствах
- **Обновлять** документацию

### При изменении UI:
- **Соблюдать** дизайн-систему
- **Использовать** стандартные компоненты iOS
- **Проверять** доступность
- **Тестировать** в разных темах
- **Адаптировать** под разные размеры экранов

---

**Этот README служит полным техническим описанием проекта GymLog и должен использоваться как справочник при любых изменениях в коде.**