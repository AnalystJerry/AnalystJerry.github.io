-- For final project
select *
from players
limit 5;

select *
from salaries
limit 5;

select *
from schools
limit 5;

select *
from school_details
limit 5;
-- Part 1
-- a) In each decade, how many schools were there that produced MLB players?
select count(distinct schoolID) as number_of_school, round(yearID, -1) as decade
from schools 
group by decade
order by decade asc;

-- What are the names of the top 5 schools that produced the most players?
select sd.name_full, count(distinct s.playerID) as number_of_players
from schools s left join school_details sd
on s.schoolID=sd.schoolID
group by sd.name_full
order by count(distinct s.playerID) desc
limit 5;
-- For each decade, what were the names of the top 3 schools that produced the most players?

with dws as (select round(s.yearID, -1) as decade, sd.name_full, count(distinct s.playerID) as number_of_players
			from schools s left join school_details sd
			on s.schoolID=sd.schoolID
			group by decade, sd.name_full
			order by decade desc),
	 rn as (select decade, name_full, number_of_players,
			row_number() over (partition by decade order by number_of_players desc) as row_num
			from dws) 
select *
from rn
where row_num < 4;

-- Part 2
-- a) Return the top 20% of teams in terms of average annual spending
with ts as (Select teamID, yearid, sum(salary) as total_spend
			from salaries
			group by teamID, yearid
			order  by teamID, yearid),
	sp as (select teamID, avg(total_spend) as avg_spend,
					NTILE(5) OVER (ORDER BY avg(total_spend) DESC) AS spend_pct
			from ts
			group by teamID)
select teamID, round(avg_spend/1000000,2) as avg_spend_millions
from sp
where spend_pct=1;

-- b) For each team, show the cumulative sum of spending over the years

with ts as (select teamID, YearID, sum(salary) as total_spend
			from salaries
			group by teamID, YearID
			order by teamID, YearID)
select teamID, YearID,
round(sum(total_spend) over (partition by teamID order by YearID)/1000000, 2)as cumulative_sum
from ts;
-- c) Return the first year that each team's cumulative spending surpassed 1 billion
with ts as (select teamID, YearID, sum(salary) as total_spend
			from salaries
			group by teamID, YearID
			order by teamID, YearID),
	sc as	(select teamID, YearID,
			round(sum(total_spend) over (partition by teamID order by YearID)/1000000, 2)as cumulative_sum
			from ts),
	rnum as (select teamID, YearID, cumulative_sum,
			row_number() over (partition by teamID order by cumulative_sum) as rn
			from sc
			where cumulative_sum > 1000)
select teamID, YearID, cumulative_sum
from rnum 
where rn=1 ;

-- a) For each player, calculate their age at their first (debut) game, their last game,
-- and their career length (all in years). Sort from longest career to shortest career.
select nameGiven, 
cast(concat(birthYear, '-', birthMonth, '-', birthDay) as date) as birth_date,
timestampdiff(year, cast(concat(birthYear, '-', birthMonth, '-', birthDay) as date), debut )
as start_age,
timestampdiff(year, cast(concat(birthYear, '-', birthMonth, '-', birthDay) as date), finalGame )
as end_age,
timestampdiff(year, debut, finalGame ) as career_length
from players
order by career_length desc ;

-- b) What team did each player play on for their starting and ending years?

select p.nameGiven, 
s.playerID as starting_year, s.teamID as starting_team,
e.playerID as ending_year, e.teamID as ending_team
from players p inner join salaries s
						on p.playerID=s.playerID
						and year(p.debut) = s.yearID
				inner join salaries e
						on p.playerID=e.playerID
						and year(p.finalGame) = e.yearID;
-- c) How many players started and ended on the same team and also played for over a decade?
select p.nameGiven, 
s.playerID as starting_year, s.teamID as starting_team,
e.playerID as ending_year, e.teamID as ending_team
from players p inner join salaries s
						on p.playerID=s.playerID
						and year(p.debut) = s.yearID
				inner join salaries e
						on p.playerID=e.playerID
						and year(p.finalGame) = e.yearID
where s.teamID=e.teamID 
and e.yearID - s.yearID > 10;
-- a) Which players have the same birthday?
with bn as(select playerID,  cast(concat(birthYear, '-', birthMonth, '-', BirthDay) as date) as birthdate,
			nameGiven
			from players)
select birthdate, group_concat(nameGiven separator ',')
from bn
where year(birthdate) between 1980 and 1990
group by birthdate 
order by birthdate;

-- b) Create a summary table that shows for each team, what percent
-- of players bat right, left and both.
select s.teamID, count(s.playerID) as num_players, 
	round(sum(case when p.bats = 'R' then 1 else 0 end)/count(s.playerID)*100,2) as bats_right,
    round(sum(case when p.bats = 'L' then 1 else 0 end)/count(s.playerID)*100,2) as bats_left,
    round(sum(case when p.bats = 'B' then 1 else 0 end)/count(s.playerID)*100,2) as bats_both
from salaries s left join players p
		on s.playerID= p.playerID
group by s.teamID;

-- c) How have average height and weight at debut game changed over the years,
-- and what's the decade-over-decade difference?

with hw as (select round(year(debut),-1) as decade, avg(height) as avg_height,
		avg(weight) as avg_weight 
		from players
		group by decade)
select decade,
avg_height-lag(avg_height) over (order by decade) as height_diff,
avg_weight - lag(avg_weight) over (order by decade) as weight_diff
from hw
where decade is not null ;