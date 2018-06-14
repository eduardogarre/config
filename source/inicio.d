/*
Copyright © 2017, Eduardo Garre <eduardo.garre@outlook.com>

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/

import std.stdio;

import datos;

// dub build --build=release --force
int main(string[] args)
{
	Respuesta respuesta;
	
	// Ejemplos con carpetas predeterminadas (/datos y ~/.datos)
	respuesta = new Datos().ejecuta(["pon", "hola.k.ase.x.ay.ask", "sí", "-b"]); writeln(respuesta);
	respuesta = new Datos().ejecuta(["lee", "hola.k.ase.x.ay.ask"]); writeln(respuesta);
	respuesta = new Datos().ejecuta(["mv", "hola.k.ase.x.ay.ask", "hola.k.ase.asky"]); writeln(respuesta);
	respuesta = new Datos().ejecuta(["qt", "hola.k.ase.asky"]); writeln(respuesta);

	respuesta = new Datos().ejecuta(["pon", "sis.hola.k.ase.x.ay.ask", "sí", "-b"]); writeln(respuesta);
	respuesta = new Datos().ejecuta(["lee", "sis.hola.k.ase.x.ay.ask"]); writeln(respuesta);
	respuesta = new Datos().ejecuta(["mv", "sis.hola.k.ase.x.ay.ask", "hola.k.ase.asky"]); writeln(respuesta);
	respuesta = new Datos().ejecuta(["qt", "sis.hola.k.ase.asky"]); writeln(respuesta);

	// Ejemplos definiendo una subcarpeta (/datos/'subcarpeta' y ~/.datos/'subcarpeta')
	respuesta = new Datos("hola").ejecuta(["pon", "hola.k.ase.x.ay.sub.hola", "sí", "-b"]); writeln(respuesta);
	respuesta = new Datos("hola").ejecuta(["lee", "hola.k.ase.x.ay.sub.hola"]); writeln(respuesta);
	respuesta = new Datos("hola").ejecuta(["qt", "hola.k.ase.x.ay.sub.hola"]); writeln(respuesta);

	// Ejemplos definiendo una ruta propia
	respuesta = new Datos(new Ruta("c:/hola")).ejecuta(["pon", "hola.k.ase.x.ay.c.hola", "sí", "-b"]); writeln(respuesta);
	respuesta = new Datos(new Ruta("c:/hola")).ejecuta(["lee", "hola.k.ase.x.ay.c.hola"]); writeln(respuesta);
	respuesta = new Datos(new Ruta("c:/hola")).ejecuta(["qt", "hola.k.ase.x.ay.c.hola"]); writeln(respuesta);

	respuesta = new Datos(new Ruta("/adios")).ejecuta(["pon", "hola.k.ase.x.ay.l.adios", "sí", "-b"]); writeln(respuesta);
	respuesta = new Datos(new Ruta("/adios")).ejecuta(["lee", "hola.k.ase.x.ay.l.adios"]); writeln(respuesta);
	respuesta = new Datos(new Ruta("/adios")).ejecuta(["qt", "hola.k.ase.x.ay.l.adios"]); writeln(respuesta);

	if(respuesta.error)
	{
		//writeln("ERROR: " ~ respuesta.mensaje_error);
		return 0;
	}
	else
	{
		foreach(d; respuesta.dato)
		{
			writeln(d.clave ~ "=" ~ d.valor ~ " [" ~ textifica(d.tipo) ~ "]");
		}
	}

	return 0;
}