# Thin layer over the official SQL Server 2025 image.
# Purpose: trust any CA certificates dropped into ./certs so SQL Server can
# call local HTTPS endpoints (Caddy in front of Ollama, mitmproxy, etc.).
# SQL Server on Linux reads the OpenSSL store, so update-ca-certificates works.
#
# ./certs always exists (contains .gitkeep), so this COPY never fails, and
# update-ca-certificates is a no-op when there are no .crt files. Safe by default.
FROM mcr.microsoft.com/mssql/server:2025-latest

USER root
COPY certs/ /usr/local/share/ca-certificates/lab/
RUN update-ca-certificates || true
USER mssql
