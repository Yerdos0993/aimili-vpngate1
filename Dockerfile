FROM python:3.12-slim-bookworm

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    VPNGATE_DATA_DIR=/data \
    UI_HOST=0.0.0.0 \
    UI_PORT=8787 \
    LOCAL_PROXY_HOST=0.0.0.0 \
    LOCAL_PROXY_PORT=7928 \
    SLOT_PROXY_HOST=0.0.0.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        iproute2 \
        iptables \
        iputils-ping \
        openvpn \
        psmisc \
        tini \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY proxy_server.py vpn_utils.py vpngate_manager.py ./
COPY docker-entrypoint.sh docker-healthcheck.py ./
COPY scripts/ ./scripts/

RUN chmod +x /app/docker-entrypoint.sh /app/scripts/selfcheck_multiexit.sh \
    && mkdir -p /data

EXPOSE 8787 7928 17928-17943

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD ["python3", "/app/docker-healthcheck.py"]

ENTRYPOINT ["/usr/bin/tini", "--", "/app/docker-entrypoint.sh"]
CMD ["python3", "/app/vpngate_manager.py"]
