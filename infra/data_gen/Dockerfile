FROM python:3.12-slim-bookworm

# ODBC Driver 18 for SQL Server (msodbcsql18) + unixodbc, needed by pyodbc.
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl gnupg apt-transport-https \
    && curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
    && curl -sSL https://packages.microsoft.com/config/debian/12/prod.list -o /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql18 unixodbc-dev \
    && apt-get purge -y curl gnupg apt-transport-https \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY datagen ./datagen

ENTRYPOINT ["python", "-m", "datagen.main"]
CMD ["backfill", "--target", "dev"]
