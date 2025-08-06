# Generic Repository Implementation Scenarios

This document provides real-world scenarios and examples for using the Generic Repository pattern.

## 1. Specification Pattern Examples

### BaseSpecification.cs
```csharp
public abstract class BaseSpecification<T> : ISpecification<T>
{
    public Expression<Func<T, bool>> Criteria { get; }
    public List<Expression<Func<T, object>>> Includes { get; } = new();
    public List<string> IncludeStrings { get; } = new();
    public Expression<Func<T, object>> OrderBy { get; private set; }
    public Expression<Func<T, object>> OrderByDescending { get; private set; }
    public int Take { get; private set; }
    public int Skip { get; private set; }
    public bool IsPagingEnabled { get; private set; }

    protected BaseSpecification() { }

    protected BaseSpecification(Expression<Func<T, bool>> criteria)
    {
        Criteria = criteria;
    }

    protected virtual void AddInclude(Expression<Func<T, object>> includeExpression)
    {
        Includes.Add(includeExpression);
    }

    protected virtual void AddInclude(string includeString)
    {
        IncludeStrings.Add(includeString);
    }

    protected virtual void ApplyPaging(int skip, int take)
    {
        Skip = skip;
        Take = take;
        IsPagingEnabled = true;
    }

    protected virtual void ApplyOrderBy(Expression<Func<T, object>> orderByExpression)
    {
        OrderBy = orderByExpression;
    }

    protected virtual void ApplyOrderByDescending(Expression<Func<T, object>> orderByDescExpression)
    {
        OrderByDescending = orderByDescExpression;
    }
}
```

## 2. Common Specification Examples

### GetActiveUsersSpecification.cs
```csharp
public class GetActiveUsersSpecification : BaseSpecification<User>
{
    public GetActiveUsersSpecification() 
        : base(u => u.IsActive)
    {
        AddInclude(u => u.UserProfile);
        ApplyOrderBy(u => u.LastLoginDate);
    }
}
```

### GetProductsWithCategorySpecification.cs
```csharp
public class GetProductsWithCategorySpecification : BaseSpecification<Product>
{
    public GetProductsWithCategorySpecification(
        string searchTerm = null,
        decimal? minPrice = null,
        decimal? maxPrice = null,
        string sortBy = null,
        int? pageSize = null,
        int? pageIndex = null)
    {
        // Base criteria
        var criteria = PredicateBuilder.True<Product>();

        if (!string.IsNullOrWhiteSpace(searchTerm))
        {
            criteria = criteria.And(p => 
                p.Name.Contains(searchTerm) || 
                p.Description.Contains(searchTerm));
        }

        if (minPrice.HasValue)
        {
            criteria = criteria.And(p => p.Price >= minPrice.Value);
        }

        if (maxPrice.HasValue)
        {
            criteria = criteria.And(p => p.Price <= maxPrice.Value);
        }

        Criteria = criteria;

        // Includes
        AddInclude(p => p.Category);
        AddInclude(p => p.ProductImages);

        // Sorting
        switch (sortBy?.ToLower())
        {
            case "price_asc":
                ApplyOrderBy(p => p.Price);
                break;
            case "price_desc":
                ApplyOrderByDescending(p => p.Price);
                break;
            case "name":
                ApplyOrderBy(p => p.Name);
                break;
            default:
                ApplyOrderByDescending(p => p.CreatedAt);
                break;
        }

        // Paging
        if (pageSize.HasValue && pageIndex.HasValue)
        {
            ApplyPaging((pageIndex.Value - 1) * pageSize.Value, pageSize.Value);
        }
    }
}
```

## 3. Repository Usage Examples

### Complex Query Example
```csharp
public class ProductService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<ProductService> _logger;

    public ProductService(IUnitOfWork unitOfWork, ILogger<ProductService> logger)
    {
        _unitOfWork = unitOfWork;
        _logger = logger;
    }

    public async Task<(IReadOnlyList<Product> Products, int TotalCount)> 
        SearchProductsAsync(ProductSearchParams searchParams)
    {
        try
        {
            var spec = new GetProductsWithCategorySpecification(
                searchParams.SearchTerm,
                searchParams.MinPrice,
                searchParams.MaxPrice,
                searchParams.SortBy,
                searchParams.PageSize,
                searchParams.PageIndex
            );

            var products = await _unitOfWork.Repository<Product>()
                .ListAsync(spec);

            var totalCount = await _unitOfWork.Repository<Product>()
                .CountAsync(spec);

            return (products, totalCount);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error searching products with params: {@SearchParams}", 
                searchParams);
            throw;
        }
    }
}
```

### Transaction Example
```csharp
public class OrderService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<OrderService> _logger;

    public OrderService(IUnitOfWork unitOfWork, ILogger<OrderService> logger)
    {
        _unitOfWork = unitOfWork;
        _logger = logger;
    }

    public async Task<Order> CreateOrderAsync(OrderCreateDto orderDto)
    {
        try
        {
            await _unitOfWork.BeginTransactionAsync();

            // Create order
            var order = new Order
            {
                UserId = orderDto.UserId,
                TotalAmount = orderDto.Items.Sum(i => i.Price * i.Quantity)
            };
            await _unitOfWork.Repository<Order>().AddAsync(order);

            // Create order items
            foreach (var item in orderDto.Items)
            {
                var orderItem = new OrderItem
                {
                    OrderId = order.Id,
                    ProductId = item.ProductId,
                    Quantity = item.Quantity,
                    Price = item.Price
                };
                await _unitOfWork.Repository<OrderItem>().AddAsync(orderItem);

                // Update product stock
                var product = await _unitOfWork.Repository<Product>()
                    .GetByIdAsync(item.ProductId);
                product.Stock -= item.Quantity;
                await _unitOfWork.Repository<Product>().UpdateAsync(product);
            }

            await _unitOfWork.CommitTransactionAsync();
            return order;
        }
        catch (Exception ex)
        {
            await _unitOfWork.RollbackTransactionAsync();
            _logger.LogError(ex, "Error creating order for user {UserId}", orderDto.UserId);
            throw;
        }
    }
}
```

## 4. Advanced Testing Scenarios

### Integration Tests
```csharp
public class ProductRepositoryIntegrationTests : IClassFixture<TestDatabaseFixture>
{
    private readonly TestDatabaseFixture _fixture;

    public ProductRepositoryIntegrationTests(TestDatabaseFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    public async Task SearchProducts_WithComplexCriteria_ReturnsCorrectResults()
    {
        // Arrange
        using var context = _fixture.CreateContext();
        var repository = new GenericRepository<Product>(context, 
            new Logger<GenericRepository<Product>>(new LoggerFactory()));

        var spec = new GetProductsWithCategorySpecification(
            searchTerm: "laptop",
            minPrice: 500,
            maxPrice: 2000,
            sortBy: "price_asc",
            pageSize: 10,
            pageIndex: 1
        );

        // Act
        var products = await repository.ListAsync(spec);

        // Assert
        Assert.NotNull(products);
        Assert.All(products, p => Assert.InRange(p.Price, 500, 2000));
        Assert.All(products, p => 
            Assert.Contains("laptop", p.Name.ToLower()) || 
            Assert.Contains("laptop", p.Description.ToLower()));
    }
}
```

### Performance Testing
```csharp
public class RepositoryPerformanceTests
{
    private readonly ITestOutputHelper _output;
    private readonly Stopwatch _stopwatch;

    public RepositoryPerformanceTests(ITestOutputHelper output)
    {
        _output = output;
        _stopwatch = new Stopwatch();
    }

    [Fact]
    public async Task BulkOperations_Performance_Test()
    {
        // Arrange
        using var context = CreateTestContext();
        var repository = new GenericRepository<Product>(context, 
            new Logger<GenericRepository<Product>>(new LoggerFactory()));

        var products = Enumerable.Range(1, 1000)
            .Select(i => new Product 
            { 
                Name = $"Product {i}",
                Price = i * 10
            })
            .ToList();

        // Act & Assert
        _stopwatch.Start();
        foreach (var product in products)
        {
            await repository.AddAsync(product);
        }
        _stopwatch.Stop();

        _output.WriteLine($"Individual inserts took: {_stopwatch.ElapsedMilliseconds}ms");

        // Test bulk operations
        _stopwatch.Restart();
        await context.BulkInsertAsync(products);
        _stopwatch.Stop();

        _output.WriteLine($"Bulk insert took: {_stopwatch.ElapsedMilliseconds}ms");
    }
}
```
