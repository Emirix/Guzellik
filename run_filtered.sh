#!/bin/bash

# Flutter uygulamasını log filtreleme ile çalıştır
# Kullanım: ./run_filtered.sh

# Çalışma dizinini al (bu betiğin olduğu klasör)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "🚀 Flutter uygulaması başlatılıyor..."
echo "🔍 Filtrelenen loglar: D/Surface, I/gralloc4"
echo ""
echo "💡 İpucu: Uygulamayı durdurmak için 'q' tuşuna basın veya Ctrl+C kullanın"
echo ""

# Flutter uygulamasını çalıştır ve istenmeyen logları filtrele
cd "$SCRIPT_DIR" && \
flutter run --dart-define=ENV=dev 2>&1 | \
grep -v "D/Surface\|I/gralloc4"
