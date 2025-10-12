# Study Planner App (Flutter)

*Author:* Josue BYIRINGIRO  
*Email:* j.byiringir@alustudent.com  
*Assignment:* Individual_Assignment_1
*Device Tested On:* Android Emulator (VS Code) & Google Pixel 4a  
*GitHub Repository:* (https://github.com/jbyiringiro/study-planner-app)  
*Demo Video (10 mins):* (https://drive.google.com/file/d/1Ry4u6AoAWzNoza3SfgSsa9YHQOvoz5pS/view?usp=drive_link)
                        (https://youtu.be/ACCsQOId3PA)


## Project Overview

The *Study Planner App* is a Flutter mobile application that helps users plan and manage their study tasks efficiently.  
It allows users to *create, view, edit, and delete tasks, view them in a **calendar, receive **reminder notifications, and store all data **locally using SQLite*.  

The project fulfills all assignment requirements:
- Multi-screen navigation using a BottomNavigationBar  
- Persistent data using SQLite and SharedPreferences  
- Reminder system (simulated via in-app popups)  
- Material Design-compliant UI  
- Functional on both *Android emulator(Pixel 4a)* 


## Core Features

### 1.  Task Management
- Add tasks with:
  - *Title (required)*
  - *Description (optional)*
  - *Due Date (required)*
  - *Reminder Time (optional)*
- Edit and delete existing tasks  
- View today’s tasks and all scheduled tasks  
- Smooth and reactive UI built with Provider state management  

### 2.  Calendar View
- Displays a *monthly calendar* 
- Dates with tasks are visually *highlighted*  wwith *red* dot on the top
- Tapping on a date filters and displays the related tasks  

### 3.  Reminder System
- Users can set an optional reminder time for each task  
- Simulated alert (popup) appears when the app opens and the reminder time is reached  
- Controlled through a toggle in *Settings*  

### 4.  Local Storage
- Tasks stored persistently using *SQLite* (sqflite + path)  
- Settings (e.g., reminder toggle) saved using *SharedPreferences*  
- Data remains intact even after the app restarts  

### 5.  Settings Screen
- Toggle switch to enable/disable reminders  
- Shows about the app 

### 6.  Navigation and Screens
Implemented using a *BottomNavigationBar* with three screens:
- *Today* → Lists all tasks due today  
- *Calendar* → Displays monthly calendar with highlights  
- *Settings* → Controls reminders and app preferences  

### 7.  Non-Functional Requirements
- Clean and responsive *Material Design* UI  
- Consistent layout on *portrait and landscape* orientations  
- Reliable data persistence and smooth performance  


##  Project Structure

```
The app is organized into multiple directories for clarity and modularity:

lib/
├── models/
│ └── task.dart # Defines the Task data model
├── providers/
│ └── task_provider.dart # State management with ChangeNotifier
├── services/
│ ├── storage_service.dart # SQLite database initialization and CRUD logic
│ └── notification_service.dart # Reminder checking and alerts
├── screens/
│ ├── main_screen.dart # Contains BottomNavigationBar and screen switching
│ ├── today_screen.dart # Displays tasks due today
│ ├── calendar_screen.dart # Calendar view of all tasks
│ ├── task_form_screen.dart # Add/Edit task form
│ └── settings_screen.dart # App settings and reminder toggle
├── widgets/
│ ├── task_list.dart # Custom reusable task list component
│ └── calendar_widget.dart # Calendar display widget
└── main.dart # Entry point; initializes DB & Provider, runs app
```

###  main.dart Overview
  
- Wraps app in MultiProvider to manage global state  
- Defines MaterialApp with title, theme, and MainScreen() as home  
- Acts as the *central link* between UI, providers, and local storage  

##  Dependencies

| Package | Purpose |
|----------|----------|
| *sqflite* | Local database storage |
| *path* | File path provider for SQLite |
| *provider* | State management |
| *shared_preferences* | Persistent app settings |
| *uuid* | Generates unique IDs for tasks |
| *table_calendar* | Monthly calendar view |

Install packages:
```bash
flutter pub get
 How to Run the App
Clone the Repository
bash
Copy code
git clone https://github.com/jbyiringiro/study-planner-app
cd study-planner-app
flutter pub get
Run on Android Emulator
bash
Copy code
flutter devices               # Verify emulator ID
flutter run -d emulator-5554  # Replace with your emulator ID
Run on Pixel 4a (Physical Device)
bash
Copy code
flutter devices # Verify device ID
flutter run -d <pixel-id>
```

## Testing and Validation

Test Case - Expected Result	Status
### 1. Add new task	- Task saved and visible immediately	
### 2. Edit/Delete task	- Updates reflected instantly	
### 3. Calendar highlights	- Days with tasks are bold or colored	
### 4. Reminder popup	- Appears when app opens at reminder time	
### 5. App restart	- Tasks persist after closing app	
### 6. Settings toggle	- State saved and restored	
### 7. Orientation	- UI remains consistent	


## Future Improvements

- Real background notifications using flutter_local_notifications
- Task categories and filtering by subject or priority
- Search bar for tasks
- Dark mode theme

## Author Notes

This app demonstrates full Flutter app development workflow, from UI and state management to local persistence and navigation.
It was tested on both emulator(Pixel 4a).
Last but not least it was made for study purpose