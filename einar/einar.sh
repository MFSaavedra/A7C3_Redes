#!/bin/sh
# Maneja la máquina virtual de Einar 1.0 en VirtualBox.
#
#   sh einar/einar.sh crear                      descarga la ISO (si falta) y crea la VM (si falta)
#   sh einar/einar.sh iniciar [gui|headless]     inicia la VM, con ventana por omisión
#   sh einar/einar.sh estado                     muestra si la VM está corriendo
#   sh einar/einar.sh apagar                     apaga la VM (se pierden los laboratorios: Einar es un live CD)
#   sh einar/einar.sh captura <carpeta> <nombre> guarda la pantalla de la VM en Informe/img/<carpeta>/<nombre>.png
#   sh einar/einar.sh teclear <archivo>          escribe cada línea del archivo en la ventana con foco de la VM
#
# La configuración sigue la del curso para VirtualBox: Linux 32 bits, sin disco
# virtual y con la ISO en la lectora. Se le dan 1024 MB en vez de 512 porque el
# laboratorio BGP levanta 8 equipos virtuales dentro de Einar.
# Variables opcionales: EINAR_VM (nombre de la VM) y EINAR_ISO (ruta de la ISO).

set -eu

VM="${EINAR_VM:-Einar}"
ISO="${EINAR_ISO:-$HOME/VirtualBox VMs/Einar/einar1.0.iso}"
ISO_URL="https://users.dcc.uchile.cl/~roarenas/einar1.0.iso"
ISO_SIZE=511236096
MEMORIA=1024

RAIZ=$(cd "$(dirname "$0")/.." && pwd)

existe_vm() {
    VBoxManage list vms | grep -q "^\"$VM\" "
}

estado_vm() {
    VBoxManage showvminfo "$VM" --machinereadable | sed -n 's/^VMState="\(.*\)"$/\1/p'
}

exigir_corriendo() {
    if ! existe_vm || [ "$(estado_vm)" != running ]; then
        echo "La VM $VM no está corriendo; iníciela con: sh einar/einar.sh iniciar" >&2
        exit 1
    fi
}

crear() {
    if [ -f "$ISO" ] && [ "$(stat -c %s "$ISO")" -eq "$ISO_SIZE" ]; then
        echo "ISO: $ISO"
    else
        echo "Descargando $ISO_URL"
        mkdir -p "$(dirname "$ISO")"
        curl -fL --retry 3 -o "$ISO.part" "$ISO_URL"
        mv "$ISO.part" "$ISO"
    fi

    if existe_vm; then
        echo "La VM $VM ya existe; no se modifica."
        return
    fi

    VBoxManage createvm --name "$VM" --ostype Linux --register
    # vboxvga y el mouse PS/2 son los dispositivos que el Knoppix de 2006 reconoce;
    # con el tablet USB por omisión el puntero no se mueve.
    VBoxManage modifyvm "$VM" \
        --memory "$MEMORIA" --vram 32 --graphicscontroller vboxvga \
        --mouse ps2 --keyboard ps2 --usb-ohci off \
        --audio-enabled off \
        --nic1 nat \
        --boot1 dvd --boot2 none --boot3 none --boot4 none
    VBoxManage storagectl "$VM" --name IDE --add ide
    VBoxManage storageattach "$VM" --storagectl IDE --port 1 --device 0 \
        --type dvddrive --medium "$ISO"
    echo "VM $VM creada."
}

iniciar() {
    tipo="${1:-gui}"
    if ! existe_vm; then
        crear
    fi
    if [ "$(estado_vm)" = running ]; then
        echo "La VM $VM ya está corriendo."
        return
    fi
    VBoxManage startvm "$VM" --type "$tipo"
}

apagar() {
    exigir_corriendo
    VBoxManage controlvm "$VM" poweroff
}

captura() {
    if [ $# -ne 2 ]; then
        echo "uso: sh einar/einar.sh captura <carpeta> <nombre>   (ej: captura paso4 paso1)" >&2
        exit 1
    fi
    exigir_corriendo
    destino="$RAIZ/Informe/img/$1/${2%.png}.png"
    mkdir -p "$(dirname "$destino")"
    VBoxManage controlvm "$VM" screenshotpng "$destino"
    echo "Captura guardada en ${destino#"$RAIZ"/}"
}

# VirtualBox traduce cada carácter al código de tecla de un teclado
# estadounidense, así que antes hay que cambiar la distribución de Einar a US
# (enlace Keyboard layout de la página de inicio; por omisión es sueca).
teclear() {
    if [ $# -ne 1 ] || [ ! -f "$1" ]; then
        echo "uso: sh einar/einar.sh teclear <archivo>" >&2
        exit 1
    fi
    exigir_corriendo
    echo "Escribiendo $1 en la ventana con foco de la VM en 3 s..."
    sleep 3
    while IFS= read -r linea || [ -n "$linea" ]; do
        if [ -n "$linea" ]; then
            VBoxManage controlvm "$VM" keyboardputstring "$linea"
        fi
        VBoxManage controlvm "$VM" keyboardputscancode 1c 9c   # Enter
        sleep 0.3
    done < "$1"
}

comando="${1:-}"
[ $# -gt 0 ] && shift
case "$comando" in
    crear)   crear ;;
    iniciar) iniciar "$@" ;;
    estado)  if existe_vm; then echo "$VM: $(estado_vm)"; else echo "La VM $VM no existe."; fi ;;
    apagar)  apagar ;;
    captura) captura "$@" ;;
    teclear) teclear "$@" ;;
    *)
        sed -n '2,10s/^# \{0,1\}//p' "$0"
        exit 1
        ;;
esac
