# Service Layer Implementation Guide

This guide provides step-by-step instructions for implementing the Service Layer in an ASP.NET Core application.

## 1. Project Structure

```plaintext
YourProject.Application/
├── Services/
│   ├── Interfaces/
│   │   ├── IBaseService.cs
│   │   └── [DomainModel]Service/
│   │       └── I[DomainModel]Service.cs
│   ├── Base/
│   │   └── BaseService.cs
│   └── Implementations/
│       └── [DomainModel]Service/
│           ├── [DomainModel]Service.cs
│           └── [DomainModel]Validator.cs
├── DTOs/
│   └── [DomainModel]/
│       ├── [DomainModel]CreateDto.cs
│       ├── [DomainModel]UpdateDto.cs
│       └── [DomainModel]Dto.cs
├── Exceptions/
│   ├── ApplicationException.cs
│   ├── NotFoundException.cs
│   └── ValidationException.cs
├── Mappings/
│   └── MappingProfile.cs
└── Validators/
    └── [DomainModel]/
        ├── [DomainModel]CreateValidator.cs
        └── [DomainModel]UpdateValidator.cs
```

## 2. NuGet Package Installation

```xml
<ItemGroup>
    <!-- Core Packages -->
    <PackageReference Include="AutoMapper.Extensions.Microsoft.DependencyInjection" Version="12.0.1" />
    <PackageReference Include="FluentValidation.AspNetCore" Version="11.3.0" />
    <PackageReference Include="MediatR.Extensions.Microsoft.DependencyInjection" Version="11.1.0" />
    
    <!-- Caching -->
    <PackageReference Include="Microsoft.Extensions.Caching.StackExchangeRedis" Version="7.0.0" />
    
    <!-- Testing -->
    <PackageReference Include="Moq" Version="4.18.0" />
    <PackageReference Include="FluentAssertions" Version="6.8.0" />
    <PackageReference Include="xunit" Version="2.4.2" />
</ItemGroup>
```

## 3. Base Service Implementation

### IBaseService.cs
```csharp
public interface IBaseService<TEntity, TDto, TCreateDto, TUpdateDto>
    where TEntity : class
    where TDto : class
    where TCreateDto : class
    where TUpdateDto : class
{
    // Task<TDto> GetByIdAsync(Guid id);
    Task<IReadOnlyList<TDto>> ListAllAsync();
    Task<TDto> CreateAsync(TCreateDto createDto);
    Task<TDto> UpdateAsync(Guid id, TUpdateDto updateDto);
    Task DeleteAsync(Guid id);
}
```

### BaseService.cs
```csharp
public abstract class BaseService<TEntity, TDto, TCreateDto, TUpdateDto> : 
    IBaseService<TEntity, TDto, TCreateDto, TUpdateDto>
    where TEntity : class
    where TDto : class
    where TCreateDto : class
    where TUpdateDto : class
{
    protected readonly IUnitOfWork _unitOfWork;
    protected readonly IMapper _mapper;
    protected readonly ILogger _logger;
    protected readonly IValidator<TCreateDto> _createValidator;
    protected readonly IValidator<TUpdateDto> _updateValidator;

    protected BaseService(
        IUnitOfWork unitOfWork,
        IMapper mapper,
        ILogger logger,
        IValidator<TCreateDto> createValidator,
        IValidator<TUpdateDto> updateValidator)
    {
        _unitOfWork = unitOfWork;
        _mapper = mapper;
        _logger = logger;
        _createValidator = createValidator;
        _updateValidator = updateValidator;
    }

    public virtual async Task<TDto> GetByIdAsync(Guid id)
    {
        var entity = await _unitOfWork.Repository<TEntity>().GetByIdAsync(id);
        if (entity == null)
            throw new NotFoundException($"{typeof(TEntity).Name} with id {id} not found");

        return _mapper.Map<TDto>(entity);
    }

    public virtual async Task<IReadOnlyList<TDto>> ListAllAsync()
    {
        var entities = await _unitOfWork.Repository<TEntity>().ListAllAsync();
        return _mapper.Map<IReadOnlyList<TDto>>(entities);
    }

    public virtual async Task<TDto> CreateAsync(TCreateDto createDto)
    {
        var validationResult = await _createValidator.ValidateAsync(createDto);
        if (!validationResult.IsValid)
            throw new ValidationException(validationResult.Errors);

        var entity = _mapper.Map<TEntity>(createDto);
        await _unitOfWork.Repository<TEntity>().AddAsync(entity);
        return _mapper.Map<TDto>(entity);
    }

    public virtual async Task<TDto> UpdateAsync(Guid id, TUpdateDto updateDto)
    {
        var validationResult = await _updateValidator.ValidateAsync(updateDto);
        if (!validationResult.IsValid)
            throw new ValidationException(validationResult.Errors);

        var entity = await _unitOfWork.Repository<TEntity>().GetByIdAsync(id);
        if (entity == null)
            throw new NotFoundException($"{typeof(TEntity).Name} with id {id} not found");

        _mapper.Map(updateDto, entity);
        await _unitOfWork.Repository<TEntity>().UpdateAsync(entity);
        return _mapper.Map<TDto>(entity);
    }

    public virtual async Task DeleteAsync(Guid id)
    {
        var entity = await _unitOfWork.Repository<TEntity>().GetByIdAsync(id);
        if (entity == null)
            throw new NotFoundException($"{typeof(TEntity).Name} with id {id} not found");

        await _unitOfWork.Repository<TEntity>().DeleteAsync(entity);
    }
}
```

## 4. DTOs and Validation

### UserDto.cs
```csharp
public class UserDto
{
    public Guid Id { get; set; }
    public string Email { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public DateTime CreatedAt { get; set; }
    public bool IsActive { get; set; }
}

public class UserCreateDto
{
    public string Email { get; set; }
    public string Password { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
}

public class UserUpdateDto
{
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public bool IsActive { get; set; }
}
```

### UserValidator.cs
```csharp
public class UserCreateValidator : AbstractValidator<UserCreateDto>
{
    public UserCreateValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty()
            .EmailAddress()
            .MaximumLength(256);

        RuleFor(x => x.Password)
            .NotEmpty()
            .MinimumLength(8)
            .MaximumLength(100)
            .Matches("[A-Z]").WithMessage("Password must contain at least one uppercase letter")
            .Matches("[a-z]").WithMessage("Password must contain at least one lowercase letter")
            .Matches("[0-9]").WithMessage("Password must contain at least one number")
            .Matches("[^a-zA-Z0-9]").WithMessage("Password must contain at least one special character");

        RuleFor(x => x.FirstName)
            .NotEmpty()
            .MaximumLength(100);

        RuleFor(x => x.LastName)
            .NotEmpty()
            .MaximumLength(100);
    }
}
```

## 5. Service Implementation Example

### IUserService.cs
```csharp
public interface IUserService : IBaseService<User, UserDto, UserCreateDto, UserUpdateDto>
{
    Task<UserDto> GetByEmailAsync(string email);
    Task<bool> ChangePasswordAsync(Guid id, string currentPassword, string newPassword);
    Task<bool> DeactivateAccountAsync(Guid id);
}
```

### UserService.cs
```csharp
public class UserService : BaseService<User, UserDto, UserCreateDto, UserUpdateDto>, IUserService
{
    private readonly IPasswordHasher _passwordHasher;
    private readonly ICacheService _cacheService;

    public UserService(
        IUnitOfWork unitOfWork,
        IMapper mapper,
        ILogger<UserService> logger,
        IValidator<UserCreateDto> createValidator,
        IValidator<UserUpdateDto> updateValidator,
        IPasswordHasher passwordHasher,
        ICacheService cacheService)
        : base(unitOfWork, mapper, logger, createValidator, updateValidator)
    {
        _passwordHasher = passwordHasher;
        _cacheService = cacheService;
    }

    public async Task<UserDto> GetByEmailAsync(string email)
    {
        var cacheKey = $"user_email_{email}";
        var cachedUser = await _cacheService.GetAsync<UserDto>(cacheKey);
        if (cachedUser != null)
            return cachedUser;

        var spec = new UserByEmailSpecification(email);
        var user = await _unitOfWork.Repository<User>().FirstOrDefaultAsync(spec);
        if (user == null)
            throw new NotFoundException($"User with email {email} not found");

        var userDto = _mapper.Map<UserDto>(user);
        await _cacheService.SetAsync(cacheKey, userDto, TimeSpan.FromMinutes(30));
        
        return userDto;
    }

    public async Task<bool> ChangePasswordAsync(Guid id, string currentPassword, string newPassword)
    {
        var user = await _unitOfWork.Repository<User>().GetByIdAsync(id);
        if (user == null)
            throw new NotFoundException($"User with id {id} not found");

        if (!_passwordHasher.Verify(currentPassword, user.PasswordHash))
            throw new ValidationException("Current password is incorrect");

        user.PasswordHash = _passwordHasher.Hash(newPassword);
        await _unitOfWork.Repository<User>().UpdateAsync(user);

        return true;
    }

    public async Task<bool> DeactivateAccountAsync(Guid id)
    {
        await _unitOfWork.BeginTransactionAsync();
        try
        {
            var user = await _unitOfWork.Repository<User>().GetByIdAsync(id);
            if (user == null)
                throw new NotFoundException($"User with id {id} not found");

            user.IsActive = false;
            user.DeactivatedAt = DateTime.UtcNow;
            await _unitOfWork.Repository<User>().UpdateAsync(user);

            // Clean up related data
            var userSessions = await _unitOfWork.Repository<UserSession>()
                .ListAsync(new UserSessionsByUserIdSpecification(id));
            
            foreach (var session in userSessions)
            {
                await _unitOfWork.Repository<UserSession>().DeleteAsync(session);
            }

            await _unitOfWork.CommitTransactionAsync();
            return true;
        }
        catch (Exception ex)
        {
            await _unitOfWork.RollbackTransactionAsync();
            _logger.LogError(ex, "Error deactivating account for user {UserId}", id);
            throw;
        }
    }

    public override async Task<UserDto> CreateAsync(UserCreateDto createDto)
    {
        // Check if email already exists
        var existingUser = await _unitOfWork.Repository<User>()
            .FirstOrDefaultAsync(new UserByEmailSpecification(createDto.Email));
        
        if (existingUser != null)
            throw new ValidationException("Email already registered");

        // Hash password before creating user
        var user = _mapper.Map<User>(createDto);
        user.PasswordHash = _passwordHasher.Hash(createDto.Password);
        
        return await base.CreateAsync(createDto);
    }
}
```

## 6. Dependency Registration

```csharp
public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddApplicationServices(
        this IServiceCollection services, IConfiguration configuration)
    {
        // AutoMapper
        services.AddAutoMapper(Assembly.GetExecutingAssembly());

        // FluentValidation
        services.AddValidatorsFromAssembly(Assembly.GetExecutingAssembly());

        // Redis Cache
        services.AddStackExchangeRedisCache(options =>
        {
            options.Configuration = configuration.GetConnectionString("Redis");
            options.InstanceName = "YourApp_";
        });

        // Services
        services.AddScoped<IUserService, UserService>();
        // Add other services...

        return services;
    }
}
```

## 7. Testing Example

```csharp
public class UserServiceTests
{
    private readonly Mock<IUnitOfWork> _unitOfWorkMock;
    private readonly Mock<IMapper> _mapperMock;
    private readonly Mock<ILogger<UserService>> _loggerMock;
    private readonly Mock<IValidator<UserCreateDto>> _createValidatorMock;
    private readonly Mock<IValidator<UserUpdateDto>> _updateValidatorMock;
    private readonly Mock<IPasswordHasher> _passwordHasherMock;
    private readonly Mock<ICacheService> _cacheServiceMock;
    
    private readonly UserService _userService;

    public UserServiceTests()
    {
        _unitOfWorkMock = new Mock<IUnitOfWork>();
        _mapperMock = new Mock<IMapper>();
        _loggerMock = new Mock<ILogger<UserService>>();
        _createValidatorMock = new Mock<IValidator<UserCreateDto>>();
        _updateValidatorMock = new Mock<IValidator<UserUpdateDto>>();
        _passwordHasherMock = new Mock<IPasswordHasher>();
        _cacheServiceMock = new Mock<ICacheService>();

        _userService = new UserService(
            _unitOfWorkMock.Object,
            _mapperMock.Object,
            _loggerMock.Object,
            _createValidatorMock.Object,
            _updateValidatorMock.Object,
            _passwordHasherMock.Object,
            _cacheServiceMock.Object
        );
    }

    [Fact]
    public async Task CreateAsync_WithValidData_ShouldCreateUser()
    {
        // Arrange
        var createDto = new UserCreateDto
        {
            Email = "test@example.com",
            Password = "Test123!",
            FirstName = "Test",
            LastName = "User"
        };

        var user = new User { Id = Guid.NewGuid() };
        var userDto = new UserDto { Id = user.Id };

        _createValidatorMock.Setup(x => x.ValidateAsync(createDto, default))
            .ReturnsAsync(new ValidationResult());

        _mapperMock.Setup(x => x.Map<User>(createDto))
            .Returns(user);

        _mapperMock.Setup(x => x.Map<UserDto>(user))
            .Returns(userDto);

        _unitOfWorkMock.Setup(x => x.Repository<User>())
            .Returns(Mock.Of<IGenericRepository<User>>());

        // Act
        var result = await _userService.CreateAsync(createDto);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(user.Id, result.Id);
    }

    [Fact]
    public async Task GetByEmailAsync_WithCachedUser_ShouldReturnFromCache()
    {
        // Arrange
        var email = "test@example.com";
        var cachedUser = new UserDto { Email = email };

        _cacheServiceMock.Setup(x => x.GetAsync<UserDto>($"user_email_{email}"))
            .ReturnsAsync(cachedUser);

        // Act
        var result = await _userService.GetByEmailAsync(email);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(email, result.Email);
        _unitOfWorkMock.Verify(x => x.Repository<User>(), Times.Never);
    }
}
```
