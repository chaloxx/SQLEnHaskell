/*a*/
SELECT DISTINCT apellido
FROM Persona, PoseeInmueble
WHERE Persona.codigo = PoseeInmueble.codigo_propietario;

/*b*/
SELECT codigo
FROM Inmueble
WHERE precio >= 600000 AND precio <= 800000;

/*c*/
SELECT DISTINCT nombre
FROM Persona,PrefiereZona
WHERE EXISTS( SELECT * FROM PrefiereZona WHERE  nombre_zona = "Norte" AND nombre_poblacion = "Santa Fe" AND codigo = codigo_cliente)
       AND
       NOT EXISTS (SELECT * FROM PrefiereZona WHERE  (nombre_zona <> "Norte" OR nombre_poblacion <> "Santa Fe") AND codigo = codigo_cliente);

/*d*/
SELECT DISTINCT nombre
FROM Persona JOIN (SELECT vendedor FROM (SELECT codigo FROM Persona JOIN PrefiereZona ON codigo = codigo_cliente WHERE nombre_poblacion = "Rosario" AND nombre_zona = "Centro") AS s1 JOIN Cliente ON s1.codigo = Cliente.codigo ) AS s2
             ON vendedor = codigo ;


/*e*/
SELECT nombre FROM Persona JOIN (SELECT vendedor FROM Cliente WHERE codigo IN (SELECT vendedor FROM Cliente)) AS s1 ON codigo = vendedor;

/*f*/

SELECT DISTINCT nombre
FROM Persona, (SELECT codigo_cliente
              FROM  PrefiereZona AS S0
              WHERE  NOT EXISTS (SELECT nombre_zona FROM Zona AS S1 WHERE nombre_poblacion = "Rosario"  AND
                     NOT EXISTS (SELECT * FROM PrefiereZona AS S2 WHERE S2.codigo_cliente = S0.codigo_cliente AND  S2.nombre_zona = S1.nombre_zona))) AS S4
WHERE Persona.codigo = S4.codigo_cliente;




/*g*/
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
