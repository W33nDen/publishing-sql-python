# ================================================
# Практична робота до теми 9. Обробка та візуалізація даних засобами Python
# pandas + SQLAlchemy + matplotlib
# База даних: publishing
# ================================================

from sqlalchemy import create_engine, text
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# Зміни YOUR_PASSWORD на свій пароль MySQL
engine = create_engine(
    "mysql+pymysql://root:YOUR_PASSWORD@localhost:3306/publishing?charset=utf8mb4"
)

# Перевірка підключення
with engine.connect() as conn:
    res = conn.execute(text("SELECT NOW()"))
    print("Підключення успішне: Поточна дата MySQL:", res.scalar())

# ================================================
# ЗАДАЧА 1: Імпорт таблиць у pandas
# ================================================
books     = pd.read_sql("SELECT * FROM books",     engine)
orders    = pd.read_sql("SELECT * FROM orders",    engine)
orderitem = pd.read_sql("SELECT * FROM orderitem", engine)
authors   = pd.read_sql("SELECT * FROM authors",   engine)
employees = pd.read_sql("SELECT * FROM employees", engine)

print("\n--- Задача 1: Розміри таблиць ---")
print("Книги:",             books.shape)
print("Замовлення:",        orders.shape)
print("Позиції замовлень:", orderitem.shape)

# ================================================
# ЗАДАЧА 2: Аналіз даних
# ================================================
print("\n--- Задача 2: Аналіз ---")
orderitem["Revenue"] = orderitem["Quantity"] * orderitem["UnitPrice"]
revenue = orderitem.groupby("BookID")["Revenue"].sum().reset_index()
revenue = revenue.sort_values("Revenue", ascending=False)
print("\nДохід по книгах:")
print(revenue)

# ================================================
# ЗАДАЧА 3: JOIN через merge
# ================================================
print("\n--- Задача 3: JOIN ---")
books_orders = pd.merge(orderitem, books, on="BookID", how="left")
top5 = (books_orders.groupby("Title")["Revenue"]
       .sum()
       .reset_index()
       .sort_values("Revenue", ascending=False)
       .head(5))
print("Топ-5 книг за доходом:")
print(top5)

# ================================================
# ЗАДАЧА 4: Фільтрація
# ================================================
print("\n--- Задача 4: Фільтрація ---")
avg = revenue["Revenue"].mean()
above_avg = revenue[revenue["Revenue"] > avg]
print(f"Книги з доходом вище середнього ({avg:.2f}):")
print(above_avg)

# ================================================
# ЗАДАЧА 5: KPI
# ================================================
print("\n--- Задача 5: KPI ---")
df = books_orders.merge(orders, on="OrderID", how="left")
df["OrderDate"] = pd.to_datetime(df["OrderDate"])

kpi = {
    "total_orders":    df["OrderID"].nunique(),
    "total_units":     int(df["Quantity"].sum()),
    "total_revenue":   float(df["Revenue"].sum()),
    "avg_order_value": float(df.groupby("OrderID")["Revenue"].sum().mean())
}
kpi_series = pd.Series(kpi, name="Value")
print(kpi_series)

# ================================================
# ЗАДАЧА 6-8: Графіки
# ================================================
print("\nГрафіки зберігаються як PNG файли...")

# Графік 1: Динаміка продажів
sales_by_date = df.groupby("OrderDate")["Revenue"].sum().reset_index().sort_values("OrderDate")
plt.figure(figsize=(8, 5))
plt.plot(sales_by_date["OrderDate"], sales_by_date["Revenue"], marker="o", color="teal")
plt.title("Динаміка продажів")
plt.savefig("sales_chart.png")
print("Збережено: sales_chart.png")

# Графік 2: Топ книг
plt.figure(figsize=(9, 5))
plt.barh(top5["Title"], top5["Revenue"], color="steelblue")
plt.title("Топ-5 книг")
plt.savefig("top_books.png")
print("Збережено: top_books.png")
