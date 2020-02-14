/*SELECT codigo_cliente
FROM  PrefiereZona AS S0
WHERE  NOT EXISTS (SELECT nombre_zona
                   FROM Zona AS S1
                   WHERE nombre_poblacion = "Rosario"  AND NOT EXISTS (SELECT *
                                                                       FROM PrefiereZona AS S2
                                                                       WHERE S2.codigo_cliente = S0.codigo_cliente AND  S2.nombre_zona = S1.nombre_zona))
*/

/*

SELECT DISTINCT nombre
FROM Persona, (SELECT codigo_cliente
               FROM  PrefiereZona AS S0
               WHERE  NOT EXISTS (SELECT nombre_zona
                                 FROM Zona AS S1
                                 WHERE nombre_poblacion = "Rosario"  AND NOT EXISTS (SELECT *
                                                                                     FROM PrefiereZona AS S2
                                                                                     WHERE S2.codigo_cliente = S0.codigo_cliente AND  S2.nombre_zona = S1.nombre_zona))) AS S4
WHERE Persona.codigo = S4.codigo_cliente
*/


SELECT Persona.nombre, Persona.apellido, Inmueble.codigo, Inmueble.nombre_zona, Inmueble.precio
FROM   Persona, PrefiereZona, Limita, Inmueble
WHERE  Persona.codigo = PrefiereZona.codigo_cliente and /*Zonas preferidas*/
       (Limita.nombre_poblacion = PrefiereZona.nombre_poblacion and /*Zonas limitrofes a las preferidas*/
       Limita.nombre_zona = PrefiereZona.nombre_zona and
       Inmueble.nombre_poblacion = Limita.nombre_poblacion_2 and /*Inmuebles en zonas limitrofes*/
       Inmueble.nombre_zona = Limita.nombre_zona_2
       or
       Limita.nombre_poblacion_2 = PrefiereZona.nombre_poblacion and /*Zonas limitrofes a las preferidas*/
       Limita.nombre_zona_2 = PrefiereZona.nombre_zona and
       Inmueble.nombre_poblacion = Limita.nombre_poblacion and /*Inmuebles en zonas limitrofes*/
       Inmueble.nombre_zona = Limita.nombre_zona)
       and
       Persona.codigo IN /*Chequear que esta persona sea un cliente que visitó todos los inmuebles en sus zonas favoritas*/
       (SELECT codigo FROM Cliente WHERE NOT EXISTS (SELECT * FROM PrefiereZona,Inmueble
                                                     WHERE Cliente.codigo = PrefiereZona.codigo_cliente and
                                                          Inmueble.nombre_poblacion = PrefiereZona.nombre_poblacion and
                                                          Inmueble.nombre_zona = PrefiereZona.nombre_zona and
                                                          NOT EXISTS (SELECT * FROM Visitas WHERE
                                                                      Visitas.codigo_cliente = Cliente.codigo and
                                                                      Visitas.codigo_inmueble = Inmueble.codigo)));

SELECT Inmueble.codigo FROM Visitas,Inmueble WHERE  Visitas.codigo_inmueble = Inmueble.codigo
