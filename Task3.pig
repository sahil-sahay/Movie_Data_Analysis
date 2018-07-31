/*
* What is the average rating given for a movie?
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


A3 = foreach A2 generate group, A1.rating;

/*
\de A3;

A3: {group: long,{(rating: double)}}

\d A3;

(1,{(4.0)})
(2,{(4.5)})
(3,{(4.5)})
(4,{(5.0),(3.5)})   --4.25 should be Average
(5,{(2.0)})
(7,{(4.0)})
(8,{(5.0)})
(10,{(5.0)})
(11,{(5.0)})
(12,{(5.0)})
(13,{(1.0)})
(14,{(4.5),(4.5)})   --4.5 should be Average
(15,{(4.5)})
(16,{(5.0)})
(17,{(4.5)})
(18,{(5.0)})
(19,{(4.0)})
(20,{(4.0)})
*/


A3 = foreach A2 generate group, AVG(A1.rating);

/*
\de A3;

A3: {group: long,double}

\d A3;

(1,4.0)
(2,4.5)
(3,4.5)
(4,4.25)
(5,2.0)
(7,4.0)
(8,5.0)
(10,5.0)
(11,5.0)
(12,5.0)
(13,1.0)
(14,4.5)
(15,4.5)
(16,5.0)
(17,4.5)
(18,5.0)
(19,4.0)
(20,4.0)
*/

B = join A by movieId, A3 by group;

/*
\de B;

B: {A::movieId: long,A::title: chararray,A::genre: bytearray,A3::group: long,double}
*/


/*
\d B;

(1,Toy Story (1995),Adventure|Animation|Children|Comedy|Fantasy,1,4.0)
(2,Jumanji (1995),Adventure|Children|Fantasy,2,4.5)
(3,Grumpier Old Men (1995),Comedy|Romance,3,4.5)
(4,Waiting to Exhale (1995),Comedy|Drama|Romance,4,4.25)
(5,Father of the Bride Part II (1995),Comedy,5,2.0)
(7,Sabrina (1995),Comedy|Romance,7,4.0)
(8,Tom and Huck (1995),Adventure|Children,8,5.0)
(10,GoldenEye (1995),Action|Adventure|Thriller,10,5.0)
(11,House of Horrors (1946),Horror|Mystery|Thriller,11,5.0)
(12,Shadow of the Blair Witch (2000),Horror|Mystery,12,5.0)
(13,The Burkittsville 7 (2000),Horror,13,1.0)
(14,Caged Heat 3000 (1995),Sci-Fi,14,4.5)
(15,Robin Hood (1991),Action|Drama|Romance,15,4.5)
(16,Subdue,Children|Drama,16,5.0)
(17,Century of Birthing (2011),Drama,17,4.5)
(18,Betrayal (2003),Action|Drama|Thriller,18,5.0)
(19,Satan Triumphant (1917),(no genres listed),19,4.0)
(20,Queerama (2017),(no genres listed),20,4.0)
*/

ratingAvg = foreach B generate $1,$4;

/*
\de ratingAvg;

ratingAvg: {A::title: chararray,double}
*/

-- ******** Since it's a larger Dataset. Fetching only top 10 rows for count of movie ratings. *******
ratingAvg = limit ratingAvg 10;


\d ratingAvg;

/*
Output
(Toy Story (1995),4.0)
(Jumanji (1995),4.5)
(Grumpier Old Men (1995),4.5)
(Waiting to Exhale (1995),4.25)
(Father of the Bride Part II (1995),2.0)
(Sabrina (1995),4.0)
(Tom and Huck (1995),5.0)
(GoldenEye (1995),5.0)
(House of Horrors (1946),5.0)
(Shadow of the Blair Witch (2000),5.0)
(The Burkittsville 7 (2000),1.0)
(Caged Heat 3000 (1995),4.5)
(Robin Hood (1991),4.5)
(Subdue,5.0)
(Century of Birthing (2011),4.5)
(Betrayal (2003),5.0)
(Satan Triumphant (1917),4.0)
(Queerama (2017),4.0)
*/