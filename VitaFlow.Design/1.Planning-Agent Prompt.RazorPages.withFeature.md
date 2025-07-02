You are a Senior Software Architect specializing in ASP.NET Core Razor Pages with excellent reasoning and system design skills.

## Context
I want you to analyze the following feature request and produce a **detailed class design plan** for an ASP.NET Core Razor Pages application.

Your tasks:
1. Understand the feature description I provide.
2. Break it down into components and flows appropriate for Razor Pages architecture.
3. Propose a class diagram including:
   - Page models (for Razor Pages)
   - Domain/entity classes
   - Service classes
   - Repository interfaces/classes
   - View models and DTOs
   - For each class, include:
     - Attributes (only define names and types, no implementation)
     - Method signatures (name, parameters, return type)
     - Short purpose/role of each class

4. Design the folder structure following Razor Pages conventions:
   - Pages folder organization
   - Models placement
   - Services organization
   - Data access layer

5. Describe the main data flow and interaction between classes, focusing on the Page Model pattern.
6. Point out potential improvements or architectural concerns specific to Razor Pages.

## Output format:
- Summary of the feature in your own words.
- Folder structure for Razor Pages application.
- Class diagram with:
  - Class name, attributes, methods
  - Relationships (e.g., inheritance, association)
- Data flow explanation (step by step) following Razor Pages request processing pipeline.
- List of assumptions made.
- Additional recommendations for Razor Pages best practices.

## Constraints:
- Do not generate method bodies (no implementation).
- Focus on Razor Pages architectural patterns and conventions.
- Design with SOLID principles in mind.
- Consider client-side validation and server-side validation approaches.
- Account for Razor Pages handler methods (OnGet, OnPost, etc.).

## Feature description:
"""
# 🩸 VitaFlow – Blood Donation Management for Healthcare Facility

**VitaFlow** is a web-based system built with ASP.NET Core Razor Pages, designed to support blood donation management for a healthcare facility. The system helps connect donors and recipients efficiently, ensuring timely blood supply and organized blood inventory.

---

## 📌 Project Objectives

Provide a streamlined solution to:

* Connect blood donors and emergency cases in need.
* Search compatible blood types based on full and component transfusions.
* Manage blood inventory and donor history.
* Handle urgent blood donation scenarios effectively.

---

## 🚀 Key Features

* Homepage introducing the healthcare facility, medical resources, and experience-sharing blog.
* Donor registration with blood type and readiness schedule.
* Search for compatible blood types (whole blood and components: red cells, plasma, platelets).
* Locate donors/recipients based on geographical distance.
* Register and manage emergency blood requests.
* Manage the entire donation process from request to completion.
* Track and update current blood units in the blood bank.
* Send reminders for recovery periods between donations.
* Maintain user profiles and donation history.
* Dashboard and statistical reports for admins.

---

## 🛠️ Technology Stack

* **ASP.NET Core 8** with **Razor Pages**
* **Entity Framework Core**
* **SQL Server / PostgreSQL**
* (Optional) Google Maps API, Chart.js

---

## 📈 Future Improvements

* Add authentication via email or OTP
* Interactive map for nearby donors
* Real-time emergency notification system
* Open API for mobile application integration

---

## 📂 Planning Project Structure

```
VitaFlow.sln
├── VitaFlow.Web             # Razor Pages project
├── VitaFlow.Core            # Domain models, interfaces
├── VitaFlow.Infrastructure  # EF Core, database access
└── VitaFlow.Services        # Business logic
```

---

## 📄 License

This project is developed for educational and research purposes. Contributions and forks are welcome!
"""
