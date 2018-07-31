/*
* What are the movie titles that the user has rated? & Not rated??? 
*/

A = load '/hadoopdata/pig/case_study/movies.csv' using PigStorage(',') as (movieId:long, title:chararray, genre:bytearray);

/*
\d A;

(1,Toy Story (1995),Adventure|Animation|Children|Comedy|Fantasy)
(2,Jumanji (1995),Adventure|Children|Fantasy)
(3,Grumpier Old Men (1995),Comedy|Romance)
(4,Waiting to Exhale (1995),Comedy|Drama|Romance)
(5,Father of the Bride Part II (1995),Comedy)
(6,Heat (1995),Action|Crime|Thriller)
(7,Sabrina (1995),Comedy|Romance)
(8,Tom and Huck (1995),Adventure|Children)
(9,Sudden Death (1995),Action)
(10,GoldenEye (1995),Action|Adventure|Thriller)
(11,House of Horrors (1946),Horror|Mystery|Thriller)
(12,Shadow of the Blair Witch (2000),Horror|Mystery)
(13,The Burkittsville 7 (2000),Horror)
(14,Caged Heat 3000 (1995),Sci-Fi)
(15,Robin Hood (1991),Action|Drama|Romance)
(16,Subdue,Children|Drama)
(17,Century of Birthing (2011),Drama)
(18,Betrayal (2003),Action|Drama|Thriller)
(19,Satan Triumphant (1917),(no genres listed))
(20,Queerama (2017),(no genres listed))
*/

A1 = load '/hadoopdata/pig/case_study/ratings.csv' using PigStorage(',') as (userId:int, movieId:long, rating:double);

/*
\d A1;

(1,13,1.0)
(2,14,4.5)
(1,11,5.0)
(3,12,5.0)
(1,16,5.0)
(4,19,4.0)
(5,14,4.5)
(3,10,5.0)
(6,20,4.0)
(7,1,4.0)
(8,3,4.5)
(8,7,4.0)
(7,8,5.0)
(3,4,3.5)
(5,2,4.5)
(4,18,5.0)
(9,4,5.0)
(9,15,4.5)
(6,17,4.5)
(3,5,2.0)

*/
A2 = group A1 by movieId;

--A2: {group: long,A1: {(userId: int,movieId: long,rating: double)}}

/*
\d A2;


(1,{(7,1,4.0)})
(2,{(5,2,4.5)})
(3,{(8,3,4.5)})
(4,{(9,4,5.0),(3,4,3.5)})
(5,{(3,5,2.0)})
(7,{(8,7,4.0)})
(8,{(7,8,5.0)})
(10,{(3,10,5.0)})
(11,{(1,11,5.0)})
(12,{(3,12,5.0)})
(13,{(1,13,1.0)})
(14,{(5,14,4.5),(2,14,4.5)})
(15,{(9,15,4.5)})
(16,{(1,16,5.0)})
(17,{(6,17,4.5)})
(18,{(4,18,5.0)})
(19,{(4,19,4.0)})
(20,{(6,20,4.0)})

*/

A3 = foreach A2 generate group, COUNT(A1);

/*
\de A3;

A3: {group: long,long}


(1,1)
(2,1)
(3,1)
(4,2) --
(5,1)
(7,1)
(8,1)
(10,1)
(11,1)
(12,1)
(13,1)
(14,2) --
(15,1)
(16,1)
(17,1)
(18,1)
(19,1)
(20,1)

*/

B = join A by movieId, A3 by group;


--\d B;

moviesRated = foreach B generate $1;


-- ******** Fetching only top 10 rows for movies that were rated *******
moviesRated = limit moviesRated 10;


-- ******** Movies that were Rated *******

\d moviesRated;

/*
(Toy Story (1995))
(Jumanji (1995))
(Grumpier Old Men (1995))
(Waiting to Exhale (1995))
(Father of the Bride Part II (1995))
(Sabrina (1995))
(Tom and Huck (1995))
(GoldenEye (1995))
(House of Horrors (1946))
(Shadow of the Blair Witch (2000))
(The Burkittsville 7 (2000))
(Caged Heat 3000 (1995))
(Robin Hood (1991))
(Subdue)
(Century of Birthing (2011))
(Betrayal (2003))
(Satan Triumphant (1917))
(Queerama (2017))
*/



-- ******** Movies that were not Rated *******

C = join A by movieId left outer, A3 by group;

--\C;


D = filter C by $3 is null;

moviesNotRated = foreach D generate $1;

-- ******** Fetching only top 10 rows for movies that were not rated *******
moviesNotRated = limit moviesNotRated 10;

\d moviesNotRated;

/*
(Heat (1995))
(Sudden Death (1995))
*/