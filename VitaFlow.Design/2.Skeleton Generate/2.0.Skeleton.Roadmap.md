# VitaFlow Skeleton Generation Strategy Guide

This document outlines the strategy for breaking down the VitaFlow project planning document into manageable parts for skeleton generation.

## Recommended Generation Order

For efficient skeleton generation, follow this incremental approach:

1. **Project Structure** (2.Skeleton.ProjectStructure.Prompt.md)
   - Generate solution and project files
   - Set up basic configuration
   - Create folder structure

2. **Domain Models** (2.Skeleton.Domain.Prompt.md)
   - Generate entity classes
   - Generate enums
   - These form the foundation of the application

3. **Repositories** (2.Skeleton.Repositories.Prompt.md)
   - Generate repository interfaces
   - Generate repository implementations
   - Set up the database context

4. **Services** (2.Skeleton.Services.Prompt.md)
   - Generate service interfaces
   - Generate service implementations
   - Implement business logic layer

5. **Page Models & View Models** (2.Skeleton.PageModels.Prompt.md)
   - Generate Razor Pages
   - Generate view models
   - Set up the UI layer

## Instructions for Using the Prompts

1. Submit each prompt file to the Skeleton Generator Agent (GPT-4o recommended)
2. After each generation, verify that the output is correct before proceeding to the next step
3. If needed, make adjustments to the generated files before continuing
4. Follow the order specified above to ensure dependencies are correctly established

## Benefits of This Approach

- Breaking down the large planning document makes it more manageable for the AI
- The incremental approach ensures proper layering and dependencies
- Each prompt focuses on a specific aspect of the application
- Generation follows the natural dependency flow of the application

## Next Steps

After skeleton generation is complete, proceed to the Implementation phase using the generated skeleton files as a foundation.
