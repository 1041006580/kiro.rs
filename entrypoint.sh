#!/bin/sh

# 从环境变量生成 config.json
cat > /app/config/config.json << EOF
{
  "host": "0.0.0.0",
  "port": 7860,
  "apiKey": "${API_KEY:-sk-kiro-rs-default}",
  "region": "${REGION:-us-east-1}"
}
EOF

# 从环境变量生成 credentials.json
# 支持单凭据模式
cat > /app/config/credentials.json << EOF
{
  "refreshToken": "${REFRESH_TOKEN}",
  "expiresAt": "${EXPIRES_AT:-2020-01-01T00:00:00.000Z}",
  "authMethod": "${AUTH_METHOD:-social}"
}
EOF

# 如果是 IdC 模式，需要添加 clientId 和 clientSecret
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
fi

echo "Starting kiro-rs..."
exec /app/kiro-rs -c /app/config/config.json --credentials /app/config/credentials.json
