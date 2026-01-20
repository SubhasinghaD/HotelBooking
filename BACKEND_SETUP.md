# Hotel Booking App - Backend Setup Guide

## Prerequisites
1. Node.js installed (v14+)
2. Stripe account with API keys
3. Firebase project with service account

## Setup Steps

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Configure Environment Variables
Edit `backend/.env` and add:
- Your Stripe secret key (starts with `sk_test_...` or `sk_live_...`)
- Path to Firebase service account JSON file

### 3. Get Firebase Service Account
1. Go to Firebase Console: https://console.firebase.google.com
2. Select your project: hotelbookingapp-ebb89
3. Go to Project Settings > Service Accounts
4. Click "Generate New Private Key"
5. Save the JSON file as `backend/service-account.json`

### 4. Start the Backend Server
```bash
cd backend
npm start
```

The server will run on http://localhost:8080

## Current Configuration
- **Firebase Project ID**: hotelbookingapp-ebb89
- **Google Maps API Key**: AIzaSyCNMN2GKLscQUJ4C68pCruzM6pAGoSkRdA
- **Stripe Publishable Key**: pk_test_51SrXRwQFHx4VIZZKke4WpollAo8cC5ukCN1jHVHlLktgtYvDtuWV9CqTfhPlC7ZeMGiXAwfDdgpKHf7aA3HCsGA400fNW70Rrz

## Testing Without Backend
The app can run without the backend for browsing hotels, adding favorites, and simulating bookings. Stripe payment functionality requires the backend to be running.
