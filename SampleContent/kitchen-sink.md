# Kitchen Sink

A sample document exercising **GitHub-Flavored Markdown** features used to tune
rendering fidelity.

## Text styles

Regular, **bold**, _italic_, ~~strikethrough~~, and `inline code`.
A [link to GitHub](https://github.com) and an autolink: https://apple.com

> A blockquote.
> Spanning two lines.

> [!NOTE]
> GitHub alerts should render as a styled callout (custom block style).

> [!WARNING]
> This one too.

## Lists

- Unordered item
  - Nested item
- Another item

1. First
2. Second

### Task list

- [x] Done
- [ ] Not done

## Code

```swift
func greet(_ name: String) -> String {
    return "Hello, \(name)!"
}
```

```typescript
interface User { id: number; name: string }

const greet = (u: User): string => `Hello, ${u.name}!`
export default greet
```

```python
def greet(name: str) -> str:
    return f"Hello, {name}!"

print(greet("world"))
```

```json
{ "name": "markdown-viewer", "version": "0.1", "native": true }
```

```bash
# build & run on device
xcodegen generate && xcodebuild -scheme MarkdownViewer build
```

## Table

| Feature      | Supported | Notes                |
|--------------|:---------:|----------------------|
| Headings     | ✅        | h1–h6                |
| Tables       | ✅        | GFM                  |
| Task lists   | ✅        | checkboxes           |

## Image

![Placeholder](https://placehold.co/600x200/png)

---

Thematic break above. Done.
