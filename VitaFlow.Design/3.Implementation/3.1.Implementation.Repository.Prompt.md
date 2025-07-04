# Generic Repository Implementation Prompt

You are an ASP.NET Core Repository Implementation Specialist focusing on Generic Repository pattern.

## Task
Implement a generic repository pattern with Entity Framework Core and PostgreSQL.

## Implementation Steps
1. Core Infrastructure Setup
   - Create `Infrastructure` project/folder structure
   - Configure dependency injection
   - Set up logging

2. Base Interfaces and Classes
   - `IEntity` interface
   - `ISpecification<T>` interface
   - `Specification<T>` base class
   - `IGenericRepository<T>` interface
   - `GenericRepository<T>` implementation
   - `IUnitOfWork` interface
   - `UnitOfWork` implementation

3. Supporting Classes
   - `PaginatedList<T>` for pagination
   - `SpecificationEvaluator<T>`
   - Common specifications
   - Repository exceptions

4. Test Project Setup
   - xUnit project structure
   - Test helpers and fixtures
   - Integration test configuration

## Required NuGet Packages
### Main Implementation:
- Microsoft.EntityFrameworkCore
- Npgsql.EntityFrameworkCore.PostgreSQL
- Microsoft.Extensions.Logging

### Testing:
- Microsoft.EntityFrameworkCore.InMemory
- Moq
- FluentAssertions

## Requirements

### Generic Repository Structure:
1. Base Interface IGenericRepository<T>:
   - CRUD operations
   - Query specifications
   - Async methods
   - Pagination support

2. Base Implementation:
   - Generic repository base class
   - PostgreSQL optimizations
   - Unit of Work pattern integration
   - Transaction management

### Implementation Details:
- Use EF Core with PostgreSQL provider
- Implement proper async/await patterns
- Add specification pattern for queries
- Include pagination and sorting capabilities
- Implement proper error handling and logging
- Add performance optimizations for PostgreSQL

### Testing:
- xUnit test setup for generic repository
- Mock DbContext for unit tests
- Integration test configuration

## Input Required:
- Entity interfaces/base classes
- DbContext configuration
- Domain models

## Expected Output:
1. Core Interfaces and Classes:
   ```csharp
   public interface IEntity
   public interface ISpecification<T>
   public abstract class Specification<T>
   public interface IGenericRepository<T> where T : class
   public class GenericRepository<T> : IGenericRepository<T> where T : class
   public interface IUnitOfWork : IDisposable
   public class UnitOfWork : IUnitOfWork
   ```

2. Supporting Classes:
   ```csharp
   public class PaginatedList<T>
   public class SpecificationEvaluator<T>
   public class OrderBySpecification<T>
   public class RepositoryException : Exception
   ```

3. Test Project Structure:
   - Unit Tests
   - Integration Tests
   - Test Helpers
   - Test Fixtures

## Reference Implementation Guide
For detailed implementation examples and code samples, refer to: 
#file:3.1.Implementation.Repository.Guide.md
