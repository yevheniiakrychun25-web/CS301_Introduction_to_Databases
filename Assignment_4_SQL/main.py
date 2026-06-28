import psycopg2
from faker import Faker
import random

fake = Faker()


def generate_data():
    # Повернули правильну назву твоєї бази!
    conn = psycopg2.connect(
        dbname="assignment_4",
        user="postgres",
        password="487148714871",
        host="localhost"
    )
    cur = conn.cursor()

    try:
        print("Очищуємо старі дані та скидаємо лічильники ID...")
        cur.execute("TRUNCATE TABLE subscription, artists, users, albums, songs, playlists RESTART IDENTITY CASCADE;")

        print("Генеруємо підписки...")
        subs = [('Free', 0.0, 1), ('Basic', 5.99, 2), ('Premium', 12.99, 5)]
        cur.executemany("INSERT INTO subscription (title, price, device_limit) VALUES (%s, %s, %s)", subs)

        print("Генеруємо артистів...")
        artists = [(fake.name(), fake.country()) for _ in range(10000)]
        cur.executemany("INSERT INTO artists (name, country) VALUES (%s, %s)", artists)

        print("Генеруємо користувачів...")
        users = [(fake.user_name(), fake.unique.email(), random.randint(1, 3)) for _ in range(50000)]
        cur.executemany("INSERT INTO users (username, email, subscription_id) VALUES (%s, %s, %s)", users)

        print("Генеруємо альбоми...")
        albums = [(fake.sentence(nb_words=2), fake.date_this_decade(), random.randint(1, 10000)) for _ in range(50000)]
        cur.executemany("INSERT INTO albums (title, release_date, artist_id) VALUES (%s, %s, %s)", albums)

        print("Генеруємо пісні (це займе трохи часу)...")
        songs = [(fake.sentence(nb_words=3), random.randint(120, 300), random.randint(1, 50000)) for _ in range(500000)]
        cur.executemany("INSERT INTO songs (title, duration_seconds, album_id) VALUES (%s, %s, %s)", songs)

        print("Генеруємо плейлисти...")
        playlists = [(random.randint(1, 200), fake.sentence(nb_words=2)) for _ in range(50)]
        cur.executemany("INSERT INTO playlists (user_id, title) VALUES (%s, %s)", playlists)

        print("Генеруємо зв'язки (пісні в плейлистах)...")
        ps = set()
        while len(ps) < 300:
            ps.add((random.randint(1, 50), random.randint(1, 500)))
        cur.executemany("INSERT INTO playlist_songs (playlist_id, song_id) VALUES (%s, %s) ON CONFLICT DO NOTHING",
                        list(ps))

        conn.commit()
        print("✅ Успіх! Усі 8 таблиць успішно заповнені зв'язаними даними.")

    except Exception as e:
        conn.rollback()
        print(f"❌ Сталася помилка: {e}")

    finally:
        cur.close()
        conn.close()


if __name__ == "__main__":
    generate_data()