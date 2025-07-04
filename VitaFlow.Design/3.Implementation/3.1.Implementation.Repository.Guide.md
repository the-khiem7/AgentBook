# Generic Repository Implementation Guide

This guide provides step-by-step instructions for implementing the Generic Repository pattern in an ASP.NET Core application with PostgreSQL.

## 1. Project Structure Setup

```plaintext
YourProject.Infrastructure/
├── Data/
│   ├── Context/
│   │   └── ApplicationDbContext.cs
│   └── Repositories/
│       ├── Base/
│       │   ├── IEntity.cs
│       │   ├── IGenericRepository.cs
│       │   └── GenericRepository.cs
│       └── UnitOfWork/
│           ├── IUnitOfWork.cs
│           └── UnitOfWork.cs
├── Specifications/
│   ├── Base/
│   │   ├── ISpecification.cs
│   │   ├── Specification.cs
│   │   └── SpecificationEvaluator.cs
│   └── Common/
│       └── OrderBySpecification.cs
└── Common/
    ├── Pagination/
    │   └── PaginatedList.cs
    └── Exceptions/
        └── RepositoryException.cs

```

## 2. NuGet Package Installation

```xml
<ItemGroup>
    <!-- Core Packages -->
    <PackageReference Include="Microsoft.EntityFrameworkCore" Version="7.0.0" />
    <PackageReference Include="Npgsql.EntityFrameworkCore.PostgreSQL" Version="7.0.0" />
    <PackageReference Include="Microsoft.Extensions.Logging" Version="7.0.0" />
    
    <!-- Testing Packages (in test project) -->
    <PackageReference Include="Microsoft.EntityFrameworkCore.InMemory" Version="7.0.0" />
    <PackageReference Include="Moq" Version="4.18.0" />
    <PackageReference Include="FluentAssertions" Version="6.8.0" />
</ItemGroup>
```

## 3. Base Interface Implementation

### IEntity.cs
```csharp
namespace YourProject.Infrastructure.Data.Base
{
    public interface IEntity
    {
        Guid Id { get; set; }
    }
}
```

### ISpecification.cs
```csharp
namespace YourProject.Infrastructure.Specifications.Base
{
    public interface ISpecification<T>
    {
        Expression<Func<T, bool>> Criteria { get; }
        List<Expression<Func<T, object>>> Includes { get; }
        List<string> IncludeStrings { get; }
        Expression<Func<T, object>> OrderBy { get; }
        Expression<Func<T, object>> OrderByDescending { get; }
        int Take { get; }
        int Skip { get; }
        bool IsPagingEnabled { get; }
    }
}
```

### IGenericRepository.cs
```csharp
namespace YourProject.Infrastructure.Data.Base
{
    public interface IGenericRepository<T> where T : class
    {
        Task<T> GetByIdAsync(Guid id);
        Task<IReadOnlyList<T>> ListAllAsync();
        Task<IReadOnlyList<T>> ListAsync(ISpecification<T> spec);
        Task<T> AddAsync(T entity);
        Task UpdateAsync(T entity);
        Task DeleteAsync(T entity);
        Task<int> CountAsync(ISpecification<T> spec);
        Task<T> FirstOrDefaultAsync(ISpecification<T> spec);
    }
}
```

## 4. Implementation Classes

### GenericRepository.cs
```csharp
namespace YourProject.Infrastructure.Data.Base
{
    public class GenericRepository<T> : IGenericRepository<T> where T : class
    {
        protected readonly ApplicationDbContext _context;
        protected readonly ILogger<GenericRepository<T>> _logger;

        public GenericRepository(ApplicationDbContext context, ILogger<GenericRepository<T>> logger)
        {
            _context = context;
            _logger = logger;
        }

        public virtual async Task<T> GetByIdAsync(Guid id)
        {
            return await _context.Set<T>().FindAsync(id);
        }

        public virtual async Task<IReadOnlyList<T>> ListAllAsync()
        {
            return await _context.Set<T>().ToListAsync();
        }

        public virtual async Task<IReadOnlyList<T>> ListAsync(ISpecification<T> spec)
        {
            return await ApplySpecification(spec).ToListAsync();
        }

        public virtual async Task<T> AddAsync(T entity)
        {
            _context.Set<T>().Add(entity);
            await _context.SaveChangesAsync();
            return entity;
        }

        public virtual async Task UpdateAsync(T entity)
        {
            _context.Entry(entity).State = EntityState.Modified;
            await _context.SaveChangesAsync();
        }

        public virtual async Task DeleteAsync(T entity)
        {
            _context.Set<T>().Remove(entity);
            await _context.SaveChangesAsync();
        }

        public virtual async Task<int> CountAsync(ISpecification<T> spec)
        {
            return await ApplySpecification(spec).CountAsync();
        }

        public virtual async Task<T> FirstOrDefaultAsync(ISpecification<T> spec)
        {
            return await ApplySpecification(spec).FirstOrDefaultAsync();
        }

        private IQueryable<T> ApplySpecification(ISpecification<T> spec)
        {
            return SpecificationEvaluator<T>.GetQuery(_context.Set<T>().AsQueryable(), spec);
        }
    }
}
```

## 5. Supporting Classes

### PaginatedList.cs
```csharp
namespace YourProject.Infrastructure.Common.Pagination
{
    public class PaginatedList<T>
    {
        public int PageIndex { get; private set; }
        public int TotalPages { get; private set; }
        public int TotalCount { get; private set; }
        public List<T> Items { get; private set; }

        public PaginatedList(List<T> items, int count, int pageIndex, int pageSize)
        {
            PageIndex = pageIndex;
            TotalPages = (int)Math.Ceiling(count / (double)pageSize);
            TotalCount = count;
            Items = items;
        }

        public bool HasPreviousPage => PageIndex > 1;
        public bool HasNextPage => PageIndex < TotalPages;

        public static async Task<PaginatedList<T>> CreateAsync(
            IQueryable<T> source, int pageIndex, int pageSize)
        {
            var count = await source.CountAsync();
            var items = await source.Skip((pageIndex - 1) * pageSize)
                                  .Take(pageSize)
                                  .ToListAsync();
            return new PaginatedList<T>(items, count, pageIndex, pageSize);
        }
    }
}
```

## 6. Unit of Work Implementation

### IUnitOfWork.cs
```csharp
namespace YourProject.Infrastructure.Data.UnitOfWork
{
    public interface IUnitOfWork : IDisposable
    {
        IGenericRepository<T> Repository<T>() where T : class;
        Task<int> CompleteAsync();
        Task BeginTransactionAsync();
        Task CommitTransactionAsync();
        Task RollbackTransactionAsync();
    }
}
```

### UnitOfWork.cs
```csharp
namespace YourProject.Infrastructure.Data.UnitOfWork
{
    public class UnitOfWork : IUnitOfWork
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<UnitOfWork> _logger;
        private bool disposed = false;
        private Dictionary<Type, object> repositories;
        private IDbContextTransaction _currentTransaction;

        public UnitOfWork(ApplicationDbContext context, ILogger<UnitOfWork> logger)
        {
            _context = context;
            _logger = logger;
            repositories = new Dictionary<Type, object>();
        }

        public IGenericRepository<T> Repository<T>() where T : class
        {
            if (repositories.ContainsKey(typeof(T)))
            {
                return (IGenericRepository<T>)repositories[typeof(T)];
            }

            var repository = new GenericRepository<T>(_context, 
                _logger.CreateLogger<GenericRepository<T>>());
            repositories.Add(typeof(T), repository);
            return repository;
        }

        public async Task<int> CompleteAsync()
        {
            return await _context.SaveChangesAsync();
        }

        public async Task BeginTransactionAsync()
        {
            _currentTransaction = await _context.Database.BeginTransactionAsync();
        }

        public async Task CommitTransactionAsync()
        {
            try
            {
                await _context.SaveChangesAsync();
                await _currentTransaction.CommitAsync();
            }
            catch
            {
                await RollbackTransactionAsync();
                throw;
            }
            finally
            {
                if (_currentTransaction != null)
                {
                    _currentTransaction.Dispose();
                    _currentTransaction = null;
                }
            }
        }

        public async Task RollbackTransactionAsync()
        {
            if (_currentTransaction != null)
            {
                await _currentTransaction.RollbackAsync();
                _currentTransaction.Dispose();
                _currentTransaction = null;
            }
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (!disposed)
            {
                if (disposing)
                {
                    _context.Dispose();
                }
            }
            disposed = true;
        }
    }
}
```

## 7. Usage Examples

### Repository Registration
```csharp
public void ConfigureServices(IServiceCollection services)
{
    // Register DbContext
    services.AddDbContext<ApplicationDbContext>(options =>
        options.UseNpgsql(Configuration.GetConnectionString("DefaultConnection")));

    // Register Unit of Work
    services.AddScoped<IUnitOfWork, UnitOfWork>();
}
```

### Using the Repository
```csharp
public class YourService
{
    private readonly IUnitOfWork _unitOfWork;

    public YourService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<Entity> GetEntityById(Guid id)
    {
        return await _unitOfWork.Repository<Entity>().GetByIdAsync(id);
    }

    public async Task<IReadOnlyList<Entity>> GetEntitiesWithSpec(ISpecification<Entity> spec)
    {
        return await _unitOfWork.Repository<Entity>().ListAsync(spec);
    }
}
```

## 8. Testing Setup

```csharp
public class GenericRepositoryTests
{
    private readonly DbContextOptions<ApplicationDbContext> _options;
    private readonly Mock<ILogger<GenericRepository<TestEntity>>> _loggerMock;
    private readonly TestEntity _testEntity;

    public GenericRepositoryTests()
    {
        _options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: "TestDb")
            .Options;

        _loggerMock = new Mock<ILogger<GenericRepository<TestEntity>>>();
        _testEntity = new TestEntity { Id = Guid.NewGuid(), Name = "Test" };
    }

    [Fact]
    public async Task GetByIdAsync_ShouldReturnEntity_WhenEntityExists()
    {
        // Arrange
        using var context = new ApplicationDbContext(_options);
        var repository = new GenericRepository<TestEntity>(context, _loggerMock.Object);
        await context.Set<TestEntity>().AddAsync(_testEntity);
        await context.SaveChangesAsync();

        // Act
        var result = await repository.GetByIdAsync(_testEntity.Id);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(_testEntity.Id, result.Id);
    }
}
```

## 9. PostgreSQL Specific Optimizations

### ApplicationDbContext.cs
```csharp
public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        // Enable batching for PostgreSQL
        optionsBuilder.UseNpgsql(options => 
        {
            options.MaxBatchSize(100);
            options.UseQuerySplittingBehavior(QuerySplittingBehavior.SplitQuery);
        });
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Add PostgreSQL specific configurations
        modelBuilder.UseIdentityColumns();
        
        // Configure indexes
        modelBuilder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());
    }
}
```

## 10. Migration Setup

```bash
# Install EF Core tools
dotnet tool install --global dotnet-ef

# Add migration
dotnet ef migrations add InitialCreate -o Data/Migrations

# Update database
dotnet ef database update
```
