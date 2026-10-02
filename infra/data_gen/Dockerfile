FROM python:3.12-slim-bookworm

# Match the SQL Server containers' TZ (docker-compose.yml sets America/Sao_Paulo on all of
# them) -- without tzdata, datetime.now()/date.today() here run in UTC while GETDATE() on the
# server doesn't, so "today"/"now" silently disagree by the UTC offset (and cross a calendar
# day near midnight). TZ itself is set via docker-compose's environment, not baked in here.
ENV DEBIAN_FRONTEND=noninteractive

# ODBC Driver 18 for SQL Server (msodbcsql18) + unixodbc, needed by pyodbc.
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl gnupg apt-transport-https tzdata \
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
