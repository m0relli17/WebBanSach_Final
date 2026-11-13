FROM mono:6.12

# Update apt repositories to archive.debian.org (Debian buster is archived)
RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
    sed -i '/buster-updates/d' /etc/apt/sources.list && \
    apt-get -o Acquire::Check-Valid-Until=false update && \
    apt-get install -y --no-install-recommends mono-xsp4 python3 curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy solution, script, backend and frontend static assets
COPY WebBanSach.sln /app/
COPY configure-web-config.py /app/
COPY backend /app/backend
COPY frontend /app/backend

# Adapt Web.config for Mono on Linux
RUN python3 /app/configure-web-config.py && rm /app/configure-web-config.py

# Restore packages and compile with msbuild
RUN nuget restore WebBanSach.sln && \
    msbuild /p:Configuration=Release /p:DebugType=none WebBanSach.sln

WORKDIR /app/backend

# Ensure OtpEmails directory exists for LocalPickup
RUN mkdir -p /app/backend/App_Data/OtpEmails

EXPOSE 8084

CMD ["xsp4", "--port", "8084", "--address", "0.0.0.0", "--nonstop"]
