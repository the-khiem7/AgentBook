# VitaFlow Agent-Driven Development Guide

## 📁 File Naming Convention

All documentation follows this naming pattern:
```
[Section].[SubSection].[Stage].[Component].[Type].md
```

The naming convention uses parallel numeric-textual pairs:

1. **Phase Level**
   - **Section**: Numeric identifier (1, 2, 3)
     - 1: Planning Phase
     - 2: Skeleton Generate Phase
     - 3: Implementation Phase
     - 4: Review Phase
   - **Stage**: Textual name of the phase
     - Planning: For Section 1
     - Skeleton: For Section 2
     - Implementation: For Section 3
     - Review: For Section 4

2. **Step Level**
   - **SubSection**: Numeric step identifier (1, 2, 3, etc.)
     - 0: Roadmap
     - 1: First component
     - 2: Second component, etc.
   - **Component**: Textual name of the step (framework-agnostic)
     - Roadmap: For SubSection 0 (Project overview)
     - Domain: For SubSection 1 (Core business logic)
     - Data: For SubSection 2 (Data access/storage)
     - Business: For SubSection 3 (Business rules/services)
     - Presentation: For SubSection 4 (UI/API/Interface)
     - Quality: For SubSection 5 (Testing/Validation)

3. **Purpose Level**
   - **Type**: Document's role
     - `Prompt.md` - AI agent input files
     - `Guide.md` - Implementation reference
     - `Scenarios.md` - Developer documentation

File structure breakdown:
```
2.1.Skeleton.Domain.Prompt.md
│ │ │        │     └─ Type (Purpose)
│ │ │        └─ Component (Step name)
│ │ └─ Stage (Phase name)
│ └─── SubSection (Step #)
└───── Section (Phase #)

Example mappings:
| Phase Level | | Step Level | |
|------------|--|------------|--|
| Section | Stage | SubSection | Component |
| 1 | Planning | 0 | Roadmap |
| 2 | Skeleton | 1 | Domain |
| 3 | Implementation | 2 | Data |
| | | 3 | Business |
| | | 4 | Presentation |
| | | 5 | Quality |

2.0.Skeleton.Roadmap.md                # Phase 2, Step 0: Project Structure
2.1.Skeleton.Domain.Prompt.md          # Phase 2, Step 1: Core Business Models
2.2.Skeleton.Data.Guide.md            # Phase 2, Step 2: Data Layer Design
2.3.Skeleton.Business.Scenarios.md     # Phase 2, Step 3: Service Layer Design
```

Exceptions:
- Roadmap files use [Section].0.[Stage].Roadmap.md (e.g., 3.0.Implementation.Roadmap.md)
- Stage matches the section's main purpose (Planning, Skeleton, Implementation)

---

## 🟢 1. Planning-Agent Prompt

✅ **Claude Sonnet 3.7 Thinking (1.25x)**

→ Đây chính là model mà trước đó bạn được khuyên dùng để plan, vì nó **chuyên về reasoning, chia nhỏ bài toán**, cực hợp để vẽ plan + thiết kế class.

```
You are a Senior Software Architect with excellent reasoning and system design skills.

## Context
I want you to analyze the following feature request and produce a **detailed class design plan**.

Your tasks:
1. Understand the feature description I provide.
2. Break it down into components and flows.
3. Propose a class diagram including:
   - Class names
   - Attributes (only define names and types, no implementation)
   - Method signatures (name, parameters, return type)
   - Short purpose/role of each class.
4. Describe the main data flow and interaction between classes.
5. Point out potential improvements or architectural concerns.

## Output format:
- Summary of the feature in your own words.
- Class diagram with:
  - Class name, attributes, methods
  - Relationships (e.g., inheritance, association)
- Data flow explanation (step by step).
- List of assumptions made.
- Additional recommendations (if any).

## Constraints:
- Do not generate method bodies (no implementation).
- Use language-agnostic class design: avoid language-specific syntax like Python decorators or C# attributes.
- Focus on clear naming, maintainability, and SOLID principles.

## Feature description:
"""
[👉👉 Dán yêu cầu tính năng của bạn vào đây 👈👈]
"""

```

---

## 🟢 2. Skeleton-Generator-Agent Prompt

✅ **GPT-4o hoặc o3-mini (0.33x)**

→ Task này không cần suy nghĩ sâu, chỉ cần generate class stub, dùng GPT-4o là quá ổn vì bạn đã “Included” sẵn → tiết kiệm cost.

→ Nếu muốn giảm chi phí hơn nữa mà chấp nhận tốc độ chậm nhẹ, thử **o3-mini (0.33x)**.

```
You are a Skeleton Generator Agent.

Your task is to generate empty class files in [CHOOSE_LANGUAGE, e.g., C#, Java, TypeScript] based on the provided class diagram.

Requirements:
- Create one file per class.
- Each class should include:
  - Class declaration with correct syntax.
  - Attributes as properties or fields (no implementation).
  - Method signatures (no method body).
- Add import/using statements if needed.
- Ensure the files are syntactically correct.

## Class diagram
"""
[Paste class diagram from Planning-Agent here]
"""

```

---

## 🟢 3. Implement-Agent Prompt

✅ **GPT-4.1 hoặc GPT-4o**

→ Task này cần hiểu rõ context + viết implement code chuẩn, GPT-4.1 bạn đang có **Included**, quá perfect.

→ GPT-4o cũng mạnh, nhưng GPT-4.1 thường chính xác hơn về các chi tiết ngữ nghĩa logic.

```
You are an Implement Agent.

Your task is to generate full implementation for the provided class skeletons based on the class diagram and data flow description.

Requirements:
- Implement all methods with meaningful logic according to the described data flow.
- Ensure that the classes work together as described in the feature specification.
- Write clean, maintainable, and readable code.
- Add necessary error handling.
- Add inline comments for complex logic.
- Generate basic unit tests for each class and its methods (optional but recommended).

## Class diagram:
"""
[Paste class diagram from Planning-Agent or Skeleton-Generator]
"""

## Data flow:
"""
[Paste data flow explanation from Planning-Agent]
"""

```

---

## 🟢 4. Review-Agent Prompt

✅ **Gemini 2.5 Pro (Preview)** hoặc **Claude Sonnet 4**

→ Review cần khả năng so sánh, phát hiện smell qua nhiều file → Gemini 2.5 Pro rất mạnh ở **context rộng + code critique**.

→ Nếu muốn giữ “team Claude” đồng bộ, **Claude Sonnet 4** cũng rất ổn.

```
You are a Senior Code Reviewer Agent.

Your task is to review the following code files.

Requirements:
- Check for adherence to coding conventions and best practices.
- Identify potential bugs, performance issues, or code smells.
- Provide suggestions for refactoring or improvement.
- Evaluate the clarity and maintainability of the code.
- If there are test cases, assess their coverage and completeness.

## Code files:
"""
[Paste generated code from Implement-Agent here]
"""

```

---

🎯 **Chốt nhanh**:

- Planning → Phân tích & thiết kế → Class diagram + Data flow
- Skeleton → Sinh file class trống → đảm bảo build OK
- Implement → Viết chi tiết logic + unit test
- Review → Kiểm tra chất lượng code & test coverage

| Agent | Model bạn nên dùng |
| --- | --- |
| Planning | Claude Sonnet 3.7 Thinking |
| Skeleton Generator | GPT-4o hoặc o3-mini |
| Implement | GPT-4.1 |
| Review | Gemini 2.5 Pro hoặc Claude 4 |

---

🎯 **Lý do chính chọn vậy**:

- Claude Sonnet 3.7 Thinking: reasoning đỉnh → planning chuẩn.
- GPT-4o/GPT-4.1: implement siêu chính xác → giảm bug.
- Gemini 2.5 Pro: review code đa chiều, phát hiện lỗi tiềm ẩn.

---

## 📂 Project Structure

The project is organized into three main sections:

### 1️⃣ Planning Phase
- `1.0.Planning.Roadmap.md`
- `1.1.Planning.Requirements.Prompt.md`
- `1.2.Planning.Output.Guide.md`

### 2️⃣ Skeleton Generation Phase
- `2.0.Skeleton.Roadmap.md`
- `2.1.Skeleton.ProjectStructure.Prompt.md`
- `2.2.Skeleton.Domain.Prompt.md`
- `2.3.Skeleton.Repositories.Prompt.md`
- `2.4.Skeleton.Services.Prompt.md`
- `2.5.Skeleton.PageModels.Prompt.md`

Each file follows [Section].[SubSection].[Stage].[Component].[Type].md pattern where [Stage] is "Skeleton" for this phase.

### 3️⃣ Implementation Phase
Components are broken down into three document types:
- **Prompt** - AI agent instructions
- **Guide** - Implementation references
- **Scenarios** - Developer documentation

Example structure:
```
3.Implementation/
├── 3.0.Implementation.Roadmap.md
├── 3.1.Implementation.Repository.Prompt.md
├── 3.1.Implementation.Repository.Guide.md
├── 3.1.Implementation.Repository.Scenarios.md
├── 3.2.Implementation.Services.Prompt.md
├── 3.2.Implementation.Service.Guide.md
└── ...
```

This structure ensures:
1. Clear separation between AI instructions and human documentation
2. Consistent naming across all project phases
3. Easy navigation between related documents
4. Progressive implementation from planning to review