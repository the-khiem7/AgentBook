# UI Implementation Guide with Tailwind CSS

This guide provides step-by-step instructions for implementing the UI layer using Tailwind CSS in an ASP.NET Core Razor Pages application.

## 1. Project Structure

```plaintext
YourProject.Web/
├── wwwroot/
│   ├── css/
│   │   ├── site.css
│   │   └── tailwind.output.css
│   ├── js/
│   │   ├── site.js
│   │   └── components/
│   │       ├── modal.js
│   │       └── datepicker.js
│   └── lib/
├── Components/
│   ├── Alert/
│   │   ├── Default.razor
│   │   └── AlertViewComponent.cs
│   ├── Modal/
│   │   ├── Default.razor
│   │   └── ModalViewComponent.cs
│   └── Pagination/
│       ├── Default.razor
│       └── PaginationViewComponent.cs
├── Pages/
│   └── Shared/
│       ├── _Layout.cshtml
│       ├── _Components.cshtml
│       └── _Styles.cshtml
└── tailwind.config.js
```

## 2. Package Installation

```json
{
  "devDependencies": {
    "tailwindcss": "^3.3.3",
    "postcss": "^8.4.27",
    "autoprefixer": "^10.4.14",
    "@tailwindcss/forms": "^0.5.4",
    "@tailwindcss/typography": "^0.5.9",
    "@tailwindcss/aspect-ratio": "^0.4.2"
  }
}
```

## 3. Tailwind Configuration

### tailwind.config.js
```javascript
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./Pages/**/*.cshtml",
    "./Components/**/*.razor",
    "./wwwroot/js/**/*.js"
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0f9ff',
          100: '#e0f2fe',
          200: '#bae6fd',
          300: '#7dd3fc',
          400: '#38bdf8',
          500: '#0ea5e9',
          600: '#0284c7',
          700: '#0369a1',
          800: '#075985',
          900: '#0c4a6e',
        },
      },
      animation: {
        'spin-slow': 'spin 3s linear infinite',
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/aspect-ratio'),
  ],
}
```

## 4. Base Components

### Components/_Styles.cshtml
```cshtml
@* Form Styles *@
<style>
.form-label {
    @apply block text-sm font-medium text-gray-700 dark:text-gray-200 mb-1;
}

.form-input {
    @apply mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500 sm:text-sm dark:bg-gray-700 dark:border-gray-600 dark:text-white;
}

.btn {
    @apply inline-flex items-center px-4 py-2 border rounded-md shadow-sm text-sm font-medium focus:outline-none focus:ring-2 focus:ring-offset-2;
}

.btn-primary {
    @apply btn bg-primary-600 border-transparent text-white hover:bg-primary-700 focus:ring-primary-500;
}

.btn-secondary {
    @apply btn bg-white border-gray-300 text-gray-700 hover:bg-gray-50 focus:ring-primary-500;
}

.badge {
    @apply inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium;
}

.badge-success {
    @apply badge bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-100;
}

.badge-danger {
    @apply badge bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-100;
}
</style>
```

## 5. Reusable Components

### Alert Component
```csharp
public class AlertViewComponent : ViewComponent
{
    public IViewComponentResult Invoke(string type, string message)
    {
        var model = new AlertViewModel
        {
            Type = type,
            Message = message
        };
        return View(model);
    }
}
```

```cshtml
@model AlertViewModel
<div class="rounded-md p-4 mb-4 @Model.GetAlertClass()">
    <div class="flex">
        <div class="flex-shrink-0">
            <svg class="h-5 w-5 @Model.GetIconClass()" viewBox="0 0 20 20" fill="currentColor">
                @Model.GetIconPath()
            </svg>
        </div>
        <div class="ml-3">
            <p class="text-sm font-medium @Model.GetTextClass()">
                @Model.Message
            </p>
        </div>
    </div>
</div>
```

### Modal Component
```javascript
// modal.js
export class Modal {
    constructor(id) {
        this.modal = document.getElementById(id);
        this.overlay = document.getElementById(`${id}-overlay`);
        this.setupListeners();
    }

    show() {
        this.modal.classList.remove('hidden');
        this.overlay.classList.remove('hidden');
        document.body.classList.add('overflow-hidden');
    }

    hide() {
        this.modal.classList.add('hidden');
        this.overlay.classList.add('hidden');
        document.body.classList.remove('overflow-hidden');
    }

    setupListeners() {
        const closeButtons = this.modal.querySelectorAll('[data-modal-close]');
        closeButtons.forEach(button => {
            button.addEventListener('click', () => this.hide());
        });

        this.overlay.addEventListener('click', () => this.hide());
    }
}
```

```cshtml
@model ModalViewModel
<div id="@Model.Id" class="hidden fixed z-10 inset-0 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
    <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
        <div id="@(Model.Id)-overlay" class="hidden fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"></div>
        <div class="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
            <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
                <div class="sm:flex sm:items-start">
                    @if (!string.IsNullOrEmpty(Model.Icon))
                    {
                        <div class="mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-@(Model.Type)-100 sm:mx-0 sm:h-10 sm:w-10">
                            @Html.Raw(Model.Icon)
                        </div>
                    }
                    <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left">
                        <h3 class="text-lg leading-6 font-medium text-gray-900" id="modal-title">
                            @Model.Title
                        </h3>
                        <div class="mt-2">
                            @Model.Content
                        </div>
                    </div>
                </div>
            </div>
            <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
                @if (Model.PrimaryButton != null)
                {
                    <button type="button" class="@Model.PrimaryButton.Class" onclick="@Model.PrimaryButton.OnClick">
                        @Model.PrimaryButton.Text
                    </button>
                }
                @if (Model.SecondaryButton != null)
                {
                    <button type="button" class="@Model.SecondaryButton.Class" onclick="@Model.SecondaryButton.OnClick">
                        @Model.SecondaryButton.Text
                    </button>
                }
            </div>
        </div>
    </div>
</div>
```

## 6. Dark Mode Implementation

### _Layout.cshtml
```cshtml
<!DOCTYPE html>
<html lang="en" class="h-full">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>@ViewData["Title"] - YourApp</title>
    <link rel="stylesheet" href="~/css/tailwind.output.css" />
    <script>
        // On page load or when changing themes, best to add inline in `head` to avoid FOUC
        if (localStorage.theme === 'dark' || (!('theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
            document.documentElement.classList.add('dark')
        } else {
            document.documentElement.classList.remove('dark')
        }
    </script>
</head>
<body class="h-full bg-gray-100 dark:bg-gray-900">
    @* Your layout content *@
</body>
</html>
```

### DarkModeToggle.js
```javascript
export class DarkModeToggle {
    constructor(buttonId) {
        this.button = document.getElementById(buttonId);
        this.setup();
    }

    setup() {
        this.button.addEventListener('click', () => this.toggle());
        this.updateIcon();
    }

    toggle() {
        if (document.documentElement.classList.contains('dark')) {
            document.documentElement.classList.remove('dark');
            localStorage.theme = 'light';
        } else {
            document.documentElement.classList.add('dark');
            localStorage.theme = 'dark';
        }
        this.updateIcon();
    }

    updateIcon() {
        const isDark = document.documentElement.classList.contains('dark');
        this.button.innerHTML = isDark ? this.getSunIcon() : this.getMoonIcon();
    }

    getSunIcon() {
        return `<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
            <!-- Sun icon path -->
        </svg>`;
    }

    getMoonIcon() {
        return `<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
            <!-- Moon icon path -->
        </svg>`;
    }
}
```

## 7. Responsive Navigation

```cshtml
<nav class="bg-white shadow dark:bg-gray-800">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
            <div class="flex">
                <!-- Logo -->
                <div class="flex-shrink-0 flex items-center">
                    <img class="h-8 w-auto" src="~/images/logo.svg" alt="Logo">
                </div>

                <!-- Desktop Navigation -->
                <div class="hidden sm:ml-6 sm:flex sm:space-x-8">
                    <a asp-page="/Index" 
                       class="@GetNavLinkClass("Index")">
                        Home
                    </a>
                    <!-- Add more navigation items -->
                </div>
            </div>

            <!-- Mobile menu button -->
            <div class="-mr-2 flex items-center sm:hidden">
                <button type="button" 
                        class="inline-flex items-center justify-center p-2 rounded-md text-gray-400 hover:text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-primary-500"
                        aria-controls="mobile-menu"
                        aria-expanded="false"
                        data-mobile-menu-toggle>
                    <!-- Menu icon -->
                </button>
            </div>
        </div>
    </div>

    <!-- Mobile menu -->
    <div class="sm:hidden hidden" id="mobile-menu">
        <div class="pt-2 pb-3 space-y-1">
            <a asp-page="/Index" 
               class="@GetMobileNavLinkClass("Index")">
                Home
            </a>
            <!-- Add more mobile navigation items -->
        </div>
    </div>
</nav>

@functions {
    private string GetNavLinkClass(string page)
    {
        var currentPage = ViewContext.RouteData.Values["page"]?.ToString();
        var isActive = currentPage?.EndsWith(page) ?? false;
        
        return isActive
            ? "border-primary-500 text-gray-900 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium dark:text-white"
            : "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium dark:text-gray-300 dark:hover:text-white";
    }

    private string GetMobileNavLinkClass(string page)
    {
        var currentPage = ViewContext.RouteData.Values["page"]?.ToString();
        var isActive = currentPage?.EndsWith(page) ?? false;
        
        return isActive
            ? "bg-primary-50 border-primary-500 text-primary-700 block pl-3 pr-4 py-2 border-l-4 text-base font-medium dark:bg-gray-700 dark:text-white"
            : "border-transparent text-gray-500 hover:bg-gray-50 hover:border-gray-300 hover:text-gray-700 block pl-3 pr-4 py-2 border-l-4 text-base font-medium dark:text-gray-300 dark:hover:bg-gray-700 dark:hover:text-white";
    }
}
```

## 8. Form Components

### InputText.cshtml
```cshtml
@model InputTextViewModel
<div class="form-group">
    <label asp-for="@Model.For" class="form-label">@Model.Label</label>
    <input asp-for="@Model.For" 
           class="form-input @(ViewData.ModelState.HasError(Model.For.Name) ? "border-red-500" : "")"
           placeholder="@Model.Placeholder" />
    <span asp-validation-for="@Model.For" class="text-red-500 text-sm mt-1"></span>
</div>
```

### Select.cshtml
```cshtml
@model SelectViewModel
<div class="form-group">
    <label asp-for="@Model.For" class="form-label">@Model.Label</label>
    <select asp-for="@Model.For" 
            asp-items="@Model.Items"
            class="form-select @(ViewData.ModelState.HasError(Model.For.Name) ? "border-red-500" : "")">
        @if (Model.ShowEmptyOption)
        {
            <option value="">@Model.EmptyOptionText</option>
        }
    </select>
    <span asp-validation-for="@Model.For" class="text-red-500 text-sm mt-1"></span>
</div>
```

## 9. Loading States

```cshtml
<button type="submit" class="btn-primary" data-loading>
    <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white hidden" data-loading-indicator fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
    </svg>
    <span data-loading-text>Save</span>
</button>

<script>
document.querySelectorAll('[data-loading]').forEach(button => {
    button.addEventListener('click', () => {
        const indicator = button.querySelector('[data-loading-indicator]');
        const text = button.querySelector('[data-loading-text]');
        
        indicator.classList.remove('hidden');
        text.textContent = 'Saving...';
        button.disabled = true;
    });
});
</script>
```

## 10. Compilation and Build Process

### package.json Scripts
```json
{
  "scripts": {
    "css:dev": "tailwindcss -i ./wwwroot/css/site.css -o ./wwwroot/css/tailwind.output.css --watch",
    "css:build": "tailwindcss -i ./wwwroot/css/site.css -o ./wwwroot/css/tailwind.output.css --minify",
    "css:purge": "tailwindcss -i ./wwwroot/css/site.css -o ./wwwroot/css/tailwind.output.css --minify --purge"
  }
}
```
