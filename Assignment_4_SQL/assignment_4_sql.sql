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