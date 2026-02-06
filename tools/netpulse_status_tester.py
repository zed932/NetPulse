"""
Небольшая утилита на Python для тестирования NetPulse:
- читает список пользователей из Firebase Realtime Database;
- позволяет изменить статус и/или кастомный статус.

Перед использованием:
- включи Realtime Database в Firebase;
- временно открой правила (для локального теста) или добавь auth;
- пропиши DATABASE_URL ниже.
"""

import json
import uuid
from dataclasses import dataclass

import requests

# TODO: подставь URL своей базы:
# пример: "https://your-project-id-default-rtdb.europe-west1.firebasedatabase.app"
DATABASE_URL = ""


@dataclass
class User:
    id: uuid.UUID
    name: str
    email: str
    username: str
    status: str
    customStatus: str | None


def fetch_users() -> list[User]:
    resp = requests.get(f"{DATABASE_URL}/users.json")
    resp.raise_for_status()
    data = resp.json() or {}
    users: list[User] = []
    for _, raw in data.items():
        try:
            users.append(
                User(
                    id=uuid.UUID(raw["id"]),
                    name=raw["name"],
                    email=raw["email"],
                    username=raw.get("username", ""),
                    status=raw.get("status", "online"),
                    customStatus=raw.get("customStatus"),
                )
            )
        except Exception:
            continue
    return users


def update_user_status(user: User, status: str | None = None, custom_status: str | None = None):
    payload = {
        "id": str(user.id),
        "name": user.name,
        "email": user.email,
        "username": user.username,
        "status": status or user.status,
        "customStatus": custom_status,
    }
    resp = requests.put(f"{DATABASE_URL}/users/{user.id}.json", data=json.dumps(payload))
    resp.raise_for_status()


def main():
    if not DATABASE_URL:
        print("Заполни DATABASE_URL в netpulse_status_tester.py")
        return

    users = fetch_users()
    print("Пользователи в Firebase:")
    for i, u in enumerate(users, start=1):
        print(f"{i}. {u.name} (@{u.username}) — {u.status} / {u.customStatus or '-'}")

    idx = int(input("Кому поменять статус (номер)? ")) - 1
    user = users[idx]

    print("Новый статус (online/offline/working/studying), Enter чтобы не менять:")
    new_status = input("> ").strip() or None

    print("Новый кастомный статус (пусто чтобы удалить):")
    new_custom = input("> ").strip()
    if new_custom == "":
        new_custom = None

    update_user_status(user, status=new_status, custom_status=new_custom)
    print("Готово. Нажми 'Обновить' в приложении NetPulse, чтобы увидеть изменения.")


if __name__ == "__main__":
    main()

