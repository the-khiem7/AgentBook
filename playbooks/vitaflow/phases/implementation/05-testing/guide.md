# Testing Implementation Guide

This guide provides comprehensive instructions for implementing testing in an ASP.NET Core Razor Pages application, covering unit tests, integration tests, and UI tests.

## 1. Project Structure

```plaintext
YourProject.Tests/
├── Unit/
│   ├── Domain/
│   │   └── Entities/
│   ├── Application/
│   │   ├── Services/
│   │   └── Validators/
│   └── Infrastructure/
│       └── Repositories/
├── Integration/
│   ├── API/
│   ├── Persistence/
│   └── Services/
├── UI/
│   ├── Pages/
│   └── Components/
├── Helpers/
│   ├── AutoMapperHelper.cs
│   ├── DatabaseHelper.cs
│   └── TestAuthenticationHandler.cs
└── TestBase/
    ├── IntegrationTestBase.cs
    └── TestContainerBase.cs
```

## 2. NuGet Package Installation

```xml
<ItemGroup>
    <!-- Core Testing Packages -->
    <PackageReference Include="xunit" Version="2.4.2" />
    <PackageReference Include="xunit.runner.visualstudio" Version="2.4.5" />
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.7.0" />
    
    <!-- Mocking -->
    <PackageReference Include="Moq" Version="4.18.4" />
    <PackageReference Include="AutoFixture" Version="4.18.0" />
    <PackageReference Include="AutoFixture.AutoMoq" Version="4.18.0" />
    
    <!-- Assertions -->
    <PackageReference Include="FluentAssertions" Version="6.11.0" />
    
    <!-- Integration Testing -->
    <PackageReference Include="Microsoft.AspNetCore.Mvc.Testing" Version="7.0.9" />
    <PackageReference Include="Testcontainers" Version="3.3.0" />
    <PackageReference Include="Testcontainers.PostgreSql" Version="3.3.0" />
    
    <!-- UI Testing -->
    <PackageReference Include="Playwright" Version="1.36.0" />
    <PackageReference Include="Microsoft.Playwright.MSTest" Version="1.36.0" />
</ItemGroup>
```

## 3. Base Test Classes

### TestContainerBase.cs
```csharp
public abstract class TestContainerBase : IAsyncLifetime
{
    private readonly PostgreSqlContainer _dbContainer;
    protected string ConnectionString { get; private set; }

    protected TestContainerBase()
    {
        _dbContainer = new PostgreSqlBuilder()
            .WithImage("postgres:15-alpine")
            .WithDatabase("test_db")
            .WithUsername("test_user")
            .WithPassword("test_pass")
            .Build();
    }

    public async Task InitializeAsync()
    {
        await _dbContainer.StartAsync();
        ConnectionString = _dbContainer.GetConnectionString();
        
        // Initialize database schema
        await using var scope = GetTestServices().CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        await context.Database.MigrateAsync();
    }

    public async Task DisposeAsync()
    {
        await _dbContainer.DisposeAsync();
    }

    protected virtual IServiceProvider GetTestServices()
    {
        var services = new ServiceCollection();

        // Add services required for testing
        services.AddDbContext<ApplicationDbContext>(options =>
            options.UseNpgsql(ConnectionString));

        return services.BuildServiceProvider();
    }
}
```

### IntegrationTestBase.cs
```csharp
public class IntegrationTestBase : IClassFixture<WebApplicationFactory<Program>>, IAsyncLifetime
{
    protected readonly WebApplicationFactory<Program> Factory;
    protected readonly HttpClient Client;

    protected IntegrationTestBase(WebApplicationFactory<Program> factory)
    {
        Factory = factory.WithWebHostBuilder(builder =>
        {
            builder.ConfigureTestServices(services =>
            {
                // Replace services with test versions
                var dbContextDescriptor = services.SingleOrDefault(
                    d => d.ServiceType == typeof(DbContextOptions<ApplicationDbContext>));

                if (dbContextDescriptor != null)
                    services.Remove(dbContextDescriptor);

                services.AddDbContext<ApplicationDbContext>(options =>
                {
                    options.UseInMemoryDatabase("TestDb");
                });

                // Add authentication test handler
                services.AddAuthentication("Test")
                    .AddScheme<AuthenticationSchemeOptions, TestAuthenticationHandler>(
                        "Test", options => { });
            });
        });

        Client = Factory.CreateClient(new WebApplicationFactoryClientOptions
        {
            AllowAutoRedirect = false
        });
    }

    public virtual Task InitializeAsync() => Task.CompletedTask;

    public virtual Task DisposeAsync() => Task.CompletedTask;
}
```

## 4. Unit Testing Examples

### Service Tests
```csharp
public class UserServiceTests
{
    private readonly IFixture _fixture;
    private readonly Mock<IUserRepository> _userRepositoryMock;
    private readonly Mock<IUnitOfWork> _unitOfWorkMock;
    private readonly IMapper _mapper;
    private readonly UserService _sut;

    public UserServiceTests()
    {
        _fixture = new Fixture().Customize(new AutoMoqCustomization());
        _userRepositoryMock = new Mock<IUserRepository>();
        _unitOfWorkMock = new Mock<IUnitOfWork>();
        
        var config = new MapperConfiguration(cfg => 
            cfg.AddProfile<UserMappingProfile>());
        _mapper = config.CreateMapper();

        _unitOfWorkMock
            .Setup(x => x.Repository<User>())
            .Returns(_userRepositoryMock.Object);

        _sut = new UserService(
            _unitOfWorkMock.Object,
            _mapper,
            Mock.Of<ILogger<UserService>>());
    }

    [Fact]
    public async Task GetUserById_WhenUserExists_ReturnsUserDto()
    {
        // Arrange
        var user = _fixture.Create<User>();
        _userRepositoryMock
            .Setup(x => x.GetByIdAsync(user.Id))
            .ReturnsAsync(user);

        // Act
        var result = await _sut.GetByIdAsync(user.Id);

        // Assert
        result.Should().NotBeNull();
        result.Id.Should().Be(user.Id);
        result.Email.Should().Be(user.Email);
    }

    [Fact]
    public async Task GetUserById_WhenUserDoesNotExist_ThrowsNotFoundException()
    {
        // Arrange
        var userId = Guid.NewGuid();
        _userRepositoryMock
            .Setup(x => x.GetByIdAsync(userId))
            .ReturnsAsync((User)null);

        // Act & Assert
        await _sut.Invoking(x => x.GetByIdAsync(userId))
            .Should().ThrowAsync<NotFoundException>();
    }
}
```

### Repository Tests
```csharp
public class UserRepositoryTests : TestContainerBase
{
    private readonly ApplicationDbContext _context;
    private readonly UserRepository _sut;

    public UserRepositoryTests()
    {
        _context = new ApplicationDbContext(
            new DbContextOptionsBuilder<ApplicationDbContext>()
                .UseNpgsql(ConnectionString)
                .Options);

        _sut = new UserRepository(_context);
    }

    [Fact]
    public async Task GetByEmail_WhenUserExists_ReturnsUser()
    {
        // Arrange
        var user = new User
        {
            Email = "test@example.com",
            PasswordHash = "hash",
            FirstName = "Test",
            LastName = "User"
        };
        
        await _context.Users.AddAsync(user);
        await _context.SaveChangesAsync();

        // Act
        var result = await _sut.GetByEmailAsync(user.Email);

        // Assert
        result.Should().NotBeNull();
        result.Email.Should().Be(user.Email);
    }
}
```

## 5. Integration Testing Examples

### Page Model Tests
```csharp
public class CreateUserPageTests : IntegrationTestBase
{
    public CreateUserPageTests(WebApplicationFactory<Program> factory) 
        : base(factory)
    {
    }

    [Fact]
    public async Task OnPostAsync_WithValidModel_CreatesUserAndRedirects()
    {
        // Arrange
        var formData = new Dictionary<string, string>
        {
            { "UserCreateModel.Email", "test@example.com" },
            { "UserCreateModel.Password", "Test123!" },
            { "UserCreateModel.FirstName", "Test" },
            { "UserCreateModel.LastName", "User" }
        };

        // Act
        var response = await Client.PostAsync("/Users/Create", 
            new FormUrlEncodedContent(formData));

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Redirect);
        response.Headers.Location.ToString()
            .Should().Contain("/Users/Index");
    }
}
```

### API Integration Tests
```csharp
public class UserApiTests : IntegrationTestBase
{
    public UserApiTests(WebApplicationFactory<Program> factory) 
        : base(factory)
    {
    }

    [Fact]
    public async Task GetUsers_ReturnsSuccessAndUsersList()
    {
        // Arrange
        await AddTestUsers();

        // Act
        var response = await Client.GetAsync("/api/users");
        var users = await response.Content
            .ReadFromJsonAsync<List<UserDto>>();

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        users.Should().NotBeEmpty();
    }

    private async Task AddTestUsers()
    {
        var scope = Factory.Services.CreateScope();
        var context = scope.ServiceProvider
            .GetRequiredService<ApplicationDbContext>();

        await context.Users.AddRangeAsync(new[]
        {
            new User { Email = "user1@test.com" },
            new User { Email = "user2@test.com" }
        });

        await context.SaveChangesAsync();
    }
}
```

## 6. UI Testing with Playwright

### Page Object Model
```csharp
public class LoginPage
{
    private readonly IPage _page;

    public LoginPage(IPage page)
    {
        _page = page;
    }

    private ILocator EmailInput => _page.Locator("input[name='Email']");
    private ILocator PasswordInput => _page.Locator("input[name='Password']");
    private ILocator LoginButton => _page.Locator("button[type='submit']");
    private ILocator ErrorMessage => _page.Locator(".validation-summary-errors");

    public async Task NavigateAsync()
    {
        await _page.GotoAsync("/Account/Login");
    }

    public async Task LoginAsync(string email, string password)
    {
        await EmailInput.FillAsync(email);
        await PasswordInput.FillAsync(password);
        await LoginButton.ClickAsync();
    }

    public async Task<string> GetErrorMessageAsync()
    {
        return await ErrorMessage.TextContentAsync();
    }
}
```

### UI Test Example
```csharp
public class LoginTests : PageTest
{
    private LoginPage _loginPage;

    public override async Task InitializeAsync()
    {
        await base.InitializeAsync();
        _loginPage = new LoginPage(Page);
    }

    [Test]
    public async Task Login_WithValidCredentials_RedirectsToDashboard()
    {
        // Arrange
        await _loginPage.NavigateAsync();

        // Act
        await _loginPage.LoginAsync("test@example.com", "Test123!");

        // Assert
        await Expect(Page).ToHaveURLAsync("/Dashboard");
    }

    [Test]
    public async Task Login_WithInvalidCredentials_ShowsError()
    {
        // Arrange
        await _loginPage.NavigateAsync();

        // Act
        await _loginPage.LoginAsync("invalid@example.com", "wrong!");

        // Assert
        await Expect(Page.Locator(".validation-summary-errors"))
            .ToContainTextAsync("Invalid login attempt");
    }
}
```

## 7. Test Data Management

### DatabaseHelper.cs
```csharp
public static class DatabaseHelper
{
    public static async Task ResetDatabase(ApplicationDbContext context)
    {
        context.Users.RemoveRange(await context.Users.ToListAsync());
        context.Roles.RemoveRange(await context.Roles.ToListAsync());
        await context.SaveChangesAsync();
    }

    public static async Task SeedTestData(ApplicationDbContext context)
    {
        var users = new[]
        {
            new User 
            { 
                Email = "admin@test.com",
                Role = "Admin",
                IsActive = true
            },
            new User 
            { 
                Email = "user@test.com",
                Role = "User",
                IsActive = true
            }
        };

        await context.Users.AddRangeAsync(users);
        await context.SaveChangesAsync();
    }
}
```

## 8. Test Configuration

### xunit.runner.json
```json
{
  "$schema": "https://xunit.net/schema/current/xunit.runner.schema.json",
  "parallelizeTestCollections": true,
  "maxParallelThreads": 0,
  "diagnosticMessages": false,
  "methodDisplay": "method",
  "methodDisplayOptions": "all"
}
```

## 9. Best Practices

1. **Test Organization**
   - Follow AAA (Arrange-Act-Assert) pattern
   - One assertion per test method
   - Use meaningful test names describing scenario and expected outcome
   - Group related tests in test classes

2. **Test Data**
   - Use AutoFixture for test data generation
   - Create specific test data only when necessary
   - Clean up test data after tests
   - Use meaningful test data that represents real scenarios

3. **Mocking**
   - Mock only what's necessary
   - Use strict mocking to catch unexpected calls
   - Verify important interactions
   - Keep mock setup simple and readable

4. **Integration Tests**
   - Use TestContainers for database tests
   - Clean state between tests
   - Test complete workflows
   - Include error scenarios

5. **UI Tests**
   - Use Page Object Model pattern
   - Test critical user journeys
   - Include accessibility tests
   - Test responsive design

6. **Performance**
   - Run tests in parallel when possible
   - Use appropriate test isolation
   - Clean up resources properly
   - Monitor test execution time

7. **Maintenance**
   - Keep tests simple and readable
   - Avoid test interdependence
   - Regular test maintenance
   - Document special test requirements

## 10. CI/CD Integration

### azure-pipelines.yml Example
```yaml
trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'

variables:
  solution: '**/*.sln'
  buildPlatform: 'Any CPU'
  buildConfiguration: 'Release'

steps:
- task: UseDotNet@2
  inputs:
    packageType: 'sdk'
    version: '7.0.x'

- task: DotNetCoreCLI@2
  inputs:
    command: 'restore'
    projects: '$(solution)'

- task: DotNetCoreCLI@2
  inputs:
    command: 'build'
    projects: '$(solution)'
    arguments: '--configuration $(buildConfiguration)'

- task: DotNetCoreCLI@2
  inputs:
    command: 'test'
    projects: '**/*Tests/*.csproj'
    arguments: '--configuration $(buildConfiguration) --collect "Code coverage"'

- task: PublishTestResults@2
  inputs:
    testRunner: VSTest
    testResultsFiles: '**/*.trx'

- task: PublishCodeCoverageResults@1
  inputs:
    codeCoverageTool: 'Cobertura'
    summaryFileLocation: '$(Agent.TempDirectory)/**/coverage.cobertura.xml'
```
