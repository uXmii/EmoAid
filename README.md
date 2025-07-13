
=======
# EmoAid

**AI-Powered Mental Health Companion**

EmoAid is an end-to-end mobile application for mental wellness that combines mood tracking, emotional analytics, and intelligent conversational support powered by large language models (LLMs) and Retrieval-Augmented Generation (RAG).

> **Note:** For deployment readiness and source code privacy, critical files such as `ai_service.dart` and Firebase initialization logic have been redacted. Full functionality is demonstrated in the following video:  
**Video Demo:** (https://www.canva.com/design/DAGr89_7iQA/pX36wVYqNUnQWHPJnKr4pA/edit)

---

##  Overview

EmoAid delivers AI-driven emotional support through a cross-platform Flutter app, integrating real-time mood tracking with personalized LLM-backed responses. The app leverages a custom RAG pipeline and secure Firebase backend to provide scalable and low-latency mental health assistance.

---

##  Key Features

- **Mood Tracking**: Log emotional states with timestamps and reflections.
- **Emotional Analytics**: Visualize mood progression, emotion frequency, and historical trends.
- **AI Chat Companion**: LLM-based chatbot enhanced with cosine similarity and user-specific embeddings for tailored responses.
- **RAG Integration**: Retrieves and grounds responses using FAISS and `sentence-transformers` across 25+ curated clinical psychology documents.
- **Deployment**: Flutter-based Android build optimized for low memory footprint and sub-300ms interactions also web app available as well.
- **Cloud Sync**: Firebase Firestore and Firebase Auth enable secure login and real-time data synchronization.

---

##  Technical Stack

| Layer         | Technologies |
|--------------|--------------|
| Frontend     | Flutter, Dart |
| Backend      | Flask, Firebase Firestore, Firebase Auth |
| AI Pipeline  | Python, SentenceTransformers, FAISS |
| NLP Layer    | LLM with custom cosine similarity embedding retriever |
| Analytics    | Pandas, Matplotlib (integrated within app) |
| Deployment   | Android APK (Play Store pending), Hugging Face demo backend |

---

## RAG + LLM Pipeline

1. Tokenize user input
2. Generate embeddings (`all-MiniLM-L6-v2`)
3. Retrieve top-k documents via FAISS vector search
4. Pass retrieved context + query into LLM for grounded, emotionally intelligent response
5. Output tailored exercises (e.g., affirmations, meditations) based on mood class

---

##  Analytics Dashboard

- **Emotion Radar**: Weekly visualizations of dominant emotional categories
- **Mood Timeline**: Tracks emotional trends over time
- **Category Frequency**: Highlights recurrent emotional patterns
- **Auto-update**: Dashboard refreshes dynamically with each mood entry

---
## Snapshots

<img width="1537" height="775" alt="Screenshot 2025-06-25 131756" src="https://github.com/user-attachments/assets/05a2bf2e-1fd6-4755-b77c-93cc60f3b768" />

<img width="1892" height="880" alt="Screenshot 2025-06-25 131904" src="https://github.com/user-attachments/assets/13148a0a-009c-46be-b108-bceffc8bb76c" />

<img width="1901" height="868" alt="Screenshot 2025-06-25 132131" src="https://github.com/user-attachments/assets/ecc4d8bd-38d6-4d9f-825b-2ee1d8263ff6" />
<img width="1904" height="870" alt="Screenshot 2025-06-25 132421" src="https://github.com/user-attachments/assets/5c0575df-aae6-4ff4-9d8a-6608911c975e" />

<img width="1868" height="866" alt="Screenshot 2025-06-25 133707" src="https://github.com/user-attachments/assets/f4c0ac64-5c87-40f0-9489-867787f6a30e" />
<img width="1912" height="851" alt="Screenshot 2025-06-25 133724" src="https://github.com/user-attachments/assets/1df4af4a-0a00-49c8-bd06-f279292c99b6" />
<img width="1909" height="882" alt="Screenshot 2025-06-25 133305" src="https://github.com/user-attachments/assets/bab5a68d-77c8-4049-97e7-bc1bc74a4a2d" />





##  Privacy & Security

- Secure authentication via Firebase Auth
- Per-user data isolation using Firestore security rules
- Offline-first architecture with queued sync on reconnection

>>>>>>> cd98969eac168e93973c314d7f6468ce97f5c0d3
