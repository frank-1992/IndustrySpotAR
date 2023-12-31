//
//  AssociatedStorage.swift
//  SCNRecorder
//
//  Created by 吴熠 on 4/7/22.
//

import Foundation

struct AssociatedStorage<T> {

  let object: AnyObject

  let key: UnsafeRawPointer

  let policy: objc_AssociationPolicy

  init(object: AnyObject, key: UnsafeRawPointer, policy: objc_AssociationPolicy) {
    self.object = object
    self.key = key
    self.policy = policy
  }

  func get() -> T? { objc_getAssociatedObject(object, key) as? T }

  nonmutating func set(_ value: T?) { objc_setAssociatedObject(object, key, value, policy) }
}
