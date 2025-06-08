# Savitri Project

This project is a mental wellness companion application.

## Project Structure

### `savitri_app`

The Flutter mobile application.

#### `lib/main.dart`
- The entry point for the Flutter application. It sets up the material app and defines the initial route.

#### `lib/screens`
- `welcome_screen.dart`: The initial screen that welcomes the user and provides a "Get Started" button to navigate to the benefits screen.
- `benefits_screen.dart`: This screen outlines the benefits of using the application and navigates to the consent screen.
- `consent_screen.dart`: A screen that displays a consent form which the user must scroll through and agree to before proceeding to the login screen.
- `login_screen.dart`: Handles user login with email and password, and navigates to the MFA screen on success.
- `mfa_screen.dart`: Handles two-factor authentication for the user and navigates to the settings screen on success.
- `settings_screen.dart`: A placeholder screen for application settings.

#### `lib/services`
- `auth_service.dart`: Provides authentication services for login, registration, and MFA verification by making API calls to the backend.
- `enhanced_therapeutic_voice_service.dart`: Manages microphone permissions and audio recording functionality.

#### `lib/widgets`
- `breathing_guide.dart`: A widget that provides a visual guide for 4-7-8 breathing exercises using an animated circle.
- `crisis_banner.dart`: A banner that is displayed to the user if a crisis is detected, providing a number to call for support.
- `emotion_indicator.dart`: A widget that displays the user's emotional state (calm, neutral, distressed) as a colored circle.
- `therapeutic_button.dart`: A reusable, styled button for use throughout the application.
- `therapeutic_visual_3d.dart`: A widget that displays a 3D visualization that changes color based on the user's emotional state.

### `live-audio`

The frontend for the live audio visualization, built with Lit, TypeScript, and Three.js.

- `index.tsx`: The main entry point for the live audio visualization. It handles audio input and output, connects to the Gemini AI for live interaction, and renders the 3D visualization.
- `analyser.ts`: A class that analyzes audio data from an `AudioNode` to extract frequency data for visualization.
- `backdrop-shader.ts`: GLSL shaders for creating a gradient with noise for the scene's background.
- `sphere-shader.ts`: A GLSL vertex shader that deforms a sphere based on live audio data from the user and the AI.
- `utils.ts`: Utility functions for encoding `Float32Array` audio data to base64 `Int16Array` and decoding it back.
- `visual-3d.ts`: A LitElement that sets up and manages the 3D scene using Three.js for the audio visualization. It includes a sphere that deforms and a camera that moves based on audio input.
- `visual.ts`: A LitElement that creates a 2D visualization of audio data using a canvas, displaying the audio as gradient bars.
- `vite.config.ts`: The Vite configuration file, which sets up environment variables and path aliases.

### `backend`

The backend server for the application, built with Node.js and TypeScript.

#### `clinical`
- `crisis-detector.ts`: Detects crisis situations based on keywords in user input text and the user's emotional state.
- `enhanced-emotion-analyzer.ts`: A placeholder for a service that would analyze emotional state from audio features using a machine learning model.
- `therapeutic-engine.ts`: Generates therapeutic responses based on user input and emotional state. It will provide a crisis response if a crisis is detected.
- `types.ts`: Defines the TypeScript types and interfaces used throughout the clinical components of the backend.

#### `persistence`
- `db.ts`: Handles the connection to the MongoDB database using Mongoose.
- `models/User.ts`: Mongoose schema for the `User` model, which includes the user's email and a reference to their sessions.
- `models/Session.ts`: Mongoose schema for the `Session` model, which includes a reference to the user, start and end times, and a list of interactions.
- `models/Interaction.ts`: Mongoose schema for the `Interaction` model, which represents a single turn in a conversation and includes the user's input, emotional state, and the therapeutic response.
