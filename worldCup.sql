CREATE TABLE Team
(
	id int NOT NULL,
	name text NOT NULL,
	pool char NOT NULL
	
);

ALTER TABLE ONLY Team
    ADD CONSTRAINT pk_team PRIMARY KEY (id);



CREATE TABLE Match
(
	id int NOT NULL,
	homeTeamId int NULL,
	awayTeamId int NULL,
	homeTeamScore int NULL,
	homeTeamTries int NULL,
	awayTeamScore int NULL,
	awayTeamTries int NULL
	
);

ALTER TABLE ONLY Match
    ADD CONSTRAINT pk_match PRIMARY KEY (id);


INSERT into Team VALUES (202, 'Australia', 'A');
INSERT into Team VALUES (204, 'England', 'A');
INSERT into Team VALUES (205, 'Fiji', 'A');
INSERT into Team VALUES (218, 'Uruguay', 'A');
INSERT into Team VALUES (220, 'Wales', 'A');


INSERT into Match VALUES (1, 204, 205, 35, 4, 11, 1);
INSERT into Match VALUES (7, 220, 218, 54, 8, 9, 0);
INSERT into Match VALUES (10, 202, 205, 28, 3, 13, 1);
INSERT into Match VALUES (16, 204, 220, 25, 1, 28, 1);
INSERT into Match VALUES (17, 202, 218, 65, 11, 3, 0);
INSERT into Match VALUES (21, 220, 205, 20, 3, 26, 4);
INSERT into Match VALUES (26, 204, 202, 27, 3, 25, 3);

ALTER TABLE ONLY Match
    ADD CONSTRAINT fk_match_team_awayTeamId FOREIGN KEY (awayTeamId) REFERENCES Team;

ALTER TABLE ONLY Match
    ADD CONSTRAINT fk_match_team_homeTeamId FOREIGN KEY (homeTeamId) REFERENCES Team;
