# UdyamBoost – From Local Business to Online Brand

**UdyamBoost** is an AI-powered digital platform designed to help small and local businesses establish and grow their online presence.

The application aims to simplify digital marketing by providing business profile management, product catalogue management, AI-generated marketing content, promotional poster creation, and basic engagement analytics.

Our mission is to empower local entrepreneurs with accessible digital tools to promote their businesses and reach more customers.

---

## Project Overview

Many small businesses have limited access to professional digital marketing tools. They often struggle to create promotional content, manage product information, and establish an online presence.

UdyamBoost aims to solve these challenges through a simple and user-friendly mobile application.

## Key Features

- **Business Profile Management** – Create and manage business information and brand identity.
- **Product Catalogue** – Add, edit, delete, and manage products with images and prices.
- **AI Content Generation** – Generate product descriptions, social media captions, and hashtags.
- **Marketing Poster Creator** – Create promotional posters for business products.
- **WhatsApp Marketing** – Prepare promotional messages for sharing.
- **Engagement Analytics** – Track basic marketing engagement and business performance.

*Note: Some features are under development or planned for future releases.*

---

## Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Mobile application development |
| Dart | Programming language |
| Supabase | Backend services |
| PostgreSQL | Database |
| Supabase Auth | User authentication |
| Supabase Storage | Image and file storage |
| AI API | AI-powered content generation |
| Git & GitHub | Version control and collaboration |
| VS Code | Development environment |

---

## Project Structure

```text
udyamboost/
│
├── android/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── services/
│   │   └── ...
│   │
│   ├── features/
│   │   ├── auth/
│   │   ├── onboarding/
│   │   ├── dashboard/
│   │   ├── products/
│   │   ├── ai_marketing/
│   │   ├── poster_creator/
│   │   └── analytics/
│   │
│   └── main.dart
│
├── test/
├── web/
├── windows/
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
├── .gitignore
└── README.md
```

---

## Getting Started

### Prerequisites

Install the following tools:

- Flutter SDK
- Dart SDK
- Git
- Visual Studio Code
- GitHub account

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/udyamboost.git
```

### 2. Navigate to the Project

```bash
cd udyamboost
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Configure Supabase

Create a Supabase project and configure the project URL and publishable key in:

```text
lib/core/constants/supabase_config.dart
```

Use your own Supabase project credentials.

Make sure the required database tables, Row Level Security (RLS) policies, and storage bucket are configured.

Never include Supabase secret keys, service-role keys, or private AI API keys in the Flutter application.

### 5. Run the Application

Check connected devices:

```bash
flutter devices
```

Run the application:

```bash
flutter run
```

### 6. Analyze the Project

```bash
flutter analyze
```

---

## Database

UdyamBoost uses Supabase PostgreSQL.

### Main Tables

**business_profiles**

Stores business information such as:

- Business name
- Owner name
- Business category
- Phone number
- Location
- Description
- Logo URL
- Brand colours
- Social media links

**products**

Stores product information such as:

- Product name
- Description
- Category
- Price
- Product image URL
- Business ID

---

## Team GrowthForge

| Team Member | Responsibility |
|---|---|
| Arun | Team Lead, Architecture, Backend, Supabase and AI Integration |
| Aliya | UI/UX Design, Authentication, Onboarding and Dashboard |
| Deeksha | Business Profile, Product Management and Image Upload |
| Hithesh | AI Marketing and Poster Creator |

---

## Git Branching Strategy

We follow a feature-branch workflow to support team collaboration.

| Branch | Purpose |
|---|---|
| `main` | Stable project version |
| `develop` | Integration and development |
| `feature/arun-backend` | Backend and architecture |
| `feature/aliya-ui` | UI/UX and authentication |
| `feature/deeksha-products` | Business profile and product management |
| `feature/hithesh-ai` | AI marketing and poster creator |

### Contribution Workflow

1. Clone the repository.
2. Switch to your assigned feature branch.
3. Pull the latest changes.
4. Implement your assigned feature.
5. Commit and push your changes.
6. Create a Pull Request targeting `develop`.
7. Get the changes reviewed and tested before merging.

Example:

```bash
git switch feature/aliya-ui
git pull origin feature/aliya-ui

git add .
git commit -m "Improve onboarding UI"

git push origin feature/aliya-ui
```

---

## Project Goals

- Make digital marketing accessible to small businesses.
- Simplify product and business management.
- Use AI to reduce the effort required to create marketing content.
- Help local entrepreneurs establish an online presence.
- Provide an affordable and user-friendly digital business platform.

---

## Future Enhancements

- Advanced business analytics.
- More AI-powered marketing tools.
- Additional poster templates.
- Social media integrations.
- Subscription and premium plans.
- Expanded platform support.

---

## Project Information

**Project Name:** UdyamBoost  
**Tagline:** From Local Business to Online Brand  
**Team:** GrowthForge  
**Platform:** Android Mobile Application  
**Development Framework:** Flutter  
**Backend:** Supabase

---

## License

This project is currently developed as an academic/team project. Licensing terms can be added when the team decides on an appropriate open-source or proprietary license.

---

**Built with ❤️ by Team GrowthForge**
