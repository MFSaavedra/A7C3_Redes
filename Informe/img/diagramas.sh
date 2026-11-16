#!/bin/sh
# Genera con Graphviz el PDF de cada diagrama (img/*.dot) del informe:
#   sh Informe/img/diagramas.sh
# Los diagramas usan Latin Modern, la fuente del informe. Graphviz busca las fuentes con fontconfig,
# que no ve las de TeX Live, así que se le agrega la carpeta de Latin Modern de la instalación de TeX.
# pdfcrop (de TeX Live) recorta el margen en blanco que deja Graphviz.
cd "$(dirname "$0")" || exit 1
conf=$(mktemp)
cat > "$conf" <<EOF
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <include ignore_missing="yes">/etc/fonts/fonts.conf</include>
  <dir>$(dirname "$(kpsewhich lmroman10-regular.otf)")</dir>
</fontconfig>
EOF
for f in *.dot; do
    FONTCONFIG_FILE="$conf" dot -Tpdf "$f" -o "${f%.dot}.pdf"
    pdfcrop --margins 2 "${f%.dot}.pdf" "${f%.dot}.pdf" > /dev/null
done
rm -f "$conf"
