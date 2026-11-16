# CC4303 — Actividad 7: simulando routers BGP

Actividad 7 del curso **Redes (CC4303)**, DCC — Universidad de Chile.
Se configura una red de 5 routers BGP y 3 computadores en el simulador Einar 1.0, se cambian las
rutas que anuncia R0 con route-maps y se filtran con prefix-lists los anuncios de R3 y R4. La
actividad se evalúa solo con el informe en PDF.

Integrantes: María Moya G., M. Fernando Saavedra.

## Einar

Einar 1.0 es un live CD de Knoppix (2006) que simula routers con Quagga 0.99.3 y computadores
con Linux. Se ejecuta en VirtualBox con la configuración que da el curso: Linux 32 bits, sin disco
virtual y con la ISO en la lectora.

```bash
sh einar/einar.sh crear                       # descarga la ISO (488 MB) y crea la VM "Einar"
sh einar/einar.sh iniciar                     # abre la VM en una ventana
sh einar/einar.sh captura paso4 paso1         # guarda la pantalla en Informe/img/paso4/paso1.png
sh einar/einar.sh teclear configs/paso5/R0.txt  # escribe el archivo en la ventana con foco de la VM
sh einar/einar.sh apagar
```

La ISO queda en `~/VirtualBox VMs/Einar/`, fuera del repositorio. La VM no tiene disco: al
apagarla se pierden los laboratorios y las configuraciones de los routers. Por eso las
configuraciones se guardan en `configs/` y las capturas en `Informe/img/`.

Al partir, Einar abre Firefox con su página de inicio y una consola de dom0. Antes de escribir
conviene usar dos enlaces de esa página:

- **Keyboard layout**: la distribución por omisión es sueca. `teclear` necesita la estadounidense,
  porque VirtualBox envía los códigos de tecla de un teclado de EE. UU.
- **Click to focus**: por omisión, el foco sigue al mouse.

Para crear un laboratorio: Create a lab → nombre, número de routers, computadores y switches →
interfaces de cada equipo (máximo 3) → conexión, IP (`192.168.0.1/24`) y default gateway de cada
interfaz. Para iniciarlo: Start a lab → Custom → nombre → Start the lab. Se abre una consola por
equipo; las de los routers entran directo a Quagga.

## Informe

El informe está en `Informe/` y usa Template-Informe, igual que las actividades anteriores. Se
compila con `cd Informe && latexmk -pdf main.tex`. `\captura{img/pasoN/nombre.png}{leyenda}{etiqueta}`
inserta una captura y, mientras el archivo no existe, deja un recuadro rojo con su nombre. Lo que
falta escribir está marcado con `\pendiente{...}`, que también sale en rojo.

## Archivos

- **`red_actividad_bgp.png`**: la red de la actividad.
- **`einar/einar.sh`**: crea, inicia y apaga la VM, toma capturas y escribe texto en ella.
- **`configs/`**: configuraciones de los routers, una carpeta por paso.
- **`Informe/`**: informe LaTeX (`main.tex`); las capturas van en `Informe/img/pasoN/`.
