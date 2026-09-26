"""Generates believable, heavy-daily-use activity for the fin_pulse schema
(see ../../database/). Ten users by default, each logging expenses, meals,
water, sleep, habits, substance intake, and journal entries most days over
the backfill window -- a "highly" active user profile, not a sparse/occasional
one.

Kept deliberately simple: plain pyodbc + executemany, no ORM, no Faker
(a small hardcoded Brazilian-Portuguese name/category pool is enough for a
lab dataset). Reproducible via --seed.
"""

import random
import signal
from datetime import date, datetime, time, timedelta
from time import sleep

# ---------------------------------------------------------------- pools

FIRST_NAMES = [
    "Ana", "Bruno", "Camila", "Diego", "Elisa",
    "Fabio", "Gabriela", "Heitor", "Isabela", "Joao",
]
LAST_NAMES = [
    "Silva", "Souza", "Costa", "Oliveira", "Pereira",
    "Rodrigues", "Almeida", "Nascimento", "Lima", "Carvalho",
]

EXPENSE_CATEGORIES = [
    "Alimentacao", "Transporte", "Moradia", "Lazer",
    "Saude", "Compras", "Assinaturas", "Educacao",
]
EXPENSE_PAYMENT_METHODS = ["Cartao de Credito", "Pix", "Debito", "Dinheiro", "Boleto"]

EARNING_CATEGORIES = ["Salario", "Freelance", "Bonus", "Rendimento"]
EARNING_PAYMENT_METHODS = ["Transferencia Bancaria", "Pix", "Deposito"]

INVESTMENT_TYPES = [
    ("Renda Fixa", "CDB"),
    ("Renda Fixa", "Tesouro Direto"),
    ("Renda Variavel", "Acoes"),
    ("Renda Variavel", "FIIs"),
    ("Cripto", "Criptomoedas"),
    ("Fundo", "Fundos Multimercado"),
]
BROKERS = ["XP Investimentos", "Nubank", "Itau", "Binance", "Rico", "Clear"]

BILL_TEMPLATES = [
    ("Aluguel", "Moradia"),
    ("Internet", "Moradia"),
    ("Energia Eletrica", "Moradia"),
    ("Netflix", "Assinaturas"),
    ("Spotify", "Assinaturas"),
    ("Academia", "Saude"),
    ("Plano de Saude", "Saude"),
    ("Celular", "Assinaturas"),
]

WEEKDAY_ROUTINES = [
    "Treino de Peito", "Treino de Costas", "Treino de Pernas",
    "Cardio", "Descanso", "Treino Funcional", "Yoga",
]  # index 0=Sunday .. 6=Saturday, matches day_of_week convention
PR_EXERCISES = [
    ("Supino Reto", "Carga Maxima", "kg", (40, 120)),
    ("Agachamento", "Carga Maxima", "kg", (50, 150)),
    ("Levantamento Terra", "Carga Maxima", "kg", (60, 180)),
    ("Corrida 5km", "Melhor Tempo", "segundos", (1200, 1800)),
    ("Barra Fixa", "Repeticoes Maximas", "reps", (5, 20)),
]

MEAL_TYPES = ["Cafe da Manha", "Almoco", "Jantar"]
SNACK_TYPE = "Lanche"

MEDITATION_TYPES = ["Guiada", "Respiracao", "Body Scan", "Mindfulness"]

JOURNAL_CATEGORIES = ["Gratidao", "Reflexao", "Metas", "Trabalho", "Relacionamentos"]
JOURNAL_SNIPPETS = [
    "Dia produtivo, consegui terminar as tarefas planejadas.",
    "Me senti um pouco cansado, preciso descansar mais.",
    "Boa conversa com a familia hoje.",
    "Fechei uma meta pequena, mas importante.",
    "Ansioso com o trabalho, mas tentando manter o foco.",
    "Gratidao pelas pequenas coisas do dia.",
]

# (name, category, target_frequency) -- "Weekly" habits only get logged on Mondays
HABIT_TEMPLATES = [
    ("Tomar Vitaminas", "Saude", "Daily"),
    ("Alongamento", "Saude", "Daily"),
    ("Ler 10 Paginas", "Produtividade", "Daily"),
    ("Sem Acucar", "Saude", "Daily"),
    ("Limite de Tela", "Produtividade", "Daily"),
    ("Skincare Noturno", "Saude", "Daily"),
    ("Revisao Semanal de Financas", "Produtividade", "Weekly"),
]

SYMPTOM_NAMES = ["Dor de Cabeca", "Fadiga", "Febre", "Dor de Garganta", "Nausea", "Insonia"]

BUDGET_NAMES = ["Mercado do Mes", "Lazer e Saidas", "Transporte", "Casa"]
GOAL_NAMES = ["Reserva de Emergencia", "Viagem", "Carro Novo", "Reforma da Casa"]

CURRENCY = "BRL"

# stream mode: relative weights for what a single "live" tick logs
STREAM_ACTIVITY_WEIGHTS = [
    ("expense", 40),
    ("water", 20),
    ("meal", 15),
    ("habit_check", 15),
    ("substance", 7),
    ("journal", 3),
]


# ---------------------------------------------------------------- helpers

def _rand_time(rng: random.Random) -> time:
    return time(hour=rng.randint(0, 23), minute=rng.randint(0, 59), second=rng.randint(0, 59))


def _daterange(start: date, end: date):
    for i in range((end - start).days + 1):
        yield start + timedelta(days=i)


def _amount(rng: random.Random, lo: float, hi: float) -> float:
    return round(rng.uniform(lo, hi), 2)


# ---------------------------------------------------------------- inserts

def reset_all(cursor) -> None:
    tables = [
        "finance.bills", "finance.investments", "finance.expenses", "finance.earnings",
        "plan.goals", "plan.budgets",
        "mind.journal_entries", "mind.meditation_sessions",
        "body.sleep_logs", "body.body_metrics", "body.water_intake",
        "body.meals", "body.personal_records", "body.workouts", "body.weekly_routines",
        "body.habit_logs", "body.habits", "body.substance_logs", "body.symptom_logs",
        "dbo.users",
    ]
    # bracket-quoted: 'plan' (as in plan.goals/plan.budgets) is a reserved keyword and breaks
    # unquoted schema.table references
    for t in tables:
        schema, name = t.split(".")
        qualified = f"[{schema}].[{name}]"
        cursor.execute(f"DELETE FROM {qualified}")
        cursor.execute(f"DBCC CHECKIDENT ('{qualified}', RESEED, 0)")


def insert_users(cursor, n: int, registered_before: date, rng: random.Random) -> list[int]:
    user_ids: list[int] = []
    names = list(zip(FIRST_NAMES, LAST_NAMES))
    for i in range(n):
        first, last = names[i % len(names)]
        suffix = "" if i < len(names) else str(i // len(names) + 1)
        username = f"{first.lower()}.{last.lower()}{suffix}"
        email = f"{username}@example.com"
        phone = f"+55119{rng.randint(1000, 9999)}{rng.randint(1000, 9999)}"  # 14 chars, fits VARCHAR(15)
        password = "$2b$12$" + "".join(rng.choices("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", k=22))
        created_at = datetime.combine(
            registered_before - timedelta(days=rng.randint(0, 20)), _rand_time(rng)
        )
        cursor.execute(
            """
            INSERT INTO dbo.users (username, phone_number, email, password, created_at)
            OUTPUT INSERTED.id
            VALUES (?, ?, ?, ?, ?)
            """,
            username, phone, email, password, created_at,
        )
        user_ids.append(cursor.fetchone()[0])
    return user_ids


def insert_budgets(cursor, user_ids: list[int], start: date, end: date, rng: random.Random) -> None:
    rows = []
    for uid in user_ids:
        for name in rng.sample(BUDGET_NAMES, k=rng.randint(2, 3)):
            limit = _amount(rng, 300, 3000)
            rows.append((
                uid, name, f"Orcamento mensal de {name.lower()}", limit, CURRENCY,
                datetime.combine(start, time(0, 0)), datetime.combine(end, time(23, 59, 59)),
                datetime.combine(start, _rand_time(rng)),
            ))
    if rows:
        cursor.fast_executemany = True
        cursor.executemany(
            """
            INSERT INTO [plan].budgets
                (user_id, name, description, amount_limit, currency_code, start_date, end_date, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
            rows,
        )


def insert_goals(cursor, user_ids: list[int], start: date, end: date, rng: random.Random) -> None:
    rows = []
    for uid in user_ids:
        for name in rng.sample(GOAL_NAMES, k=rng.randint(1, 3)):
            target = _amount(rng, 2000, 50000)
            current = round(target * rng.uniform(0.05, 0.6), 2)
            due = end + timedelta(days=rng.randint(60, 720))
            rows.append((
                uid, name, f"Meta: {name.lower()}", target, current, CURRENCY,
                datetime.combine(due, time(0, 0)),
                datetime.combine(start, _rand_time(rng)),
            ))
    if rows:
        cursor.fast_executemany = True
        cursor.executemany(
            """
            INSERT INTO [plan].goals
                (user_id, name, description, target_amount, current_amount, currency_code, due_date, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
            rows,
        )


def insert_earnings(cursor, user_ids: list[int], start: date, end: date, rng: random.Random) -> None:
    rows = []
    for uid in user_ids:
        base_salary = _amount(rng, 3000, 12000)
        month_cursor = date(start.year, start.month, 1)
        while month_cursor <= end:
            pay_day = min(5, 28)
            pay_date = date(month_cursor.year, month_cursor.month, pay_day)
            if start <= pay_date <= end:
                rows.append((
                    uid, "Salario", rng.choice(EARNING_PAYMENT_METHODS), base_salary, CURRENCY,
                    "Pagamento mensal", datetime.combine(pay_date, _rand_time(rng)),
                    datetime.combine(pay_date, _rand_time(rng)),
                ))
                if rng.random() < 0.25:
                    extra_day = pay_date + timedelta(days=rng.randint(3, 20))
                    if extra_day <= end:
                        category = rng.choice(["Freelance", "Bonus", "Rendimento"])
                        rows.append((
                            uid, category, rng.choice(EARNING_PAYMENT_METHODS), _amount(rng, 150, 2500),
                            CURRENCY, f"Renda extra: {category.lower()}",
                            datetime.combine(extra_day, _rand_time(rng)),
                            datetime.combine(extra_day, _rand_time(rng)),
                        ))
            month_cursor = date(month_cursor.year + (month_cursor.month == 12),
                                 month_cursor.month % 12 + 1, 1)
    if rows:
        cursor.fast_executemany = True
        cursor.executemany(
            """
            INSERT INTO finance.earnings
                (user_id, category, payment_method, amount, currency_code, description, earning_date, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
            rows,
        )


def insert_expenses(cursor, user_ids: list[int], start: date, end: date, rng: random.Random) -> None:
    rows = []
    for uid in user_ids:
        for day in _daterange(start, end):
            count = rng.choices([1, 2, 3, 4, 5], weights=[10, 25, 30, 20, 15])[0]
            for _ in range(count):
                category = rng.choice(EXPENSE_CATEGORIES)
                rows.append((
                    uid, category, rng.choice(EXPENSE_PAYMENT_METHODS), _amount(rng, 8, 450), CURRENCY,
                    f"Gasto com {category.lower()}", datetime.combine(day, _rand_time(rng)),
                    datetime.combine(day, _rand_time(rng)),
                ))
    if rows:
        cursor.fast_executemany = True
        cursor.executemany(
            """
            INSERT INTO finance.expenses
                (user_id, category, payment_method, amount, currency_code, description, expense_date, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
            rows,
        )


def insert_investments(cursor, user_ids: list[int], start: date, end: date, rng: random.Random) -> None:
    """Only records what the user put in and when -- current value/returns are the app's job to
    compute from a market-data API, not this table's."""
    rows = []
    for uid in user_ids:
        for _ in range(rng.randint(4, 8)):
            inv_type, category = rng.choice(INVESTMENT_TYPES)
            invested = _amount(rng, 500, 20000)
            purchase_date = start - timedelta(days=rng.randint(0, 400))
            maturity = None
            if inv_type == "Renda Fixa" and rng.random() < 0.7:
                maturity = purchase_date + timedelta(days=rng.randint(365, 1825))
            rows.append((
                uid, inv_type, category, f"{category} {rng.randint(1, 99)}", rng.choice(BROKERS), CURRENCY,
                invested,
                datetime.combine(purchase_date, _rand_time(rng)),
                datetime.combine(maturity, time(0, 0)) if maturity else None,
                datetime.combine(purchase_date, _rand_time(rng)),
            ))
    if rows:
        cursor.fast_executemany = True
        cursor.executemany(
            """
            INSERT INTO finance.investments
                (user_id, investment_type, category, asset_name, broker, currency_code,
                 invested_amount, purchase_date, maturity_date, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            rows,
        )


def insert_bills(cursor, user_ids: list[int], start: date, end: date, rng: random.Random) -> None:
    rows = []
    for uid in user_ids:
        for name, category in rng.sample(BILL_TEMPLATES, k=rng.randint(4, 6)):
            due_day = rng.randint(1, 28)
            due_date = date(start.year, start.month, due_day)
            next_due = due_date + timedelta(days=30)
            rows.append((
                uid, name, category, rng.choice(["Cartao de Credito", "Debito Automatico", "Pix"]),
                _amount(rng, 30, 350), CURRENCY, due_date, "Monthly", 1, next_due, None,
                f"Conta recorrente: {name.lower()}",
                datetime.combine(start, _rand_time(rng)), None,
            ))
    if rows:
        cursor.fast_executemany = True
        cursor.executemany(
            """
            INSERT INTO finance.bills
                (user_id, bill_name, category, payment_method, amount, currency_code, due_date,
                 recurrence_type, recurrence_interval, next_due_date, paid_date, description,
                 created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            rows,
        )


def insert_weekly_routines(cursor, user_ids: list[int], start: date, rng: random.Random) -> dict[int, dict[int, str]]:
    routines: dict[int, dict[int, str]] = {}
    rows = []
    for uid in user_ids:
        per_user = {}
        for dow, name in enumerate(WEEKDAY_ROUTINES):
            per_user[dow] = name
            rows.append((
                uid, dow, name, f"Rotina padrao para o dia: {name.lower()}",
                datetime.combine(start, _rand_time(rng)),
            ))
        routines[uid] = per_user
    if rows:
        cursor.fast_executemany = True
        cursor.executemany(
            """
            INSERT INTO body.weekly_routines (user_id, day_of_week, routine_name, description, created_at)
            VALUES (?, ?, ?, ?, ?)
            """,
            rows,
        )
    return routines


def insert_workouts(cursor, user_ids: list[int], start: date, end: date,
                     routines: dict[int, dict[int, str]], rng: random.Random) -> None:
    rows = []
    for uid in user_ids:
        for day in _daterange(start, end):
            dow = (day.weekday() + 1) % 7  # Python Monday=0 -> convert to Sunday=0 convention
            routine_name = routines[uid][dow]
            if routine_name == "Descanso" or rng.random() < 0.15:
                continue
            rows.append((
                uid, day, routine_name, rng.randint(30, 90), _amount(rng, 150, 700),
                None, datetime.combine(day, _rand_time(rng)),
            ))
    if rows:
        cursor.fast_executemany = True
        cursor.executemany(
            """
            INSERT INTO body.workouts
                (user_id, workout_date, routine_name, duration_minutes, calories_burned, notes, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            rows,
        )


def insert_personal_records(cursor, user_ids: list[int], start: date, end: date, rng: random.Random) -> None:
    rows = []
    for uid in user_ids:
        for _ in range(rng.randint(3, 6)):
            exercise, metric, unit, (lo, hi) = rng.choice(PR_EXERCISES)
            day = start + timedelta(days=rng.randint(0, max((end - start).days, 0)))
            rows.append((
                uid, exercise, metric, round(rng.uniform(lo, hi), 2), unit, day, None,
                datetime.combine(day, _rand_time(rng)),
            ))
    if rows:
        cursor.fast_executemany = True
        cursor.executemany(
            """
            INSERT INTO body.personal_records
                (user_id, exercise_name, metric_type, value, unit, achieved_date, notes, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
            rows,
        )


def insert_meals(cursor, user_ids: list[int], start: date, end: date, rng: random.Random) -> None:
    rows = []
    for uid in user_ids:
        for day in _daterange(start, end):
            meal_types = list(MEAL_TYPES)
            if rng.random() < 0.3:
                meal_types.append(SNACK_TYPE)
            for meal_type in meal_types:
                calories = _amount(rng, 250, 950)
                rows.append((
                    uid, day, meal_type, None, calories,
                    _amount(rng, 10, 60), _amount(rng, 20, 120), _amount(rng, 5, 40),
                    datetime.combine(day, _rand_time(rng)),
                ))
    if rows:
        cursor.fast_executemany = True
        cursor.executemany(
            """
            INSERT INTO body.meals
                (user_id, meal_date, meal_type, description, calories, protein_grams, carbs_grams, fat_grams, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            rows,
        )


def insert_water_intake(cursor, user_ids: list[int], start: date, end: date, rng: random.Random) -> None:
    rows = []
    for uid in user_ids:
        for day in _daterange(start, end):
            rows.append((uid, day, rng.randint(1200, 3000), datetime.combine(day, _rand_time(rng))))
    if rows:
        cursor.fast_executemany = True
        cursor.executemany(
            "INSERT INTO body.water_intake (user_id, intake_date, amount_ml, created_at) VALUES (?, ?, ?, ?)",
            rows,
        )


def insert_body_metrics(cursor, user_ids: list[int], start: date, end: date, rng: random.Random) -> None:
    rows = []
    for uid in user_ids:
        weight = _amount(rng, 55, 100)
        height = _amount(rng, 155, 195)
        day = start
        while day <= end:
            weight = round(max(40, weight + rng.uniform(-0.6, 0.6)), 2)
            rows.append((
                uid, day, weight, height, round(rng.uniform(12, 32), 2), None,
                datetime.combine(day, _rand_time(rng)),
            ))
            day += timedelta(days=7)
    if rows:
        cursor.fast_executemany = True
        cursor.executemany(
            """
            INSERT INTO body.body_metrics
                (user_id, measured_date, weight_kg, height_cm, body_fat_percent, notes, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            rows,
        )


def insert_sleep_logs(cursor, user_ids: list[int], start: date, end: date, rng: random.Random) -> None:
    rows = []
    for uid in user_ids:
        for day in _daterange(start, end):
            if rng.random() < 0.05:
                continue
            bed = datetime.combine(day, time(rng.randint(21, 23), rng.randint(0, 59)))
            wake = bed + timedelta(hours=rng.uniform(5.5, 9))
            rows.append((uid, bed, wake, None, datetime.combine(day, _rand_time(rng))))
    if rows:
        cursor.fast_executemany = True
        cursor.executemany(
            "INSERT INTO body.sleep_logs (user_id, bed_time, wake_time, notes, created_at) VALUES (?, ?, ?, ?, ?)",
            rows,
        )


def insert_habits(cursor, user_ids: list[int], start: date, rng: random.Random) -> dict[int, list[tuple[int, str]]]:
    """Inserts 3-5 habits per user and returns {user_id: [(habit_id, target_frequency), ...]}
    for insert_habit_logs. Needs the generated ids back, so this uses OUTPUT INSERTED.id per row
    (like insert_users) instead of executemany."""
    habits: dict[int, list[tuple[int, str]]] = {}
    for uid in user_ids:
        per_user = []
        for name, category, frequency in rng.sample(HABIT_TEMPLATES, k=rng.randint(3, 5)):
            cursor.execute(
                """
                INSERT INTO body.habits (user_id, habit_name, category, target_frequency, description, created_at)
                OUTPUT INSERTED.id
                VALUES (?, ?, ?, ?, ?, ?)
                """,
                uid, name, category, frequency, f"Habito: {name.lower()}",
                datetime.combine(start, _rand_time(rng)),
            )
            per_user.append((cursor.fetchone()[0], frequency))
        habits[uid] = per_user
    return habits


def insert_habit_logs(cursor, habits: dict[int, list[tuple[int, str]]],
                       start: date, end: date, rng: random.Random) -> None:
    rows = []
    for uid, user_habits in habits.items():
        for habit_id, frequency in user_habits:
            for day in _daterange(start, end):
                if frequency == "Weekly" and day.weekday() != 0:  # Mondays only
                    continue
                if rng.random() < 0.1:  # occasionally forgets to log
                    continue
                is_completed = rng.random() < 0.75
                rows.append((
                    uid, habit_id, day, is_completed, None,
                    datetime.combine(day, _rand_time(rng)),
                ))
    if rows:
        cursor.fast_executemany = True
        cursor.executemany(
            """
            INSERT INTO body.habit_logs (user_id, habit_id, log_date, is_completed, notes, created_at)
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            rows,
        )


def insert_substance_logs(cursor, user_ids: list[int], start: date, end: date, rng: random.Random) -> None:
    rows = []
    for uid in user_ids:
        for day in _daterange(start, end):
            if rng.random() < 0.8:  # caffeine most days, 1-2 entries, morning/early afternoon
                for _ in range(rng.randint(1, 2)):
                    consumed_at = datetime.combine(day, time(rng.randint(6, 14), rng.randint(0, 59)))
                    rows.append((
                        uid, consumed_at, "Cafeina", _amount(rng, 30, 200), "mg", None,
                        datetime.combine(day, _rand_time(rng)),
                    ))
            alcohol_chance = 0.35 if day.weekday() >= 5 else 0.08  # more likely on weekends
            if rng.random() < alcohol_chance:
                consumed_at = datetime.combine(day, time(rng.randint(18, 23), rng.randint(0, 59)))
                rows.append((
                    uid, consumed_at, "Alcool", _amount(rng, 1, 4), "doses", None,
                    datetime.combine(day, _rand_time(rng)),
                ))
    if rows:
        cursor.fast_executemany = True
        cursor.executemany(
            """
            INSERT INTO body.substance_logs (user_id, consumed_at, substance_type, amount, unit, notes, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            rows,
        )


def insert_symptom_logs(cursor, user_ids: list[int], start: date, end: date, rng: random.Random) -> None:
    rows = []
    window_days = max((end - start).days, 1)
    for uid in user_ids:
        for _ in range(rng.randint(2, 5)):  # a handful of off days per user over the window
            day = start + timedelta(days=rng.randint(0, window_days))
            rows.append((
                uid, day, rng.choice(SYMPTOM_NAMES), rng.randint(1, 5), None,
                datetime.combine(day, _rand_time(rng)),
            ))
    if rows:
        cursor.fast_executemany = True
        cursor.executemany(
            """
            INSERT INTO body.symptom_logs (user_id, log_date, symptom, severity, notes, created_at)
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            rows,
        )


def insert_meditation_sessions(cursor, user_ids: list[int], start: date, end: date, rng: random.Random) -> None:
    rows = []
    for uid in user_ids:
        for day in _daterange(start, end):
            if rng.random() >= 0.45:
                continue
            mood_before = rng.randint(1, 5) if rng.random() < 0.8 else None
            mood_after = min(5, mood_before + rng.randint(0, 2)) if mood_before else None
            rows.append((
                uid, day, rng.randint(5, 30), rng.choice(MEDITATION_TYPES),
                mood_before, mood_after, None, datetime.combine(day, _rand_time(rng)),
            ))
    if rows:
        cursor.fast_executemany = True
        cursor.executemany(
            """
            INSERT INTO mind.meditation_sessions
                (user_id, session_date, duration_minutes, meditation_type, mood_before, mood_after, notes, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
            rows,
        )


def insert_journal_entries(cursor, user_ids: list[int], start: date, end: date, rng: random.Random) -> None:
    rows = []
    for uid in user_ids:
        for day in _daterange(start, end):
            if rng.random() >= 0.7:
                continue
            title = rng.choice(JOURNAL_CATEGORIES) if rng.random() < 0.5 else None
            mood = rng.randint(1, 5) if rng.random() < 0.8 else None
            category = rng.choice(JOURNAL_CATEGORIES) if rng.random() < 0.7 else None
            rows.append((
                uid, day, title, rng.choice(JOURNAL_SNIPPETS), mood, category,
                datetime.combine(day, _rand_time(rng)),
            ))
    if rows:
        cursor.fast_executemany = True
        cursor.executemany(
            """
            INSERT INTO mind.journal_entries (user_id, entry_date, title, content, mood, category, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            rows,
        )


# ---------------------------------------------------------------- entrypoint

def backfill(conn, users_n: int, days: int, seed: int, reset: bool) -> None:
    rng = random.Random(seed)
    today = date.today()
    start = today - timedelta(days=days)

    cursor = conn.cursor()
    if reset:
        print("Resetting existing fin_pulse data...")
        reset_all(cursor)

    print(f"Generating {users_n} users, {days} days of activity ({start} .. {today})...")
    user_ids = insert_users(cursor, users_n, start, rng)

    insert_budgets(cursor, user_ids, start, today, rng)
    insert_goals(cursor, user_ids, start, today, rng)
    insert_earnings(cursor, user_ids, start, today, rng)
    insert_expenses(cursor, user_ids, start, today, rng)
    insert_investments(cursor, user_ids, start, today, rng)
    insert_bills(cursor, user_ids, start, today, rng)

    routines = insert_weekly_routines(cursor, user_ids, start, rng)
    insert_workouts(cursor, user_ids, start, today, routines, rng)
    insert_personal_records(cursor, user_ids, start, today, rng)
    insert_meals(cursor, user_ids, start, today, rng)
    insert_water_intake(cursor, user_ids, start, today, rng)
    insert_body_metrics(cursor, user_ids, start, today, rng)
    insert_sleep_logs(cursor, user_ids, start, today, rng)
    habits = insert_habits(cursor, user_ids, start, rng)
    insert_habit_logs(cursor, habits, start, today, rng)
    insert_substance_logs(cursor, user_ids, start, today, rng)
    insert_symptom_logs(cursor, user_ids, start, today, rng)
    insert_meditation_sessions(cursor, user_ids, start, today, rng)
    insert_journal_entries(cursor, user_ids, start, today, rng)

    conn.commit()
    print("Done.")


# ------------------------------------------------------------------ stream

_stop_requested = False


def _handle_stop_signal(signum, frame) -> None:
    global _stop_requested
    _stop_requested = True


def _load_existing_habits(cursor, user_ids: list[int]) -> dict[int, list[int]]:
    habits: dict[int, list[int]] = {uid: [] for uid in user_ids}
    if not user_ids:
        return habits
    placeholders = ",".join("?" * len(user_ids))
    cursor.execute(
        f"SELECT user_id, id FROM body.habits WHERE status = 1 AND user_id IN ({placeholders})",
        user_ids,
    )
    for uid, habit_id in cursor.fetchall():
        habits[uid].append(habit_id)
    return habits


def _stream_expense(cursor, uid: int, rng: random.Random) -> str:
    category = rng.choice(EXPENSE_CATEGORIES)
    amount = _amount(rng, 8, 450)
    now = datetime.now()
    cursor.execute(
        """
        INSERT INTO finance.expenses
            (user_id, category, payment_method, amount, currency_code, description, expense_date, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """,
        uid, category, rng.choice(EXPENSE_PAYMENT_METHODS), amount, CURRENCY,
        f"Gasto com {category.lower()}", now, now,
    )
    return f"expense R${amount:.2f} ({category})"


def _stream_water(cursor, uid: int, rng: random.Random) -> str:
    today = date.today()
    add_ml = rng.randint(200, 400)
    cursor.execute(
        "SELECT amount_ml FROM body.water_intake WHERE user_id = ? AND intake_date = ?", uid, today,
    )
    if cursor.fetchone():
        cursor.execute(
            "UPDATE body.water_intake SET amount_ml = amount_ml + ? WHERE user_id = ? AND intake_date = ?",
            add_ml, uid, today,
        )
    else:
        cursor.execute(
            "INSERT INTO body.water_intake (user_id, intake_date, amount_ml, created_at) VALUES (?, ?, ?, ?)",
            uid, today, add_ml, datetime.now(),
        )
    return f"+{add_ml}ml water"


def _stream_meal(cursor, uid: int, rng: random.Random) -> str:
    meal_type = rng.choice(MEAL_TYPES + [SNACK_TYPE])
    calories = _amount(rng, 250, 950)
    cursor.execute(
        """
        INSERT INTO body.meals
            (user_id, meal_date, meal_type, description, calories, protein_grams, carbs_grams, fat_grams, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        uid, date.today(), meal_type, None, calories,
        _amount(rng, 10, 60), _amount(rng, 20, 120), _amount(rng, 5, 40), datetime.now(),
    )
    return f"meal {meal_type} ({calories:.0f} kcal)"


def _stream_habit_check(cursor, uid: int, habits: dict[int, list[int]], rng: random.Random) -> str | None:
    user_habits = habits.get(uid) or []
    if not user_habits:
        return None
    habit_id = rng.choice(user_habits)
    today = date.today()
    cursor.execute(
        "SELECT 1 FROM body.habit_logs WHERE user_id = ? AND habit_id = ? AND log_date = ?",
        uid, habit_id, today,
    )
    if cursor.fetchone():
        return None  # already logged today, nothing to do this tick
    cursor.execute(
        """
        INSERT INTO body.habit_logs (user_id, habit_id, log_date, is_completed, notes, created_at)
        VALUES (?, ?, ?, ?, ?, ?)
        """,
        uid, habit_id, today, True, None, datetime.now(),
    )
    return "habit checked off"


def _stream_substance(cursor, uid: int, rng: random.Random) -> str:
    now = datetime.now()
    cursor.execute(
        """
        INSERT INTO body.substance_logs (user_id, consumed_at, substance_type, amount, unit, notes, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """,
        uid, now, "Cafeina", _amount(rng, 30, 200), "mg", None, now,
    )
    return "caffeine logged"


def _stream_journal(cursor, uid: int, rng: random.Random) -> str:
    cursor.execute(
        """
        INSERT INTO mind.journal_entries (user_id, entry_date, title, content, mood, category, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """,
        uid, date.today(), None, rng.choice(JOURNAL_SNIPPETS), rng.randint(1, 5),
        rng.choice(JOURNAL_CATEGORIES), datetime.now(),
    )
    return "journal entry"


def stream_tick(cursor, user_ids: list[int], habits: dict[int, list[int]], rng: random.Random) -> list[str]:
    """One cycle of 'right now' activity for a handful of random users -- inserts/upserts using
    today's date and the current timestamp, unlike backfill's historical window."""
    events = []
    activities = [name for name, _ in STREAM_ACTIVITY_WEIGHTS]
    weights = [w for _, w in STREAM_ACTIVITY_WEIGHTS]
    for uid in rng.sample(user_ids, k=min(len(user_ids), rng.randint(1, 3))):
        activity = rng.choices(activities, weights=weights)[0]
        if activity == "habit_check":
            result = _stream_habit_check(cursor, uid, habits, rng)
        else:
            result = {
                "expense": _stream_expense,
                "water": _stream_water,
                "meal": _stream_meal,
                "substance": _stream_substance,
                "journal": _stream_journal,
            }[activity](cursor, uid, rng)
        if result:
            events.append(f"user {uid}: {result}")
    return events


def stream(conn, interval: float, seed: int) -> None:
    """Continuously logs small bursts of 'live' activity for users that already exist in the
    database (run `backfill` first), so replicas/observers have something to watch trickle in.
    Runs until Ctrl+C (SIGINT) or `docker stop` (SIGTERM)."""
    rng = random.Random(seed)
    cursor = conn.cursor()

    cursor.execute("SELECT id FROM dbo.users WHERE status = 1")
    user_ids = [row[0] for row in cursor.fetchall()]
    if not user_ids:
        raise SystemExit("No users found in dbo.users -- run `backfill` first to seed users.")
    habits = _load_existing_habits(cursor, user_ids)

    signal.signal(signal.SIGTERM, _handle_stop_signal)
    signal.signal(signal.SIGINT, _handle_stop_signal)

    # Not a TTY under `docker compose run` from a non-interactive shell (or when piped/backgrounded),
    # so stdout defaults to block-buffered -- flush explicitly or a SIGTERM kill loses every tick.
    print(f"Streaming live activity for {len(user_ids)} users every {interval}s (Ctrl+C to stop)...", flush=True)
    while not _stop_requested:
        events = stream_tick(cursor, user_ids, habits, rng)
        conn.commit()
        stamp = datetime.now().strftime("%H:%M:%S")
        for event in events:
            print(f"[{stamp}] {event}", flush=True)
        sleep(interval)
    print("Stream stopped.", flush=True)
