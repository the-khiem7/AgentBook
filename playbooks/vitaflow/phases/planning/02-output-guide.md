# VitaFlow - Blood Donation Management System Design

## Summary of the Feature
VitaFlow is a web-based blood donation management system for healthcare facilities that connects donors with recipients, manages blood inventory, tracks donation history, and handles emergency requests. The system enables blood type compatibility matching, geographical donor/recipient location, and complete management of the donation process from request to fulfillment, while providing administrative reporting capabilities.

## Folder Structure for Razor Pages Application

```
VitaFlow.Web/
├── Pages/
│   ├── Home/
│   │   └── Index.cshtml/.cshtml.cs
│   ├── Donors/
│   │   ├── Register.cshtml/.cshtml.cs
│   │   ├── List.cshtml/.cshtml.cs
│   │   ├── Details.cshtml/.cshtml.cs
│   │   └── Edit.cshtml/.cshtml.cs
│   ├── Recipients/
│   │   ├── Register.cshtml/.cshtml.cs
│   │   ├── List.cshtml/.cshtml.cs
│   │   └── Details.cshtml/.cshtml.cs
│   ├── BloodRequests/
│   │   ├── Create.cshtml/.cshtml.cs
│   │   ├── List.cshtml/.cshtml.cs
│   │   └── Details.cshtml/.cshtml.cs
│   ├── Donations/
│   │   ├── Schedule.cshtml/.cshtml.cs
│   │   ├── Process.cshtml/.cshtml.cs
│   │   └── Complete.cshtml/.cshtml.cs
│   ├── Inventory/
│   │   ├── Overview.cshtml/.cshtml.cs
│   │   └── Manage.cshtml/.cshtml.cs
│   ├── Blog/
│   │   ├── List.cshtml/.cshtml.cs
│   │   └── Post.cshtml/.cshtml.cs
│   ├── Admin/
│   │   ├── Dashboard.cshtml/.cshtml.cs
│   │   └── Reports.cshtml/.cshtml.cs
│   └── Shared/
│       ├── _Layout.cshtml
│       └── _ValidationScriptsPartial.cshtml
├── wwwroot/
├── ViewModels/
├── Extensions/
├── Program.cs
└── appsettings.json

VitaFlow.Core/
├── Entities/
├── Enums/
├── Interfaces/
│   ├── Repositories/
│   └── Services/
└── Constants/

VitaFlow.Infrastructure/
├── Data/
├── Repositories/
└── Migrations/

VitaFlow.Services/
```

## Class Diagram

### Domain/Entity Classes

#### Base Classes
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
```

#### Blood Management Entities
```csharp
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
```

#### Supporting Entities
```csharp
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
```

### Enums
```csharp
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

### Repository Interfaces
```csharp
public interface IBaseRepository<T> where T : class
{
    Task<T> GetByIdAsync(int id);
    Task<IEnumerable<T>> GetAllAsync();
    Task<T> AddAsync(T entity);
    Task UpdateAsync(T entity);
    Task DeleteAsync(int id);
}

public interface IDonorRepository : IBaseRepository<Donor>
{
    Task<IEnumerable<Donor>> GetAvailableDonorsByBloodTypeAsync(BloodType bloodType);
    Task<IEnumerable<Donor>> GetDonorsByLocationAsync(double latitude, double longitude, double radiusInKm);
    Task<int> GetDonorCountByBloodTypeAsync(BloodType bloodType);
    Task UpdateDonorAvailabilityAsync(int donorId, DateTime nextAvailableDate);
}

public interface IBloodDonationRepository : IBaseRepository<BloodDonation>
{
    Task<IEnumerable<BloodDonation>> GetDonationsByDonorIdAsync(int donorId);
    Task<IEnumerable<BloodDonation>> GetDonationsByRequestIdAsync(int requestId);
    Task<IEnumerable<BloodDonation>> GetDonationsByDateRangeAsync(DateTime startDate, DateTime endDate);
}

public interface IBloodRequestRepository : IBaseRepository<BloodRequest>
{
    Task<IEnumerable<BloodRequest>> GetActiveRequestsAsync();
    Task<IEnumerable<BloodRequest>> GetEmergencyRequestsAsync();
    Task<IEnumerable<BloodRequest>> GetRequestsByBloodTypeAsync(BloodType bloodType);
    Task UpdateRequestStatusAsync(int requestId, RequestStatus status);
}

public interface IBloodInventoryRepository : IBaseRepository<BloodInventory>
{
    Task<double> GetTotalVolumeByBloodTypeAsync(BloodType bloodType, bool wholeBloodOnly = false);
    Task<IEnumerable<BloodInventory>> GetExpiringInventoryAsync(int daysToExpiry);
    Task UpdateInventoryAsync(BloodType bloodType, double volume, bool isAddition);
}
```

### Service Interfaces
```csharp
public interface IDonorService
{
    Task<Donor> GetDonorByIdAsync(int id);
    Task<IEnumerable<Donor>> GetAllDonorsAsync();
    Task<Donor> RegisterDonorAsync(Donor donor);
    Task UpdateDonorAsync(Donor donor);
    Task<IEnumerable<Donor>> FindCompatibleDonorsAsync(BloodType recipientBloodType);
    Task<IEnumerable<Donor>> FindNearbyDonorsAsync(double latitude, double longitude, double radiusInKm);
    Task UpdateDonorAvailabilityAsync(int donorId);
    Task<IEnumerable<BloodDonation>> GetDonorHistoryAsync(int donorId);
}

public interface IBloodCompatibilityService
{
    Task<bool> IsCompatibleAsync(BloodType donorType, BloodType recipientType);
    Task<IEnumerable<BloodType>> GetCompatibleDonorTypesAsync(BloodType recipientType);
    Task<IEnumerable<BloodType>> GetCompatibleRecipientTypesAsync(BloodType donorType);
}

public interface IDonationProcessService
{
    Task<BloodDonation> ScheduleDonationAsync(int donorId, DateTime scheduledDate);
    Task<BloodDonation> CompleteDonationAsync(int donationId);
    Task CancelDonationAsync(int donationId, string reason);
    Task<BloodDonation> AssignDonationToRequestAsync(int donationId, int requestId);
    Task<BloodRequest> CreateBloodRequestAsync(BloodRequest request);
    Task<BloodRequest> FulfillRequestAsync(int requestId);
}

public interface INotificationService
{
    Task SendDonationReminderAsync(int donorId);
    Task SendEmergencyRequestAsync(IEnumerable<int> donorIds);
    Task SendDonationCompletedNotificationAsync(int donorId, int donationId);
    Task SendRequestStatusUpdateAsync(int recipientId, int requestId);
    Task MarkNotificationAsReadAsync(int notificationId);
    Task<IEnumerable<Notification>> GetUserNotificationsAsync(int userId);
}

public interface IBloodInventoryService
{
    Task<IEnumerable<BloodInventory>> GetCurrentInventoryAsync();
    Task<BloodInventory> AddToInventoryAsync(BloodInventory inventory);
    Task UpdateInventoryAsync(BloodInventory inventory);
    Task<bool> CheckAvailabilityAsync(BloodType bloodType, double requiredVolume);
    Task<IEnumerable<BloodInventory>> GetExpiringInventoryAsync();
    Task<Dictionary<BloodType, double>> GetInventorySummaryAsync();
}

public interface IDashboardService
{
    Task<Dictionary<BloodType, int>> GetDonorCountsByBloodTypeAsync();
    Task<Dictionary<RequestStatus, int>> GetRequestStatusSummaryAsync();
    Task<Dictionary<string, int>> GetDonationsPerMonthAsync(int year);
    Task<Dictionary<BloodType, double>> GetInventoryLevelsByBloodTypeAsync();
    Task<int> GetActiveEmergencyRequestCountAsync();
}
```

### Page Models (Razor Pages)
```csharp
// Donor Registration Page Model
public class RegisterModel : PageModel
{
    private readonly IDonorService _donorService;
    private readonly ILocationService _locationService;
    
    [BindProperty]
    public DonorRegistrationViewModel DonorVM { get; set; }
    
    public void OnGet() { }
    
    public async Task<IActionResult> OnPostAsync()
    {
        if (!ModelState.IsValid)
            return Page();
            
        // Create donor from viewmodel
        // Register donor through service
        // Redirect to confirmation page
    }
}

// Blood Request Creation Page Model
public class CreateRequestModel : PageModel
{
    private readonly IDonationProcessService _donationProcessService;
    private readonly IDonorService _donorService;
    private readonly INotificationService _notificationService;
    
    [BindProperty]
    public BloodRequestViewModel RequestVM { get; set; }
    
    public List<BloodType> BloodTypes { get; set; }
    
    public void OnGet()
    {
        // Initialize form with blood types
    }
    
    public async Task<IActionResult> OnPostAsync()
    {
        if (!ModelState.IsValid)
            return Page();
            
        // Create and process blood request
        // Notify donors if emergency
        // Redirect to details page
    }
}

// Blood Inventory Overview Page Model
public class OverviewModel : PageModel
{
    private readonly IBloodInventoryService _inventoryService;
    
    public Dictionary<BloodType, double> InventorySummary { get; set; }
    public IEnumerable<BloodInventory> ExpiringInventory { get; set; }
    
    public async Task OnGetAsync()
    {
        // Load inventory data for display
    }
}

// Admin Dashboard Page Model
public class DashboardModel : PageModel
{
    private readonly IDashboardService _dashboardService;
    
    public Dictionary<BloodType, int> DonorCountsByBloodType { get; set; }
    public Dictionary<RequestStatus, int> RequestStatusSummary { get; set; }
    public Dictionary<string, int> DonationsPerMonth { get; set; }
    public Dictionary<BloodType, double> InventoryLevels { get; set; }
    public int EmergencyRequestCount { get; set; }
    
    public async Task OnGetAsync()
    {
        // Load dashboard statistics
    }
}
```

### View Models
```csharp
public class DonorRegistrationViewModel
{
    [Required]
    [Display(Name = "First Name")]
    public string FirstName { get; set; }
    
    [Required]
    [Display(Name = "Last Name")]
    public string LastName { get; set; }
    
    [Required]
    [DataType(DataType.Date)]
    [Display(Name = "Date of Birth")]
    [AgeValidation(18)]
    public DateTime DateOfBirth { get; set; }
    
    [Required]
    [EmailAddress]
    public string Email { get; set; }
    
    [Required]
    [Phone]
    public string PhoneNumber { get; set; }
    
    [Required]
    public string Address { get; set; }
    
    [Required]
    public BloodType BloodType { get; set; }
    
    [Display(Name = "Available for emergency donations")]
    public bool IsEmergencyDonor { get; set; }
    
    public string MedicalNotes { get; set; }
}

public class BloodRequestViewModel
{
    public int RecipientId { get; set; }
    
    [Required]
    public BloodType RequiredBloodType { get; set; }
    
    [Required]
    [Range(1, 5000)]
    public double VolumeNeeded { get; set; }
    
    public bool IsWholeBloodNeeded { get; set; }
    public bool IsRedCellsNeeded { get; set; }
    public bool IsPlasmaNeeded { get; set; }
    public bool IsPlateletsNeeded { get; set; }
    
    [DataType(DataType.Date)]
    public DateTime? RequiredByDate { get; set; }
    
    public bool IsEmergency { get; set; }
    public string MedicalNotes { get; set; }
}

public class DonationScheduleViewModel
{
    public int DonorId { get; set; }
    
    [Required]
    [DataType(DataType.Date)]
    [FutureDate]
    public DateTime ScheduledDate { get; set; }
    
    public string Notes { get; set; }
}

public class InventoryOverviewViewModel
{
    public Dictionary<BloodType, double> TotalWholeBlood { get; set; }
    public Dictionary<BloodType, double> TotalComponents { get; set; }
    public IEnumerable<InventoryItemViewModel> ExpiringItems { get; set; }
}
```

## Data Flow Explanation

### Donor Registration Flow
1. User navigates to `/Donors/Register`
2. `RegisterModel.OnGet()` initializes the form
3. User fills form and submits
4. `RegisterModel.OnPostAsync()` validates the form data
5. On valid data:
   - `IDonorService.RegisterDonorAsync()` is called
   - `DonorService` converts the view model to a `Donor` entity
   - `IDonorRepository.AddAsync()` persists data to database
6. User is redirected to a confirmation page

### Blood Request Flow
1. Staff navigates to `/BloodRequests/Create`
2. `CreateRequestModel.OnGet()` loads form with blood type options
3. Staff completes and submits form
4. `CreateRequestModel.OnPostAsync()` validates the form data
5. On valid data:
   - `IDonationProcessService.CreateBloodRequestAsync()` creates request
   - If emergency, `IDonorService.FindCompatibleDonorsAsync()` identifies compatible donors
   - `INotificationService.SendEmergencyRequestAsync()` alerts compatible donors
6. User is redirected to request details page

### Blood Donation Process Flow
1. Donor arrives for scheduled donation
2. Staff navigates to `/Donations/Process/{donorId}`
3. `ProcessModel.OnGetAsync()` loads donor information
4. Staff completes the donation form and submits
5. `ProcessModel.OnPostAsync()` processes the donation:
   - `IDonationProcessService.CompleteDonationAsync()` records donation
   - `IBloodInventoryService.AddToInventoryAsync()` adds blood to inventory
   - `IDonorService.UpdateDonorAvailabilityAsync()` updates donor's next available date
6. Staff is redirected to donation confirmation page

### Blood Inventory Management Flow
1. Admin navigates to `/Inventory/Overview`
2. `OverviewModel.OnGetAsync()` calls:
   - `IBloodInventoryService.GetInventorySummaryAsync()`
   - `IBloodInventoryService.GetExpiringInventoryAsync()`
3. Data is displayed to admin in tables and charts
4. Admin can take actions (update, dispose) based on inventory status

## Assumptions Made
1. Authentication will be implemented using ASP.NET Core Identity
2. All dates are stored in UTC and converted to local time for display
3. Blood compatibility rules follow standard medical guidelines
4. Staff manually verifies donor eligibility (health conditions, medications)
5. Blood expiry dates vary by component (42 days for red cells, 5 days for platelets)
6. Recovery period between donations is set to 56 days for whole blood
7. System is designed for a single healthcare facility or network
8. Email/SMS notifications are supported through external services
9. Geographical calculations use straight-line distance

## Additional Recommendations for Razor Pages Best Practices

1. **Effective Page Model Usage**
   - Keep page models focused on UI concerns
   - Move business logic to services
   - Use handler methods (OnGetAsync, OnPostAsync) consistently

2. **Validation Strategy**
   - Implement client-side validation with _ValidationScriptsPartial.cshtml
   - Create custom validation attributes for domain-specific rules
   - Use model state for server-side validation

3. **Partial Views & Components**
   - Create partial views for reusable UI components
   - Use view components for complex UI elements that need server logic
   - Implement tag helpers for consistent UI elements

4. **Performance Considerations**
   - Use async/await throughout the application
   - Implement caching for static data and reports
   - Add pagination for lists of donors, recipients, donations

5. **Security Implementation**
   - Apply appropriate authorization policies to page handlers
   - Use anti-forgery tokens for all forms
   - Implement proper data access filtering based on user roles

6. **Exception Handling**
   - Create custom error pages
   - Implement global exception handling middleware
   - Log exceptions properly with structured logging

7. **API Extensions**
   - Consider adding minimal API endpoints for mobile app integration
   - Design with future extension in mind

8. **Testing Strategy**
   - Create unit tests for services
   - Implement integration tests for Razor Pages
   - Use UI tests for critical user journeys
