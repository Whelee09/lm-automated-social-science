#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
#  progreso.sh — Ver cómo va la simulación
#  Uso:  bash scripts/progreso.sh
# ═══════════════════════════════════════════════════════════

LOG="run_full.log"

if [ ! -f "$LOG" ]; then
  echo ""
  echo "  ⚠️  No hay simulación en curso (no existe $LOG)"
  echo "      Primero ejecuta:  bash scripts/simular.sh"
  echo ""
  exit 1
fi

echo ""

# Verificar si sigue corriendo
if [ -f .sim_pid ] && kill -0 "$(cat .sim_pid)" 2>/dev/null; then
  echo "  🔄  La simulación sigue corriendo (PID: $(cat .sim_pid))"
else
  echo "  ✅  La simulación ya terminó"
fi

# Contar conversaciones completadas
TERMINADAS=$(grep -c "Ending condition is reached" "$LOG" 2>/dev/null || echo "0")
echo "  📊  Conversaciones completadas: $TERMINADAS"
echo ""

# Mostrar últimas líneas
echo "  ── Últimas 20 líneas del log ──────────────────"
echo ""
tail -n 20 "$LOG"
echo ""
echo "  ───────────────────────────────────────────────"
echo "  💡  Para ver el log en vivo:  tail -f $LOG"
echo "      (Ctrl+C para salir)"
echo ""
