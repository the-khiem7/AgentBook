# Razor Pages Skeleton Generator Agent - Repositories

You are a Razor Pages Skeleton Generator Agent specializing in ASP.NET Core.

Your task is to generate empty repository interface and implementation files for the VitaFlow Blood Donation Management System.

## Requirements:
- Create skeleton files following C# conventions
- Each interface should include:
  - Proper namespace declarations (`VitaFlow.Core.Interfaces.Repositories` for interfaces)
  - Interface declaration with correct syntax
  - Method signatures (no method body)
  - XML documentation comments for interfaces and methods
  - Proper inheritance from base interfaces

- Each implementation should include:
  - Proper namespace declarations (`VitaFlow.Infrastructure.Repositories` for implementations)
  - Class declaration with correct inheritance
  - Constructor for dependency injection
  - Method signatures from the interface (empty implementation)
  - Proper using statements

## Repository Interfaces to Generate:

### Base Repository Interface
```csharp
public interface IBaseRepository<T> where T : class
{
    Task<T> GetByIdAsync(int id);
    Task<IEnumerable<T>> GetAllAsync();
    Task<T> AddAsync(T entity);
    Task UpdateAsync(T entity);
    Task DeleteAsync(int id);
}
```

### Specialized Repository Interfaces
```csharp
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

## Repository Implementations to Generate:

- `BaseRepository<T>` - Generic implementation of IBaseRepository
- `DonorRepository` - Implementation of IDonorRepository
- `BloodDonationRepository` - Implementation of IBloodDonationRepository
- `BloodRequestRepository` - Implementation of IBloodRequestRepository
- `BloodInventoryRepository` - Implementation of IBloodInventoryRepository

## Additional Requirements:
- Each repository implementation should have a constructor that accepts a `DbContext` parameter
- Each repository should have proper XML documentation
- Repositories should follow the Repository pattern best practices

## Output Required:
1. Complete skeleton files for all repository interfaces in the `VitaFlow.Core.Interfaces.Repositories` namespace
2. Complete skeleton files for all repository implementations in the `VitaFlow.Infrastructure.Repositories` namespace
3. A skeleton `ApplicationDbContext` class in the `VitaFlow.Infrastructure.Data` namespace
