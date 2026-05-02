#!/bin/sh
NEO4J_HOST="${NEO4J_HOST:-neo4j}"
NEO4J_BOLT_PORT="${NEO4J_BOLT_PORT:-7687}"
MAX_ATTEMPTS=60
SLEEP_SECONDS=2

echo "⏳ Waiting for Neo4j Bolt at ${NEO4J_HOST}:${NEO4J_BOLT_PORT}..."
attempt=0
until nc -z "${NEO4J_HOST}" "${NEO4J_BOLT_PORT}" 2>/dev/null; do
  attempt=$((attempt + 1))
  if [ "$attempt" -ge "$MAX_ATTEMPTS" ]; then
    echo "✗ Neo4j not available after $((MAX_ATTEMPTS * SLEEP_SECONDS))s"
    exit 1
  fi
  echo "  [${attempt}/${MAX_ATTEMPTS}] retrying in ${SLEEP_SECONDS}s..."
  sleep "$SLEEP_SECONDS"
done
echo "✓ Neo4j Bolt is ready"
sleep 5
echo "🚀 Running migration..."
exec "$@"
