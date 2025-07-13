<<<<<<< HEAD
# emoaid

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
=======
# EmoAid

EmoAid: AI-Powered Mental Health Companion
An end-to-end AI mental wellness app offering mood tracking, analytics, and emotionally intelligent chat support.
Video Demo: https://www.canva.com/design/DAGr89_7iQA/pX36wVYqNUnQWHPJnKr4pA/edit

# Overview
EmoAid is an AI-powered mental health mobile application designed to support emotional well-being through intelligent mood tracking, reflective analytics, and personalized conversational assistance. Built using cutting-edge NLP and Retrieval-Augmented Generation (RAG), the app delivers safe, scalable mental health tools directly to users’ smartphones.

# Key Features
Mood Tracker: Capture and log daily mood entries with time-stamped records and personal notes.

Emotional Analytics: Visualize trends through interactive graphs, emotion frequency charts, and mood progression timelines.

AI Chat Companion: Empathetic LLM-powered assistant built using cosine similarity and custom embeddings to retrieve personalized, context-aware responses.

RAG Integration: Contextual document retrieval pipeline using sentence embeddings and FAISS to ground responses in reliable resources from more than 25+ clinical research papers. Based on mood, generates RAG-based breathing exercises, affirmations, and meditations.

Cloud-Connected: Firebase backend integration for secure data sync and real-time updates.

Mobile Deployment: Flutter-based Android app with smooth UI and minimal latency across interactions.

# Technical Stack
Layer	Technology
Frontend	Flutter, Dart
Backend	Firebase Firestore, Firebase Auth
AI Pipeline	SentenceTransformers, FAISS, Python
NLP Model	LLM (custom embedding pipeline with cosine similarity)
Analytics	Matplotlib, Pandas (visualized in-app)
Deployment	Android APK (Google Play upcoming), Hugging Face for AI logic demo

# RAG & LLM Integration
Custom retrieval pipeline:

Tokenizes user input → converts to embeddings via all-MiniLM-L6-v2

Runs FAISS similarity search on pre-embedded emotional support documents

Returns top-k results passed into LLM for grounded response

Ensures high contextual relevance and safe interaction boundaries

# Analytics Dashboard
Emotion Radar: Weekly radar plots of top emotional states

Mood Timeline: Visual representation of highs/lows over time

Category Frequency: Insights on most recurring thought/emotion categories

All analytics update in real-time post mood entry submission

## Data & Privacy
Firebase Authentication for secure login

Firestore rules configured for per-user data access

Offline-first architecture with sync-on-connect fallback
>>>>>>> cd98969eac168e93973c314d7f6468ce97f5c0d3
