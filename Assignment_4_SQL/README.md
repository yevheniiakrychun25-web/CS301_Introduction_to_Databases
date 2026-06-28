\`\`\`mermaid  
erDiagram  
    subscription ||--o{ users : "has"  
    users ||--|| user\_settings : "configures"  
    users ||--o{ playlists : "creates"  
    artists ||--o{ albums : "releases"  
    albums ||--o{ songs : "contains"  
    playlists ||--o{ playlist\_songs : "includes"  
    songs ||--o{ playlist\_songs : "is in"

    subscription {  
        int subscription\_id PK  
        varchar title  
        numeric price  
        int device\_limit  
    }  
    users {  
        int user\_id PK  
        varchar username  
        varchar email  
        int subscription\_id FK  
        timestamp registration\_date  
    }  
    user\_settings {  
        int setting\_id PK  
        int user\_id FK  
        varchar theme  
        varchar app\_language  
        boolean offline\_mode  
    }  
    artists {  
        int artist\_id PK  
        varchar name  
        varchar country  
    }  
    albums {  
        int album\_id PK  
        int artist\_id FK  
        varchar title  
        date release\_date  
    }  
    songs {  
        int song\_id PK  
        int album\_id FK  
        varchar title  
        int duration\_seconds  
    }  
    playlists {  
        int playlist\_id PK  
        int user\_id FK  
        varchar title  
        timestamp created\_at  
    }  
    playlist\_songs {  
        int playlist\_id PK  
        int song\_id PK  
        timestamp added\_at  
    }  
\`\`\`  
