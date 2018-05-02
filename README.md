# datos
`datos` es un programa para línea de comandos que sirve para gestionar
información y/o configuraciones. Su interfaz está completamente en Español.


## Resumen:
El comando `datos` interpreta y almacena la información como **parejas de claves-valores**.
La lista da claves se organiza jerárquicamente, formando un árbol. Como almacén de la
información, `datos` usa el sistema de archivos habitual de nuestro ordenador.
Una clave `abc.def.ghi` se tratará como el archivo `abc/def/ghi`.
Como inconveniente, cada archivo final se usará para almacenar el valor de una única
clave. Por este motivo, la densidad de la información en el disco suele ser baja.

Hay 2 posibles almacenes de información:
1. Global o del sistema, en `/datos`
2. Local o del usuario actual, en `~/.datos`

De forma predeterminada se asume que el usuario accede a su información local:
`datos lee usr.nombre` accede al archivo `~/.datos/usr/nombre` y nos muestra
su contenido.

Si se pretende acceder a la configuración global o del sistema, el primer nombre
de la clave debe ser `sis`:
`datos ls sis.hostname` accede al archivo `/datos/hostname` y nos muestra su
contenido.

Hay 4 posibles tipos de datos:
1. `texto`    => El tipo predeterminado.
2. `booleano` => `sí` `Sí` `SÍ` `SI` `no` `No` `NO` `cierto` `Cierto` `CIERTO` `falso` `Falso` `FALSO`
3. `entero`   => `-288`, `0`, `365` 
4. `real`     => `3.14`, `9.1234E-18`

`datos` puede deducir el tipo a partir del dato que has introducido, pero si
precisas establecer el tipo por tí mismo, puedes usar las siguientes opciones:
1. texto    `-t` o `--texto`
2. booleano `-b` o `--booleano`
3. entero   `-e` o `--entero`
4. real     `-r` o `--real`


## Compilación e instalación:
`datos` se ha desarrollado con el lenguaje `D`, usando el gestor de proyectos
`dub`. Para compilar el proyecto necesitas instalar un compilador de `D` (por
ejemplo `dmd`, `ldc` o `gdc`) y el gestor de proyectos `dub`.

Una vez hayas instalado estos requisitos, ejecuta `dub build --build=release --force`.
`dub` descargará la única dependencia del proyecto, `docopt.d`, para después
ejecutar el compilador que hayas instalado para generarar un único ejecutable,
llamado `datos`.

Para instalar `datos`, mueve el ejecutable a una carpeta listada en tu variable
de entorno `PATH`.


## Uso:
```
datos [--info | --charlatan] (lista | ls) <clave>
datos [--info | --charlatan] lee <clave>
datos [--info | --charlatan] tipo <clave>
datos [--info | --charlatan] pon <clave> <valor> [--texto | --booleano | --entero | --real]
datos [--info | --charlatan] (mueve | mv | renombra | rnm) <clave-antigua> <clave-nueva>
datos [--info | --charlatan] (borra | br | quita | qt) <clave>
datos [--charlatan] --ayuda
datos [--charlatan] --version
```

#### Opciones:
```
 -a --ayuda           Muestra esta pantalla.
 -v --version         Muestra la version.
 -t --texto           <valor> es 'texto'.
 -b --booleano        <valor> es 'booleano'
 -e --entero          <valor> es 'entero'
 -r --real            <valor> es 'real'
 -i --info            Opcion 'habladora'.
 -c --charlatan       Opcion 'verborreica', MUY habladora.
```
#### Subcomandos:
```
 lista/ls        Enumera todas las claves bajo la raiz <clave> (incluyendo
                 a esta ultima), e imprime sus valores.

 tipo            Imprime el tipo de la <clave> proporcionada.
                 Puede ser: 'texto', 'booleano', 'entero' o 'real'.

 pon             Asigna un <valor> a la <clave> proporcionada. Si <clave>
                 no existe, se crea. Si bien este comando es capaz de
                 detectar el tipo de dato proporcionado, se proporcionan
                 opciones para establecer el tipo del dato directamente.

 mueve/mv/renombra/rnm   Cambia el nombre de <clave-antigua> por el de
                         <clave-nueva>.

 borra/br/quita/qt       Elimina la <clave> proporcionada.
```
#### Argumentos:
```
 <clave>         Si <clave> comienza por 'sis', se accede a las claves
                 globales del sistema, en `/datos`.
                 En cualquier otro caso, se accede a las claves del usuario
                 actual, en `~/.datos`.

 <valor>         El dato que desees. Se interpretará como uno de los 4 tipos:
                 Texto | Entero | Real | Booleano.
```

## Ejemplos:
`datos ls sis` Lista todas las claves globales, en `/datos/`.

`datos lista` Lista todas las claves locales, en `~/.datos/`.

`datos lee sis.fecha` Muestra el contenido de la clave guardada en `/datos/fecha`.

`datos ls sis.fecha` Lista todas las claves bajo `sis.fecha`. Si `sis.fecha` es una clave "final", se comporta como `datos lee sis.fecha`.

`datos pon sis.hostname nombredelsistema` Guarda `"nombredelsistema"` en `/datos/hostname`.

`datos pon usr.askpwd sí` Guarda el booleano `sí` (tipo automático) en `~/.datos/usr/adkpwd`.

`datos pon usr.askpwd sí -b` Guarda el booleano `sí` en `~/.datos/usr/adkpwd`.

`datos pon usr.askpwd sí -t` Guarda el texto `"sí"` en `~/.datos/usr/adkpwd`

`datos mv usr.askpwd usr.pwd` Cambia el nombre de `usr.askpwd` por el de `usr.pwd`.

`datos borra usr.pwd` Borra la clave `usr.pwd`.


## Licencia:
El programa es libre y gratuito, lo publico bajo la licencia ISC.
