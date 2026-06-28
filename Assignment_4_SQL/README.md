```mermaid
erDiagram
    subscription ||--o{ users : "has"
    users ||--|| user_settings : "configures"
    users ||--o{ playlists : "creates"
    artists ||--o{ albums : "releases"
    albums ||--o{ songs : "contains"
    playlists ||--o{ playlist_songs : "includes"
    songs ||--o{ playlist_songs : "is in"

    subscription {
        int subscription_id PK
        varchar title
        numeric price
        int device_limit
    }
    users {
        int user_id PK
        varchar username
        varchar email
        int subscription_id FK
        timestamp registration_date
    }
    user_settings {
        int setting_id PK
        int user_id FK
        varchar theme
        varchar app_language
        boolean offline_mode
    }
    artists {
        int artist_id PK
        varchar name
        varchar country
    }
    albums {
        int album_id PK
        int artist_id FK
        varchar title
        date release_date
    }
    songs {
        int song_id PK
        int album_id FK
        varchar title
        int duration_seconds
    }
    playlists {
        int playlist_id PK
        int user_id FK
        varchar title
        timestamp created_at
    }
    playlist_songs {
        int playlist_id PK
        int song_id PK
        timestamp added_at
    }
```


explain analyze

Щоб продемонструвати роботу індексування баз даних, я провела тестування продуктивності на таблиці songs, в яку додала 500 000 записів.

До індексації: 

До створення індексів база даних виконувала повне сканування таблиці. 
Тип сканування: Parallel Seq Scan (Паралельне послідовне сканування).
Час виконання: 21.095 ms

<img width="2644" height="768" alt="image" src="https://github.com/user-attachments/assets/22b40cb7-b714-4ad8-9a97-ec21104215c0" />

Після індексації:

Я додала індекси для всіх зовнішніх ключів. Планувальник запитів використав створений індекс, щоб миттєво знайти точне розташування записів.
Тип сканування: Bitmap Index Scan (Сканування за індексом).
Час виконання: 0.110 ms

<img width="2636" height="736" alt="image" src="https://github.com/user-attachments/assets/852299f5-94c8-47c7-9611-fcf2a52ca720" />


