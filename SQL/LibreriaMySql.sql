DROP TABLE IF EXISTS `Escribe`;
DROP TABLE IF EXISTS `Autor`;
DROP TABLE IF EXISTS `Libro`;




CREATE TABLE Autor (
    Nombre Char(50),
    Apellido Char(50),
    Nacionalidad Char(50),
    Residencia Char(50),
    Id Integer AUTO_INCREMENT,
    PRIMARY KEY (Id)
);

CREATE TABLE Libro (
    Titulo Char(50),
    Editorial Char(50),
    Precio Int,
    Isbn Char(50),
    PRIMARY KEY (Isbn)
);



CREATE TABLE Escribe (
    Año Date,
    Id Integer,
    Isbn Char(50),
    PRIMARY KEY (Id, Isbn, Año),
    FOREIGN KEY (Id) REFERENCES Autor (Id),
    FOREIGN KEY (Isbn) REFERENCES Libro (Isbn)
    ON DELETE CASCADE ON UPDATE CASCADE
);





INSERT INTO Autor (Nombre, Apellido, Nacionalidad, Residencia)
    VALUES ("Damian", "Ariel", "Argentina", "Rosario");
INSERT INTO Autor (Nombre, Apellido, Nacionalidad, Residencia)
    VALUES ("Pablo", "Luis", "Argentina", "Venado");
INSERT INTO Autor (Nombre, Apellido, Nacionalidad, Residencia)
    VALUES ("Abelardo", "Castillo", "Argentina", "Rosario");
INSERT INTO Autor (Nombre, Apellido, Nacionalidad, Residencia)
    VALUES ("Jose", "Saramago", "Portugal", "Lisboa");
INSERT INTO Autor (Nombre, Apellido, Nacionalidad, Residencia)
    VALUES ("Bram", "Stoker", "Inglaterra", "Londres");
INSERT INTO Autor (Nombre, Apellido, Nacionalidad, Residencia)
    VALUES ("Pepito", "Lopes", "Brasil", "San Pablo");


INSERT INTO Libro (ISBN, Titulo, Editorial, Precio)
    VALUES ("0001", "Ensayo Sobre la Ceguera", "EMPA", 800);
INSERT INTO Libro (ISBN, Titulo, Editorial, Precio)
    VALUES ("0002", "Dracula", "EMPA", 800);
INSERT INTO Libro (ISBN, Titulo, Editorial, Precio)
    VALUES ("0003", "Calculo I", "UNR", 300);
INSERT INTO Libro (ISBN, Titulo, Editorial, Precio)
    VALUES ("0004", "Sistemas", "UNR", 100);
INSERT INTO Libro (ISBN, Titulo, Editorial, Precio)
    VALUES ("0005", "Aventuras", "UNR", 100);

INSERT INTO Escribe (Id, Isbn, Año)
    VALUES (4, "0001", '2000-1-1');
INSERT INTO Escribe (Id, Isbn, Año)
    VALUES (5, "0002", '1897-1-1');
INSERT INTO Escribe (Id, Isbn, Año)
    VALUES (5, "0004", '1995-1-1');
INSERT INTO Escribe (Id, Isbn, Año)
    VALUES (6, "0005", '1998-1-1');
