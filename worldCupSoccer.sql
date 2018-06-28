-- http://sqlfiddle.com/#!18/c0701/1
-- https://stackoverflow.com/questions/32876744/ranking-teams-equal-on-points-in-a-pool-based-on-who-won-the-game-they-played

SELECT 
	HT.id AS id, 
        HT.name AS "Home Team", 
        M.hometeamscore AS "home Team Score", 
        M.awayteamscore AS "away Team Score", 
        AT.name AS "away Team"
FROM 
		Match AS M 
		INNER JOIN Team AS HT 
			ON M.homeTeamId = HT.id 
		INNER JOIN Team AS AT 
			ON M.awayTeamId = AT.id;


Soccer World Cup Rulling

a) greatest number of points obtained in all group matches;
b) goal difference in all group matches;
c) greatest number of goals scored in all group matches.

d) greatest number of points obtained in the group matches between the
teams concerned;
e) goal difference resulting from the group matches between the teams
concerned;
f) greater number of goals scored in all group matches between the teams
concerned;
g) greater number of points obtained in the fair play conduct of the teams
based on yellow and red cards received in all group matches as follows:
 – yellow card: minus 1 point
 – indirect red card: minus 3 points
(as a result of a second yellow card)
 – direct red card: minus 4 points
 – yellow card and direct red card: minus 5 points
Only one of the above deductions shall be applied to a player in a single
match;

WITH RawPoolResults (MatchId, TeamId, Team, P, W, D, L, PF, PA, PTS) AS
(
SELECT 
		M.Id AS MatchId, 
		M.HomeTeamId AS TeamId,
		HT.Name AS Team,
		1 AS P, 
		CASE WHEN M.HomeTeamScore > M.AwayTeamScore THEN 1 ELSE 0 END AS W, --Wins
		CASE WHEN M.HomeTeamScore = M.AwayTeamScore THEN 1 ELSE 0 END AS D, --Draws
		CASE WHEN M.HomeTeamScore < M.AwayTeamScore THEN 1 ELSE 0 END AS L, --Loses
		M.HomeTeamScore AS PF, 
		M.AwayTeamScore AS PA, 
		CASE 
			WHEN M.HomeTeamScore > M.AwayTeamScore THEN 3 
			WHEN M.HomeTeamScore = M.AwayTeamScore THEN 1 
			WHEN M.HomeTeamScore < M.AwayTeamScore THEN 0 
		END AS PTS
		
	FROM 
		Match AS M 
		INNER JOIN Team AS HT 
			ON M.HomeTeamId = HT.Id 
	WHERE 
		M.HomeTeamScore IS NOT NULL

	UNION 

	SELECT 
		M.Id AS MatchId, 
		M.AwayTeamId AS TeamId, 
		AT.Name AS Team, 
		1 AS P, 
		CASE WHEN M.AwayTeamScore > M.HomeTeamScore THEN 1 ELSE 0 END AS W, 
		CASE WHEN M.AwayTeamScore = M.HomeTeamScore THEN 1 ELSE 0 END AS D, 
		CASE WHEN M.AwayTeamScore < M.HomeTeamScore THEN 1 ELSE 0 END AS L, 
		M.AwayTeamScore AS PF, 
		M.HomeTeamScore AS PA, 
		CASE 
			WHEN M.AwayTeamScore > M.HomeTeamScore THEN 3 
			WHEN M.AwayTeamScore = M.HomeTeamScore THEN 1 
			WHEN M.AwayTeamScore < M.HomeTeamScore THEN 0 
		END AS PTS
		
	FROM 
		Match AS M 
		INNER JOIN Team AS AT 
			ON M.AwayTeamId = AT.Id 
	WHERE 
		M.AwayTeamScore IS NOT NULL
)
SELECT 
	TeamId, 
	Team,
	SUM(P) AS P,
	SUM(W) AS W, 
	SUM(D) AS D, 
	SUM(L) AS L, 
	SUM(PF) AS PF, 
	SUM(PA) AS PA, 
	SUM(PTS) AS PTS 
FROM 
	RawPoolResults 
GROUP BY 
	TeamId, 
	Team;

--When the number of gols Home + Away in all matchs is use as tie break criteria
WITH PoolResults (MatchId, TeamId, Team, P, W, D, L, PF, PA, PTS) AS
(
SELECT 
		M.Id AS MatchId, 
		M.HomeTeamId AS TeamId,
		HT.Name AS Team,
		1 AS P, 
		CASE WHEN M.HomeTeamScore > M.AwayTeamScore THEN 1 ELSE 0 END AS W, --Wins
		CASE WHEN M.HomeTeamScore = M.AwayTeamScore THEN 1 ELSE 0 END AS D, --Draws
		CASE WHEN M.HomeTeamScore < M.AwayTeamScore THEN 1 ELSE 0 END AS L, --Loses
		M.HomeTeamScore AS PF, 
		M.AwayTeamScore AS PA, 
		CASE 
			WHEN M.HomeTeamScore > M.AwayTeamScore THEN 3 
			WHEN M.HomeTeamScore = M.AwayTeamScore THEN 1 
			WHEN M.HomeTeamScore < M.AwayTeamScore THEN 0 
		END AS PTS
		
	FROM 
		Match AS M 
		INNER JOIN Team AS HT 
			ON M.HomeTeamId = HT.Id 
	WHERE 
		M.HomeTeamScore IS NOT NULL

	UNION 

	SELECT 
		M.Id AS MatchId, 
		M.AwayTeamId AS TeamId, 
		AT.Name AS Team, 
		1 AS P, 
		CASE WHEN M.AwayTeamScore > M.HomeTeamScore THEN 1 ELSE 0 END AS W, 
		CASE WHEN M.AwayTeamScore = M.HomeTeamScore THEN 1 ELSE 0 END AS D, 
		CASE WHEN M.AwayTeamScore < M.HomeTeamScore THEN 1 ELSE 0 END AS L, 
		M.AwayTeamScore AS PF, 
		M.HomeTeamScore AS PA, 
		CASE 
			WHEN M.AwayTeamScore > M.HomeTeamScore THEN 3 
			WHEN M.AwayTeamScore = M.HomeTeamScore THEN 1 
			WHEN M.AwayTeamScore < M.HomeTeamScore THEN 0 
		END AS PTS
		
	FROM 
		Match AS M 
		INNER JOIN Team AS AT 
			ON M.AwayTeamId = AT.Id 
	WHERE 
		M.AwayTeamScore IS NOT NULL
	)

SELECT ROW_NUMBER() OVER (ORDER BY SUM(PF + PA) DESC) AS Position, 
	TeamId, 
	Team,
	SUM(P) AS P,
	SUM(W) AS W, 
	SUM(D) AS D, 
	SUM(L) AS L, 
	SUM(PF) AS PF, 
	SUM(PA) AS PA, 
	SUM(PTS) AS PTS 
FROM 
	PoolResults 
GROUP BY 
	TeamId, 
	Team;



--TODO: Resolve Issue shoud be
-- 1-Wales
-- 2-England
-- 3-Australia
--When the direct confornt is used as tie break criteria
WITH PoolResults (MatchId, TeamId, Team, P, W, D, L, PF, PA, PTS) AS
(
SELECT 
		M.Id AS MatchId, 
		M.HomeTeamId AS TeamId,
		HT.Name AS Team,
		1 AS P, 
		CASE WHEN M.HomeTeamScore > M.AwayTeamScore THEN 1 ELSE 0 END AS W, --Wins
		CASE WHEN M.HomeTeamScore = M.AwayTeamScore THEN 1 ELSE 0 END AS D, --Draws
		CASE WHEN M.HomeTeamScore < M.AwayTeamScore THEN 1 ELSE 0 END AS L, --Loses
		M.HomeTeamScore AS PF, 
		M.AwayTeamScore AS PA, 
		CASE 
			WHEN M.HomeTeamScore > M.AwayTeamScore THEN 3 
			WHEN M.HomeTeamScore = M.AwayTeamScore THEN 1 
			WHEN M.HomeTeamScore < M.AwayTeamScore THEN 0 
		END AS PTS
		
	FROM 
		Match AS M 
		INNER JOIN Team AS HT 
			ON M.HomeTeamId = HT.Id 
	WHERE 
		M.HomeTeamScore IS NOT NULL

	UNION 

	SELECT 
		M.Id AS MatchId, 
		M.AwayTeamId AS TeamId, 
		AT.Name AS Team, 
		1 AS P, 
		CASE WHEN M.AwayTeamScore > M.HomeTeamScore THEN 1 ELSE 0 END AS W, 
		CASE WHEN M.AwayTeamScore = M.HomeTeamScore THEN 1 ELSE 0 END AS D, 
		CASE WHEN M.AwayTeamScore < M.HomeTeamScore THEN 1 ELSE 0 END AS L, 
		M.AwayTeamScore AS PF, 
		M.HomeTeamScore AS PA, 
		CASE 
			WHEN M.AwayTeamScore > M.HomeTeamScore THEN 3 
			WHEN M.AwayTeamScore = M.HomeTeamScore THEN 1 
			WHEN M.AwayTeamScore < M.HomeTeamScore THEN 0 
		END AS PTS
	FROM 
		Match AS M 
		INNER JOIN Team AS AT 
			ON M.AwayTeamId = AT.Id 
	WHERE 
		M.AwayTeamScore IS NOT NULL
	),
	
PoolResultsWithPosition (Position, TeamId, Team, PTS) AS
(
SELECT  ROW_NUMBER() OVER (ORDER BY SUM(PF) DESC) AS Position, 
	TeamId, 
	Team,
	SUM(PTS) AS PTS
FROM 
	PoolResults
GROUP BY 
	TeamId, 
	Team
),
PoolResultsWithPositionBreakTie (Position, TeamId, Team, PTS, PreviousTeam, NextTeam, PreviousRank, NextRank) AS
(
SELECT  *,
        LAG(team) OVER (ORDER BY Position) PreviousTeam,
        LEAD(TeamId) OVER (ORDER BY Position) NextTeam,
        LAG(Position) OVER (ORDER BY Position) PreviousRank,
        LEAD(Position) OVER (ORDER BY Position) NextRank
FROM 
	PoolResultsWithPosition B

GROUP BY 
	Position,
	TeamId, 
	Team,
	PTS
Order BY Position
)
SELECT *, CASE 
       WHEN B.Position = B.NextRank and B.TeamId = (
						     Select id from Match M where M.HomeTeamScore > M.AwayTeamScore AND M.homeTeamId = TeamId AND M.awayTeamId = NextTeam
						   ) THEN 1
       WHEN B.Position = B.PreviousRank and B.TeamId = (
						     Select id from Match M where M.HomeTeamScore > M.AwayTeamScore AND M.homeTeamId = NextTeam AND M.awayTeamId = TeamId
						   ) THEN 1
       ELSE 0
    END as breakT
FROM PoolResultsWithPositionBreakTie B
LEFT JOIN Match T 
   ON ( B.TeamId = T.homeTeamId or B.TeamId = T.awayTeamId)
  AND ( cast(B.NextTeam as numeric) = T.homeTeamId or cast(B.NextTeam as numeric) = T.awayTeamId)
ORDER BY 
    Position,
    CASE 
       WHEN B.Position = B.NextRank and B.TeamId = (
						     Select id from Match M where M.HomeTeamScore > M.AwayTeamScore AND M.homeTeamId = TeamId AND M.awayTeamId = NextTeam
						   ) THEN 1
       WHEN B.Position = B.PreviousRank and B.TeamId = (
						     Select id from Match M where M.HomeTeamScore > M.AwayTeamScore AND M.homeTeamId = NextTeam AND M.awayTeamId = TeamId
						   ) THEN 1
       ELSE 0
    END
  
