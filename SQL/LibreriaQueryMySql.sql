
UPDATE Autor SET
    Residencia = "Buenos Aires"
    WHERE Nombre = "Abelardo" AND Apellido = "Castillo";




UPDATE Libro SET
    Precio = Precio + (Precio/10)
    WHERE Editorial = "UNR";




DELETE FROM Libro
	WHERE EXISTS (SELECT * FROM Escribe WHERE Libro.Isbn = Escribe.Isbn AND Año = '1998-1-1');


