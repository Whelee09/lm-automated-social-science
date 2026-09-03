#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
#  simular.sh — Lanza la simulación del taller
#  Uso:  bash scripts/simular.sh
# ═══════════════════════════════════════════════════════════
set -e

# ── Parámetros (no cambiar) ──────────────────────────────
ESCENARIO="src/Example/two people bargaining over a mug.json"
MAX_TURNOS=10
MODO="parallel"
LOG="run_full.log"
PIDFILE=".sim_pid"

# ── Verificar API key ────────────────────────────────────
if ! grep -qP 'DEEPSEEK_API_KEY=.{10,}' .env 2>/dev/null; then
  echo ""
  echo "  ❌  Falta configurar la API key."
  echo "      Abre el archivo .env y pega tu key de DeepSeek."
  echo ""
  echo "      Ejemplo:  DEEPSEEK_API_KEY=sk-abc123..."
  echo ""
  exit 1
fi

# ── Limpiar experimentos anteriores ──────────────────────
if [ -d "experiment_logs" ]; then
  echo "🗑️  Limpiando logs de experimentos anteriores..."
  rm -rf experiment_logs
fi
rm -f "$LOG" "$PIDFILE"

# ── Lanzar simulación en segundo plano ───────────────────
echo ""
echo "  🚀  Lanzando simulación..."
echo "      Escenario:  Two people bargaining over a mug"
echo "      Turnos máx: $MAX_TURNOS"
echo "      Modo:       $MODO"
echo ""

nohup python -m src run-experiment-with-scm \
  "$ESCENARIO" \
  --max-interactions "$MAX_TURNOS" \
  --mode "$MODO" \
  > "$LOG" 2>&1 &

SIM_PID=$!
echo $SIM_PID > "$PIDFILE"

echo "      PID: $SIM_PID"
echo ""
echo "  ⏳  La simulación está corriendo en segundo plano."
echo "      Puedes minimizar esta pestaña e ir al juego."
echo "      NO cierres la pestaña del navegador."
echo ""
echo "  ─────────────────────────────────────────────────"
echo ""

# ── Keep-alive: mantiene la terminal activa ──────────────
#    Imprime estado cada 30 segundos para evitar que
#    Codespaces entre en modo inactivo y se apague.
SEGUNDOS=0
while kill -0 "$SIM_PID" 2>/dev/null; do
  sleep 30
  SEGUNDOS=$((SEGUNDOS + 30))
  MINUTOS=$((SEGUNDOS / 60))

  # Contar simulaciones completadas
  if [ -f "$LOG" ]; then
    TERMINADAS=$(grep -c "Ending condition is reached\|Success!" "$LOG" 2>/dev/null || echo "0")
  else
    TERMINADAS=0
  fi

  echo "  ⏳  ${MINUTOS} min transcurridos — ${TERMINADAS} conversaciones completadas..."
done

# ── Simulación terminó ───────────────────────────────────
MINUTOS=$((SEGUNDOS / 60))
echo ""
echo "  ═══════════════════════════════════════════════"
echo "  ✅  ¡Simulación terminada! (${MINUTOS} minutos)"
echo ""
echo "      Resultados en:  experiment_logs/"
echo "      Log completo:   $LOG"
echo ""
echo "      Para ver detalles:  bash scripts/progreso.sh"
echo "  ═══════════════════════════════════════════════"
echo ""

rm -f "$PIDFILE"
