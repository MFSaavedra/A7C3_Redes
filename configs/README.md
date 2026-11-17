# Configuraciones de los routers

Una carpeta por paso (`paso5/`, `paso6/`, ...) con un archivo por router (`R0.txt`, ...). Cada
archivo contiene los comandos tal como se escriben en la consola Quagga del router, empezando
desde el prompt `R0#`, por ejemplo:

```
configure terminal
router bgp 65000
 neighbor 192.168.1.X remote-as 65001
end
```

Cuando un paso tiene varias etapas, los archivos se numeran en el orden en que se aplican y llevan el router y la etapa en el nombre (`paso3/1_R1_bgp.txt`, `paso3/4_R1_filtro_salida.txt`, ...).

Para escribirlos en Einar, ponga el foco en la consola del router y ejecute
`sh einar/einar.sh teclear configs/paso5/R0.txt`. La distribución del teclado de Einar debe estar
en US (enlace Keyboard layout de la página de inicio).

Einar no guarda nada al apagarse, así que estos archivos son la única copia de las
configuraciones. Después de aplicarlas, compare con `show running-config`.
