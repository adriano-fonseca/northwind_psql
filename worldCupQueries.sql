--http://sqlfiddle.com/#!18/c0701/1

SELECT 
	HT.id AS id, 
        HT.name AS "Home Team", 
        M.hometeamscore AS "home Team Score", 
        M.awayteamscore AS "away Team Score", 
        HT.name AS "away Team"
FROM 
		Match AS M 
		INNER JOIN Team AS HT 
			ON M.homeTeamId = HT.id 
		INNER JOIN Team AS AT 
			ON M.awayTeamId = AT.id;

WITH RawPoolResults ([MatchId], [TeamId], [Team], [P], [W], [D], [L], [PF], [PA], [PD], [TF], [TA], [TD], [PTS], [BP]) 
AS (SELECT 
		M.[Id] AS [MatchId], 
		M.[HomeTeamId] AS [TeamId], 
		HT.[Name] AS [Team], 
		1 AS [P], 
		CASE WHEN M.[HomeTeamScore] > M.[AwayTeamScore] THEN 1 ELSE 0 END AS [W], 
		CASE WHEN M.[HomeTeamScore] = M.[AwayTeamScore] THEN 1 ELSE 0 END AS [D], 
		CASE WHEN M.[HomeTeamScore] < M.[AwayTeamScore] THEN 1 ELSE 0 END AS [L], 
		M.[HomeTeamScore] AS [PF], 
		M.[AwayTeamScore] AS [PA], 
		(M.[HomeTeamScore] - M.[AwayTeamScore]) AS [PD], 
		M.[HomeTeamTries] AS [TF], 
		M.[AwayTeamTries] AS [TA], 
		(M.[HomeTeamTries] - M.[AwayTeamTries]) AS [TD], 
		CASE 
			WHEN M.[HomeTeamScore] > M.[AwayTeamScore] THEN 4 
			WHEN M.[HomeTeamScore] = M.[AwayTeamScore] THEN 2 
			WHEN M.[HomeTeamScore] < M.[AwayTeamScore] THEN 0 
		END AS [PTS], 
		CASE 
			WHEN ((M.[AwayTeamScore] - M.[HomeTeamScore]) BETWEEN 1 AND 7) AND M.[HomeTeamTries] >= 4 THEN 2 
			WHEN ((M.[AwayTeamScore] - M.[HomeTeamScore]) BETWEEN 1 AND 7) THEN 1 
			WHEN M.[HomeTeamTries] >= 4 THEN 1 
			ELSE 0 
		END AS [BP] 
	FROM 
		Match AS M 
		INNER JOIN Team AS HT 
			ON M.[HomeTeamId] = HT.[Id] 
	WHERE 
		M.[HomeTeamScore] IS NOT NULL

	UNION 

	SELECT 
		M.[Id] AS [MatchId], 
		M.[AwayTeamId] AS [TeamId], 
		AT.[Name] AS [Team], 
		1 AS [P], 
		CASE WHEN M.[AwayTeamScore] > M.[HomeTeamScore] THEN 1 ELSE 0 END AS [W], 
		CASE WHEN M.[AwayTeamScore] = M.[HomeTeamScore] THEN 1 ELSE 0 END AS [D], 
		CASE WHEN M.[AwayTeamScore] < M.[HomeTeamScore] THEN 1 ELSE 0 END AS [L], 
		M.[AwayTeamScore] AS [PF], 
		M.[HomeTeamScore] AS [PA], 
		(M.[AwayTeamScore] - M.[HomeTeamScore]) AS [PD], 
		M.[AwayTeamTries] AS [TF], 
		M.[HomeTeamTries] AS [TA], 
		(M.[AwayTeamTries] - M.[HomeTeamTries]) AS [TD], 
		CASE 
			WHEN M.[AwayTeamScore] > M.[HomeTeamScore] THEN 4 
			WHEN M.[AwayTeamScore] = M.[HomeTeamScore] THEN 2 
			WHEN M.[AwayTeamScore] < M.[HomeTeamScore] THEN 0 
		END AS [PTS], 
		CASE 
			WHEN ((M.[HomeTeamScore] - M.[AwayTeamScore]) BETWEEN 1 AND 7) AND M.[AwayTeamTries] >= 4 THEN 2 
			WHEN ((M.[HomeTeamScore] - M.[AwayTeamScore]) BETWEEN 1 AND 7) THEN 1 
			WHEN M.[AwayTeamTries] >= 4 THEN 1 
			ELSE 0 
		END AS [BP] 
	FROM 
		Match AS M 
		INNER JOIN Team AS AT 
			ON M.[AwayTeamId] = AT.[Id] 
	WHERE 
		M.[AwayTeamScore] IS NOT NULL
	)

SELECT 
	[TeamId], 
	[Team], 
	SUM([P]) AS [P], 
	SUM([W]) AS [W], 
	SUM([D]) AS [D], 
	SUM([L]) AS [L], 
	SUM([PF]) AS [PF], 
	SUM([PA]) AS [PA], 
	SUM([PD]) AS [PD], 
	SUM([TF]) AS [TF], 
	SUM([TA]) AS [TA], 
	SUM([BP]) AS [BP], 
	SUM([BP] + [PTS]) AS [PTS] 
FROM 
	RawPoolResults 
GROUP BY 
	[TeamId], 
	[Team];

WITH PoolResults ([MatchId], [TeamId], [Team], [P], [W], [D], [L], [PF], [PA], [PD], [TF], [TA], [TD], [PTS], [BP]) 
AS (SELECT 
		M.[Id] AS [MatchId], 
		M.[HomeTeamId] AS [TeamId], 
		HT.[Name] AS [Team], 
		1 AS [P], 
		CASE WHEN M.[HomeTeamScore] > M.[AwayTeamScore] THEN 1 ELSE 0 END AS [W], 
		CASE WHEN M.[HomeTeamScore] = M.[AwayTeamScore] THEN 1 ELSE 0 END AS [D], 
		CASE WHEN M.[HomeTeamScore] < M.[AwayTeamScore] THEN 1 ELSE 0 END AS [L], 
		M.[HomeTeamScore] AS [PF], 
		M.[AwayTeamScore] AS [PA], 
		(M.[HomeTeamScore] - M.[AwayTeamScore]) AS [PD], 
		M.[HomeTeamTries] AS [TF], 
		M.[AwayTeamTries] AS [TA], 
		(M.[HomeTeamTries] - M.[AwayTeamTries]) AS [TD], 
		CASE 
			WHEN M.[HomeTeamScore] > M.[AwayTeamScore] THEN 4 
			WHEN M.[HomeTeamScore] = M.[AwayTeamScore] THEN 2 
			WHEN M.[HomeTeamScore] < M.[AwayTeamScore] THEN 0 
		END AS [PTS], 
		CASE 
			WHEN ((M.[AwayTeamScore] - M.[HomeTeamScore]) BETWEEN 1 AND 7) AND M.[HomeTeamTries] >= 4 THEN 2 
			WHEN ((M.[AwayTeamScore] - M.[HomeTeamScore]) BETWEEN 1 AND 7) THEN 1 
			WHEN M.[HomeTeamTries] >= 4 THEN 1 
			ELSE 0 
		END AS [BP] 
	FROM 
		Match AS M 
		INNER JOIN Team AS HT 
			ON M.[HomeTeamId] = HT.[Id] 
	WHERE 
		M.[HomeTeamScore] IS NOT NULL

	UNION 

	SELECT 
		M.[Id] AS [MatchId], 
		M.[AwayTeamId] AS [TeamId], 
		AT.[Name] AS [Team], 
		1 AS [P], 
		CASE WHEN M.[AwayTeamScore] > M.[HomeTeamScore] THEN 1 ELSE 0 END AS [W], 
		CASE WHEN M.[AwayTeamScore] = M.[HomeTeamScore] THEN 1 ELSE 0 END AS [D], 
		CASE WHEN M.[AwayTeamScore] < M.[HomeTeamScore] THEN 1 ELSE 0 END AS [L], 
		M.[AwayTeamScore] AS [PF], 
		M.[HomeTeamScore] AS [PA], 
		(M.[AwayTeamScore] - M.[HomeTeamScore]) AS [PD], 
		M.[AwayTeamTries] AS [TF], 
		M.[HomeTeamTries] AS [TA], 
		(M.[AwayTeamTries] - M.[HomeTeamTries]) AS [TD], 
		CASE 
			WHEN M.[AwayTeamScore] > M.[HomeTeamScore] THEN 4 
			WHEN M.[AwayTeamScore] = M.[HomeTeamScore] THEN 2 
			WHEN M.[AwayTeamScore] < M.[HomeTeamScore] THEN 0 
		END AS [PTS], 
		CASE 
			WHEN ((M.[HomeTeamScore] - M.[AwayTeamScore]) BETWEEN 1 AND 7) AND M.[AwayTeamTries] >= 4 THEN 2 
			WHEN ((M.[HomeTeamScore] - M.[AwayTeamScore]) BETWEEN 1 AND 7) THEN 1 
			WHEN M.[AwayTeamTries] >= 4 THEN 1 
			ELSE 0 
		END AS [BP] 
	FROM 
		Match AS M 
		INNER JOIN Team AS AT 
			ON M.[AwayTeamId] = AT.[Id] 
	WHERE 
		M.[AwayTeamScore] IS NOT NULL
	)

SELECT ROW_NUMBER() OVER (ORDER BY SUM([BP] + [PTS]) DESC) AS [Position], 
	[TeamId], 
	[Team], 
	SUM([P]) AS [P], 
	SUM([W]) AS [W], 
	SUM([D]) AS [D], 
	SUM([L]) AS [L], 
	SUM([PF]) AS [PF], 
	SUM([PA]) AS [PA], 
	SUM([PD]) AS [PD], 
	SUM([TF]) AS [TF], 
	SUM([TA]) AS [TA], 
	SUM([BP]) AS [BP], 
	SUM([BP] + [PTS]) AS [PTS] 
FROM 
	PoolResults 
GROUP BY 
	[TeamId], 
	[Team];
