// RUN: %target-typecheck-verify-swift -parse-as-library

// MARK: - Valid declarations

// OK: top level functions
@available(macOS 11.0, *)
@_backDeploy(macOS 12.0)
public func backDeployedTopLevelFunc() {}

// OK: internal decls may be back deployed when @usableFromInline
@available(macOS 11.0, *)
@_backDeploy(macOS 12.0)
@usableFromInline
internal func backDeployedUsableFromInlineTopLevelFunc() {}

// OK: function decls in a struct
public struct TopLevelStruct {
  @available(macOS 11.0, *)
  @_backDeploy(macOS 12.0)
  public func backDeployedMethod() {}

  @available(macOS 11.0, *)
  @_backDeploy(macOS 12.0)
  public var backDeployedComputedProperty: Int { 98 }
}

public class TopLevelClass {
  @available(macOS 11.0, *)
  @_backDeploy(macOS 12.0)
  final public func backDeployedFinalMethod() {}

  @available(macOS 11.0, *)
  @_backDeploy(macOS 12.0)
  public var backDeployedComputedProperty: Int { 98 }
}

// MARK: - Unsupported declaration types

@_backDeploy(macOS 12.0) // expected-error {{'@_backDeploy' attribute cannot be applied to this declaration}}
public class CannotBackDeployClass {}

@_backDeploy(macOS 12.0) // expected-error {{'@_backDeploy' attribute cannot be applied to this declaration}}
public struct CannotBackDeployStruct {
  @_backDeploy(macOS 12.0) // expected-error {{'@_backDeploy' must not be used on stored properties}}
  public var cannotBackDeployStoredProperty: Int = 83

  @_backDeploy(macOS 12.0) // expected-error {{'@_backDeploy' must not be used on stored properties}}
  public lazy var cannotBackDeployLazyStoredProperty: Int = 15
}

@_backDeploy(macOS 12.0) // expected-error {{'@_backDeploy' attribute cannot be applied to this declaration}}
public enum CannotBackDeployEnum {
  @_backDeploy(macOS 12.0) // expected-error {{'@_backDeploy' attribute cannot be applied to this declaration}}
  case cannotBackDeployEnumCase
}

@_backDeploy(macOS 12.0) // expected-error {{'@_backDeploy' must not be used on stored properties}}
public var cannotBackDeployTopLevelVar = 79

@_backDeploy(macOS 12.0) // expected-error {{'@_backDeploy' attribute cannot be applied to this declaration}}
extension TopLevelStruct {}

// MARK: - Incompatible declarations

@_backDeploy(macOS 12.0) // expected-error {{'@_backDeploy' may not be used on fileprivate declarations}}
fileprivate func filePrivateFunc() {}

@_backDeploy(macOS 12.0) // expected-error {{'@_backDeploy' may not be used on private declarations}}
private func privateFunc() {}

@_backDeploy(macOS 12.0) // expected-error {{'@_backDeploy' may not be used on internal declarations}}
internal func internalFunc() {}

// FIXME(backDeploy): back deployed methods must be final
public class TopLevelClass2 {
  @available(macOS 11.0, *)
  @_backDeploy(macOS 12.0)
  public func backDeployedNonFinalMethod() {}
}

@_backDeploy(macOS 12.0) // expected-error {{'@_backDeploy' requires that 'missingAllAvailabilityFunc()' have explicit availability for macOS}}
public func missingAllAvailabilityFunc() {}

@available(macOS 11.0, *)
@_backDeploy(macOS 12.0, iOS 15.0) // expected-error {{'@_backDeploy' requires that 'missingiOSAvailabilityFunc()' have explicit availability for iOS}}
public func missingiOSAvailabilityFunc() {}

@available(macOS 12.0, *)
@_backDeploy(macOS 12.0) // expected-error {{'@_backDeploy' has no effect because 'availableSameVersionAsBackDeployment()' is not available before macOS 12.0}}
public func availableSameVersionAsBackDeployment() {}

@available(macOS 12.1, *)
@_backDeploy(macOS 12.0) // expected-error {{'availableAfterBackDeployment()' is not available before macOS 12.0}}
public func availableAfterBackDeployment() {}

@available(macOS 11.0, *)
@_backDeploy(macOS 12.0, macOS 13.0) // expected-error {{'@_backDeploy' contains multiple versions for macOS}}
public func duplicatePlatformsFunc1() {}

@available(macOS 11.0, *)
@_backDeploy(macOS 12.0)
@_backDeploy(macOS 13.0) // expected-error {{'@_backDeploy' contains multiple versions for macOS}}
public func duplicatePlatformsFunc2() {}

@available(macOS 11.0, *)
@_backDeploy(macOS 12.0)
@_alwaysEmitIntoClient // expected-error {{'@_alwaysEmitIntoClient' cannot be applied to back deployed declarations}}
public func alwaysEmitIntoClientFunc() {}

@available(macOS 11.0, *)
@_backDeploy(macOS 12.0)
@inlinable // expected-error {{'@inlinable' cannot be applied to back deployed declarations}}
public func inlinableFunc() {}

@available(macOS 11.0, *)
@_backDeploy(macOS 12.0)
@_transparent // expected-error {{'@_transparent' cannot be applied to back deployed declarations}}
public func transparentFunc() {}

// MARK: - Attribute parsing

@_backDeploy(macOS 12.0, unknownOS 1.0) // expected-warning {{unknown platform 'unknownOS' for attribute '@_backDeploy'}}
public func unknownOSFunc() {}

@_backDeploy(@) // expected-error {{expected platform in '@_backDeploy' attribute}}
public func badPlatformFunc1() {}

@_backDeploy(@ 12.0) // expected-error {{expected platform in '@_backDeploy' attribute}}
public func badPlatformFunc2() {}

@_backDeploy(macOS) // expected-error {{expected version number in '@_backDeploy' attribute}}
public func missingVersionFunc1() {}

@_backDeploy(macOS 12.0, iOS) // expected-error {{expected version number in '@_backDeploy' attribute}}
public func missingVersionFunc2() {}

@_backDeploy(macOS, iOS) // expected-error 2{{expected version number in '@_backDeploy' attribute}}
public func missingVersionFunc3() {}

@available(macOS 11.0, iOS 14.0, *)
@_backDeploy(macOS 12.0, iOS 15.0,) // expected-error {{unexpected ',' separator}}
public func unexpectedSeparatorFunc() {}

@available(macOS 11.0, *)
@_backDeploy(macOS 12.0.1) // expected-warning {{'@_backDeploy' only uses major and minor version number}}
public func patchVersionFunc() {}

@available(macOS 11.0, *)
@_backDeploy(macOS 12.0, * 9.0) // expected-warning {{* as platform name has no effect in '@_backDeploy' attribute}}
public func wildcardWithVersionFunc() {}

@available(macOS 11.0, *)
@_backDeploy(macOS 12.0, *) // expected-warning {{* as platform name has no effect in '@_backDeploy' attribute}}
public func trailingWildcardFunc() {}

@available(macOS 11.0, iOS 14.0, *)
@_backDeploy(macOS 12.0, *, iOS 15.0) // expected-warning {{* as platform name has no effect in '@_backDeploy' attribute}}
public func embeddedWildcardFunc() {}

@_backDeploy() // expected-error {{expected at least one platform version in '@_backDeploy' attribute}}
public func zeroPlatformVersionsFunc() {}

@_backDeploy // expected-error {{expected '(' in '_backDeploy' attribute}}
public func expectedLeftParenFunc() {}

@_backDeploy(macOS 12.0 // expected-note {{to match this opening '('}}
public func expectedRightParenFunc() {} // expected-error {{expected ')' in '@_backDeploy' argument list}}
