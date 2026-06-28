create table subscription(
	subscription_id serial primary key,
	title varchar(100) not null,
	price numeric(10, 2) not null,
	device_limit int not null
);

create table users(
	user_id serial primary key,
	username varchar(100) not null,
	email varchar(150) unique not null,
	subscription_id int references  subscription(subscription_id) on delete set null,
	registration_date timestamp default current_timestamp
);

create table user_settings(
	setting_id serial primary key,
	user_id int unique references users(user_id) on delete cascade,
	theme varchar(50) default 'dark',
	app_language varchar(50) default 'en',
	offline_mode boolean default false
);

create table artists(
	artist_id serial primary key,
	name varchar(100) not null,
	country varchar(100)
);

create table albums(
	album_id serial primary key,
	artist_id int references artists(artist_id) on delete cascade,
	title varchar(150) not null,
	release_date date
);

create table songs(
	song_id serial primary key,
	album_id int references albums(album_id) on delete cascade,
	title varchar(150) not null,
	duration_seconds int not null check (duration_seconds > 0)
);

create table playlists(
	playlist_id serial primary key,
	user_id int references users(user_id) on delete cascade,
	title varchar(150) not null,
	created_at timestamp default current_timestamp
);

create table playlist_songs(
	playlist_id int references playlists(playlist_id) on delete cascade,
	song_id int references songs(song_id) on delete cascade,
	added_at timestamp default current_timestamp,
	primary key (playlist_id, song_id)
);

create user app_admin
with password 'admin123';
grant all privileges on all tables
in schema public to app_admin;

create user app_analyst
with password 'analyst123';
grant select on all tables
in schema public to app_analyst;

create user app_client
with password 'client123';
grant select, insert, update, delete on all tables
in schema public to app_client;

create view active_user_view as
select u.user_id,
	u.username,
	u.email,
	s.title,
	s.price
from users u 
left join subscription s 
on u.subscription_id = s.subscription_id;

create or replace procedure change_user_subscription(p_user_id int, p_new_sub_id int)
language plpgsql
as $$
begin
	update users
	set subscription_id = p_new_sub_id
	where user_id = p_user_id;
end;
$$;

create or replace function create_default_settings()
returns trigger as $$
begin
	insert into user_settings(user_id) values
	(new.user_id);
	return new;
end;
$$
language plpgsql;

create trigger trigger_new_user_settings
after insert on users
for each row
execute function create_default_settings();

insert into subscription(title, price, device_limit) values
('Free', 0.00, 1),
('Premium', 9.99, 5);

insert into users(username, email, subscription_id) values 
('test_girl', 'test@example.com', 1);

select *
from user_settings;

select *
from active_user_view;

call change_user_subscription(1, 2);

select *
from users;

create index idx_songs_album_id on songs(album_id);
create index idx_albums_artist_id on albums(artist_id);
create index idx_playlists_user_id on playlists(user_id);
create index idx_playlist_songs_song_id on playlist_songs(song_id);

explain analyze
select *
from songs
where album_id = 4500;
