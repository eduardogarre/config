module dato;

import docopt;
import std.conv;
import std.file;
import std.path;
import std.process;
import std.stdio;
import std.string;
import std.uni; // isAlpha(), isNumber(), isAlphaNum(), isWhite()

enum Tipo {
    TEXTO,
    BOOLEANO,
    ENTERO,
    REAL
}

struct Tríada {
    string  clave;
    string  dato;
    Tipo    tipo;
}

struct Respuesta {
    bool        error;
    Tríada[]    resultado;
}


class Dato {
    int profundidad = 0;

    bool INFO = false;
    bool CHARLATAN = false;

    string RUTA = "~/.config";
    string SISTEMA = "/cfg";

    Respuesta respuesta;

    this()
    {}



    int ejecuta(string[] args)
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
            return 0;
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

                if(lista(clave))
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
                if(lista(null))
                {
                    return 0;
                }
                else
                {
                    return -1;
                }
            }
        }

        if(argumentos["lee"].isTrue())
        {
            string clave = argumentos["<clave>"].value().toString;

            if(CHARLATAN)
            {
                writeln("\"" ~ clave ~ "\" = [ ]");
            }

            if(lee(clave))
            {
                return 0;
            }
            else
            {
                return -1;
            }
        }

        if(argumentos["tipo"].isTrue())
        {
            string clave = argumentos["<clave>"].value().toString;

            if(CHARLATAN)
            {
                writeln("\"" ~ clave ~ "\" = T[ ]");
            }

            if(lee_tipo(clave))
            {
                return 0;
            }
            else
            {
                return -1;
            }
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
                if(pon(clave, valor, "texto"))
                {
                    return 0;
                }
                else
                {
                    return -1;
                }
            }
            else if(argumentos["--booleano"].isTrue())
            {
                if(!_booleano(valor))
                {
                    return -1;
                }
                
                if(pon(clave, valor, "booleano"))
                {
                    return 0;
                }
                else
                {
                    return -1;
                }
            }
            else if(argumentos["--real"].isTrue())
            {
                if(!_real(valor))
                {
                    return -1;
                }
                
                if(pon(clave, valor, "real"))
                {
                    return 0;
                }
                else
                {
                    return -1;
                }
            }
            else if(argumentos["--entero"].isTrue())
            {
                if(!_entero(valor))
                {
                    return -1;
                }
                
                if(pon(clave, valor, "entero"))
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
                //writeln("\"" ~ clave ~ "\" = [" ~ valor ~ "]");
                if(_booleano(valor))
                {
                    if(pon(clave, valor, "booleano"))
                    {
                        return 0;
                    }
                    else
                    {
                        return -1;
                    }
                }
                else if(_real(valor))
                {
                    if(pon(clave, valor, "real"))
                    {
                        return 0;
                    }
                    else
                    {
                        return -1;
                    }
                }
                else if(_entero(valor))
                {
                    if(pon(clave, valor, "entero"))
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
                    if(pon(clave, valor, "texto"))
                    {
                        return 0;
                    }
                    else
                    {
                        return -1;
                    }
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

            if(renombra(antigua, nueva))
            {
                return 0;
            }
            else
            {
                return -1;
            }
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

            if(borra(clave))
            {
                return 0;
            }
            else
            {
                return -1;
            }
        }

        return -1;
    }

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

    bool construye_árbol(string ruta, Nodo raíz)
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

    bool recorre_árbol(Nodo n)
    {
        profundidad++;

        if(n)
        {
            //entra_en_nodo(n);

            int i;
            for(i = 0; i < n.ramas.length; i++)
            {
                entra_en_nodo(n.ramas[i]);
            }

            profundidad--;

            return true;
        }

        profundidad--;

        return false;
    }

    bool entra_en_nodo(Nodo n)
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

                writeln(clave ~ "=" ~ contenido);

                return true;
            }
            else
            {
                if(CHARLATAN)
                {
                    write(n.ruta);
                }
                
                return true;
            }
        }

        return false;
    }

    string obtén_directorio(string miruta)
    {
        return miruta[0..(lastIndexOf(miruta, '/'))];
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
                miruta = SISTEMA ~ "/";
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

    bool lista(string clave)
    {
        string miruta;

        if(clave == null)
        {
            miruta = RUTA;
        }

        if(clave.length > 0)
        {
            miruta = interpreta_clave(clave);
        }

        if((!exists(miruta)))
        {
            if(INFO)
            {
                writeln("ERROR: La clave proporcionada no existe.");
            }
            return false;
        }

        if(!isDir(miruta))
        {
            if(isFile(miruta))
            {
                return lee(clave);
            }

            if(INFO)
            {
                writeln("ERROR: No se puede acceder a la clave.");
            }
            return false;
        }

        // bucle de lectura recursiva de claves
        if(INFO)
        {
            writeln("bucle de lectura");
        }

        auto raíz = new Nodo(miruta, "");

        construye_árbol(miruta, raíz);
        recorre_árbol(raíz);

        return true;
    }

    bool lee(string clave)
    {
        if(clave.length > 0)
        {
            string miruta = interpreta_clave(clave);

            if((!exists(miruta)))
            {
                if(INFO)
                {
                    writeln("ERROR: La clave proporcionada no existe.");
                }
                return false;
            }

            if(isDir(miruta))
            {
                if(INFO)
                {
                    writeln("ERROR: La clave proporcionada es un contenedor.");
                }
                return false;
            }

            string contenido = readText(miruta);

            writeln(clave ~ "=" ~ contenido);

            return true;
        }
        else
        {
            return false;
        }
    }

    bool lee_tipo(string clave)
    {
        if(clave.length > 0)
        {
            string miruta = interpreta_clave(clave);

            if((!exists(miruta)))
            {
                if(INFO)
                {
                    writeln("ERROR: La clave proporcionada no existe.");
                }
                return false;
            }

            string contenido = readText(miruta);
            
            string tipo = interpreta_tipo(contenido);

            if(tipo)
            {
                writeln(clave ~ "=<" ~ tipo ~ ">");
            }

            return true;
        }
        else
        {
            return false;
        }
    }

    bool pon(string clave, string valor, string tipo)
    {
        if(clave.length > 0)
        {
            string miruta = interpreta_clave(clave);

            if((!exists(miruta)))
            {
                if(INFO)
                {
                    writeln("INFO: La clave proporcionada no existia.");
                }
            }
            else if(isDir(miruta))
            {
                if(INFO)
                {
                    writeln("ERROR: La clave proporcionada es un contenedor.");
                }
                return false;
            }

            string dir = obtén_directorio(miruta);
            std.file.mkdirRecurse(dir);

            switch(tipo)
            {
                case "texto":
                    std.file.write(miruta, "\"" ~ valor ~ "\"");
                    break;

                case "booleano":
                    std.file.write(miruta, valor);
                    break;

                case "real":
                    std.file.write(miruta, valor);
                    break;

                case "entero":
                    std.file.write(miruta, valor);
                    break;

                default:
                    writeln("ERROR: No reconozco el tipo '" ~ tipo ~ "'.");
                    return false;
            }

            //std.file.write(miruta, valor);

            return true;
        }
        else
        {
            return false;
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

    bool borra(string clave)
    {
        if(clave.length > 0)
        {
            string miruta = interpreta_clave(clave);

            if((!exists(miruta)))
            {
                if(INFO)
                {
                    writeln("ERROR: La clave proporcionada no existe.");
                }
                return false;
            }

            if(isFile(miruta))
            {
                remove(miruta);

                int archivos = 0;
                
                foreach (string name; dirEntries(obtén_directorio(miruta), SpanMode.shallow))
                {
                    archivos++;
                }
                if(archivos == 0)
                {
                    //rmdir(obtén_directorio(miruta));
                }
            }
            else if(isDir(miruta))
            {
                rmdir(miruta);
            }
            else
            {
                return false;
            }

            return true;
        }
        else
        {
            return false;
        }
    }

    bool renombra(string antigua, string nueva)
    {
        if((antigua.length > 0) && (nueva.length > 0))
        {
            string antiguo = interpreta_clave(antigua);
            string nuevo = interpreta_clave(nueva);

            if(!exists(antiguo))
            {
                if(INFO)
                {
                    writeln("ERROR: La clave proporcionada no existe.");
                }
                return false;
            }

            if( exists(nuevo) )
            {
                if(INFO)
                {
                    writeln("ERROR: La clave nueva clave ya existe.");
                }
                return false;
            }

            std.file.rename(antiguo, nuevo);

            return true;
        }
        else
        {
            return false;
        }
    }

    string interpreta_tipo(string contenido)
    {
        if(_texto(contenido))
        {
            return "texto";
        }
        else if(_booleano(contenido))
        {
            return "booleano";
        }
        else if(_real(contenido))
        {
            return "real";
        }
        else if(_entero(contenido))
        {
            return "entero";
        }
        else
        {
            return null;
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