create table Cinemas (
    Cinema_ID SERIAL primary key,
    Cinema_Name varchar(100) not null,
    City varchar(50) not null
);

create table Halls (
    Hall_ID SERIAL primary key,
    Cinema_ID int,
    Hall_Name varchar(50) not null,
    Capacity int,
    foreign key (Cinema_ID) references Cinemas(Cinema_ID)
);

create table Movies (
    Movie_ID SERIAL primary key,
    Title varchar(150) not null,
    Genre varchar(50) not null,
    Duration int not null 
);

create table Showtimes (
    Showtime_ID SERIAL primary key,
    Movie_ID int,
    Hall_ID int,
    Showtime_Date date not null,
    Base_Price decimal(10, 2) not null,
    foreign key (Movie_ID) references Movies(Movie_ID),
    foreign key (Hall_ID) references Halls(Hall_ID)
);

create table Tickets (
    Ticket_ID SERIAL primary key,
    Showtime_ID int,
    Seat_Number int not null,
    Final_Price decimal(10, 2) not null,
    foreign key (Showtime_ID) references Showtimes(Showtime_ID)
);

create table ArchivedTickets (
    Ticket_ID int primary key,
    Showtime_ID int,
    Seat_Number int not null,
    Final_Price decimal(10, 2) not null
);

insert into Cinemas (Cinema_Name, City) values
('Multiplex Premium', 'Kyiv'),
('Planeta Kino', 'Lviv'),
('Cinema Citi', 'Odesa'),
('Multiplex Dafi', 'Dnipro'),
('French Boulevard', 'Kharkiv');

insert into Halls (Cinema_ID, Hall_Name, Capacity) values
(1, 'IMAX Hall', 200), (1, 'Chillin Hall', 50),
(2, '4DX Hall', 120),  (2, 'Cinetech+', 90),
(3, 'Laser Hall', 180),
(4, 'Standard 1', 100), (4, 'VIP', 30),
(5, 'IMAX Laser', 250);

insert into Movies (Title, Genre, Duration) values
('Inception', 'Sci-Fi', 148),
('The Dark Knight', 'Action', 152),
('Interstellar', 'Sci-Fi', 169),
('The Hangover', 'Comedy', 100),
('Avatar: 3', 'Fantasy', 192),
('The Conjuring', 'Horror', 112),
('Toy Story 5', 'Animation', 105),
('Dune: Part Three', 'Sci-Fi', 166),
('Gladiator 2', 'Action', 150),
('Deadpool 3', 'Comedy', 120);

insert into Showtimes (Movie_ID, Hall_ID, Showtime_Date, Base_Price) values
(1, 1, '2026-09-26', 250.00), (8, 1, '2026-09-27', 300.00),
(4, 2, '2026-09-28', 150.00), (10, 2, '2026-09-29', 200.00),
(2, 3, '2026-10-01', 220.00), (9, 4, '2026-10-02', 240.00),
(6, 3, '2026-10-03', 180.00),
(5, 5, '2026-09-25', 200.00), (7, 5, '2026-09-30', 160.00),
(8, 6, '2026-10-05', 180.00), (2, 7, '2026-10-06', 400.00),
(9, 8, '2026-10-10', 250.00), (10, 8, '2026-10-11', 220.00);

insert into Tickets (Showtime_ID, Seat_Number, Final_Price) values
(1, 45, 250.00), (1, 46, 250.00), (2, 10, 300.00), (2, 11, 300.00),
(3, 5, 150.00), (4, 12, 200.00), (4, 13, 200.00),
(5, 88, 220.00), (6, 40, 240.00), (6, 41, 240.00),
(7, 15, 180.00), (7, 16, 180.00),
(8, 10, 200.00), (8, 11, 200.00), (9, 20, 160.00),
(10, 50, 180.00), (11, 1, 400.00), (11, 2, 400.00),
(12, 100, 250.00), (12, 101, 250.00), (13, 55, 220.00);

insert into ArchivedTickets (Ticket_ID, Showtime_ID, Seat_Number, Final_Price) values
(1001, 1, 10, 250.00), (1002, 2, 5, 300.00),
(1003, 5, 6, 220.00), (1004, 6, 7, 240.00),
(1005, 8, 8, 200.00), (1006, 11, 3, 400.00),
(1007, 12, 50, 250.00), (1008, 13, 10, 220.00);

with AllTickets as (
	select ShowTime_ID,
	Final_Price
	from Tickets
	union all
	select ShowTime_ID, Final_Price
	from ArchivedTickets
)
select c.City,
	c.Cinema_Name,
	m.Genre,
	count(t.Showtime_ID) as Total_Ticket_Sold,
	sum(t.Final_Price) as Total_Revenue,
	rank() over(partition by c.City order by sum(t.Final_Price) desc) as Rank_In_City,
	case 
		when sum(t.Final_Price) >= 500 then 'popular'
		when sum(t.Final_Price) < 500 and sum(t.Final_Price) > 300 then 'medium'
		when sum(t.Final_Price) <= 300 then 'unpopular'
	end as Popularity_Rate
from AllTickets t
left join Showtimes s 
on t.Showtime_ID = s.Showtime_ID
left join Movies m
on s.Movie_ID = m.Movie_ID
left join Halls h
on s.Hall_ID = h.Hall_ID
left join Cinemas c
on h.Cinema_ID = c.Cinema_ID
where s.Showtime_Date >= '2026-09-25' and t.Final_Price >= s.Base_Price
group by c.City, c.Cinema_Name, m.Genre
having sum(t.Final_Price) > 200
order by Total_Revenue desc, Total_Ticket_Sold desc