# EnumComparable

EnumComparable is a swift macro that makes comparing enum cases, that have associated values, easier (debatable ofc).

## "Problem" Statement

The swift syntax of comparing enum cases is either utilizing `Equatable` conformance or pattern matching.
When dealing with _C-like enums_ the single cases can simply be compared using the `==` operator. As soon as `associatedValues` come into play
things get a bit more complex. `==` can still be used but an associatedValue needs to be provided. But sometimes one
doesn't care about the case's content, the swift solution for that would be pattern matching.
The syntax for pattern matching looks something like this: `guard case .foo = fooOrBar else { ... }`

I always found this to read quite bulky. Especially as autocompletion doesn't work properly.

`EnumComparable` can be attached to every enum and will make the previous example a bit easier: `guard fooOrBar.is(.foo) else { ... }`

Whether this makes thing actually easier is of course in the eye of the beholder.

## Breakdown

Let's take a look at an example:

```swift
@EnumComparable
enum MyEnum {
    case myFirstCase(String, Int)
    case mySecondCase(Bool)
    case iRestMyCase
}
```

This gets expanded into:

```swift
enum MyEnum {
    case myFirstCase(String, Int)
    case mySecondCase(Bool)
    case iRestMyCase

    enum _MyEnum {
        case myFirstCase
        case mySecondCase
        case iRestMyCase
    }

    func `is`(_ rhs: _MyEnum) -> Bool { 
        switch (self, rhs) {
        case (.myFirstCase, .myFirstCase):
            return true
        case (.mySecondCase, .mySecondCase):
            return true
        case (.iRestMyCase, .iRestMyCase):
            return true
        default:
            return false
        }
    }
}
```

## Considerations

There are two things that I should mention before I can hand this out in good conscience.
1. The resulting syntax is purely my personal choice of style. I'm not claiming that this should be used by everyone.
2. A big downside to this approach is the creation of the subtype that is internally available. This might lead to
confusion and misuse. Additionally as of now this won't work in an environment where the target enum is publicly available.

## LICENSE

EnumComparable is under the MIT License. Refer to [LICENSE](LICENSE) for details.