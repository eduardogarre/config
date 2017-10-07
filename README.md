# config
`config` es una herramienta de control y configuración para sistemas operativos,
en Español.


## Resumen:
El comando `config` interpreta y almacena la información como una lista de claves
estructuradas jerárquicamente, formando un árbol. Como almacén de la información,
usa el sistema de archivos habitual de nuestro ordenador.
Una clave `abc.def.ghi` se tratará como el archivo `abc/def/ghi`.

Hay 2 posibles almacenes de información:
1. Global o del sistema, en `/cfg`
2. Local o del usuario actual, en `~/.config`

De forma predeterminada se asume que el usuario accede a su información local:
`config lee usr.nombre` accede al archivo `~/.config/usr/nombre` y nos muestra
su contenido.

Si se pretende acceder a la configuración global o del sistema, el primer nombre
de la clave debe ser `sis`:
`config ls sis.hostname` accede al archivo `/cfg/hostname` y nos muestra su
contenido.

Hay 4 posibles tipos de datos:
1. `texto`    => El tipo predeterminado.
2. `booleano` => `sí` `Sí` `SÍ` `SI`
                 `no` `No` `NO`
                 `cierto` `Cierto` `CIERTO`
                 `falso` `Falso` `FALSO`
3. `entero`   => `-288`, `0`, `365` 
4. `real`     => `3.14`, `9.1234E-18`

`config` puede deducir el tipo a partir del dato que has introducido, pero si
precisas establecer el tipo por tí mismo, puedes usar las siguientes opciones:
1. texto    `-t` o `--texto`
2. booleano `-b` o `--booleano`
3. entero   `-e` o `--entero`
4. real     `-r` o `--real`


## Compilación e instalación:
`config` se ha desarrollado con el lenguaje `D`, usando el gestor de proyectos
`dub`. Para compilar el proyecto necesitas instalar un compilador de `D` (por
ejemplo `dmd`, `ldc` o `gdc`) y el gestor de proyectos `dub`.

Una vez hayas instalado estos requisitos, ejecuta `dub build --build=release --force`.
`dub` descargará la única dependencia del proyecto, `docopt.d`, para después
ejecutar el compilador que hayas instalado para generarar un único ejecutable,
llamado `config`.

Para instalar `config`, mueve el ejecutable a una carpeta listada en tu variable
de entorno `PATH`.


## Uso:
```
config [--info | --charlatan] (lista | ls) <clave>
config [--info | --charlatan] lee <clave>
config [--info | --charlatan] tipo <clave>
config [--info | --charlatan] pon <clave> <valor> [--texto | --booleano | --entero | --real]
config [--info | --charlatan] (mueve | mv | renombra | rnm) <clave-antigua> <clave-nueva>
config [--info | --charlatan] (borra | br | quita | qt) <clave>
config [--charlatan] --ayuda
config [--charlatan] --version
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
                 globales del sistema, en `/cfg`.
                 En cualquier otro caso, se accede a las claves del usuario
                 actual, en `~/.config`.

 <valor>         El dato que desees. Se interpretará como uno de los 4 tipos:
                 Texto | Entero | Real | Booleano.
```

## Ejemplos:
`config ls sis` Lista todas las claves globales.

`config ls` Lista todas las claves locales.

`config pon sis.hostname nombredelsistema` Guarda `"nombredelsistema"` en `/cfg/hostname`

`config pon usr.askpwd sí` Guarda el booleano `sí` (tipo automático) en `~/.config/usr/adkpwd`

`config pon usr.askpwd sí -b` Guarda el booleano `sí` en `~/.config/usr/adkpwd`

`config pon usr.askpwd sí -t` Guarda el texto `"sí"` en `~/.config/usr/adkpwd`

`config mv usr.askpwd usr.pwd` Cambia el nombre de `usr.askpwd` por el de `usr.pwd`.

`config borra usr.pwd` Borra la clave `usr.pwd`


## Licencia:
El programa es libre y gratuito, lo publico bajo la licencia ISC.