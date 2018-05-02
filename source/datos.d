module datos;

import docopt;
import std.algorithm.searching;
import std.conv;
import std.file;
import std.path;
import std.process;
import std.stdio;
import std.string;
import std.uni; // isAlpha(), isNumber(), isAlphaNum(), isWhite()

string textifica(Tipo t)
{
    switch(t)
    {
        case Tipo.TEXTO:
            return "texto";
            
        case Tipo.BOOLEANO:
            return "booleano";

        case Tipo.ENTERO:
            return "entero";

        case Tipo.REAL:
            return "real";

        default:
            return "nada";
    }
}

enum Tipo {
    NADA,
    TEXTO,
    BOOLEANO,
    ENTERO,
    REAL
}

struct Tríada {
    string  clave;
    string  valor;
    Tipo    tipo;
}

struct Respuesta {
    bool     error;
    string   mensaje_error;
    Tríada[] dato;
}


class Datos
{
    int profundidad = 0;

    bool INFO = false;
    bool CHARLATAN = false;

    bool sistema = false;

    string carpeta = "datos";
    string RUTA = "~/";
    string SISTEMA = "/";

    Respuesta respuesta;

    class Nodo
    {
        private string miruta;

        Nodo[] ramas;

        this(string raíz, string nombre)
        {
            if((nombre == null) || (nombre.length < 1))
            {
                miruta = raíz;
            }
            else if((raíz == null) || (raíz.length < 1))
            {
                miruta = nombre;
            }
            else
            {
                miruta = raíz ~ "/" ~ nombre;
            }
        }

        string ruta()
        {
            return miruta;
        }

        string clave()
        {
            int i;

            if(miruta.length > RUTA.length)
            {
                for(i=0; (i<RUTA.length); i++)
                {
                    if(RUTA[i] != miruta[i])
                    {
                        return null;
                    }
                }

                i++;

                string _ruta = miruta[i..$];

                // quitar barras invertidas
                _ruta = tr(_ruta, "\\", ".");
                // quitar barras
                _ruta = tr(_ruta, "/", ".");

                return _ruta;
            }
            else
            {
                return null;
            }
        }
    }

    this()
    {
        RUTA ~= "." ~ carpeta;
        SISTEMA ~= carpeta;
    }

    Respuesta ejecuta(string[] args)
    {
        auto doc = "config - Herramienta de control y configuracion.

        Usage:
        config [--info | --charlatan] (lista | ls) [<clave>]
        config [--info | --charlatan] lee <clave>
        config [--info | --charlatan] tipo <clave>
        config [--info | --charlatan] pon <clave> <valor> [--texto | --booleano | --entero | --real]
        config [--info | --charlatan] (mueve | mv | renombra | rnm) <clave-antigua> <clave-nueva>
        config [--info | --charlatan] (borra | br | quita | qt) <clave>
        config [--charlatan] --ayuda
        config [--charlatan] --version

        Options:
        -a --ayuda           Muestra esta pantalla.
        -v --version         Muestra la version.
        -t --texto           <valor> es 'texto' (es el tipo asumido).
        -b --booleano        <valor> es 'booleano'
        -e --entero          <valor> es 'entero'
        -r --real            <valor> es 'real'
        -i --info            Opcion 'habladora'.
        -c --charlatan       Opcion 'verborreica', MUY habladora.

        Argumentos:
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

        <clave>         Si <clave> comienza por 'sis', se accede a las claves
                        globales del sistema, en " ~ SISTEMA ~ ".
                        En cualquier otro caso, se accede a las claves del usuario
                        actual, en " ~ RUTA ~ ".
        <valor>         Texto | Entero | Real | Booleano.
        ";

        auto argumentos = docopt.docopt(doc, args[1..$], false, "ctl 1.0");

        if(argumentos["--info"].isTrue())
        {
            INFO = true;
        }

        if(argumentos["--charlatan"].isTrue())
        {
            INFO = true;
            CHARLATAN = true;
        }

        if(CHARLATAN)
        {
            writeln();
            writeln(argumentos);
            writeln();
        }

        if(argumentos["--ayuda"].isTrue())
        {
            writeln(doc);

            Respuesta r;
            return r;
        }

        if(RUTA[0] == '~')
        {
            // Es necesario construir la ruta
            RUTA = expandTilde(RUTA);
            
            if(RUTA[0] == '~')
            {
                // expandTilde() no ha hecho nada. No estamos en POSIX.
                // Probablemente estamos en Windows
                // Debemos obtener la ruta por nuestra cuenta
                RUTA = RUTA[1..$];

                auto disco =  environment.get("HOMEDRIVE", null);
                auto camino = environment.get("HOMEPATH",  null);

                RUTA = disco ~ camino ~ RUTA;

                // Si estamos en Windows, también debemos construir SISTEMA
                SISTEMA = disco ~ SISTEMA;
            }
        }

        if(CHARLATAN)
        {
            writeln(RUTA);
            writeln(SISTEMA);
        }

        if((argumentos["ls"].isTrue()) || (argumentos["lista"].isTrue()))
        {
            if(argumentos["<clave>"].isTrue())
            {
                string clave = argumentos["<clave>"].value().toString;

                if(CHARLATAN)
                {
                    writeln("\"" ~ clave ~ ".x\"=...\n\"" ~ clave ~ ".y\"=...\n\"" ~ clave ~ ".z\"=...\n...\n");
                }

                return lista(clave);
            }
            else
            {
                return lista(null);
            }
        }

        if(argumentos["lee"].isTrue())
        {
            string clave = argumentos["<clave>"].value().toString;

            if(CHARLATAN)
            {
                writeln("\"" ~ clave ~ "\" = [ ]");
            }

            return lee(clave);
        }

        if(argumentos["tipo"].isTrue())
        {
            string clave = argumentos["<clave>"].value().toString;

            if(CHARLATAN)
            {
                writeln("\"" ~ clave ~ "\" = T[ ]");
            }

            return lista(clave);
        }

        if(argumentos["pon"].isTrue())
        {
            string clave = argumentos["<clave>"].value().toString;
            string valor = argumentos["<valor>"].value().toString;
        /*
                if(argumentos["--tipo"].isString())
                {
                    string tipo = argumentos["--tipo"].value().toString;

                    //writeln("\"" ~ clave ~ "\" = [" ~ valor ~ "] T[" ~ tipo ~"]");

                    if(pon(clave, valor, tipo))
                    {
                        return 0;
                    }
                    else
                    {
                        return -1;
                    }
                }
        */

            if(CHARLATAN)
            {
                writeln("\"" ~ clave ~ "\" = [" ~ valor ~ "]");
            }

            if(argumentos["--texto"].isTrue())
            {
                return pon(clave, valor, Tipo.TEXTO);
            }
            else if(argumentos["--booleano"].isTrue())
            {
                Respuesta respuesta;

                if(!_booleano(valor))
                {
                    respuesta.error = true;
                    respuesta.mensaje_error = "El valor [" ~ valor ~ "] no es booleano";
                    return respuesta;
                }

                respuesta = pon(clave, valor, Tipo.BOOLEANO);

                return respuesta;
            }
            else if(argumentos["--real"].isTrue())
            {
                Respuesta respuesta;

                if(!_real(valor))
                {
                    respuesta.error = true;
                    respuesta.mensaje_error = "El valor [" ~ valor ~ "] no es un número real";
                    return respuesta;
                }

                respuesta = pon(clave, valor, Tipo.BOOLEANO);

                return respuesta;
            }
            else if(argumentos["--entero"].isTrue())
            {
                Respuesta respuesta;

                if(!_entero(valor))
                {
                    respuesta.error = true;
                    respuesta.mensaje_error = "El valor [" ~ valor ~ "] no es un número entero";
                    return respuesta;
                }

                respuesta = pon(clave, valor, Tipo.BOOLEANO);

                return respuesta;
            }
            else
            {
                //writeln("\"" ~ clave ~ "\" = [" ~ valor ~ "]");
                if(_booleano(valor))
                {
                    return pon(clave, valor, Tipo.BOOLEANO);
                }
                else if(_real(valor))
                {
                    return pon(clave, valor, Tipo.REAL);
                }
                else if(_entero(valor))
                {
                    return pon(clave, valor, Tipo.ENTERO);
                }
                else
                {
                    return pon(clave, valor, Tipo.TEXTO);
                }
            }
        }

        /*
            if(argumentos["incluye"].isTrue())
            {
                string clave = argumentos["<clave>"].value().toString;
                string valor = argumentos["<valor>"].value().toString;

                if(argumentos["--tipo"].isString())
                {
                    string tipo = argumentos["--tipo"].value().toString;

                    //writeln("\"" ~ clave ~ "\" += [" ~ valor ~ "] T[" ~ tipo ~"]");

                    if(incluye(clave, valor, "texto"))
                    {
                        return 0;
                    }
                    else
                    {
                        return -1;
                    }
                }
                else
                {
                    //writeln("\"" ~ clave ~ "\" += [" ~ valor ~ "]");

                    if(incluye(clave, valor, "texto"))
                    {
                        return 0;
                    }
                    else
                    {
                        return -1;
                    }
                }
            }
        */

        if(  argumentos["mueve"].isTrue()
        || argumentos["mv"].isTrue()
        || argumentos["renombra"].isTrue()
        || argumentos["rnm"].isTrue()
        )
        {
            string antigua = argumentos["<clave-antigua>"].value().toString;
            string nueva = argumentos["<clave-nueva>"].value().toString;

            if(CHARLATAN)
            {
                writeln("\"" ~ antigua ~ "\" => \"" ~ nueva ~ "\"");
            }

            return renombra(antigua, nueva);
        }

        if(  argumentos["borra"].isTrue()
        || argumentos["br"].isTrue()
        || argumentos["quita"].isTrue()
        || (argumentos["qt"].isTrue())
        )
        {
            string clave = argumentos["<clave>"].value().toString;

            if(CHARLATAN)
            {
                writeln("\"" ~ clave ~ "\" => X");
            }

            return borra(clave);
        }

        Respuesta respuesta;

        respuesta.error = true;
        respuesta.mensaje_error = "No entiendo la consulta.";

        return respuesta;
    }

    bool construye_árbol(string ruta, ref Nodo raíz)
    {
        if(!exists(ruta))
        {
            return false;
        }
        
        if(isFile(ruta))
        {
            return false;
        }

        foreach (string nombre; dirEntries(ruta, SpanMode.breadth))
        {
            auto n = new Nodo(null, nombre);

            construye_árbol(n.ruta(), n);

            bool añadir = true;

            foreach(Nodo rama; raíz.ramas)
            {
                if(rama.ruta() == n.ruta())
                {
                    añadir = false;
                }
            }

            if(añadir)
            {
                raíz.ramas ~= n;
            }
        }

        return true;
    }

    Respuesta recorre_árbol(Nodo n, ref Respuesta respuesta)
    {
        profundidad++;

        if(n)
        {
            //entra_en_nodo(n);

            int i;
            for(i = 0; i < n.ramas.length; i++)
            {
                entra_en_nodo(n.ramas[i], respuesta);
            }

            profundidad--;

            return respuesta;
        }

        profundidad--;

        respuesta.mensaje_error = "No he podido crear un árbol de claves correcto.";
        respuesta.error = true;
        return respuesta;
    }

    Respuesta entra_en_nodo(Nodo n, ref Respuesta respuesta)
    {
        string ruta = n.ruta();

        if(exists(ruta))
        {

            string clave = n.clave();

            string desplazamiento;

            for(int i = 0; i< profundidad; i++)
            {
                desplazamiento ~= " ";
            }

            if(CHARLATAN)
            {
                write(desplazamiento ~ "[hijos:");
                write(n.ramas.length);
                write("]:");
            }

            if(isFile(ruta))
            {
                string contenido = readText(ruta);

                if(CHARLATAN)
                {
                    write(n.ruta ~ " - ");
                }

                Tríada r;

                r.clave = clave;
                r.valor = contenido;
                r.tipo = interpreta_tipo(contenido);

                respuesta.dato ~= r;

                return respuesta;
            }
            else
            {
                if(CHARLATAN)
                {
                    write(n.ruta);
                }
                
                return respuesta;
            }
        }

        respuesta.mensaje_error = "La ruta proporcionada [" ~ ruta ~ "] no existe.";
        respuesta.error = true;
        return respuesta;
    }

    string obtén_directorio_superior(string miruta)
    {
        return miruta[0..(lastIndexOf(miruta, '/'))];
    }

    Respuesta crea_directorio(string miruta)
    {
        Respuesta respuesta;

        if(miruta is null || miruta.length < 1)
        {
            respuesta.mensaje_error = "Me has pasado una ruta inválida [" ~ miruta ~ "].";
            respuesta.error = true;
            return respuesta;
        }

        if(miruta == "/")
        {
            try
            {
                std.file.mkdirRecurse(miruta);
            }
            catch(Exception e)
            {
                respuesta.mensaje_error = "No puedo crear la ruta [" ~ miruta ~ "] tras llegar a la raíz.";
                respuesta.error = true;
                return respuesta;
            }
        }
        else if((miruta.length < 4) && (miruta[1] == ':'))
        {
            try
            {
                std.file.mkdirRecurse(miruta);
            }
            catch(Exception e)
            {
                respuesta.mensaje_error = "No puedo crear la ruta [" ~ miruta ~ "] tras llegar a la raíz.";
                respuesta.error = true;
                return respuesta;
            }
        }
        else if(miruta == "C:")
        {
            return respuesta;
        }
        else if(!exists(miruta))
        {
            string _miruta = obtén_directorio_superior(miruta);

            if(miruta == _miruta || _miruta == "/")
            {
                respuesta.mensaje_error = "No puedo crear la ruta [" ~ _miruta ~ "].";
                respuesta.error = true;
                return respuesta;
            }
            Respuesta _res = crea_directorio(_miruta);
            if(_res.error)
            {
                return _res;
            }
            
            try
            {
                std.file.mkdirRecurse(miruta);
            }
            catch(Exception e)
            {
                respuesta.mensaje_error = "No puedo crear la ruta [" ~ miruta ~ "].";
                respuesta.error = true;
                return respuesta;
            }
            return respuesta;
        }
        else if(isDir(miruta))
        {
            respuesta.mensaje_error = "La ruta [" ~ miruta ~ "] es una carpeta.";
            return respuesta;
        }

        respuesta.error = true;
        respuesta.mensaje_error = "Error indeterminado al intentar crear una carpeta [" ~ miruta ~ "].";
        return respuesta;
    }

    Respuesta borrado_recursivo(string raíz, string subdirectorio)
    {
        Respuesta respuesta;

    // Ambos directorios deben ser válidos
        if(raíz is null || raíz.length < 1)
        {
            respuesta.error = true;
            respuesta.mensaje_error = "El directorio raíz [" ~ raíz ~ "] no es válido.";
            return respuesta;
        }

        if(subdirectorio is null || subdirectorio.length < 1)
        {
            respuesta.error = true;
            respuesta.mensaje_error = "El subdirectorio [" ~ subdirectorio ~ "] no es válido.";
            return respuesta;
        }

    // Si son iguales, he terminado
        if(raíz == subdirectorio)
        {
            respuesta.mensaje_error = "El subdirectorio [" ~ subdirectorio ~ "] ha llegado a la raíz [" ~ raíz ~ "].";
            return respuesta;
        }

    // La ruta del subdirectorio debe ser mayor que la de raíz
        if(raíz.length >= subdirectorio.length)
        {
            respuesta.error = false;
            respuesta.mensaje_error = "La ruta del subdirectorio [" ~ subdirectorio ~ "] debe ser más larga que la de la raíz [" ~ raíz ~ "].";
            return respuesta;
        }

    // Compruebo la existencia de ambos directorios
        bool existe = false;

        // Directorio raíz
        try
        {
            existe = exists(raíz);
        }
        catch(Exception e)
        {
            existe = false;
        }

        if(!existe)
        {
            respuesta.error = true;
            respuesta.mensaje_error = "El directorio raíz [" ~ raíz ~ "] no existe.";
            return respuesta;
        }
        // Subdirectorio
        try
        {
            existe = exists(subdirectorio);
        }
        catch(Exception e)
        {
            existe = false;
        }

        if(!existe)
        {
            respuesta.error = true;
            respuesta.mensaje_error = "El subdirectorio [" ~ subdirectorio ~ "] no existe.";
            return respuesta;
        }
        
    // Subdirectorio debe ser un hijo de raíz
        if(!startsWith(subdirectorio, raíz))
        {
            respuesta.error = true;
            respuesta.mensaje_error = "La ruta de la raíz [" ~ raíz ~ "] debe estar incluida en el subdirectorio [" ~ subdirectorio ~ "].";
            return respuesta;
        }

    // Subdirectorio debe estar vacío
        int archivos = 0;
        
        foreach (string name; dirEntries(subdirectorio, SpanMode.shallow))
        {
            archivos++;
        }

        if(archivos != 0)
        {
            respuesta.mensaje_error = "El subdirectorio [" ~ subdirectorio ~ "] no está vacío: [" ~ to!string(archivos) ~ "] archivos.";
            return respuesta;
        }

    // Borro subdirectorio
        try
        {
            //writeln("rmdir(" ~ subdirectorio ~ ");");
            rmdir(subdirectorio);
        }
        catch(Exception e)
        {
            respuesta.error = true;
            respuesta.mensaje_error = "No he podido borrar el subdirectorio [" ~ subdirectorio ~ "].";
            return respuesta;
        }

        return borrado_recursivo(raíz, obtén_directorio_superior(subdirectorio));
    }

    string interpreta_clave(string clave)
    {
        if(clave.length > 0)
        {
            int posición = 0;
            string miruta;

            int i = indexOf(clave, '.');
            string txt = clave[0..i];

            if(txt == "sis")
            {

                RUTA = miruta = SISTEMA ~ "/";
                clave = clave[i+1..$];
            }
            else
            {
                miruta = RUTA ~ "/";
            }

            int pos = 0;

            do{
                pos = indexOf(clave, '.', posición);
                if(pos < 0)
                {
                    break;
                }
                miruta ~= clave[posición..pos];
                miruta ~= "/";
                posición = pos + 1;
            } while(pos > 0);

            miruta ~= clave[posición..$];

            return miruta;
        }
        else
        {
            return null;
        }
    }

    Respuesta lista(string clave)
    {
        string miruta;
        Respuesta respuesta;

        if(clave is null || clave.length == 0)
        {
            miruta = RUTA;
        }

        if(clave.length > 0)
        {
            miruta = interpreta_clave(clave);
        }

        if((!exists(miruta)))
        {
            respuesta.mensaje_error = "La clave [" ~ clave ~ "] no existe.";
            respuesta.error = true;
            return respuesta;
        }

        if(!isDir(miruta))
        {
            if(isFile(miruta))
            {
                return lee(clave);
            }
            
            respuesta.mensaje_error = "No puedo acceder a la clave [" ~ clave ~ "].";
            respuesta.error = true;
            return respuesta;
        }

        // bucle de lectura recursiva de claves
        if(INFO)
        {
            writeln("bucle de lectura");
        }

        auto raíz = new Nodo(miruta, "");

        construye_árbol(miruta, raíz);
        recorre_árbol(raíz, respuesta);

        return respuesta;
    }

    Respuesta lee(string clave)
    {
        Respuesta respuesta;

        if(clave is null)
        {
            respuesta.mensaje_error = "Clave inválida.";
            respuesta.error = true;
            return respuesta;
        }

        if(clave.length > 0)
        {
            string miruta = interpreta_clave(clave);

            if(!exists(miruta))
            {
                respuesta.mensaje_error = "La clave [" ~ clave ~ "] no existe.";
                respuesta.error = true;
                return respuesta;
            }
            else if(isDir(miruta))
            {
                respuesta.mensaje_error = "La clave [" ~ clave ~ "] es un contenedor.";
                respuesta.error = true;
                return respuesta;
            }
            else if(exists(miruta))
            {
                string contenido = readText(miruta);

                if(contenido is null || contenido.length < 1)
                {
                    respuesta.mensaje_error = "La clave [" ~ clave ~ "] está vacía.";
                    respuesta.error = true;
                    return respuesta;
                }

                Tríada r;

                r.clave = clave;
                r.valor = contenido;
                r.tipo = interpreta_tipo(contenido);

                if(r.tipo == Tipo.NADA)
                {
                    respuesta.mensaje_error = "Tipo [" ~ to!string(r.tipo) ~ "] no reconocido.";
                    respuesta.error = true;
                    return respuesta;
                }
                
                respuesta.dato ~= r;

                return respuesta;
            }

            respuesta.mensaje_error = "Clave [" ~ clave ~ "] inválida.";
            respuesta.error = true;
            return respuesta;
        }
        else
        {
            respuesta.mensaje_error = "No has pasado ninguna clave.";
            respuesta.error = true;
            return respuesta;
        }
    }

    Respuesta pon(string clave, string valor, Tipo tipo)
    {
        Respuesta respuesta;
        Tríada t;

        if(clave.length > 0)
        {
            string miruta = interpreta_clave(clave);
            string dir = obtén_directorio_superior(miruta);

            bool existe = false;

            try
            {
                existe = exists(miruta);
            }
            catch(Exception e)
            {
                existe = false;
            }

            if(existe)
            {
                respuesta = lee(clave);
                respuesta.mensaje_error = "La clave [" ~ clave ~ "] ya existe.";
                respuesta.error = true;
                return respuesta;
            }

            Respuesta _res = crea_directorio(dir);
            if(_res.error)
            {
                return _res;
            }

            switch(tipo)
            {
                case Tipo.TEXTO:
                    try
                    {
                        std.file.write(miruta, "\"" ~ valor ~ "\"");
                    }
                    catch(Exception e)
                    {
                        respuesta.mensaje_error = "Error al crear la clave [" ~ clave ~ "] e intentar escribir el valor [" ~ valor ~ "].";
                        respuesta.error = true;
                        return respuesta;
                    }
                    
                    t.tipo = Tipo.TEXTO;
                    break;

                case Tipo.BOOLEANO:
                    try
                    {
                        std.file.write(miruta, valor);
                    }
                    catch(Exception e)
                    {
                        respuesta.mensaje_error = "Error al crear la clave [" ~ clave ~ "] e intentar escribir el valor [" ~ valor ~ "].";
                        respuesta.error = true;
                        return respuesta;
                    }

                    t.tipo = Tipo.BOOLEANO;
                    break;

                case Tipo.REAL:
                    try
                    {
                        std.file.write(miruta, valor);
                    }
                    catch(Exception e)
                    {
                        respuesta.mensaje_error = "Error al crear la clave [" ~ clave ~ "] e intentar escribir el valor [" ~ valor ~ "].";
                        respuesta.error = true;
                        return respuesta;
                    }
                    
                    t.tipo = Tipo.REAL;
                    break;

                case Tipo.ENTERO:
                    try
                    {
                        std.file.write(miruta, valor);
                    }
                    catch(Exception e)
                    {
                        respuesta.mensaje_error = "Error al crear la clave [" ~ clave ~ "] e intentar escribir el valor [" ~ valor ~ "].";
                        respuesta.error = true;
                        return respuesta;
                    }
                    
                    t.tipo = Tipo.ENTERO;
                    break;

                default:
                    respuesta.mensaje_error = "No reconozco el tipo [" ~ to!string(tipo) ~ "].";
                    respuesta.error = true;
                    return respuesta;
            }

            t.clave = clave;
            t.valor = valor;
            respuesta.dato ~= t;

            return respuesta;
        }
        else
        {
            respuesta.mensaje_error = "No has pasado ninguna clave.";
            respuesta.error = true;
            return respuesta;
        }
    }

    bool incluye(string clave, string valor, string tipo)
    {
        if(clave.length > 0)
        {
            string miruta = interpreta_clave(clave);

            if(!miruta)
            {
                return false;
            }

            switch(tipo)
            {
                case "texto":
                    std.file.append(miruta, "\n\"" ~ valor ~ "\"");
                    break;

                case "entero":
                case "real":
                case "booleano":
                    std.file.append(miruta, "\n" ~ valor);
                    break;

                default:
                    break;
            }

            //std.file.write(miruta, valor);

            return true;
        }
        else
        {
            return false;
        }
    }

    Respuesta borra(string clave)
    {
        Respuesta respuesta;

        if(clave.length > 0)
        {
            string miruta = interpreta_clave(clave);

            if((!exists(miruta)))
            {
                respuesta.mensaje_error = "La clave [" ~ clave ~ "] no existe.";
                respuesta.error = true;
                return respuesta;
            }

            if(isFile(miruta))
            {
                try
                {
                    remove(miruta);
                }
                catch(Exception e)
                {
                    respuesta.mensaje_error = "Error al intentar borrar la clave [" ~ clave ~ "].";
                    respuesta.error = true;
                    return respuesta;
                }

                int archivos = 0;
                
                foreach (string name; dirEntries(obtén_directorio_superior(miruta), SpanMode.shallow))
                {
                    archivos++;
                }

                if(archivos == 0)
                {
                    return borrado_recursivo(RUTA, obtén_directorio_superior(miruta));
                }
            }
            else if(isDir(miruta))
            {
                return borrado_recursivo(RUTA, miruta);
            }
            else
            {
                respuesta.mensaje_error = "No puedo acceder a la clave [" ~ clave ~ "].";
                respuesta.error = true;
                return respuesta;
            }

            return respuesta;
        }
        else
        {
            respuesta.mensaje_error = "No has proporcionado una clave.";
            respuesta.error = true;
            return respuesta;
        }
    }

    Respuesta renombra(string antigua, string nueva)
    {
        Respuesta respuesta;

        if(antigua is null)
        {
            respuesta.mensaje_error = "No has proporcionado una clave.";
            respuesta.error = true;
            return respuesta;
        }
        else if(nueva is null)
        {
            respuesta.mensaje_error = "No has proporcionado una clave nueva.";
            respuesta.error = true;
            return respuesta;
        }
        else if(antigua.length < 1)
        {
            respuesta.mensaje_error = "No has proporcionado una clave.";
            respuesta.error = true;
            return respuesta;
        }
        else if(nueva.length < 1)
        {
            respuesta.mensaje_error = "No has proporcionado una clave nueva.";
            respuesta.error = true;
            return respuesta;
        }
        else if((antigua.length > 0) && (nueva.length > 0))
        {
            respuesta = lee(antigua);
            if(respuesta.error)
            {
                respuesta.mensaje_error ~= " No he podico obtener la clave antigua [" ~ antigua ~ "].";
                return respuesta;
            }

            if(respuesta.dato.length < 1)
            {
                respuesta.error = true;
                respuesta.mensaje_error = "No he podico obtener la clave antigua [" ~ antigua ~ "].";
                return respuesta;
            }
            
            respuesta = pon(nueva, respuesta.dato[0].valor, respuesta.dato[0].tipo);
            if(respuesta.error)
            {
                respuesta.mensaje_error ~= " No he podico crear la clave nueva [" ~ nueva ~ "].";
                return respuesta;
            }

            respuesta = lee(nueva);
            if(respuesta.error)
            {
                respuesta.mensaje_error ~= " No he podico comprobar la clave nueva [" ~ nueva ~ "].";
                return respuesta;
            }

            respuesta = borra(antigua);
            if(respuesta.error)
            {
                respuesta.mensaje_error ~= " No he podico borrar la clave antigua [" ~ antigua ~ "].";
                return respuesta;
            }

            return respuesta;
        }
        else
        {
            respuesta.mensaje_error = "No he podido renombrar la clave [" ~ antigua ~ "].";
            respuesta.error = true;
            return respuesta;
        }
    }

    Tipo interpreta_tipo(string contenido)
    {
        if(_texto(contenido))
        {
            return Tipo.TEXTO;
        }
        else if(_booleano(contenido))
        {
            return Tipo.BOOLEANO;
        }
        else if(_real(contenido))
        {
            return Tipo.REAL;
        }
        else if(_entero(contenido))
        {
            return Tipo.ENTERO;
        }
        else
        {
            return Tipo.NADA;
        }
    }

    private bool _texto(string contenido)
    {
        uint cursor = 0;

        if(contenido[cursor] == '\"')
        {
            cursor++;

            dstring texto;

            while((contenido[cursor] != '\"') && (cursor < contenido.length-1))
            {
                cursor++;
            }

            if(contenido[cursor] != '\"')
            {
                if(INFO)
                {
                    writeln("ERROR: Esperaba un cierre de comilla doble [\"].");
                    writeln("Contenido: [" ~ contenido ~ "]");
                }

                return false;
            }

            return true;
        }
        else
        {
            return false;
        }
    }

    private bool _booleano(string contenido)
    {
        bool resultado = false;
        
        string s = contenido;

        if( (s == "cierto")
        || (s == "falso")
        || (s == "Cierto")
        || (s == "Falso")
        || (s == "CIERTO")
        || (s == "FALSO")
        || (s == "sí")
        || (s == "no")
        || (s == "Sí")
        || (s == "No")
        || (s == "SÍ")
        || (s == "NO")
        || (s == "SI")
        || (s == "NO")
        )
        {
            resultado = true;
        }

        return resultado;
    }

    private bool _real(string contenido)
    {
        contenido ~= " ";

        bool res = _notacióncientífica(contenido) || _númerodecimales(contenido);
        return res;
    }

    private bool _notacióncientífica(string contenido)
    {
        bool resultado = false;

        uint cursor = 0;
            
        while(esdígito(contenido[cursor]) && (cursor < (contenido.length-1)))
        {
            resultado = true;
            cursor++;
        }

        if(contenido[cursor] != '.')
        {
            return false;
        }
        
        if(cursor == (contenido.length-1))
        {
            //return false;
        }

        cursor++;

        do {
            resultado = true;
            cursor++;
        } while(esdígito(contenido[cursor]) && (cursor < (contenido.length-1)));

        dchar e = 'e';
        dchar E = 'E';
        if((contenido[cursor] != e) && (contenido[cursor] != E))
        {
            return false;
        }
        
        if(cursor == (contenido.length-1))
        {
            return false;
        }

        cursor++;
        
        if(cursor < (contenido.length-1) && (contenido[cursor] == '-') || (contenido[cursor] == '+') )
        {
            cursor++;
        }

        while(esdígito(contenido[cursor]) && (cursor < (contenido.length-1)))
        {
            resultado = true;
            cursor++;
        }

        return resultado;
    }

    private bool _númerodecimales(string contenido)
    {
        bool resultado = false;

        uint cursor = 0;
            
        while(esdígito(contenido[cursor]))
        {
            resultado = true;
            if(cursor == (contenido.length-1))
            {
                return false;
            }
            cursor++;
        }

        if(contenido[cursor] != '.')
        {
            return false;
        }
        
        if(cursor == (contenido.length-1))
        {
            return false;
        }
        
        cursor++;
            
        if(!esdígito(contenido[cursor]))
        {
            return false;
        }

        do {
            resultado = true;
            if(cursor == (contenido.length-1))
            {
                return false;
            }
            cursor++;
        } while(esdígito(contenido[cursor]));

        return resultado;
    }

    private bool _entero(string contenido)
    {
        contenido ~= " ";
        
        bool resultado = false;

        uint cursor = 0;

        if(esdígito(contenido[cursor]))
        {
            resultado = true;
            do {
                if(cursor == (contenido.length+1))
                {
                    return true;
                }
                cursor++;
            } while(esdígito(contenido[cursor]));
        }

        return resultado;
    }

    bool esdígito(dchar c)
    {
        return isNumber(c);
    }
}