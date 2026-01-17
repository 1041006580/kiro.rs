#!/bin/sh

# 从环境变量生成 config.json
if [ -n "${ADMIN_API_KEY}" ]; then
  # 如果设置了 ADMIN_API_KEY，包含在配置中
  cat > /app/config/config.json << EOF
{
  "host": "0.0.0.0",
  "port": 7860,
  "apiKey": "${API_KEY:-sk-kiro-rs-default}",
  "region": "${REGION:-us-east-1}",
  "adminApiKey": "${ADMIN_API_KEY}"
}
EOF
else
  # 否则不包含 adminApiKey
  cat > /app/config/config.json << EOF
{
  "host": "0.0.0.0",
  "port": 7860,
  "apiKey": "${API_KEY:-sk-kiro-rs-default}",
  "region": "${REGION:-us-east-1}"
}
EOF
fi

# 从环境变量生成 credentials.json
# 支持两种模式：
# 1. 多凭据模式：通过 CREDENTIALS_JSON 环境变量传入完整的 JSON 数组
# 2. 单凭据模式：通过单独的环境变量（向后兼容）

if [ -n "${CREDENTIALS_JSON}" ]; then
  # 多凭据模式：直接使用 CREDENTIALS_JSON
  echo "${CREDENTIALS_JSON}" > /app/config/credentials.json
  echo "Using multi-credential mode from CREDENTIALS_JSON"
else
  # 单凭据模式
  if [ "${AUTH_METHOD}" = "idc" ]; then
    cat > /app/config/credentials.json << EOF
{
  "refreshToken": "${REFRESH_TOKEN}",
  "expiresAt": "${EXPIRES_AT:-2020-01-01T00:00:00.000Z}",
  "authMethod": "idc",
  "clientId": "${CLIENT_ID}",
  "clientSecret": "${CLIENT_SECRET}"
}
EOF
  else
    cat > /app/config/credentials.json << EOF
{
  "refreshToken": "${REFRESH_TOKEN}",
  "expiresAt": "${EXPIRES_AT:-2020-01-01T00:00:00.000Z}",
  "authMethod": "${AUTH_METHOD:-social}"
}
EOF
  fi
  echo "Using single-credential mode"
fi

echo "Starting kiro-rs..."
exec /app/kiro-rs -c /app/config/config.json --credentials /app/config/credentials.json
