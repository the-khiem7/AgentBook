# Razor Pages Implementation Guide

This guide provides step-by-step instructions for implementing Razor Pages in an ASP.NET Core application.

## 1. Project Structure

```plaintext
YourProject.Web/
├── Pages/
│   ├── Shared/
│   │   ├── _Layout.cshtml
│   │   ├── _ValidationScriptsPartial.cshtml
│   │   └── Components/
│   │       ├── Alert/
│   │       └── Pagination/
│   ├── _ViewImports.cshtml
│   ├── _ViewStart.cshtml
│   └── [Feature]/
│       ├── Index.cshtml
│       ├── Index.cshtml.cs
│       ├── Create.cshtml
│       ├── Create.cshtml.cs
│       ├── Edit.cshtml
│       ├── Edit.cshtml.cs
│       ├── Details.cshtml
│       └── Details.cshtml.cs
├── ViewModels/
│   └── [Feature]/
│       ├── IndexViewModel.cs
│       ├── CreateViewModel.cs
│       └── EditViewModel.cs
└── Filters/
    ├── PageModelValidationFilter.cs
    └── ExceptionHandlerFilter.cs
```

## 2. Base Page Model Implementation

### BasePageModel.cs
```csharp
public abstract class BasePageModel : PageModel
{
    protected readonly ILogger _logger;
    protected readonly IMapper _mapper;
    protected readonly INotifier _notifier;

    protected BasePageModel(
        ILogger logger,
        IMapper mapper,
        INotifier notifier)
    {
        _logger = logger;
        _mapper = mapper;
        _notifier = notifier;
    }

    protected void SetSuccessMessage(string message)
    {
        _notifier.Success(message);
    }

    protected void SetErrorMessage(string message)
    {
        _notifier.Error(message);
    }

    protected IActionResult RedirectToIndexWithMessage(string message, bool isSuccess = true)
    {
        if (isSuccess)
            SetSuccessMessage(message);
        else
            SetErrorMessage(message);

        return RedirectToPage("./Index");
    }

    protected async Task<IActionResult> HandleCommandAsync(
        Func<Task> action,
        string successMessage,
        string errorMessage = null)
    {
        try
        {
            await action();
            return RedirectToIndexWithMessage(successMessage);
        }
        catch (ValidationException ex)
        {
            foreach (var error in ex.Errors)
            {
                ModelState.AddModelError(error.PropertyName, error.ErrorMessage);
            }
            return Page();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error performing action");
            return RedirectToIndexWithMessage(
                errorMessage ?? "An error occurred while processing your request.", 
                false);
        }
    }
}
```

## 3. Example Page Model Implementation

### Index.cshtml.cs
```csharp
public class IndexModel : BasePageModel
{
    private readonly IUserService _userService;

    public IndexModel(
        ILogger<IndexModel> logger,
        IMapper mapper,
        INotifier notifier,
        IUserService userService)
        : base(logger, mapper, notifier)
    {
        _userService = userService;
    }

    [BindProperty(SupportsGet = true)]
    public IndexViewModel ViewModel { get; set; } = new();

    public async Task<IActionResult> OnGetAsync()
    {
        try
        {
            var users = await _userService.ListAllAsync();
            ViewModel.Users = _mapper.Map<List<UserDto>>(users);
            return Page();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving users");
            SetErrorMessage("Failed to load users");
            return Page();
        }
    }
}
```

### Index.cshtml
```cshtml
@page
@model IndexModel
@{
    ViewData["Title"] = "Users";
}

<div class="container mx-auto px-4 py-8">
    <div class="flex justify-between items-center mb-6">
        <h1 class="text-2xl font-bold">Users</h1>
        <a asp-page="Create" class="btn-primary">Create New</a>
    </div>

    <div class="bg-white rounded-lg shadow-md">
        @if (Model.ViewModel.Users?.Any() == true)
        {
            <table class="min-w-full">
                <thead>
                    <tr>
                        <th class="px-6 py-3 border-b">Name</th>
                        <th class="px-6 py-3 border-b">Email</th>
                        <th class="px-6 py-3 border-b">Status</th>
                        <th class="px-6 py-3 border-b">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach (var user in Model.ViewModel.Users)
                    {
                        <tr>
                            <td class="px-6 py-4 border-b">
                                @user.FullName
                            </td>
                            <td class="px-6 py-4 border-b">
                                @user.Email
                            </td>
                            <td class="px-6 py-4 border-b">
                                <span class="@(user.IsActive ? "badge-success" : "badge-danger")">
                                    @(user.IsActive ? "Active" : "Inactive")
                                </span>
                            </td>
                            <td class="px-6 py-4 border-b">
                                <div class="flex space-x-2">
                                    <a asp-page="./Edit" asp-route-id="@user.Id" 
                                       class="btn-secondary">Edit</a>
                                    <a asp-page="./Details" asp-route-id="@user.Id" 
                                       class="btn-info">Details</a>
                                </div>
                            </td>
                        </tr>
                    }
                </tbody>
            </table>
        }
        else
        {
            <div class="p-6 text-center text-gray-500">
                No users found.
            </div>
        }
    </div>
</div>

@section Scripts {
    <partial name="_ValidationScriptsPartial" />
}
```

## 4. Form Handling Example

### Create.cshtml.cs
```csharp
public class CreateModel : BasePageModel
{
    private readonly IUserService _userService;

    public CreateModel(
        ILogger<CreateModel> logger,
        IMapper mapper,
        INotifier notifier,
        IUserService userService)
        : base(logger, mapper, notifier)
    {
        _userService = userService;
    }

    [BindProperty]
    public CreateUserViewModel ViewModel { get; set; }

    public IActionResult OnGet()
    {
        return Page();
    }

    public async Task<IActionResult> OnPostAsync()
    {
        if (!ModelState.IsValid)
            return Page();

        return await HandleCommandAsync(
            async () =>
            {
                var dto = _mapper.Map<UserCreateDto>(ViewModel);
                await _userService.CreateAsync(dto);
            },
            "User created successfully.");
    }
}
```

### Create.cshtml
```cshtml
@page
@model CreateModel
@{
    ViewData["Title"] = "Create User";
}

<div class="container mx-auto px-4 py-8">
    <div class="max-w-2xl mx-auto">
        <div class="flex justify-between items-center mb-6">
            <h1 class="text-2xl font-bold">Create User</h1>
            <a asp-page="Index" class="btn-secondary">Back to List</a>
        </div>

        <div class="bg-white rounded-lg shadow-md p-6">
            <form method="post">
                <div asp-validation-summary="ModelOnly" class="text-red-500 mb-4"></div>

                <div class="mb-4">
                    <label asp-for="ViewModel.Email" class="form-label"></label>
                    <input asp-for="ViewModel.Email" class="form-input" />
                    <span asp-validation-for="ViewModel.Email" class="text-red-500"></span>
                </div>

                <div class="mb-4">
                    <label asp-for="ViewModel.Password" class="form-label"></label>
                    <input asp-for="ViewModel.Password" type="password" class="form-input" />
                    <span asp-validation-for="ViewModel.Password" class="text-red-500"></span>
                </div>

                <div class="grid grid-cols-2 gap-4 mb-4">
                    <div>
                        <label asp-for="ViewModel.FirstName" class="form-label"></label>
                        <input asp-for="ViewModel.FirstName" class="form-input" />
                        <span asp-validation-for="ViewModel.FirstName" class="text-red-500"></span>
                    </div>
                    <div>
                        <label asp-for="ViewModel.LastName" class="form-label"></label>
                        <input asp-for="ViewModel.LastName" class="form-input" />
                        <span asp-validation-for="ViewModel.LastName" class="text-red-500"></span>
                    </div>
                </div>

                <div class="flex justify-end space-x-2">
                    <button type="submit" class="btn-primary">Create</button>
                    <a asp-page="Index" class="btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>
</div>

@section Scripts {
    <partial name="_ValidationScriptsPartial" />
}
```

## 5. View Models

### ViewModels/User/IndexViewModel.cs
```csharp
public class IndexViewModel
{
    public List<UserDto> Users { get; set; } = new();
    public string SearchTerm { get; set; }
    public bool ShowInactive { get; set; }
}

public class CreateUserViewModel
{
    [Required]
    [EmailAddress]
    [Display(Name = "Email")]
    public string Email { get; set; }

    [Required]
    [StringLength(100, MinimumLength = 8)]
    [DataType(DataType.Password)]
    [Display(Name = "Password")]
    public string Password { get; set; }

    [Required]
    [Display(Name = "First Name")]
    public string FirstName { get; set; }

    [Required]
    [Display(Name = "Last Name")]
    public string LastName { get; set; }
}
```

## 6. Custom Page Model Filter

```csharp
public class PageModelValidationFilter : IAsyncPageFilter
{
    public async Task OnPageHandlerExecutionAsync(
        PageHandlerExecutingContext context,
        PageHandlerExecutionDelegate next)
    {
        if (!context.ModelState.IsValid && IsPost(context))
        {
            var result = new PageResult();
            result.StatusCode = 400;
            context.Result = result;
            return;
        }

        await next.Invoke();
    }

    private bool IsPost(PageHandlerExecutingContext context)
    {
        return context.HandlerMethod?.HttpMethod == "Post";
    }

    public Task OnPageHandlerSelectionAsync(PageHandlerSelectedContext context)
    {
        return Task.CompletedTask;
    }
}
```

## 7. Testing Example

```csharp
public class CreateModelTests
{
    private readonly Mock<ILogger<CreateModel>> _loggerMock;
    private readonly Mock<IMapper> _mapperMock;
    private readonly Mock<INotifier> _notifierMock;
    private readonly Mock<IUserService> _userServiceMock;
    private readonly CreateModel _pageModel;

    public CreateModelTests()
    {
        _loggerMock = new Mock<ILogger<CreateModel>>();
        _mapperMock = new Mock<IMapper>();
        _notifierMock = new Mock<INotifier>();
        _userServiceMock = new Mock<IUserService>();

        _pageModel = new CreateModel(
            _loggerMock.Object,
            _mapperMock.Object,
            _notifierMock.Object,
            _userServiceMock.Object);
    }

    [Fact]
    public async Task OnPostAsync_WithValidModel_ShouldCreateUser()
    {
        // Arrange
        var viewModel = new CreateUserViewModel
        {
            Email = "test@example.com",
            Password = "Test123!",
            FirstName = "Test",
            LastName = "User"
        };

        var dto = new UserCreateDto();
        _mapperMock.Setup(m => m.Map<UserCreateDto>(viewModel))
            .Returns(dto);

        _pageModel.ViewModel = viewModel;

        // Act
        var result = await _pageModel.OnPostAsync();

        // Assert
        var redirectResult = Assert.IsType<RedirectToPageResult>(result);
        Assert.Equal("Index", redirectResult.PageName);
        _userServiceMock.Verify(x => x.CreateAsync(dto), Times.Once);
    }
}
```

## 8. Registration in Startup

```csharp
public void ConfigureServices(IServiceCollection services)
{
    services.AddRazorPages(options =>
    {
        options.Conventions.AuthorizeFolder("/Admin");
        options.Conventions.AddPageRoute("/Error", "/Error/{code:int}");
    })
    .AddMvcOptions(options =>
    {
        options.Filters.Add<PageModelValidationFilter>();
        options.ModelBindingMessageProvider.SetValueMustNotBeNullAccessor(
            _ => "The field is required.");
    });

    // Register AutoMapper profiles
    services.AddAutoMapper(typeof(Startup));

    // Register services
    services.AddScoped<INotifier, TempDataNotifier>();
}
```
