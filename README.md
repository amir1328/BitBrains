# BitBrains - AI & DS Department Platform

This project is a full-stack application for the AI & DS Department, featuring a Python FastAPI backend and a Flutter frontend.

## Prerequisites

-   **Docker Desktop**: Required for the PostgreSQL database with `pgvector`.
-   **Python 3.10+**: For the backend.
-   **Flutter SDK**: For the frontend.
-   **PostgreSQL Client** (Optional): For inspecting the database.

---

## 🚀 How to Run

### 1. Start the Database (Docker)

The database is containerized to ensure the `pgvector` extension is available.

1.  Open a terminal in the project root (where `docker-compose.yml` is).
2.  Run the database container:
    ```bash
    docker-compose up -d db
    ```
3.  *First time only*: The database will be initialized automatically.

### 2. Start the Backend (FastAPI)

1.  Navigate to the backend directory:
    ```bash
    cd backend
    ```
2.  (Optional) Create and activate a virtual environment:
    ```bash
    python -m venv venv
    # Windows:
    .\venv\Scripts\activate
    # Mac/Linux:
    source venv/bin/activate
    ```
3.  Install dependencies:
    ```bash
    pip install -r requirements.txt
    ```
4.  Run the server:
    ```bash
    uvicorn app.main:app --reload
    ```
    -   The API will be available at `http://127.0.0.1:8000`.
    -   Docs: `http://127.0.0.1:8000/docs`.

### 3. Start the Frontend (Flutter)

1.  Navigate to the frontend directory:
    ```bash
    cd frontend
    ```
2.  Get dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the app:
    -   **For Web (Chrome):**
        ```bash
        flutter run -d chrome
        ```
    -   **For Android Emulator:**
        ```bash
        flutter run -d emulator-id
        ```

---

## 🛠️ Configuration

-   **Environment Variables**: Backend settings are in `backend/.env`.
-   **API URL**: Checks `kIsWeb` to switch between `127.0.0.1` (Web) and `10.0.2.2` (Android).
-   **Database Port**: Docker maps PostgreSQL to port `5435` to avoid conflicts with local installations.

## 🐛 Common Issues & Fixes

-   **Backend Crash/Bcrypt Error**: A patch is included in `app/utils.py` to fix `passlib` compatibility.
-   **Gemini API Rate Limit (429)**: The chat API handles this gracefully. Wait ~1 minute if you see an error.
-   **WebSocket Connection**: Ensure you use `flutter run -d chrome` for Web testing. The backend `app.main.py` has a permissive CORS regex for development.
