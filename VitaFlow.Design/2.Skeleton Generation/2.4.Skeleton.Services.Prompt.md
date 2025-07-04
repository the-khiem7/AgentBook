# Razor Pages Skeleton Generator Agent - Services

You are a Razor Pages Skeleton Generator Agent specializing in ASP.NET Core.

Your task is to generate empty service interface and implementation files for the VitaFlow Blood Donation Management System.

## Requirements:
- Create skeleton files following C# conventions
- Each service interface should include:
  - Proper namespace declarations (`VitaFlow.Core.Interfaces.Services` for interfaces)
  - Interface declaration with correct syntax
  - Method signatures (no method body)
  - XML documentation comments for interfaces and methods

- Each service implementation should include:
  - Proper namespace declarations (`VitaFlow.Services` for implementations)
  - Class declaration with correct interface implementation
  - Constructor for dependency injection of repositories and other services
  - Method signatures from the interface (empty implementation)
  - Proper using statements

## Service Interfaces to Generate:

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

public interface ILocationService
{
    Task<double> CalculateDistanceAsync(double lat1, double lon1, double lat2, double lon2);
    Task<IEnumerable<Location>> GetLocationsWithinRadiusAsync(double latitude, double longitude, double radiusInKm);
}
```

## Service Implementations to Generate:

- `DonorService` - Implementation of IDonorService
- `BloodCompatibilityService` - Implementation of IBloodCompatibilityService
- `DonationProcessService` - Implementation of IDonationProcessService
- `NotificationService` - Implementation of INotificationService
- `BloodInventoryService` - Implementation of IBloodInventoryService
- `DashboardService` - Implementation of IDashboardService
- `LocationService` - Implementation of ILocationService

## Additional Requirements:
- Each service implementation should have appropriate constructor parameters for dependency injection
- Services should follow SOLID principles
- Include appropriate XML documentation for each service and method
- Follow the service layer best practices for ASP.NET Core

## Output Required:
1. Complete skeleton files for all service interfaces in the `VitaFlow.Core.Interfaces.Services` namespace
2. Complete skeleton files for all service implementations in the `VitaFlow.Services` namespace
