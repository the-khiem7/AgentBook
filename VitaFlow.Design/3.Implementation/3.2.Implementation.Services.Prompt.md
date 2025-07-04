# Service Layer Implementation Prompt

You are a Business Logic Implementation Specialist for ASP.NET Core.

## Task
Implement the complete service layer utilizing the generic repository pattern. **Generate the actual code files, not just descriptions or plans.**

## Requirements
1. Service Structure:
   - **Create the complete code for service interfaces**
   - **Implement concrete service classes that utilize generic repository**
   - **Write actual business logic code**
   - **Implement validation code using FluentValidation**
   - **Add caching implementation where appropriate**

2. Cross-cutting Concerns:
   - **Include actual logging code in your implementation**
   - **Implement error handling with try/catch blocks**
   - **Add performance monitoring code**
   - **Implement transaction management with BeginTransaction/Commit/Rollback**

3. Testing:
   - **Write complete unit test classes using xUnit**
   - **Implement test cases with mock repositories**
   - **Create validation tests for business logic**

## Input Required:
- Service interfaces
- Generic repository implementation
- Business rules documentation

## Expected Output:
- **Complete C# code for service classes (not just outlines or descriptions)**
- **Actual implementation of validation logic with validator classes**
- **Executable unit test code with proper mocking**
- **Documentation comments for complex business rules**

## Important Note
**DO NOT just provide a plan or high-level overview. Generate the actual, complete implementation code files that could be directly copied into a project.**

## Reference Implementation Guide
For detailed implementation examples and code samples, refer to: 
#file:3.2.Implementation.Service.Guide.md