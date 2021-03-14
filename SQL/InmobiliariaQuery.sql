SELECT USER pablo alonso;
USE Inmobiliaria;

/*a*/
/*Nombres de los dueños de los inmuebles*/
/*
SELECT DISTINCT apellido
FROM Persona, PoseeInmueble
WHERE Persona.codigo = PoseeInmueble.codigo_propietario;
*/




/*b*/
/*códigos de los inmuebles cuyo precio está en el intervalo 600.000 a 700.000
inclusive.*/

/*
SELECT codigo
FROM Inmueble AS I
WHERE precio >= 600000 AND precio <= 800000
ORDER BY codigo ASC;
*/

/*c*/
/*Obtener los nombres de los clientes que prefieran inmuebles sólo en la zona Norte de Santa Fe.*/
/*
SELECT DISTINCT  nombre
FROM Persona,PrefiereZona AS PZ
WHERE EXISTS( SELECT ALL FROM PrefiereZona WHERE  nombre_zona = "Norte" AND nombre_poblacion = "Santa Fe" AND codigo = codigo_cliente)
      AND
      NOT  EXISTS (SELECT ALL FROM PrefiereZona WHERE  (nombre_zona <> "Norte" OR nombre_poblacion <> "Santa Fe") AND codigo = codigo_cliente );
*/
/*d*/
/*
SELECT DISTINCT nombre
FROM Persona AS p INNER JOIN (SELECT vendedor FROM (SELECT codigo AS cod FROM Persona JOIN PrefiereZona ON codigo = codigo_cliente WHERE nombre_poblacion = "Rosario" AND nombre_zona = "Centro") AS s1 JOIN Cliente ON s1.cod = Cliente.codigo ) AS s2
             ON vendedor = codigo;
*/



/*e*/
/*
SELECT nombre FROM Persona JOIN (SELECT vendedor FROM Cliente AS C WHERE codigo IN (SELECT vendedor FROM Cliente)) AS s1 ON codigo = vendedor;
*/

/*f*/

/*
SELECT DISTINCT nombre
FROM Persona, (SELECT codigo_cliente
              FROM  PrefiereZona AS S0
              WHERE  NOT EXISTS (SELECT nombre_zona FROM Zona AS S1 WHERE nombre_poblacion = "Rosario"  AND
                     NOT EXISTS (SELECT ALL FROM PrefiereZona AS S2 WHERE S2.codigo_cliente = S0.codigo_cliente AND  S2.nombre_zona = S1.nombre_zona))) AS S4
WHERE Persona.codigo = S4.codigo_cliente;

*/

/*g*/


/*Esta es la subconsulta original, no termina más*/
/*Para testearla la dividí en 2 (g1 y g2) */
/*
SELECT Persona.nombre, Persona.apellido, Inmueble.codigo, Inmueble.nombre_zona, Inmueble.precio
FROM   Persona, PrefiereZona, Limita, Inmueble
WHERE  Persona.codigo = PrefiereZona.codigo_cliente AND
       (Limita.nombre_poblacion = PrefiereZona.nombre_poblacion AND
       Limita.nombre_zona = PrefiereZona.nombre_zona AND
       Inmueble.nombre_poblacion = Limita.nombre_poblacion_2 AND
       Inmueble.nombre_zona = Limita.nombre_zona_2
       OR
       Limita.nombre_poblacion_2 = PrefiereZona.nombre_poblacion AND
       Limita.nombre_zona_2 = PrefiereZona.nombre_zona AND
       Inmueble.nombre_poblacion = Limita.nombre_poblacion AND
       Inmueble.nombre_zona = Limita.nombre_zona) AND
       Persona.codigo IN
       (SELECT codigo FROM Cliente WHERE NOT EXISTS (SELECT ALL FROM PrefiereZona AS PZ,Inmueble AS I
                                                     WHERE Cliente.codigo = PZ.codigo_cliente AND
                                                          Inmueble.nombre_poblacion = PZ.nombre_poblacion AND
                                                          Inmueble.nombre_zona = PZ.nombre_zona AND
                                                          NOT EXISTS (SELECT ALL FROM Visitas WHERE
                                                                      Visitas.codigo_cliente = Cliente.codigo AND
                                                                      Visitas.codigo_inmueble = Inmueble.codigo)));
*/


/*g1*/
/*
SELECT Persona.nombre, Persona.apellido, Inmueble.codigo, Inmueble.nombre_zona, Inmueble.precio
FROM   Persona, PrefiereZona AS PZ, Limita, Inmueble
WHERE  Persona.codigo = PZ.codigo_cliente AND
       (Limita.nombre_poblacion = PZ.nombre_poblacion AND
       Limita.nombre_zona = PZ.nombre_zona AND
       Inmueble.nombre_poblacion = Limita.nombre_poblacion_2 AND
       Inmueble.nombre_zona = Limita.nombre_zona_2
       OR
       Limita.nombre_poblacion_2 = PZ.nombre_poblacion AND
       Limita.nombre_zona_2 = PZ.nombre_zona AND
       Inmueble.nombre_poblacion = Limita.nombre_poblacion AND
       Inmueble.nombre_zona = Limita.nombre_zona) AND
       Persona.codigo IN (1001,1011,1013)
*/

/*Esta subconsulta devuelve 1001,1011 y 1013 */
/*g2*/
/*
SELECT codigo FROM Cliente WHERE NOT EXISTS (SELECT ALL FROM PrefiereZona AS PZ2,Inmueble AS I2
                                             WHERE Cliente.codigo = PZ2.codigo_cliente AND
                                                  I2.nombre_poblacion = PZ2.nombre_poblacion AND
                                                  I2.nombre_zona = PZ2.nombre_zona AND
                                                  NOT EXISTS (SELECT ALL FROM Visitas WHERE
                                                              Visitas.codigo_cliente = Cliente.codigo AND
                                                              Visitas.codigo_inmueble = I2.codigo));
*/



SELECT SUM(precio),nombre_poblacion FROM Inmueble GROUP BY nombre_poblacion;
SELECT SUM(precio),nombre_poblacion,nombre_zona FROM Inmueble GROUP BY nombre_poblacion,nombre_zona;
SELECT nombre_poblacion FROM Inmueble GROUP BY nombre_poblacion;
SELECT ALL FROM SELECT SUM(precio),nombre_poblacion FROM Inmueble GROUP BY nombre_poblacion;
SELECT ALL FROM SELECT ALL FROM SELECT SUM(precio),nombre_poblacion FROM Inmueble GROUP BY nombre_poblacion;
SELECT nombre_poblacion FROM  (SELECT SUM(precio) AS sum,nombre_poblacion FROM Inmueble GROUP BY nombre_poblacion) WHERE sum > 1000000.0;
SELECT nombre_poblacion,nombre_zona FROM Inmueble GROUP BY nombre_poblacion HAVING SUM(precio) > 1000000.0;
SELECT precioMedio AS precioMean AS somePrecio AS pepo FROM (SELECT AVG(precio) AS precioMedio ,nombre_poblacion FROM Inmueble GROUP BY nombre_poblacion);
SELECT nombre_poblacion,nombre_zona FROM Inmueble GROUP BY nombre_poblacion HAVING SUM(precio) > 1000000.0;
SELECT ALL FROM (SELECT nombre_poblacion FROM Inmueble GROUP BY nombre_poblacion HAVING AVG(superficie) > 100.0) AS Inmueblazo;
SELECT Inmueblazo.nombre_poblacion FROM (SELECT nombre_poblacion FROM Inmueble GROUP BY nombre_poblacion HAVING AVG(superficie) > 100.0) AS Inmueblazo;
SELECT SUM(precio) FROM Inmueble GROUP BY nombre_poblacion HAVING AVG(superficie) > 100.0;
SELECT SUM(precio)+1+2+3 FROM Inmueble GROUP BY nombre_poblacion HAVING AVG(superficie) > 100.0;
SELECT SUM(precio)+1+2+3 AS total, SUM(precio)+1+2+3 AS totales FROM Inmueble GROUP BY nombre_poblacion HAVING AVG(superficie) > 100.0;
SELECT SUM(precio)+1+2+3 AS total, SUM(precio)+1+2+3 AS total FROM Inmueble GROUP BY nombre_poblacion HAVING AVG(superficie) > 100.0;
SELECT SUM(precio) AS total, SUM(precio)*3 AS totalBy3 FROM Inmueble GROUP BY nombre_poblacion HAVING AVG(superficie) > 100.0;
SELECT MIN(precio) AS min, MIN(precio)*3 AS minBy3 FROM Inmueble GROUP BY nombre_poblacion HAVING AVG(superficie) > 100.0;
SELECT MIN(precio) AS min, MIN(precio)/3 AS minDiv3 FROM Inmueble GROUP BY nombre_poblacion HAVING AVG(superficie) > 100.0;
SELECT MIN(precio) , MIN(precio)/3 FROM Inmueble GROUP BY nombre_poblacion HAVING AVG(superficie) > 100.0;
SELECT max,maxDiv3 FROM SELECT MAX(precio) AS max , MAX(precio)/3 AS maxDiv3 FROM Inmueble GROUP BY nombre_poblacion HAVING AVG(superficie) > 100.0;
SELECT COUNT(direccion) AS count AS total FROM Inmueble GROUP BY nombre_poblacion HAVING AVG(superficie) > 100.0;
SELECT ALL FROM Limita WHERE nombre_poblacion_2 LIKE "Ros%";
SELECT COUNT(precio),nombre_poblacion FROM Inmueble GROUP BY nombre_poblacion;
SELECT ALL FROM Visitas WHERE fecha_hora < 2014-10-15 10:00:00;
/*SELECT ALL FROM Visitas WHERE fecha_hora < 2014-10-15 ;*//*Error de tipo*/
SELECT ALL FROM Visitas LIMIT 50;
SELECT ALL FROM Visitas LIMIT 0;
SELECT ALL FROM (Persona LEFT JOIN Visitas ON codigo = codigo_cliente) AS left;
SELECT DISTINCT left.codigo_cliente FROM (Persona LEFT JOIN Visitas ON codigo = codigo_cliente) AS left WHERE left.codigo_cliente <> NULL;
/*SELECT left.codigo_cliente AS new_cod FROM (Persona LEFT JOIN Visitas ON codigo = codigo_cliente) AS left WHERE left.codigo_cliente <> NULL;*//*Esto va a tirar un error;*/
SELECT DISTINCT codigo_cliente AS new_cod FROM (Persona LEFT JOIN Visitas ON codigo = codigo_cliente) AS left WHERE left.codigo_cliente <> NULL;
