-- creating schema and table, using not exists to avoid possible duplication errors

create schema if not exists netflix;



create table if not exists netflix.titles (
    id text primary key,
    title text not null,
    type text check (type in ('MOVIE','SHOW')),
    description text,
    release_year int check (release_year > 1900),
    age_certification text,
    runtime int check (runtime >= 0),
    imdb_id text,
    imdb_score numeric(3,1) check (imdb_score between 0 and 10),
    imdb_votes int check (imdb_votes >= 0)
);

-- standardizing type

update netflix.titles
set "type" = upper(trim("type"))
where "type" is not null and "type" <> upper(trim("type"));


-- turning empty age_certification into NULLs, votes where age_cert is null into 0

update netflix.titles
set age_certification = null
where nullif(trim(age_certification),'') is null
  and age_certification is not null;

update netflix.titles
set imdb_votes = 0
where imdb_votes is null;



-- quick data overview

select count(*) as total_rows from netflix.titles;
select count(*) as rows_with_score from netflix.titles where imdb_score is not null;
select age_certification , count(*) as rows_per_cert
from netflix.titles
group by age_certification 
order by rows_per_cert desc nulls last;


-- displaying top 10 with more than 10k votes (most popular by score and number of votes)


select title, age_certification as age_cert, imdb_score, imdb_votes
from netflix.titles
where imdb_score is not null and imdb_votes >= 10000
order by imdb_score desc, imdb_votes desc nulls last, title asc
limit 10;

-- average score, median votes and title count by age certification

select
  age_certification as age_cert,
  round(avg(imdb_score)::numeric, 2) as avg_score,
  percentile_cont(0.5) within group (order by imdb_votes) as median_votes,
  count(*) as titles
from netflix.titles
where imdb_score is not null and age_certification is not null
group by age_cert 
order by avg_score desc;


-- ratings by decade

select
  (release_year/10)*10 as decade,
  round(avg(imdb_score)::numeric, 2) as avg_score,
  count(*) as titles
from netflix.titles
where imdb_score is not null
group by (release_year/10)*10
order by decade;


-- top 5 in each age certification group

select age_certification, id, title, "type", imdb_score, imdb_votes
from (
  select
    age_certification,
    id, title, "type", imdb_score, imdb_votes,
    row_number() over (
      partition by age_certification
      order by imdb_score desc, imdb_votes desc nulls last, title asc
    ) as rn
  from netflix.titles
  where imdb_score is not null and age_certification is not null
) s
where rn <= 5
order by age_certification, rn;

-- creating a view for top 5 per age certification

create or replace view netflix.view_top5_per_cert as
select age_certification, id, title, "type", imdb_score, imdb_votes
from (
  select
    age_certification, id, title, "type", imdb_score, imdb_votes,
    row_number() over (
      partition by age_certification
      order by imdb_score desc, imdb_votes desc nulls last, title asc
    ) as rn
  from netflix.titles
  where imdb_score is not null and age_certification is not null
) s
where rn <= 5;

select * from netflix.view_top5_per_cert order by age_certification, imdb_score desc;
