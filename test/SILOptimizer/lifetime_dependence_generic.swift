// RUN: %target-swift-frontend %s -emit-sil \
// RUN:   -o /dev/null \
// RUN:   -verify \
// RUN:   -sil-verify-all \
// RUN:   -enable-experimental-feature NonescapableTypes \
// RUN:   -enable-experimental-feature NoncopyableGenerics \
// RUN:   -parse-stdlib -module-name Swift

// REQUIRES: asserts
// REQUIRES: swift_in_compiler

@_marker public protocol Escapable {}

@_silgen_name("imagineInt64")
func imagineInt64() -> Builtin.Int64

precedencegroup AssignmentPrecedence { assignment: true }

protocol P {
  associatedtype E: ~Escapable
  borrowing func getE() -> _borrow(self) E
}

extension P {
  borrowing func getDefault() -> _borrow(self) E {
    return getE()
  }
}

public struct Bits {
  var i = imagineInt64()
}

struct PBits: P {
  func getE() -> Bits { return Bits() }
}

public func pbits_ret_concerete() -> Bits {
  let pbits = PBits()
  return pbits.getDefault()
}

struct NCInt: ~Copyable {
  var value: Builtin.Int64

  init(_ value: Builtin.Int64) { self.value = value }
}

struct NEInt: ~Escapable {
  let value: Builtin.Int64

  init<O: ~Copyable & ~Escapable>(v: Builtin.Int64, o: borrowing O) -> _borrow(o) Self {
    self.value = v
    return self
  }

  // Test a generic storage owner.
  init(borrowed: borrowing NCInt) -> _borrow(borrowed) Self {
    self.init(v: borrowed.value, o: borrowed)
    return self
  }
}

public func consume_indirect<NE: ~Escapable>(ne: consuming NE) -> _consume(ne) NE {
  return ne
}

public func copy_indirect<NE: ~Escapable>(ne: borrowing NE) -> _copy(ne) NE {
  return copy ne
}

public func copy_inout<NE: ~Escapable>(ne: inout NE) -> _copy(ne) NE {
  return copy ne
}
