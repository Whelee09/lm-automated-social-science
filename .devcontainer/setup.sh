#!/usr/bin/env bash
set -e

echo "🔧 Instalando dependencias de Python..."
pip install --no-cache-dir -r requirements.txt
pip install -e .

echo "📊 Instalando R y lavaan (para estimación SEM)..."
sudo apt-get update -qq
sudo apt-get install -y --no-install-recommends r-base-core r-base-dev
. /etc/os-release
sudo Rscript -e "install.packages('lavaan', repos='https://packagemanager.posit.co/cran/__linux__/${VERSION_CODENAME}/latest')"

# Verificar que lavaan quedó instalado correctamente
if Rscript -e "library(lavaan); cat('lavaan OK\n')" 2>/dev/null; then
  echo "✅ lavaan instalado correctamente"
else
  echo "⚠️  lavaan no se instaló correctamente — la estimación SEM puede fallar"
fi

# Crear .env si no existe (para que el código no falle al buscar variables)
if [ ! -f .env ]; then
  echo "LLM_PROVIDER=deepseek" > .env
  echo "DEEPSEEK_API_KEY=PEGAR_TU_KEY_AQUI" >> .env
  echo ""
  echo "⚠️  Archivo .env creado con valores por defecto."
  echo "   Edita el archivo .env y pega tu API key de DeepSeek."
fi

echo ""
echo "════════════════════════════════════════════════════"
echo "  ✅  ¡Entorno listo!"
echo ""
echo "  Antes de correr la simulación, edita el archivo"
echo "  .env y pega tu API key de DeepSeek."
echo ""
echo "  Luego ejecuta:"
echo "    python -m src end-to-end \"tu escenario\" --n-causes 2"
echo ""
echo "  Ejemplo:"
echo "    python -m src end-to-end \"Two people bargaining over a mug\" --n-causes 2"
echo "════════════════════════════════════════════════════"