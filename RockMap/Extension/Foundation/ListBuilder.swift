//
//  ListBuilder.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/07/10.
//

import Foundation

@resultBuilder
public struct ListBuilder<T> {

    /*
     Either (if/else)
     */
    public static func buildEither(first component: [T]) -> [T] {
        component
    }

    public static func buildEither(first component: [T]?) -> [T] {
        component ?? [T]()
    }

    public static func buildEither(first component: T...) -> [T] {
        component
    }

    public static func buildEither(first component: [T?]) -> [T] {
        component.compactMap { $0 }
    }

    public static func buildEither(first component: T?...) -> [T] {
        component.compactMap { $0 }
    }

    public static func buildEither(second component: [T]) -> [T] {
        component
    }

    public static func buildEither(second component: T...) -> [T] {
        component
    }

    public static func buildEither(second component: [T?]) -> [T] {
        component.compactMap { $0 }
    }

    public static func buildEither(second component: T?...) -> [T] {
        component.compactMap { $0 }
    }

    public static func buildEither(second component: [T]?) -> [T] {
        component ?? [T]()
    }

    public static func buildEither<C: ContentAccessible>(second component: C...) -> [T]
    where C.ChildContent == T {
        component.map({ $0.childContent }).reduce([], { $0 + $1 })
    }

    public static func buildEither<C: ContentAccessible>(first component: C...) -> [T]
    where C.ChildContent == T {
        component.map({ $0.childContent }).reduce([], { $0 + $1 })
    }

    /*
     Expression ( { ... } )
     */
    public static func buildExpression<C: ContentAccessible>(_ expression: C) -> [T]
    where C.ChildContent == T {
        expression.childContent
    }

    public static func buildExpression(_ expression: T) -> [T] {
        [expression]
    }

    public static func buildExpression(_ expression: [T]) -> [T] {
        expression
    }

    public static func buildExpression(_ expression: [T]?) -> [T] {
        expression ?? [T]()
    }

    public static func buildExpression(_ expression: T...) -> [T] {
        expression
    }

    public static func buildExpression(_ expression: T?) -> [T] {
        expression.map {
            [$0]
        } ?? [T]()
    }

    public static func buildExpression(_ expression: T?...) -> [T] {
        expression.compactMap {
            $0
        }
    }

    static func buildExpression(_ expression: () -> T) -> T {
        expression()
    }

    static func buildExpression(_ expression: (() -> T)...) -> [T] {
        expression.compactMap { $0() }
    }



    /*
     Expression ( [ ... ] )
     */
    public static func buildArray(_ components: [T]) -> [T] {
        components
    }

    public static func buildArray(_ components: [T?]) -> [T] {
        components.compactMap { $0 }
    }

    public static func buildOptional<C: ContentAccessible>(_ component: [C]) -> [T]
    where C.ChildContent == T {
        component.map({ $0.childContent }).reduce([], { $0 + $1 })
    }

    /*
     Optional ( x? )
     */
    public static func buildOptional(_ component: [T?]?) -> [T] {
        component?.compactMap { $0 } ?? []
    }

    public static func buildOptional<C: ContentAccessible>(_ component: [C?]?) -> [T]
    where C.ChildContent == T {
        component?.compactMap { $0?.childContent }.reduce([], { $0 + $1 } ) ?? []
    }

    public static func buildOptional<C: ContentAccessible>(_ component: C?) -> [T]
    where C.ChildContent == T {
        component?.childContent ?? []
    }

    /*
     Check availability Macro ( #if available(...))
     */
    public static func buildLimitedAvailability(_ component: [T]) -> [T] {
        component
    }


    /*
     Code Block
     */
    public static func buildBlock(_ components: [T]) -> [T] {
        components
    }

    public static func buildBlock(_ components: [T]...) -> [T] {
        components.reduce([]) { $0 + $1 }
    }

    public static func buildBlock(_ components: [T?]...) -> [T] {
        components.reduce([]) { $0.compactMap { $0 } + $1.compactMap { $0 } }
    }


    public static func buildBlock(_ components: T...) -> [T] {
        components
    }

    public static func buildBlock(_ components: T?...) -> [T] {
        components.compactMap { $0 }
    }

    public static func buildBlock(_ components: [T]?...) -> [T] {
        components.reduce([]) { $0 + ($1 ?? [T]()) }
    }

    public static func buildBlock<C: ContentAccessible>(_ components: C) -> [T]
    where C.ChildContent == T {
        components.childContent
    }

    public static func buildBlock<C: ContentAccessible>(_ components: C...) -> [T]
    where C.ChildContent == T {
        components.compactMap { $0.childContent }.reduce([]) { $0 + $1 }
    }

    public static func buildBlock<C: ContentAccessible>(_ components: [C]) -> [T]
    where C.ChildContent == T {
        components.compactMap { $0.childContent }.reduce([]) { $0 + $1 }
    }

    /*
     Convert Some Final Output
     */
    public static func buildFinalResult(_ component: [T]) -> [T] {
        component
    }

    public static func buildFinalResult<C: ContentAccessible>(_ component: [C]) -> [T]
    where C.ChildContent == T {
        component.compactMap { $0.childContent }.reduce([]) { $0 + $1 }
    }

    public static func buildFinalResult<C: ContentAccessible>(_ component: C...) -> [T]
    where C.ChildContent == T {
        component.compactMap { $0.childContent }.reduce([]) { $0 + $1 }
    }

    public static func buildFinalResult<C: ContentAccessible>(_ component: C) -> [T]
    where C.ChildContent == T {
        component.childContent
    }
}

public protocol ContentAccessible {
    associatedtype ChildContent
    var childContent: [ChildContent] { get }
}
