/*Creazione tabella da entità Utente*/
CREATE TABLE dbo.Utenti(
	IdUtente INT NOT NULL,
	Username NVARCHAR(50) NOT NULL,
	Email VARCHAR(50) NOT NULL,
	DataRegistrazione DATETIME NOT NULL,
	PRIMARY KEY (IdUtente));

/*Creazione tabella da entità Post*/
CREATE TABLE dbo.Post(
	IdPost INT NOT NULL,
	Titolo NVARCHAR(100) NOT NULL,
	Contenuto NVARCHAR(MAX) NOT NULL,
	DataPubblicazione DATETIME NOT NULL,
	Pubblicato BIT NOT NULL,
	PRIMARY KEY (IdPost));

/*Gestione relazione Utente-Post*/
ALTER TABLE dbo.Post ADD IdUtente INT NOT NULL;

ALTER TABLE dbo.Post 
ADD FOREIGN KEY (IdUtente) 
REFERENCES dbo.Utenti(IdUtente);

/*Creazione tabella da entità Categoria*/
CREATE TABLE  dbo.Categoria(
	IdCategoria INT NOT NULL PRIMARY KEY,
	NOME VARCHAR(50),
	DESCRZIONE VARCHAR(100));

/*Gestione relazione Post-Categoria*/
CREATE TABLE dbo.PostCategoria(
	IdPost INT NOT NULL,
	IdCategoria INT NOT NULL,
	PRIMARY KEY(IdPost,IdCategoria),
	FOREIGN KEY (IdPost) REFERENCES dbo.Post(IdPost),
	FOREIGN KEY (IdCategoria) REFERENCES dbo.Categoria(IdCategoria))


/*Creazione tabella da entità Follow con gestione delle due
relazioni Utente-Follow*/
CREATE TABLE dbo.Follow(
	IdFollow int NOT NULL,
	data_follow datetime not null,
	id_utente_follower int not null,
	id_utente_following int not null,
	primary key (IdFollow),
	foreign key (id_utente_follower) 
		references  dbo.Utenti(IDUTENTE),
	foreign key (id_utente_following) 
		references  dbo.Utenti(IDUTENTE),
	CHECK (id_utente_follower != id_utente_following) )
