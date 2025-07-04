# Razor Pages Skeleton Generator Agent - Domain Models

You are a Razor Pages Skeleton Generator Agent specializing in ASP.NET Core.

Your task is to generate empty class files for the **domain models and enums** of the VitaFlow Blood Donation Management System.

## Requirements:
- Create skeleton files following C# conventions
- Each class should include:
  - Proper namespace declarations (`VitaFlow.Core.Entities` for entities, `VitaFlow.Core.Enums` for enums)
  - Class declaration with correct syntax
  - Attributes as properties (no implementation)
  - Appropriate using statements
  - XML documentation comments for classes and properties

## Domain Classes to Generate:

### Base Classes
- `User` class with properties for Id, FirstName, LastName, DateOfBirth, Email, PhoneNumber, Address, Location navigation property, UserRole enum, and timestamps
- `Donor` class inheriting from User with properties for BloodType, IsActive, LastDonationDate, NextAvailableDate, IsEmergencyDonor, DonationHistory collection, and MedicalNotes
- `Recipient` class inheriting from User with properties for BloodType, MedicalNotes, and RequestHistory collection

### Blood Management Entities
- `BloodDonation` class with properties for Id, DonorId, Donor navigation property, BloodType, Volume, DonationDate, DonationStatus enum, Notes, optional BloodRequestId and BloodRequest, optional InventoryId and Inventory
- `BloodRequest` class with properties for Id, RecipientId, Recipient, RequiredBloodType, VolumeNeeded, component flags (IsWholeBloodNeeded, etc.), RequestStatus, RequestDate, RequiredByDate, IsEmergency, MedicalNotes, and AssignedDonations collection
- `BloodInventory` class with properties for Id, BloodType, volume properties for different components, CollectionDate, ExpiryDate, IsAvailable, StorageLocation, and BatchNumber
- `BloodCompatibility` class with properties for Id, DonorBloodType, RecipientBloodType, and IsCompatible flag

### Supporting Entities
- `Location` class with properties for Id, Latitude, Longitude, City, State, ZipCode, and Country
- `Notification` class with properties for Id, UserId, User navigation property, Title, Message, IsRead, CreatedAt, and Type
- `BlogPost` class with properties for Id, Title, Content, AuthorId, Author navigation property, PublishedDate, ImageUrl, IsPublished, and Tags collection

### Enums
- `BloodType` enum with values for different blood types (APositive, ANegative, etc.)
- `DonationStatus` enum with values for donation statuses
- `RequestStatus` enum with values for request statuses
- `UserRole` enum with values for user roles

## Class diagram:
```csharp
public class User
{
    public int Id { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public DateTime DateOfBirth { get; set; }
    public string Email { get; set; }
    public string PhoneNumber { get; set; }
    public string Address { get; set; }
    public Location Location { get; set; }
    public UserRole Role { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

public class Donor : User
{
    public BloodType BloodType { get; set; }
    public bool IsActive { get; set; }
    public DateTime? LastDonationDate { get; set; }
    public DateTime? NextAvailableDate { get; set; }
    public bool IsEmergencyDonor { get; set; }
    public List<BloodDonation> DonationHistory { get; set; }
    public string MedicalNotes { get; set; }
}

public class Recipient : User
{
    public BloodType BloodType { get; set; }
    public string MedicalNotes { get; set; }
    public List<BloodRequest> RequestHistory { get; set; }
}

// Blood Management Entities
public class BloodDonation
{
    public int Id { get; set; }
    public int DonorId { get; set; }
    public Donor Donor { get; set; }
    public BloodType BloodType { get; set; }
    public double Volume { get; set; }
    public DateTime DonationDate { get; set; }
    public DonationStatus Status { get; set; }
    public string Notes { get; set; }
    public int? BloodRequestId { get; set; }
    public BloodRequest BloodRequest { get; set; }
    public int? InventoryId { get; set; }
    public BloodInventory Inventory { get; set; }
}

public class BloodRequest
{
    public int Id { get; set; }
    public int RecipientId { get; set; }
    public Recipient Recipient { get; set; }
    public BloodType RequiredBloodType { get; set; }
    public double VolumeNeeded { get; set; }
    public bool IsWholeBloodNeeded { get; set; }
    public bool IsRedCellsNeeded { get; set; }
    public bool IsPlasmaNeeded { get; set; }
    public bool IsPlateletsNeeded { get; set; }
    public RequestStatus Status { get; set; }
    public DateTime RequestDate { get; set; }
    public DateTime? RequiredByDate { get; set; }
    public bool IsEmergency { get; set; }
    public string MedicalNotes { get; set; }
    public List<BloodDonation> AssignedDonations { get; set; }
}

public class BloodInventory
{
    public int Id { get; set; }
    public BloodType BloodType { get; set; }
    public double WholeBloodVolume { get; set; }
    public double RedCellsVolume { get; set; }
    public double PlasmaVolume { get; set; }
    public double PlateletsVolume { get; set; }
    public DateTime CollectionDate { get; set; }
    public DateTime ExpiryDate { get; set; }
    public bool IsAvailable { get; set; }
    public string StorageLocation { get; set; }
    public string BatchNumber { get; set; }
}

public class BloodCompatibility
{
    public int Id { get; set; }
    public BloodType DonorBloodType { get; set; }
    public BloodType RecipientBloodType { get; set; }
    public bool IsCompatible { get; set; }
}

// Supporting Entities
public class Location
{
    public int Id { get; set; }
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public string City { get; set; }
    public string State { get; set; }
    public string ZipCode { get; set; }
    public string Country { get; set; }
}

public class Notification
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public User User { get; set; }
    public string Title { get; set; }
    public string Message { get; set; }
    public bool IsRead { get; set; }
    public DateTime CreatedAt { get; set; }
    public string Type { get; set; }
}

public class BlogPost
{
    public int Id { get; set; }
    public string Title { get; set; }
    public string Content { get; set; }
    public int AuthorId { get; set; }
    public User Author { get; set; }
    public DateTime PublishedDate { get; set; }
    public string ImageUrl { get; set; }
    public bool IsPublished { get; set; }
    public List<string> Tags { get; set; }
}

// Enums
public enum BloodType
{
    APositive,
    ANegative,
    BPositive,
    BNegative,
    ABPositive,
    ABNegative,
    OPositive,
    ONegative
}

public enum DonationStatus
{
    Scheduled,
    Completed,
    Canceled,
    Failed,
    Processing,
    Expired
}

public enum RequestStatus
{
    New,
    InProgress,
    Fulfilled,
    Canceled,
    Expired
}

public enum UserRole
{
    Admin,
    Donor,
    Recipient,
    Staff
}
```

## Output Required:
1. Complete skeleton files for all entity classes in the `VitaFlow.Core.Entities` namespace
2. Complete skeleton files for all enums in the `VitaFlow.Core.Enums` namespace
3. Ensure proper relationships between entities with navigation properties and collections

Make sure to follow C# conventions for class structure, property naming, and organization. Add appropriate XML comments.
