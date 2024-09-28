use IPL
drop table if exists ipls;

create table ipls 
(
id	float,
inning	float,
overr	float,
ball	float,
batsman	nvarchar(255),
non_striker	nvarchar(255),
bowler	nvarchar(255),
batsman_runs	float,
extra_runs	float,
total_runs	float,
non_boundary	float,
is_wicket	float,
dismissal_kind	nvarchar(255),
player_dismissed	nvarchar(255),
fielder	nvarchar(255),
extras_type	nvarchar(255),
batting_team	nvarchar(255),
bowling_team nvarchar(255)
)

insert into ipls
select * from ipl1
union
select * from ipl2
union
select * from ipl3
union
select * from ipl4;

select count(*) from ipls;
select count(*) from ipl1;
select count(*) from ipl2;
select count(*) from ipl3;
select count(*) from ipl4;

select * from ipls
Select * from ipl

--- 1. matches per season
Select sum(matches) matches_per_season, year from
(select count(distinct id) matches, year(date) year from ipl
group by date) a
group by year

--- 2. most man of the matches

Select top 1 count(player_of_match) count_of_mom, player_of_match from ipl
group by player_of_match
order by count_of_mom desc

-- most mom year wise rank

select * from
(select player_of_match,yr,mom,rank() over(partition by yr order by mom desc) rnk from
(
select player_of_match,year(date) yr,count(player_of_match) mom from ipl 
group by player_of_match,year(date) 
)a)b where rnk = 1

-- most wins by any team rank them in ascending order

Select no_of_wins, winner, rank() over(order by no_of_wins desc) rnk from
(Select count(winner) no_of_wins, winner from Ipl group by winner
) a 

--- top 5 venues where matches are played
select Top 5 venues_count, venue, rank () over(order by venues_count desc) rnk from 
(Select count(venue) venues_count, venue from Ipl
group by venue) a

--- most runs by any batsman
Select top 1 batsman, rank () over (order by batsman_run desc) rnk from
(
Select batsman, sum(batsman_runs) batsman_run from ipls
group by batsman) a 

--- total runs scored in Ipl
Select sum(total_runs) total_runs from ipls

--- % of total runs scored by each batsman (recheck)
select batsman, batsman_run, sum(total_run) from
(Select batsman, sum(batsman_runs) batsman_run, sum(total_runs) total_run from ipls
group by batsman) a

--- most sixes by any cricketer
Select Top 1 batsman, most_sixes, rank() over (order by most_sixes desc) rnk from
(Select batsman, count(batsman_runs) most_sixes from ipls 
where batsman_runs = 6 group by batsman)a

--- most fours by any cricketer
Select top 1 batsman, count(batsman_runs) most_fours from ipls 
where batsman_runs = 4 group by batsman order by most_fours desc

--- cricketers having more than or equal to 3000 runs
Select * from 
(Select batsman, sum(batsman_runs) total_batsman_runs from ipls 
group by batsman) a where total_batsman_runs > 3000 order by total_batsman_runs desc

--- highest strike rate (no of runs per ball by the batsman)
Select batsman,round((batsman_run/balls)*100,2) strike_rate from 
(Select Batsman, sum(batsman_runs) batsman_run, count(ball) balls from ipls
group by batsman)a
order by strike_rate desc

--- lowest economy rate of the bowler who has bowled atleast 50 overs
Select * from ipls

select top 1 bowler,(total_runs_conceded/(total_balls*1.0)) economy_rate from
(select bowler,count(bowler) total_balls,sum(total_runs) total_runs_conceded
from ipls
group by bowler)a
where total_balls>300
order by (total_runs_conceded/(total_balls*1.0))

-- total number of matches till 2020
Select count(count_matches) no_of_matches from
(Select year(date)count_matches from ipl ) a where count_matches < = 2020

--- total number of matches win by each team till date
Select winner, count(winner) matches_win from ipl group by winner order by matches_win desc

--- does toss winning affects match winning (chances of winning are more when toss is won)

select count(prediction) count_of_match ,prediction from
(Select winner, toss_winner, case when winner = toss_winner then 1 else 0 end as prediction from ipl)a 
group by prediction

-- Avg score of each team in all season
Select winner, Round((total_runs_per_team/no_of_season),2) avg_score from (
Select winner, sum(runs) total_runs_per_team, sum(matches_per_season) no_of_season from  
(
Select count(distinct season) matches_per_season, season, winner, sum(total_runs) runs from 
(Select a.id, year(a.date) season, a.winner, b.total_runs from ipl a inner join ipls b on a.id = b.id )c group by season , winner) 
d group by winner) e group by winner, total_runs_per_team, no_of_season


--- how many times each team scored 200+ runs 
Select winner, runs, season from 
(Select id, winner, sum(total_runs) runs, season from 
(Select a.id, year(a.date) season, a.winner, b.total_runs from ipl a 
inner join ipls b on a.id = b.id )c group by id, winner, season )d where runs> 200


--- most title wins(check)
Select season, team_wins, winner, rank() over(order by team_wins desc) rnk from
(Select season, sum(pp) team_wins, winner from
(Select year(date) season, winner, count(winner) pp from ipl group by date, winner) a 
group by season, winner order by season asc) b 


--- top 10 players with most runs
Select top 10 batsman, runs , rank () over(order by runs desc) rnk from 
(Select batsman, Sum(batsman_runs) runs from ipls group by batsman) a

--- top 10 best performances/ mom 
Select top 10 player_of_match, mom, rank() over(order by mom desc) rnk from
(Select player_of_match, count(player_of_match) mom from ipl group by player_of_match) a

--- top 10 bowlers till 2020
Select top 10 bowler, no_ from
(Select count(bowler) no_, bowler, line from
(Select a.player_of_match, b.bowler, case when player_of_match = bowler then 1 else 0 end as line 
from ipl a inner join ipls b on a.id =b.id)c where line = 1 group by bowler, line)d order by no_ desc

--- top 10 bowling performance till 2020 (check)
Select top 10 bowler, round((runs/overs_count),2) economy_rate, rank() over (order by round((runs/overs_count),2) asc) rnk from 
(Select bowler, sum(total_runs) runs, count(distinct overr) overs_count from ipls 
group by bowler)a

--- count of matches played in each season
Select season, sum(count_of_season) season_count from
(Select year(date) season, count(year(date)) count_of_season from ipl group by date)a group by season

--- how many runs were scored in each season
Select season, sum(total_runs) runs from
(select a.id, year(a.date) season, b.total_runs from ipl a inner join ipls b on a.id = b.id ) 
c group by season order by season

--- what were the runs scored per match in different season on an avg ?
Select season, round((runs_per_season/no_of_matches),2) runs_per_match from 
(Select season, sum(total_runs) runs_per_season, count(distinct date) no_of_matches from 
(select a.id, year(a.date) season, a.date, b.total_runs from ipl a inner join ipls b on a.id = b.id)c 
group by season)d

--- who has umpired the most 
select umpire1,umpire2 from ipl 

--- which team has won most of the tosses?
Select toss_winner, count(toss_winner) count_toss from ipl group by toss_winner order by count_toss desc

--- what does the team has decided max after winning the toss?(fielding)
Select toss_decision, count(toss_decision) from ipl group by toss_decision

--- how many times chasing team (fielding team) have won the meatches
Select sum(output_count), toss_decision from
(Select winner, count(toss_decision) output_count, toss_decision  from ipl
group by toss_decision, winner)a 
group by toss_decision

--- which all team has won the IPL (check)
Select max(date) final_match, season from
(Select date, year(date) season, winner from Ipl) a group by season order by season asc

Select count(winner), winner,  max(date), year(date) season from ipl group by year(date) order by year(date) asc
Select * from ipl where year(date) = 2008


--- Is there a lucky venue for any particular team (yes) 
Select max(venue_count) ma, venue, winner from
(Select venue ,count(venue) venue_count, winner from ipl group by venue, winner)
a group by winner, venue order by ma desc

--- highest run scored by a team in single match
Select top 1 batting_team, sum(total_runs) mm, date from
(Select a.id, a.batting_team,a.total_runs , b.date from ipls a 
inner join ipl b on a.id = b.id) c group by date, batting_team order by mm desc

--- Biggest win in terms of run margins

Select top 1 winner,result, result_margin from ipl
where result = 'runs'
order by result_margin desc

--- which batsman has played most number of balls
Select top 1 batsman, sum(ball_count) balls_played from
(Select Batsman, count(ball) ball_count from ipls group by batsman, ball)a group by batsman
order by balls_played desc 

--- highest strike rate
Select Top 1 batsman, round(((runs/ball_count)*100),2) strike_rate from 
(Select batsman, count(ball) ball_count, sum(total_runs) runs from ipls
group by batsman)a order by strike_rate desc


--- leading wicket taker in every season or purple cap winner (recheck)

Select season, player_of_match, count(player_of_match) pp from
(Select season, player_of_match, bowler from
(Select a.id, year(a.date) season, a.player_of_match, b.bowler from 
ipl a inner join ipls b on a.id = b.id)c where player_of_match=bowler)d 
group by season, player_of_match order by season asc, pp desc



--- leading wicket taker of all time
Select top 1 player_of_match, count(player_of_match) pp from
(Select season, player_of_match, bowler from
(Select a.id, year(a.date) season, a.player_of_match, b.bowler from 
ipl a inner join ipls b on a.id = b.id)c where player_of_match=bowler)d 
group by player_of_match order by pp desc

--- Which stadium has hosted most number of matches??
Select top 1 venue, count(venue) venue_count from ipl group by venue order by venue_count desc

--- count of fours in every season
select sum(fours) no_of_fours, season from
(Select count(a.total_runs) fours, year(b.date) season from ipls a inner join ipl b on a.id =b.id 
where total_runs = 4 group by total_runs, date) c group by season order by season asc

-- count of sixes in every season
select sum(sixes) sixes, season from
(Select count(a.total_runs) sixes, year(b.date) season from ipls a inner join ipl b on a.id =b.id 
where total_runs = 6 group by total_runs, date) c group by season order by season asc

--- what is the count of runs scored from boundaries in each season 
Select * from ipl
Select * from ipls
Select season, sum(pp) boundary_runs from 
(
Select year(a.date) season, sum(b.batsman_runs) pp from ipl a inner join ipls b on a.id = b.id
where batsman_runs in(4,6) group by date) c group by season order by season

--- Powerplay avg runs per season
Select season, round(avg(powerplay_runs),2) Avg_powerplay_runs from (
Select year(a.date) season, count(b.batsman_runs) powerplay_runs from ipl a inner join ipls b on a.id = b.id
where overr between 0 and 6 group by date)c group by season
 
Select Round(avg(runs_per_match),2) powerplay_runs, season from 
(Select date, sum(runs_per_over) runs_per_match, year(date) season from
(Select a.date , b.overr, sum(b.batsman_runs) runs_per_over from ipl a inner join ipls b on a.id = b.id
where overr in (0,1,2,3,4,5,6) group by date, overr) c group by date)
d group by season order by season

--- Powerplay avg dismissals
Select season, round(avg(wickets_in_powerplay),0) wickets_in_powerplay_per_season from 
(Select year(date) season, sum(wickets) wickets_in_powerplay from
(Select a.date , b.overr, sum(is_wicket) wickets from ipl a inner join ipls b on a.id = b.id
where overr in (0,1,2,3,4,5,6) group by date, overr)c group by date) d group by season


--- Highest average overall

Select batsman, Case when dismisals=0 then null Else round((runs/dismisals),2) End from
(Select batsman, sum(batsman_runs) runs, sum(is_wicket) dismisals from ipls  group by batsman)a 


--- orange cap holders of each season

Select * from(
Select *, rank() over (partition by season order by Orange_cap_winners desc) As rnk from
(Select batsman, sum(runs) Orange_cap_winners, season from
(Select a.batsman, sum(a.batsman_runs) runs, year(b.date) season from ipls a inner join 
ipl b on a.id = b.id group by batsman,date) c group by batsman,season ) e)d where rnk = 1

--- purple cap winner of each season
Select * from
(Select*, rank() over(partition by season order by wickets_per_season desc) as rnk from 
(Select bowler, season, sum(wickets) wickets_per_season from
(Select year(b.date) season, a.bowler, sum(a.is_wicket) wickets from ipls a inner join ipl b on a.id = b.id
group by bowler, date) c group by bowler,season)d)e where rnk = 1

--- which team has the highest no of win in seasons (check)

Select max(date) final_match, season, winner from
(Select date, year(date) season, winner from Ipl group by winner,date) a group by season order by season asc, winner asc


--- which team has scored highest number of runs in last four overs/ rank them

Select top 1 sum(total_runs) total_runs_in_last_four_overs,batting_team from 
(Select overr, total_runs, batting_team from ipls where overr in (16,17,18,19) )a group by batting_team order by total_runs_in_last_four_overs desc

Select * from 
(Select *, rank() over(order by total_runs_in_last_four_overs desc) rnk from
(Select sum(total_runs) total_runs_in_last_four_overs,batting_team from  
(Select overr, total_runs, batting_team from ipls where overr in (16,17,18,19) ) a group by batting_team) b) c 

--- which team has the best scoring run rate in first 6 overs?

Select *, rank() over(order by run_rate desc) as rnk from 
(Select batting_team, round(Avg(total_runs_in_six_overs/total_matches),2) run_rate from 
(select batting_team, sum(runs) total_runs_in_six_overs, count(day_match) total_matches from 
(Select a.batting_team, sum(a.total_runs) runs, count(b.date)/count(overr) as day_match , year(date) season from ipls a inner join ipl b on a.id =b.id 
where overr in (0,1,2,3,4,5)group by batting_team, date) c group by batting_team, day_match) d group by batting_team) e 

---- percentage wins of each team


--- Ipl season winners list 

---- which team has won how many times 

Select winner, sum(wins) from
(Select winner, count(winner) wins from ipl group by winner)a group by wins


Select * from ipl