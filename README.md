
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
<img width="540" height="1060" alt="Screenshot 2025-07-02 100916" src="https://github.com/user-attachments/assets/4b791869-ccda-47b0-8929-fd3d1164c205" />
<img width="564" height="1045" alt="Screenshot 2025-07-02 101031" src="https://github.com/user-attachments/assets/6c989311-79e1-4e9d-b38d-7e1ea5405aad" />
<img width="529" height="1061" alt="Screenshot 2025-07-02 101312" src="https://github.com/user-attachments/assets/da7c5dad-fa6f-43e4-b7f2-5a5fd21f5710" />
<img width="524" height="797" alt="Screenshot 2025-07-02 101337" src="https://github.com/user-attachments/assets/9d7f9e94-a7d6-4714-87d9-fa56b6a66c39" />
<img width="531" height="1053" alt="Screenshot 2025-07-02 101159" src="https://github.com/user-attachments/assets/5e640cdc-98d4-4b10-a167-4342fc4c7256" />
<img width="230" height="421" alt="image" src="https://github.com/user-attachments/assets/219a4336-2b50-4adb-b208-eb589e6bb6e2" />
<img width="222" height="430" alt="image" src="https://github.com/user-attachments/assets/77b53af5-b360-4289-969c-de1ec0bb3460" />
<img width="216" height="401" alt="image" src="https://github.com/user-attachments/assets/d9c61710-a2e0-488c-b023-75e9f6e49f75" />
<img width="205" height="420" alt="image" src="https://github.com/user-attachments/assets/40ea6871-dd3c-4422-a5d3-f2360b6d39ba" />
<img width="216" height="416" alt="image" src="https://github.com/user-attachments/assets/12f520bc-945f-472c-92b6-04f4943cb521" />



##  Privacy & Security

- Secure authentication via Firebase Auth
- Per-user data isolation using Firestore security rules
- Offline-first architecture with queued sync on reconnection

>>>>>>> cd98969eac168e93973c314d7f6468ce97f5c0d3
