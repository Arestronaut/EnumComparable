import EnumComparable

@EnumComparable
enum Foo {
    case foo
    case bar(String)
    case fooBar(String, Int)
}

let foo = Foo.bar("Hello")

if foo.is(.foo) {
    print("Happy face")
} else {
    print("Sad face")
}


enum Bar {
    case foo
    case bar(String)
}

let bar = Bar.foo
