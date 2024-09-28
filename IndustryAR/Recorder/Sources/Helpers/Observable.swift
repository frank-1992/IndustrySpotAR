//
//  SCNObservable.swift
//  SCNRecorder
//


import Foundation

public protocol SCNObservableInterface: AnyObject {

  associatedtype Property

  typealias Observer = (Property) -> Void

  var observer: Observer? { get set }
}

@propertyWrapper
public final class SCNObservable<Property>: SCNObservableInterface {

  public typealias Observer = (Property) -> Void

  public var wrappedValue: Property {
    didSet { observer?(wrappedValue) }
  }

  public var value: Property { wrappedValue }

  public var projectedValue: SCNObservable<Property> { self }

  public var observer: Observer?

  public init(wrappedValue: Property) { self.wrappedValue = wrappedValue }
}

public extension SCNObservableInterface {

  func observe(
    on queue: DispatchQueue? = nil,
    _ observer: @escaping Observer
  ) {
    // swiftlint:disable opening_brace
    self.observer = queue.map { queue in
      { value in queue.async { observer(value) }}
    } ?? observer
    // swiftlint:enable opening_brace
  }
}

public extension SCNObservableInterface where Property: Equatable {

  func observeUnique(
    on queue: DispatchQueue? = nil,
    _ observer: @escaping Observer
  ) {
    var oldValue: Property?
    observe(on: queue) { (value) in
      guard oldValue != value else { return }
      observer(value)
      oldValue = value
    }
  }
}
